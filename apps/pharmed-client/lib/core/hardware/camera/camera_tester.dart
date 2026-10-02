import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'camera.dart';

/// Kurulum ekranındaki deneme çekiminin sonucu.
class CameraTestResult {
  const CameraTestResult({
    required this.snapshot,
    required this.connectTime,
    required this.sampleDuration,
    required this.sampleBytes,
    required this.testedAt,
  });

  /// Kameranın o anki görüntüsü (JPEG) — "doğru yere bakıyor mu?" kontrolü.
  final Uint8List snapshot;

  /// Akışa bağlanıp ilk kareyi almak için geçen süre.
  final Duration connectTime;

  /// Deneme kaydı: kaydedicinin gerçekten dosyaya yazdığını doğrular.
  final Duration sampleDuration;
  final int sampleBytes;
  final DateTime testedAt;

  /// Yaklaşık bitrate — disk ihtiyacı tahmini için.
  double get bitrateKbps => sampleDuration.inMilliseconds == 0 ? 0 : sampleBytes * 8 / sampleDuration.inMilliseconds;

  /// Dakikada yaklaşık MB.
  double get mbPerMinute => bitrateKbps * 60 / 8 / 1024;
}

/// Kamera kurulumunda bağlantı + anlık görüntü + kısa deneme kaydı.
/// Canlı kayıtla AYNI yolu (RTSP/ffmpeg, aynı kaydedici) kullanır; test
/// geçtiyse operasyon kaydı da çalışır. [SWREQ-CAM-055]
class CameraTester {
  CameraTester({required String ffmpegPath, Directory? workDir})
    : _ffmpegPath = ffmpegPath,
      _workDir = workDir ?? Directory(p.join(Directory.systemTemp.path, 'pharmed_camtest'));

  static const _unit = 'SW-UNIT-CAM';
  static const _swreq = 'SWREQ-CAM-055';

  final String _ffmpegPath;
  final Directory _workDir;

  Future<Result<CameraTestResult>> test(CameraConfig config, {Duration sample = const Duration(seconds: 3)}) async {
    await _workDir.create(recursive: true);

    final snapshot = await takeSnapshot(config);
    if (snapshot.isError) return Result.error(_errorOf(snapshot));
    final (bytes, connectTime) = snapshot.data!;

    // Deneme kaydı — canlıdaki kaydedicinin aynısı.
    final recorder = FfmpegOperationRecorder(config: config, ffmpegPath: _ffmpegPath, outputDir: _workDir);
    try {
      final started = await recorder.start(sessionId: 'camtest-${DateTime.now().millisecondsSinceEpoch}');
      if (started.isError) return Result.error(_errorOf(started));
      await Future<void>.delayed(sample);
      final stopped = await recorder.stop();
      if (stopped.isError) return Result.error(_errorOf(stopped));
      final file = stopped.data!;
      unawaited(File(file.path).delete().catchError((_) => File(file.path)));

      final result = CameraTestResult(
        snapshot: bytes,
        connectTime: connectTime,
        sampleDuration: file.duration,
        sampleBytes: file.sizeBytes,
        testedAt: DateTime.now(),
      );
      MedLogger.info(
        unit: _unit,
        swreq: _swreq,
        message: 'Kamera testi başarılı',
        context: {
          'source': config.maskedRtspUrl,
          'connectMs': connectTime.inMilliseconds,
          'bitrateKbps': result.bitrateKbps.round(),
        },
      );
      return Result.ok(result);
    } finally {
      await recorder.dispose();
    }
  }

  /// Akıştan tek kare alır. Kurulumda "Yenile" ile tekrar çağrılır.
  Future<Result<(Uint8List, Duration)>> takeSnapshot(CameraConfig config) async {
    await _workDir.create(recursive: true);
    final out = File(p.join(_workDir.path, 'snap_${DateTime.now().microsecondsSinceEpoch}.jpg'));
    final watch = Stopwatch()..start();

    final ProcessResult run;
    try {
      run = await _run([
        '-hide_banner',
        '-loglevel',
        'error',
        '-rtsp_transport',
        'tcp',
        '-timeout',
        '${config.ioTimeout.inMicroseconds}',
        '-i',
        config.rtspUrl,
        '-frames:v',
        '1',
        '-q:v',
        '3',
        '-y',
        out.path,
      ], timeout: config.startupTimeout + const Duration(seconds: 5));
    } on ProcessException catch (e) {
      return _fail(CameraRecordingFailureReason.ffmpegNotFound, 'ffmpeg başlatılamadı', [config.redact(e.message)]);
    } on TimeoutException {
      return _fail(CameraRecordingFailureReason.startupTimeout, 'Kameradan görüntü alınamadı (zaman aşımı)', const []);
    }
    watch.stop();

    final stderr = const LineSplitter()
        .convert(run.stderr as String)
        .where((l) => l.trim().isNotEmpty)
        .map(config.redact) // [SWREQ-CAM-005]
        .toList();

    if (run.exitCode != 0 || !await out.exists()) {
      return _fail(
        FfmpegOperationRecorder.isAuthFailure(stderr)
            ? CameraRecordingFailureReason.authenticationFailed
            : CameraRecordingFailureReason.streamUnreachable,
        'Kameradan görüntü alınamadı',
        stderr,
      );
    }

    final bytes = await out.readAsBytes();
    unawaited(out.delete().catchError((_) => out));
    return Result.ok((bytes, watch.elapsed));
  }

  /// Process.run zaman aşımında süreci öldüremez; bu yüzden start + kill.
  Future<ProcessResult> _run(List<String> args, {required Duration timeout}) async {
    final process = await Process.start(_ffmpegPath, args, runInShell: false);
    final stdout = process.stdout.drain<void>();
    final stderr = process.stderr.transform(const Utf8Decoder(allowMalformed: true)).join();
    try {
      final code = await process.exitCode.timeout(timeout);
      await stdout;
      return ProcessResult(process.pid, code, '', await stderr);
    } on TimeoutException {
      process.kill();
      rethrow;
    }
  }

  Result<T> _fail<T>(CameraRecordingFailureReason reason, String message, List<String> diagnostics) {
    MedLogger.warn(unit: _unit, swreq: _swreq, message: '$message [${reason.name}]', context: {'stderr': diagnostics});
    return Result.error(CameraRecordingException(message: message, reason: reason, diagnostics: diagnostics));
  }

  static AppException _errorOf(Result<Object?> r) => r.when(ok: (_) => const UnexpectedException(), error: (e) => e);
}
