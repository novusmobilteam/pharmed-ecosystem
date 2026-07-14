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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'cabin_sensor_logger.dart';
import 'cabin_sensor_state.dart';

final cabinSensorProvider = NotifierProvider<CabinSensorNotifier, CabinSensorState>(CabinSensorNotifier.new);

/// Sparkline'da tutulacak nokta sayısı.
const _historyLength = 40;

class CabinSensorNotifier extends Notifier<CabinSensorState> {
  StreamSubscription<CabinSensorReading>? _sub;
  int _pauseCount = 0;

  ICabinOperationService get _cabinOps => ref.read(cabinOperationServiceProvider);
  CabinSensorLogger get _logger => ref.read(cabinSensorLoggerProvider);
  AppSettingsCache get _settings => ref.read(appSettingsCacheProvider);

  @override
  CabinSensorState build() {
    ref.onDispose(() => _sub?.cancel());
    unawaited(_init());
    return const CabinSensorState();
  }

  Future<void> _init() async {
    // Kurulum tamamlanmadıysa ne kabin var ne eşik — donanıma hiç dokunma.
    if (!await _settings.isSetupComplete()) {
      MedLogger.info(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Kurulum tamamlanmamış — sensör başlatılmadı',
      );
      return;
    }

    // Eşikler ve stream paralel — biri diğerini bekletmesin.
    await Future.wait([_loadThresholds(), _start()]);
  }

  // ------------------------------------------------------------------- eşik

  Future<void> _loadThresholds() async {
    final cabinId = await _settings.getCurrentCabinId();
    if (cabinId == null) return;

    final result = await ref.read(getCabinThresholdsUseCaseProvider)(cabinId: cabinId);

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(thresholds: value);

      case Error():
        // Eşik çekilemedi → fallback'te kal. State'in başlangıç değeri zaten
        // fallback; UI yanlış alarm vermez, sadece varsayılan aralık gösterir.
        MedLogger.warn(
          unit: 'CabinSensor',
          swreq: 'SWREQ-HW-SENSOR-002',
          message: 'Eşik değerleri alınamadı — varsayılan kullanılıyor',
        );
    }
  }

  /// Kabin değiştiğinde (debug/setup) eşikleri yeniden çeker.
  Future<void> refreshThresholds() => _loadThresholds();

  // ----------------------------------------------------------------- stream

  Future<void> _start() async {
    if (_pauseCount > 0) return; // duraklatılmışken başlatma

    final manager = await _cabinOps.getOrScanManager();
    if (manager == null) {
      MedLogger.warn(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Yönetim kartı yok — sensör stream başlatılamadı',
      );
      return;
    }

    await _sub?.cancel();
    _sub = _cabinOps
        .streamCabinSensors(manager: manager)
        .listen(
          _onReading,
          onError: (Object e) => MedLogger.warn(
            unit: 'CabinSensor',
            swreq: 'SWREQ-HW-SENSOR-001',
            message: 'Sensör stream hatası',
            context: {'error': e.toString()},
          ),
        );
  }

  void _onReading(CabinSensorReading reading) {
    state = state.copyWith(
      reading: reading,
      tempHistory: _push(state.tempHistory, reading.temperature),
      humidityHistory: _push(state.humidityHistory, reading.humidity),
    );

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
      state = state.copyWith(isPaused: true);

      MedLogger.info(unit: 'CabinSensor', swreq: 'SWREQ-HW-SENSOR-001', message: 'Sensör polling duraklatıldı');
    }
  }

  /// Duraklatmayı kaldırır. Sayaç sıfırlanınca polling yeniden başlar.
  void resume() {
    if (_pauseCount == 0) return;

    _pauseCount--;
    if (_pauseCount == 0) {
      state = state.copyWith(isPaused: false);
      unawaited(_start());

      MedLogger.info(unit: 'CabinSensor', swreq: 'SWREQ-HW-SENSOR-001', message: 'Sensör polling devam ediyor');
    }
  }
}
