// [SWREQ-HW-SENSOR-003] [IEC 62304 §5.5]
// Kabin ısı/nem/batarya okumalarını periyodik olarak kalıcılaştırır.
//
// Sensör stream'i saniyede birden fazla okuma üretir; hepsini yazmak anlamsız
// ve sunucuyu boğar. Sabit aralıkla örnekleyip tek tek gönderiyoruz.
// Repository tek kayıt aldığı için batch gönderim yok.
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class CabinSensorLogger {
  CabinSensorLogger(this._saveSensorValues, this._settings);

  final SaveSensorValuesUseCase _saveSensorValues;
  final AppSettingsCache _settings;

  /// Kayıt aralığı — bundan sık gelen okumalar atlanır.
  /// Saatte 12 kayıt; ısı/nem trendi için fazlasıyla yeterli.
  static const _sampleInterval = Duration(minutes: 5);

  DateTime? _lastSaved;

  /// Yavaş yanıt sırasında ikinci istek açılmasını engeller.
  bool _inFlight = false;

  void record(CabinSensorReading reading) {
    if (_inFlight) return;

    final now = DateTime.now();
    if (_lastSaved != null && now.difference(_lastSaved!) < _sampleInterval) {
      return;
    }

    _lastSaved = now;
    unawaited(_save(reading));
  }

  Future<void> _save(CabinSensorReading reading) async {
    _inFlight = true;

    try {
      final cabinId = await _settings.getCurrentCabinId();
      if (cabinId == null) {
        MedLogger.warn(
          unit: 'CabinSensor',
          swreq: 'SWREQ-HW-SENSOR-003',
          message: 'Kabin seçili değil — sensör okuması kaydedilmedi',
        );
        return;
      }

      final result = await _saveSensorValues(reading: reading, cabinId: cabinId);

      // Hata → aralığı sıfırla, bir sonraki okumada yeniden dene.
      // Kuyruk tutulmuyor; tek okumanın kaybı kritik değil.
      if (result is Error) {
        _lastSaved = null;
      }
    } finally {
      _inFlight = false;
    }
  }
}
