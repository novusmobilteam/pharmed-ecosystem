// [SWREQ-CORE-LOG-002] [SWREQ-CORE-LOG-003] [IEC 62304 §9.2]
// Uygulama açılışında loglamayı kurar:
//   - MedLogger çıktısı cihazda günlük dosyalara yazılır
//     (pharmed-client-YYYY-MM-DD.log, 14 gün; klasör için bkz. appLogDirectoryPath).
//   - Yakalanmamış Flutter/async hataları loglanır.
// Sahadaki bir cihazda yarıda kalan bir işlemin sebebi bu dosyalardan bulunur.
//
// Sınıf: Class B

import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../flavor/app_flavor.dart';
import '../hardware/hardware_mode.dart';
import '../storage/app_data_paths.dart';
import 'shipping/shipping.dart';

export '../storage/app_data_paths.dart' show appLogDirectoryPath, revealInFileManager;

const _unit = 'SW-UNIT-APP';
const _swreq = 'SWREQ-CORE-LOG-003';

/// `FlavorConfig.initialize` sonrasında, `runApp`'ten önce çağrılır.
Future<void> initAppLogging({required bool verbose}) async {
  MedLogger.configure(verboseLogging: verbose);

  final dir = Directory(appLogDirectoryPath());
  try {
    MedLogger.addSink(await FileLogSink.open(directory: dir, filePrefix: 'pharmed-client'));
  } catch (e) {
    // Dosyaya yazılamıyorsa uygulama yine açılmalı — konsola düşer.
    debugPrint('Log klasörü açılamadı (${dir.path}): $e');
  }

  // [SWREQ-NET-007] Backend'e gönderim (varsayılan açık; LOG_UPLOAD_ENABLED=false ile kapanır).
  // Kuyruk burada kurulur ki açılış satırları da gitsin; gönderici
  // logShippingBootstrapProvider ile Riverpod hazır olunca başlar.
  final shipping = LogShipping.init(
    config: LogShippingConfig.fromEnvironment(),
    dataRoot: pharmedDataRoot(),
    flavor: HardwareConfig.variant,
  );

  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    MedLogger.error(
      unit: _unit,
      swreq: _swreq,
      message: 'Yakalanmamış Flutter hatası',
      context: {'library': ?details.library, 'context': ?details.context?.toString()},
      error: details.exception,
      stackTrace: details.stack,
    );
    previousFlutterHandler?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    MedLogger.error(
      unit: _unit,
      swreq: _swreq,
      message: 'Yakalanmamış asenkron hata',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  MedLogger.info(
    unit: _unit,
    swreq: _swreq,
    message: 'Uygulama başlatıldı',
    context: {
      'flavor': FlavorConfig.instance.flavor.name,
      'hardware': HardwareConfig.mode.name,
      'os': Platform.operatingSystemVersion,
      'host': Platform.localHostname,
      'logDir': dir.path,
      'logUpload': shipping != null,
      if (shipping != null) 'deviceId': shipping.device.deviceId,
      if (shipping != null) 'appRunId': shipping.appRunId,
      if (shipping != null) 'appVersion': shipping.config.appVersion,
    },
  );
}
