import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

import 'package:pharmed_client/core/hardware/camera/camera_config.dart';

/// Testte sahte Process enjekte edebilmek için. [SWTEST]
typedef ProcessStarter = Future<Process> Function(String executable, List<String> arguments);

Future<Process> _defaultProcessStarter(String executable, List<String> arguments) =>
    Process.start(executable, arguments, runInShell: false);

/// RTSP akışını ffmpeg ile yeniden encode ETMEDEN (`-c copy`) MP4'e yazar.
///
/// - Başlatma, dosyaya ilk baytlar yazılınca doğrulanmış sayılır (akış gerçekten bağlı).
/// - Fragmented MP4: süreç öldürülse/elektrik kesilse bile dosya oynatılabilir kalır.
/// - Durdurma: stdin'e 'q' → ffmpeg dosyayı düzgün kapatır; yanıt yoksa kill.
/// - Akış koparsa (`-timeout`) ffmpeg çıkar → [RecorderInterrupted] yayılır.
///
/// IEC 62304: SW-UNIT-CAM. Sınıf, kayıt zorunluluğu kararına kadar Class B kabul edilir.
class FfmpegOperationRecorder implements IOperationRecorder {
  FfmpegOperationRecorder({
    required CameraConfig config,
    required String ffmpegPath,
    required Directory outputDir,
    ProcessStarter processStarter = _defaultProcessStarter,
    DateTime Function() clock = DateTime.now,
  }) : _config = config,
       _ffmpegPath = ffmpegPath,
       _outputDir = outputDir,
       _processStarter = processStarter,
       _clock = clock;

  static const _unit = 'SW-UNIT-CAM';
  static const _stderrTailSize = 20;
  static const _pollInterval = Duration(milliseconds: 200);
  static const _killWait = Duration(seconds: 3);

  /// maxDuration'a bu kadar yakın biten kayıt "süre doldu" sayılır.
  static const _maxDurationTolerance = Duration(seconds: 3);

  final CameraConfig _config;
  final String _ffmpegPath;
  final Directory _outputDir;
  final ProcessStarter _processStarter;
  final DateTime Function() _clock;

  final _statusController = StreamController<CameraRecorderStatus>.broadcast();
  CameraRecorderStatus _status = const RecorderIdle();

  Process? _process;
  File? _file;
  String? _sessionId;
  DateTime? _startedAt;
  DateTime? _exitedAt;
  int? _exitCode;
  bool _stopRequested = false;
  final _stderrTail = ListQueue<String>();
  StreamSubscription<String>? _stderrSub;

  @override
  CameraRecorderStatus get status => _status;

  @override
  Stream<CameraRecorderStatus> get statusStream => _statusController.stream;

  // ---------------------------------------------------------------------------
  // start
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> start({required String sessionId}) async {
    const swreq = 'SWREQ-CAM-001';

    if (sessionId.trim().isEmpty) {
      return _fail(swreq, CameraRecordingFailureReason.invalidInput, 'sessionId boş olamaz');
    }
    if (!_config.isConfigured) {
      return _fail(swreq, CameraRecordingFailureReason.invalidInput, 'Kamera yapılandırması eksik (host/şifre)');
    }
    if (_status is! RecorderIdle) {
      return _fail(
        swreq,
        CameraRecordingFailureReason.busy,
        'Aktif bir kayıt varken yeni kayıt başlatılamaz '
        '(durum: ${_status.runtimeType})',
      );
    }

    _sessionId = sessionId;
    _stopRequested = false;
    _exitCode = null;
    _exitedAt = null;
    _stderrTail.clear();
    _setStatus(RecorderStarting(sessionId));

    final File file;
    final Process process;
    try {
      await _outputDir.create(recursive: true);
      file = File(p.join(_outputDir.path, '${_sanitize(sessionId)}_${_clock().millisecondsSinceEpoch}.mp4'));
      process = await _processStarter(_ffmpegPath, _buildArguments(file.path));
    } on ProcessException catch (e, st) {
      _reset();
      return _fail(
        swreq,
        CameraRecordingFailureReason.ffmpegNotFound,
        'ffmpeg başlatılamadı ($_ffmpegPath)',
        error: e,
        stackTrace: st,
      );
    } catch (e, st) {
      _reset();
      return _fail(
        swreq,
        CameraRecordingFailureReason.unexpected,
        'Kayıt başlatılırken beklenmeyen hata',
        error: e,
        stackTrace: st,
      );
    }

    _process = process;
    _file = file;
    _attachProcess(process);

    // [SWREQ-CAM-002] Akış gerçekten dosyaya yazılmaya başlayana kadar bekle.
    final startupWatch = Stopwatch()..start();
    final ready = await _waitForFirstBytes(process, file);
    startupWatch.stop();

    if (!identical(_process, process)) {
      // Başlatma sürerken abort() çağrıldı; temizlik orada yapıldı.
      return _fail('SWREQ-CAM-002', CameraRecordingFailureReason.aborted, 'Kayıt başlatılırken iptal edildi');
    }

    if (!ready) {
      final exited = _exitCode != null;
      final diagnostics = List<String>.of(_stderrTail);
      await _killAndCleanup(deleteFile: true);
      return _fail(
        'SWREQ-CAM-002',
        switch ((exited, isAuthFailure(diagnostics))) {
          (_, true) => CameraRecordingFailureReason.authenticationFailed,
          (true, false) => CameraRecordingFailureReason.streamUnreachable,
          (false, false) => CameraRecordingFailureReason.startupTimeout,
        },
        exited ? 'Kamera akışına bağlanılamadı' : 'Kayıt ${_config.startupTimeout.inSeconds} sn içinde başlamadı',
        diagnostics: diagnostics,
      );
    }

    final startedAt = _clock();
    _startedAt = startedAt;
    _setStatus(RecorderRecording(sessionId: sessionId, startedAt: startedAt));
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-CAM-002',
      message: 'Kamera kaydı başladı',
      context: {
        'sessionId': sessionId,
        'source': _config.maskedRtspUrl,
        'startupMs': startupWatch.elapsedMilliseconds,
        'file': file.path,
      },
    );
    return const Result.ok(null);
  }

  // ---------------------------------------------------------------------------
  // stop
  // ---------------------------------------------------------------------------

  @override
  Future<Result<RecordingFile>> stop() async {
    const swreq = 'SWREQ-CAM-003';
    final status = _status;

    if (status is! RecorderRecording && status is! RecorderInterrupted) {
      return _fail(
        swreq,
        CameraRecordingFailureReason.notRecording,
        'Durdurulacak aktif kayıt yok (durum: ${status.runtimeType})',
      );
    }

    final process = _process!;
    final file = _file!;
    final sessionId = _sessionId!;
    final startedAt = _startedAt!;

    _stopRequested = true;
    _setStatus(RecorderStopping(sessionId));

    var endReason = status is RecorderInterrupted ? status.reason : RecordingEndReason.stopped;

    if (_exitCode == null) {
      final clean = await _requestGracefulExit(process);
      if (!clean) endReason = RecordingEndReason.forceKilled;
    }
    await _stderrSub?.cancel();
    _stderrSub = null;

    final endedAt = _exitedAt ?? _clock();

    try {
      final size = await file.exists() ? await file.length() : 0;
      if (size == 0) {
        final diagnostics = List<String>.of(_stderrTail);
        _reset();
        return _fail(
          swreq,
          CameraRecordingFailureReason.emptyOutput,
          'Kayıt dosyası boş veya bulunamadı: ${file.path}',
          diagnostics: diagnostics,
        );
      }

      final digest = await crypto.sha256.bind(file.openRead()).first;
      final recording = RecordingFile(
        sessionId: sessionId,
        path: file.path,
        startedAt: startedAt,
        endedAt: endedAt,
        sizeBytes: size,
        sha256: digest.toString(),
        endReason: endReason,
      );

      MedLogger.info(
        unit: _unit,
        swreq: swreq,
        message: 'Kamera kaydı tamamlandı',
        context: {
          'sessionId': sessionId,
          'file': file.path,
          'sizeBytes': size,
          'durationSec': recording.duration.inSeconds,
          'endReason': endReason.name,
          'sha256': recording.sha256,
        },
      );
      _reset();
      return Result.ok(recording);
    } catch (e, st) {
      _reset();
      return _fail(
        swreq,
        CameraRecordingFailureReason.unexpected,
        'Kayıt dosyası doğrulanamadı',
        error: e,
        stackTrace: st,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // abort / dispose
  // ---------------------------------------------------------------------------

  @override
  Future<void> abort() async {
    if (_status is RecorderIdle) return;
    MedLogger.info(
      unit: _unit,
      swreq: 'SWREQ-CAM-003',
      message: 'Kamera kaydı iptal edildi, dosya siliniyor',
      context: {'sessionId': _sessionId, 'file': _file?.path},
    );
    await _killAndCleanup(deleteFile: true);
  }

  @override
  Future<void> dispose() async {
    final process = _process;
    if (process != null && _exitCode == null) {
      // Dosya SİLİNMEZ: denetim kaydı korunur. Upload kuyruğu sahipsiz
      // dosyaları kayıt klasöründen ayrıca toplamalıdır.
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-003',
        message: 'Recorder aktif kayıtla dispose ediliyor',
        context: {'sessionId': _sessionId, 'file': _file?.path},
      );
      _stopRequested = true;
      await _requestGracefulExit(process);
    }
    await _stderrSub?.cancel();
    _reset();
    await _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Süreç yönetimi
  // ---------------------------------------------------------------------------

  List<String> _buildArguments(String outputPath) => [
    '-hide_banner',
    '-loglevel', 'error',
    '-rtsp_transport', 'tcp',
    // Akıştan bu süre veri gelmezse çık → akış kopması tespiti [SWREQ-CAM-004]
    '-timeout', '${_config.ioTimeout.inMicroseconds}',
    '-i', _config.rtspUrl,
    // Sadece video. Kameranın sesi (G.711) MP4'e copy edilemez.
    '-map', '0:v:0',
    '-c:v', 'copy',
    '-t', '${_config.maxDuration.inSeconds}',
    '-f', 'mp4',
    '-movflags', '+frag_keyframe+empty_moov+default_base_moof',
    '-y',
    outputPath,
  ];

  void _attachProcess(Process process) {
    // stdout boşaltılmazsa pipe dolup ffmpeg bloklanabilir.
    unawaited(process.stdout.drain<void>());
    _stderrSub = process.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen(_pushStderr);
    unawaited(process.exitCode.then((code) => _onProcessExit(process, code)));
  }

  void _pushStderr(String line) {
    if (line.trim().isEmpty) return;
    // ffmpeg hata mesajlarında URL'yi (şifre dahil) basabilir. [SWREQ-CAM-005]
    _stderrTail.addLast(_config.redact(line));
    while (_stderrTail.length > _stderrTailSize) {
      _stderrTail.removeFirst();
    }
  }

  void _onProcessExit(Process process, int code) {
    if (!identical(process, _process)) return; // eski/temizlenmiş süreç
    _exitCode = code;
    _exitedAt = _clock();

    final status = _status;
    if (status is RecorderRecording && !_stopRequested) {
      // [SWREQ-CAM-004]
      final elapsed = _exitedAt!.difference(status.startedAt);
      final reason = elapsed + _maxDurationTolerance >= _config.maxDuration
          ? RecordingEndReason.maxDurationReached
          : RecordingEndReason.streamLost;

      _setStatus(RecorderInterrupted(sessionId: status.sessionId, reason: reason));
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-004',
        message: 'Kamera kaydı kendiliğinden sona erdi',
        context: {
          'sessionId': status.sessionId,
          'reason': reason.name,
          'exitCode': code,
          'elapsedSec': elapsed.inSeconds,
          'stderr': List<String>.of(_stderrTail),
        },
      );
    }
  }

  Future<bool> _waitForFirstBytes(Process process, File file) async {
    final watch = Stopwatch()..start();
    while (watch.elapsed < _config.startupTimeout) {
      if (!identical(_process, process)) return false; // abort edildi
      if (_exitCode != null) return false;
      try {
        if (await file.exists() && await file.length() > 0) return true;
      } on FileSystemException {
        // ffmpeg dosyayı oluştururken anlık erişim hatası olabilir; tekrar dene.
      }
      await Future<void>.delayed(_pollInterval);
    }
    return false;
  }

  /// 'q' gönderir; ffmpeg süresinde çıkarsa true, kill gerekirse false.
  Future<bool> _requestGracefulExit(Process process) async {
    try {
      process.stdin.write('q');
      await process.stdin.flush();
    } catch (_) {
      // stdin kapanmış olabilir; aşağıdaki timeout + kill devreye girer.
    }
    try {
      await process.exitCode.timeout(_config.stopTimeout);
      return true;
    } on TimeoutException {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-CAM-003',
        message: 'ffmpeg q komutuna yanıt vermedi, süreç sonlandırılıyor',
        context: {'sessionId': _sessionId},
      );
      process.kill();
      // Dosya handle'ı bırakılsın diye çıkışı kısa süre bekle.
      await process.exitCode.timeout(_killWait, onTimeout: () => -1);
      return false;
    }
  }

  Future<void> _killAndCleanup({required bool deleteFile}) async {
    final process = _process;
    final file = _file;
    _stopRequested = true;

    if (process != null && _exitCode == null) {
      process.kill();
      await process.exitCode.timeout(_killWait, onTimeout: () => -1);
    }
    await _stderrSub?.cancel();
    _stderrSub = null;

    if (deleteFile && file != null) {
      try {
        if (await file.exists()) await file.delete();
      } catch (e) {
        MedLogger.warn(
          unit: _unit,
          swreq: 'SWREQ-CAM-003',
          message: 'Kayıt dosyası silinemedi',
          context: {'file': file.path, 'error': e.toString()},
        );
      }
    }
    _reset();
  }

  // ---------------------------------------------------------------------------
  // Yardımcılar
  // ---------------------------------------------------------------------------

  void _reset() {
    _process = null;
    _file = null;
    _sessionId = null;
    _startedAt = null;
    _exitedAt = null;
    _exitCode = null;
    _stderrSub = null;
    _stopRequested = false;
    _setStatus(const RecorderIdle());
  }

  void _setStatus(CameraRecorderStatus status) {
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }

  /// ffmpeg çıktısında RTSP 401 var mı? (Teşhis için; kamera kilitlenmesin
  /// diye kimlik hatasında otomatik yeniden deneme YAPILMAMALI.)
  static bool isAuthFailure(Iterable<String> stderr) =>
      stderr.any((l) => l.contains('401') || l.contains('Unauthorized'));

  static String _sanitize(String value) => value.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  Result<T> _fail<T>(
    String swreq,
    CameraRecordingFailureReason reason,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    List<String> diagnostics = const [],
  }) {
    // [SWREQ-CAM-005] ProcessException gibi hatalar komut satırını (RTSP URL +
    // şifre) içerir. Ham hata nesnesi ASLA log'a veya cause'a verilmez.
    final safeError = error == null ? null : _config.redact(error.toString());
    final exception = CameraRecordingException(
      message: message,
      reason: reason,
      diagnostics: diagnostics,
      cause: safeError,
    );
    MedLogger.error(
      unit: _unit,
      swreq: swreq,
      message: '$message [${reason.name}]',
      error: safeError ?? exception,
      stackTrace: stackTrace,
    );
    if (diagnostics.isNotEmpty) {
      MedLogger.warn(unit: _unit, swreq: swreq, message: 'ffmpeg çıktısı', context: {'stderr': diagnostics});
    }
    return Result.error(exception);
  }
}
