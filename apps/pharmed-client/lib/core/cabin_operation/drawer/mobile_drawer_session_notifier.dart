// pharmed-client/lib/core/cabin_operation/notifier/mobile_drawer_session_notifier.dart
//
// [SWREQ-CLI-CABIN-OP-002] [IEC 62304 §5.5]
// Mobil çekmece oturumunun yaşam döngüsünü yönetir.
//
// Sorumluluk:
//   - StartMobileDrawerSessionUseCase'i çalıştırır
//   - Stream'i dinler, stage'i state'e yansıtır
//   - reopen / stop API'leri sunar
//
// COM port bilgisi use case içindeki getOrScanManager tarafından otomatik
// hallediliyor; bu seviyede port adı taşınmaz.
//
// Sınıf: Class B

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'mobile_drawer_session_state.dart';

final mobileDrawerSessionProvider = NotifierProvider<MobileDrawerSessionNotifier, MobileDrawerSessionState>(
  MobileDrawerSessionNotifier.new,
);

class MobileDrawerSessionNotifier extends Notifier<MobileDrawerSessionState> {
  StreamSubscription<MobileDrawerStage>? _sub;

  // Reopen için son parametreler
  int? _lastDrawerPort;
  int? _lastSlotId;

  StartMobileDrawerSessionUseCase get _startSession => ref.read(startMobileDrawerSessionUseCaseProvider);

  @override
  MobileDrawerSessionState build() {
    ref.onDispose(() => _sub?.cancel());
    return const MobileDrawerSessionState.initial();
  }

  /// Yeni bir çekmece oturumu başlatır. Önceki oturum varsa iptal edilir.
  Future<void> start({required int drawerPort, required int slotId}) async {
    await _sub?.cancel();
    _lastDrawerPort = drawerPort;
    _lastSlotId = slotId;

    _sub = _startSession
        .call(drawerPort: drawerPort, slotId: slotId)
        .listen(
          (stage) => state = state.copyWith(stage: stage),
          onError: (e, _) {
            MedLogger.error(
              unit: 'MobileDrawerSessionNotifier',
              swreq: 'SWREQ-CLI-CABIN-OP-002',
              message: 'Stream hatası',
              context: {'error': e.toString()},
            );
            state = state.copyWith(stage: MobileDrawerFailed(message: 'Beklenmeyen hata: $e'));
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
    state = const MobileDrawerSessionState.initial();
  }
}
