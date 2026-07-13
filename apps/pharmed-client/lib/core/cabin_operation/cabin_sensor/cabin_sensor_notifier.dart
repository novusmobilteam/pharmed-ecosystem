import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'cabin_sensor_state.dart';

final cabinSensorProvider =
    NotifierProvider<CabinSensorNotifier, CabinSensorState>(CabinSensorNotifier.new);


    /// Kabin sensör polling'ini yönetir.
///
/// Kabin işlemi (çekmece açma/status polling) sırasında seri hat yoğun
/// kullanıldığından, işlem süresince polling duraklatılır.
/// [pause]/[resume] nested-safe sayaç ile çalışır — birden fazla işlem
/// aynı anda duraklatabilir.
///
/// [SWREQ-HW-SENSOR-001]
class CabinSensorNotifier extends Notifier<CabinSensorState> {
  StreamSubscription<CabinSensorReading>? _sub;
  int _pauseCount = 0;

  ICabinOperationService get _cabinOps => ref.read(cabinOperationServiceProvider);

  @override
  CabinSensorState build() {
    ref.onDispose(() => _sub?.cancel());
    unawaited(_start());
    return const CabinSensorState();
  }

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
    _sub = _cabinOps.streamCabinSensors(manager: manager).listen(
      (reading) => state = state.copyWith(reading: reading),
      onError: (Object e) => MedLogger.warn(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Sensör stream hatası',
        context: {'error': e.toString()},
      ),
    );
  }

  /// Sensör polling'ini duraklatır (nested-safe).
  /// Kabin işlemi başlarken çağrılır.
  void pause() {
    _pauseCount++;
    if (_pauseCount == 1) {
      _sub?.cancel();
      _sub = null;
      state = state.copyWith(isPaused: true);
      MedLogger.info(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Sensör polling duraklatıldı',
      );
    }
  }

  /// Duraklatmayı kaldırır. Sayaç sıfırlanınca polling yeniden başlar.
  void resume() {
    if (_pauseCount == 0) return;
    _pauseCount--;
    if (_pauseCount == 0) {
      state = state.copyWith(isPaused: false);
      unawaited(_start());
      MedLogger.info(
        unit: 'CabinSensor',
        swreq: 'SWREQ-HW-SENSOR-001',
        message: 'Sensör polling devam ediyor',
      );
    }
  }
}