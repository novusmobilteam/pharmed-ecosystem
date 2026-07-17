// pharmed-client/lib/core/cabin_operation/notifier/mobile_drawer_session_notifier.dart
//
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
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../features/auth/notifier/auth_notifier.dart';
import '../../providers/providers.dart';
import '../cabin_operation.dart';

final mobileDrawerSessionProvider = NotifierProvider<MobileDrawerSessionNotifier, MobileDrawerSessionState>(
  MobileDrawerSessionNotifier.new,
);

class MobileDrawerSessionNotifier extends Notifier<MobileDrawerSessionState> {
  StreamSubscription<MobileDrawerStage>? _sub;

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
    // Eski oturum Opening/Opened'da kalmış olabilir, stream artık event
    // göndermeyecek → kendi flag'imizle release et.
    _releaseAuthPauseIfHeld();

    _lastDrawerPort = drawerPort;
    _lastSlotId = slotId;

    _sub = _startSession
        .call(drawerPort: drawerPort, slotId: slotId)
        .listen(
          _onStage,
          onError: (e, _) {
            MedLogger.error(
              unit: 'MobileDrawerSessionNotifier',
              swreq: 'SWREQ-CLI-CABIN-OP-002',
              message: 'Stream hatası',
              context: {'error': e.toString()},
            );
            _onStage(MobileDrawerFailed(message: contextlessL10n().common_error_unexpectedWithDetail(e.toString())));
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

  // ───────────────────────────── Internal

  /// Tek state geçiş noktası. Auth pause/resume transition'larını burada
  /// yönetir → state'i başka yerde direkt set etmeyelim.
  void _onStage(MobileDrawerStage next) {
    final wasOpen = _isDrawerPhysicallyOpen(state.stage);
    final isOpen = _isDrawerPhysicallyOpen(next);

    state = state.copyWith(stage: next);

    if (!wasOpen && isOpen) {
      _acquireAuthPause();
      _acquireSensorPause();
    } else if (wasOpen && !isOpen) {
      _releaseAuthPauseIfHeld();
      _releaseSensorPauseIfHeld();
    }
  }

  /// Fiziksel çekmece açık mı? Closed durumunda kullanıcı UI'ya döndüğü
  /// için pointer event'ler timer'ı zaten reset eder; pause gereksiz.
  bool _isDrawerPhysicallyOpen(MobileDrawerStage s) => s is MobileDrawerOpening || s is MobileDrawerOpened;

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
}
