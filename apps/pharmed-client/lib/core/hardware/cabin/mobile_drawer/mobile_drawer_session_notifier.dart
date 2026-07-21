// [SWREQ-CLI-CABIN-OP-002] [IEC 62304 §5.5]
// Mobil çekmece oturumunun yaşam döngüsünü yönetir.
//
// Sorumluluk:
//   - StartMobileDrawerSessionUseCase'i çalıştırır
//   - Stream'i dinler, stage'i state'e yansıtır
//   - reopen / stop API'leri sunar
//   - Çekmece fiziksel olarak açıkken auth inactivity timer'ını duraklatır
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../features/auth/notifier/auth_notifier.dart';
import '../../../providers/providers.dart';
import '../../hardware.dart';

final mobileDrawerSessionProvider = NotifierProvider<MobileDrawerSessionNotifier, MobileDrawerSessionState>(
  MobileDrawerSessionNotifier.new,
);

class MobileDrawerSessionNotifier extends Notifier<MobileDrawerSessionState> {
  StreamSubscription<DrawerSessionEvent>? _sub;

  // Reopen için son parametreler
  int? _lastDrawerPort;
  int? _lastSlotId;

  // Auth inactivity timer'ı bizim tarafımızdan pause edildi mi?
  // Pause/resume simetrisini KENDİ scope'umuzda sıkı tutmak için flag.
  // (auth notifier nested-safe counter tutuyor ama biz kendi balansımızı
  // bozmazsak counter'a kirli giriş yapma riskimiz olmaz.)
  bool _authPaused = false;
  bool _sensorPaused = false;

  StartMobileDrawerSessionUseCase get _startSession => ref.read(startMobileDrawerSessionUseCaseProvider);

  @override
  MobileDrawerSessionState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _releaseAuthPauseIfHeld();
    });
    return const MobileDrawerSessionState.initial();
  }

  /// Yeni bir çekmece oturumu başlatır. Önceki oturum varsa iptal edilir.
  Future<void> start({required int drawerPort, required int slotId}) async {
    await _sub?.cancel();
    _releaseAuthPauseIfHeld();
    _releaseSensorPauseIfHeld();

    _lastDrawerPort = drawerPort;
    _lastSlotId = slotId;

    _sub = _startSession
        .call(drawerPort: drawerPort)
        .listen(
          (event) => _onEvent(event, slotId: slotId),
          onError: (e, _) {
            MedLogger.error(
              unit: 'MobileDrawerSessionNotifier',
              swreq: 'SWREQ-CLI-CABIN-OP-002',
              message: 'Stream hatası',
              context: {'error': e.toString()},
            );
            _onEvent(
              DrawerFailed(failure: MobileDrawerFailure.statusReadError, detail: e.toString()),
              slotId: slotId,
            );
          },
          onDone: () => _sub = null,
        );
  }

  /// Aynı slot/port için oturumu yeniden başlatır.
  Future<void> reopen() async {
    if (_lastDrawerPort == null || _lastSlotId == null) return;
    await start(drawerPort: _lastDrawerPort!, slotId: _lastSlotId!);
  }

  /// Oturumu sonlandır.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _lastDrawerPort = null;
    _lastSlotId = null;
    _releaseAuthPauseIfHeld();
    state = const MobileDrawerSessionState.initial();
  }

  void _acquireAuthPause() {
    if (_authPaused) return;
    ref.read(authNotifierProvider.notifier).pauseInactivityTimer();
    _authPaused = true;
  }

  void _releaseAuthPauseIfHeld() {
    if (!_authPaused) return;
    ref.read(authNotifierProvider.notifier).resumeInactivityTimer();
    _authPaused = false;
  }

  void _acquireSensorPause() {
    if (_sensorPaused) return;
    ref.read(cabinSensorProvider.notifier).pause();
    _sensorPaused = true;
  }

  void _releaseSensorPauseIfHeld() {
    if (!_sensorPaused) return;
    ref.read(cabinSensorProvider.notifier).resume();
    _sensorPaused = false;
  }

  void _onEvent(DrawerSessionEvent event, {required int slotId}) {
    final stage = _toStage(event, slotId: slotId);
    _applyStage(stage);
  }

  MobileDrawerStage _toStage(DrawerSessionEvent event, {required int slotId}) {
    final port = _lastDrawerPort ?? 0;
    return switch (event) {
      DrawerOpening() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerOpeningWithStep() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerWaitingForPull() => MobileDrawerOpening(port: port, slotId: slotId),
      DrawerOpened() => MobileDrawerOpened(port: port, slotId: slotId),
      DrawerClosed() => MobileDrawerClosed(port: port, slotId: slotId),
      DrawerFailed(:final failure, :final detail) => MobileDrawerFailed(
        failure: failure as MobileDrawerFailure,
        detail: detail,
        port: port,
        slotId: slotId,
      ),
    };
  }

  void _applyStage(MobileDrawerStage next) {
    final wasOpen = _isPhysicallyOpen(state.stage);
    final isOpen = _isPhysicallyOpen(next);

    state = state.copyWith(stage: next);

    if (!wasOpen && isOpen) {
      _acquireAuthPause();
      _acquireSensorPause();
    } else if (wasOpen && !isOpen) {
      _releaseAuthPauseIfHeld();
      _releaseSensorPauseIfHeld();
    }
  }

  bool _isPhysicallyOpen(MobileDrawerStage s) => s is MobileDrawerOpening || s is MobileDrawerOpened;
}
