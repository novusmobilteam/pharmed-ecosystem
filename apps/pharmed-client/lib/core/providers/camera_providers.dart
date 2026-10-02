import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';

import 'package:pharmed_client/core/hardware/camera/camera_config.dart';
import 'package:pharmed_client/core/hardware/camera/ffmpeg_operation_recorder.dart';

/// Paketlenmiş ffmpeg (`<uygulama klasörü>/ffmpeg/ffmpeg.exe`) varsa onu,
/// yoksa geliştirme ortamında PATH'teki ffmpeg'i kullanır.
String resolveFfmpegPath() {
  // Geliştirmede açık yol vermek için: --dart-define=FFMPEG_PATH=C:\...\ffmpeg.exe
  const override = String.fromEnvironment('FFMPEG_PATH');
  if (override.isNotEmpty) return override;

  final bundled = p.join(p.dirname(Platform.resolvedExecutable), 'ffmpeg', 'ffmpeg.exe');
  return File(bundled).existsSync() ? bundled : 'ffmpeg';
}

/// Kayıt arşivinin kökü — kullanıcı bazlı yazılabilir alan
/// (Program Files kurulumlarında uygulama klasörü yazılabilir olmayabilir).
String recordingRootPath() {
  final base = Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
  return p.join(base, 'PharMed', 'recordings');
}

/// Kaydedici yarım dosyaları buraya yazar; tamamlananlar arşive taşınır.
const recordingStagingFolder = '.staging';

final cameraConfigProvider = Provider<CameraConfig>((ref) => CameraConfig.fromEnvironment());

/// Global: kiosk başına tek kamera, tek aktif kayıt.
final operationRecorderProvider = Provider<IOperationRecorder>((ref) {
  final recorder = FfmpegOperationRecorder(
    config: ref.watch(cameraConfigProvider),
    ffmpegPath: resolveFfmpegPath(),
    outputDir: Directory(p.join(recordingRootPath(), recordingStagingFolder)),
  );
  ref.onDispose(recorder.dispose);
  return recorder;
});

final operationRecorderStatusProvider = StreamProvider<CameraRecorderStatus>(
  (ref) => ref.watch(operationRecorderProvider).statusStream,
);
