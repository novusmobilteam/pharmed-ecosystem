// Çevre birimleri: parmak izi okuyucu, fiş yazıcı, IP kamera.
//
//   • Parmak izi ve yazıcı, client ile AYNI sürücü koduyla (pharmed_hardware)
//     çalışır; okuyucu seçimi client'taki createFingerprintScanner ile aynıdır.
//   • Kamera testi client'taki kurulum testinin mantığıdır: RTSP akışından tek
//     kare (doğru yere bakıyor mu?) ve kısa deneme kaydı (kayıt gerçekten
//     dosyaya yazılıyor mu, bitrate / disk ihtiyacı).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pharmed_core/pharmed_core.dart' hide TimeoutException;
import 'package:pharmed_hardware/pharmed_hardware.dart';

// ── Parmak izi ───────────────────────────────────────────────────────────

/// Client'taki seçimle aynı: `FINGERPRINT_VENDOR` (auto / secugen / suprema),
/// `FINGERPRINT_MOCK=true` ile sahte okuyucu.
IFingerprintScanner createFingerprintScanner() {
  const forceMock = bool.fromEnvironment('FINGERPRINT_MOCK');
  if (forceMock) return MockFingerprintScanner();

  IFingerprintScanner secuGen() => SecuGenFingerprintScanner(settings: SecuGenSettings.fromEnvironment());
  IFingerprintScanner bioMini() => BioMiniFingerprintScanner(settings: BioMiniSettings.fromEnvironment());

  const vendor = String.fromEnvironment('FINGERPRINT_VENDOR', defaultValue: 'auto');
  return switch (vendor) {
    'secugen' => secuGen(),
    'suprema' || 'biomini' => bioMini(),
    _ => AutoFingerprintScanner([secuGen(), bioMini()]),
  };
}

String fingerprintFailureText(FingerprintFailureReason r) => switch (r) {
  FingerprintFailureReason.libraryNotFound => 'Okuyucu SDK kütüphanesi (DLL) bulunamadı',
  FingerprintFailureReason.deviceNotFound => 'Okuyucu bulunamadı — USB bağlantısını kontrol edin',
  FingerprintFailureReason.deviceDisconnected => 'Okuyucu bağlantısı koptu',
  FingerprintFailureReason.notOpen => 'Okuyucu açık değil',
  FingerprintFailureReason.busy => 'Okuyucu meşgul',
  FingerprintFailureReason.timeout => 'Süre doldu, parmak okutulmadı',
  FingerprintFailureReason.cancelled => 'İptal edildi',
  FingerprintFailureReason.fingerOnSensor => 'Parmak sensörde — kaldırıp tekrar deneyin',
  FingerprintFailureReason.fakeFinger => 'Sahte parmak algılandı (canlılık kontrolü)',
  FingerprintFailureReason.lowQuality => 'Kalite düşük — parmağı ortalayıp tekrar okutun',
  FingerprintFailureReason.extractionFailed => 'Şablon çıkarılamadı',
  FingerprintFailureReason.sensorDirty => 'Sensör kirli olabilir',
  FingerprintFailureReason.unexpected => 'Beklenmeyen hata',
};

String fingerprintErrorText(AppException e) {
  if (e is FingerprintException) {
    final reason = fingerprintFailureText(e.reason);
    return e.sdkStatus == null ? reason : '$reason (SDK durum ${e.sdkStatus})';
  }
  return e.message;
}

// ── Fiş yazıcı ───────────────────────────────────────────────────────────

/// Markasız deneme fişi: Türkçe karakterler, sol-sağ satır, ayraçlar,
/// Code128 ve EAN-13 barkod — client'taki test fişiyle aynı kontroller.
ReceiptDocument buildTestReceipt(PrinterConfig config) {
  String two(int v) => v.toString().padLeft(2, '0');
  final now = DateTime.now();
  final connection = switch (config.connectionType) {
    PrinterConnectionType.serial => '${config.target} · ${config.baudRate}',
    PrinterConnectionType.windowsSpooler => config.target,
  };
  return ReceiptDocument(
    title: 'Deneme fişi',
    blocks: [
      const ReceiptText('DENEME FİŞİ', size: ReceiptTextSize.large, bold: true, align: ReceiptAlign.center),
      ReceiptText(
        '${two(now.day)}.${two(now.month)}.${now.year}  ${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
        align: ReceiptAlign.center,
      ),
      const ReceiptDivider(ReceiptDividerStyle.thick),
      ReceiptKeyValue('Bağlantı:', connection),
      const ReceiptDivider(),
      const ReceiptText('Türkçe karakterler', bold: true),
      const ReceiptText('ç ğ ı i ö ş ü   Ç Ğ I İ Ö Ş Ü'),
      const ReceiptText('0123456789  % / - + ( ) . , :'),
      const ReceiptDivider(ReceiptDividerStyle.dashed),
      const ReceiptText('Barkod', bold: true),
      const ReceiptSpacer(),
      const ReceiptBarcode('P2026100601'),
      const ReceiptSpacer(),
      const ReceiptBarcode('869951200101', type: ReceiptBarcodeType.ean13, height: 50),
    ],
  );
}

// ── Kamera ───────────────────────────────────────────────────────────────

/// Paketli ffmpeg (`<exe klasörü>/ffmpeg/ffmpeg.exe`), yoksa PATH'teki ffmpeg.
/// `--dart-define=FFMPEG_PATH=...` ile açık yol verilebilir (client ile aynı).
String resolveFfmpegPath() {
  const override = String.fromEnvironment('FFMPEG_PATH');
  if (override.isNotEmpty) return override;
  final sep = Platform.pathSeparator;
  final exeDir = File(Platform.resolvedExecutable).parent.path;
  final bundled = '$exeDir${sep}ffmpeg${sep}ffmpeg.exe';
  return File(bundled).existsSync() ? bundled : 'ffmpeg';
}

class CameraTarget {
  const CameraTarget({
    required this.host,
    required this.username,
    required this.password,
    this.rtspPort = 554,
    this.channel = 101,
  });

  final String host;
  final String username;
  final String password;
  final int rtspPort;

  /// 101 = ana akış, 102 = alt akış (Hikvision).
  final int channel;

  String get rtspUrl =>
      'rtsp://${Uri.encodeComponent(username)}:${Uri.encodeComponent(password)}@$host:$rtspPort/Streaming/Channels/$channel';

  /// Rapor ve ekran için şifresiz adres.
  String get maskedUrl => 'rtsp://***@$host:$rtspPort/Streaming/Channels/$channel';

  /// Metindeki şifreyi (ham ve URL-encoded) maskeler.
  String redact(String text) {
    if (password.isEmpty) return text;
    return text.replaceAll(Uri.encodeComponent(password), '***').replaceAll(password, '***');
  }
}

class CameraTestResult {
  const CameraTestResult({
    required this.snapshot,
    required this.connectTime,
    required this.sampleDuration,
    required this.sampleBytes,
  });

  /// Kameranın o anki görüntüsü (JPEG).
  final Uint8List snapshot;

  /// Akışa bağlanıp ilk kareyi alma süresi.
  final Duration connectTime;
  final Duration sampleDuration;
  final int sampleBytes;

  double get bitrateKbps => sampleDuration.inMilliseconds == 0 ? 0 : sampleBytes * 8 / sampleDuration.inMilliseconds;

  double get mbPerMinute => bitrateKbps * 60 / 8 / 1024;
}

class CameraTestException implements Exception {
  const CameraTestException(this.message, [this.diagnostics = const []]);

  final String message;
  final List<String> diagnostics;

  @override
  String toString() => diagnostics.isEmpty ? message : '$message\n${diagnostics.take(4).join('\n')}';
}

class CameraTester {
  CameraTester({String? ffmpegPath}) : ffmpegPath = ffmpegPath ?? resolveFfmpegPath();

  final String ffmpegPath;

  static const _startupTimeout = Duration(seconds: 15);
  static const _ioTimeout = Duration(seconds: 5);

  Future<Directory> _workDir() async {
    final dir = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}pharmed_hwtest_cam');
    await dir.create(recursive: true);
    return dir;
  }

  /// Anlık görüntü + [sample] süreli deneme kaydı.
  Future<CameraTestResult> test(CameraTarget target, {Duration sample = const Duration(seconds: 3)}) async {
    final (snapshot, connectTime) = await takeSnapshot(target);
    final dir = await _workDir();
    final out = File('${dir.path}${Platform.pathSeparator}sample_${DateTime.now().microsecondsSinceEpoch}.mp4');
    try {
      final run = await _run([
        '-hide_banner',
        '-loglevel',
        'error',
        '-rtsp_transport',
        'tcp',
        '-timeout',
        '${_ioTimeout.inMicroseconds}',
        '-i',
        target.rtspUrl,
        '-t',
        '${sample.inMilliseconds / 1000}',
        '-c',
        'copy',
        '-an',
        '-y',
        out.path,
      ], timeout: _startupTimeout + sample + const Duration(seconds: 10), target: target);
      if (run.exitCode != 0 || !await out.exists()) {
        throw CameraTestException('Deneme kaydı yazılamadı', _lines(run.stderr as String, target));
      }
      final bytes = await out.length();
      if (bytes == 0) throw const CameraTestException('Deneme kaydı boş');
      return CameraTestResult(snapshot: snapshot, connectTime: connectTime, sampleDuration: sample, sampleBytes: bytes);
    } finally {
      unawaited(out.delete().then((_) => null, onError: (_) => null));
    }
  }

  /// Akıştan tek kare (JPEG) ve bağlanma süresi.
  Future<(Uint8List, Duration)> takeSnapshot(CameraTarget target) async {
    final dir = await _workDir();
    final out = File('${dir.path}${Platform.pathSeparator}snap_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final watch = Stopwatch()..start();
    final run = await _run([
      '-hide_banner',
      '-loglevel',
      'error',
      '-rtsp_transport',
      'tcp',
      '-timeout',
      '${_ioTimeout.inMicroseconds}',
      '-i',
      target.rtspUrl,
      '-frames:v',
      '1',
      '-q:v',
      '3',
      '-y',
      out.path,
    ], timeout: _startupTimeout, target: target);
    watch.stop();
    if (run.exitCode != 0 || !await out.exists()) {
      final lines = _lines(run.stderr as String, target);
      final auth = lines.any((l) => l.contains('401') || l.toLowerCase().contains('unauthorized'));
      throw CameraTestException(
        auth ? 'Kullanıcı adı / şifre kabul edilmedi' : 'Kameradan görüntü alınamadı (adres, port, kanal ya da ağ)',
        lines,
      );
    }
    final bytes = await out.readAsBytes();
    unawaited(out.delete().then((_) => null, onError: (_) => null));
    return (bytes, watch.elapsed);
  }

  List<String> _lines(String stderr, CameraTarget target) =>
      const LineSplitter().convert(stderr).where((l) => l.trim().isNotEmpty).map(target.redact).toList();

  /// Process.run zaman aşımında süreci öldüremez; bu yüzden start + kill.
  Future<ProcessResult> _run(List<String> args, {required Duration timeout, required CameraTarget target}) async {
    final Process process;
    try {
      process = await Process.start(ffmpegPath, args);
    } on ProcessException catch (e) {
      throw CameraTestException('ffmpeg çalıştırılamadı ($ffmpegPath)', [target.redact(e.message)]);
    }
    final stdout = process.stdout.drain<void>();
    final stderr = process.stderr.transform(const Utf8Decoder(allowMalformed: true)).join();
    try {
      final code = await process.exitCode.timeout(timeout);
      await stdout;
      return ProcessResult(process.pid, code, '', await stderr);
    } on TimeoutException {
      process.kill();
      throw const CameraTestException('Kameradan cevap gelmedi (zaman aşımı)');
    }
  }
}
