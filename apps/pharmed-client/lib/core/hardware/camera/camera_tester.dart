import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'camera.dart';

/// Kamera kaydedilirken arka planda bağlantı kontrolü: akıştan tek kare.
/// Canlı kayıtla AYNI yolu (RTSP/ffmpeg) kullanır; kare alınabiliyorsa
/// operasyon kaydı da bağlanabilir. Ayrıntılı test (görüntü + deneme kaydı)
/// pharmed-hw-test uygulamasındadır. [SWREQ-CAM-055]
class CameraTester {
  CameraTester({required String ffmpegPath, Directory? workDir})
    : _ffmpegPath = ffmpegPath,
      _workDir = workDir ?? Directory(p.join(Directory.systemTemp.path, 'pharmed_camtest'));

  static const _unit = 'SW-UNIT-CAM';
  static const _swreq = 'SWREQ-CAM-055';

  final String _ffmpegPath;
  final Directory _workDir;

  /// Akıştan tek kare alır; bağlantı süresiyle döner.
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
}
