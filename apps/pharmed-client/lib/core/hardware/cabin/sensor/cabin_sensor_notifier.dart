// [SWREQ-HW-SENSOR-001] [IEC 62304 §5.5]
// Kabin sensör polling'ini ve eşik konfigürasyonunu yönetir.
//
// Kabin işlemi (çekmece açma/status polling) sırasında seri hat yoğun
// kullanıldığından, işlem süresince polling duraklatılır.
// [pause]/[resume] nested-safe sayaç ile çalışır — birden fazla işlem
// aynı anda duraklatabilir.
//
// Okunan her değer CabinSensorLogger'a iletilir; loglama bu notifier'ın
// yaşam döngüsünden bağımsızdır.
// Sınıf: Class B

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'cabin_sensor_logger.dart';

/// Sparkline'da tutulacak nokta sayısı.
const _historyLength = 40;

class CabinSensorNotifier extends ChangeNotifier {
  CabinSensorNotifier({
    required StreamCabinSensorsUseCase streamSensors,
    required CabinSensorLogger logger,
    required AppSettingsCache settings,
    required GetCabinThresholdsUseCase getCabinThresholds,
  }) : _streamSensors = streamSensors,
       _logger = logger,
       _settings = settings,
       _getCabinThresholds = getCabinThresholds {
    unawaited(_init());
  }

  final StreamCabinSensorsUseCase _streamSensors;
  final CabinSensorLogger _logger;
  final AppSettingsCache _settings;
  final GetCabinThresholdsUseCase _getCabinThresholds;

  StreamSubscription<CabinSensorReading>? _sub;
  int _pauseCount = 0;

  bool _isDisposed = false;

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sub?.cancel();
    super.dispose();
  }

  // ── State ────────────────────────────────────────────────────────

  CabinSensorReading? _reading;
  CabinSensorReading? get reading => _reading;

  /// Servisten gelen ısı/nem eşikleri. Çekilene kadar (veya hata durumunda)
  /// fallback değerler kullanılır.
  CabinSensorThresholds _thresholds = CabinSensorThresholds.fallback;
  CabinSensorThresholds get thresholds => _thresholds;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  /// Sparkline için son N okuma. Null okumalar geçmişe girmez.
  List<double> _tempHistory = const [];
  List<double> get tempHistory => _tempHistory;

  List<double> _humidityHistory = const [];
  List<double> get humidityHistory => _humidityHistory;

  // TODO : Düzelecek.
  Future<void> _init() async {
    // Kurulum tamamlanmadıysa ne kabin var ne eşik — donanıma hiç dokunma.
    // if (!await _settings.isSetupComplete()) {
    //   return;
    // }

    // // Eşikler ve stream paralel — biri diğerini bekletmesin.
    // await Future.wait([_loadThresholds(), _start()]);
  }

  // ------------------------------------------------------------------- eşik

  Future<void> _loadThresholds() async {
    final cabinId = await _settings.getCurrentCabinId();
    if (_isDisposed) return;
    if (cabinId == null) return;

    final result = await _getCabinThresholds(cabinId: cabinId);
    if (_isDisposed) return;

    switch (result) {
      case Ok(:final value):
        _thresholds = value;
        _notify();
      case Error():
    }
  }

  /// Kabin değiştiğinde (debug/setup) eşikleri yeniden çeker.
  Future<void> refreshThresholds() => _loadThresholds();

  Future<void> _start() async {
    if (_pauseCount > 0) return;

    await _sub?.cancel();
    if (_isDisposed) return;

    try {
      _sub = _streamSensors().listen(
        _onReading,
        onError: (Object e) => MedLogger.warn(
          unit: 'CabinSensor',
          swreq: 'SWREQ-HW-SENSOR-001',
          message: 'Sensör stream hatası',
          context: {'error': e.toString()},
        ),
      );
    } on CabinConnectionException {
      MedLogger.warn(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Yönetim kartı yok — sensör stream başlatılamadı',
      );
    }
  }

  void _onReading(CabinSensorReading reading) {
    _reading = reading;
    _tempHistory = _push(_tempHistory, reading.temperature);
    _humidityHistory = _push(_humidityHistory, reading.humidity);
    _notify();

    _logger.record(reading);
  }

  /// Null okuma geçmişe girmez — sparkline'da yalancı sıfır oluşturur.
  List<double> _push(List<double> buf, double? value) {
    if (value == null) return buf;

    final next = [...buf, value];
    return next.length > _historyLength ? next.sublist(next.length - _historyLength) : next;
  }

  // ------------------------------------------------------------ pause/resume

  /// Sensör polling'ini duraklatır (nested-safe).
  /// Kabin işlemi başlarken çağrılır.
  void pause() {
    _pauseCount++;
    if (_pauseCount == 1) {
      _sub?.cancel();
      _sub = null;
      _isPaused = true;
      _notify();

      MedLogger.info(unit: 'CabinSensor', swreq: 'SWREQ-HW-SENSOR-001', message: 'Sensör polling duraklatıldı');
    }
  }

  /// Duraklatmayı kaldırır. Sayaç sıfırlanınca polling yeniden başlar.
  void resume() {
    if (_pauseCount == 0) return;

    _pauseCount--;
    if (_pauseCount == 0) {
      _isPaused = false;
      _notify();
      unawaited(_start());

      MedLogger.info(unit: 'CabinSensor', swreq: 'SWREQ-HW-SENSOR-001', message: 'Sensör polling devam ediyor');
    }
  }
}
