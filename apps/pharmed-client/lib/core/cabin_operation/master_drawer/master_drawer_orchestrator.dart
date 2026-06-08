// pharmed-client/lib/core/cabin_operation/master_drawer_orchestrator.dart
//
// [SWREQ-CLI-CABIN-OP-013] [IEC 62304 §5.5]
// Master kabin çekmece oturumunu feature notifier'larla birleştiren helper.
//
// Sorumluluk:
//   - masterDrawerSessionProvider'a subscribe olur
//   - Stage geçişlerini feature notifier'a callback ile bildirir
//   - open / openCubicLid / confirmClose / reopen / stop API'lerini sarmalar
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'master_drawer_session_notifier.dart';
import 'master_drawer_stage.dart';

typedef MasterDrawerStageCallback = void Function(MasterDrawerStage? previous, MasterDrawerStage current);

class MasterDrawerOrchestrator {
  MasterDrawerOrchestrator({required this.ref});

  final Ref ref;

  ProviderSubscription<MasterDrawerSessionState>? _drawerSub;
  MasterDrawerStageCallback? _onStage;
  bool _initialized = false;

  // ── Init / Dispose ────────────────────────────────────────────────────────

  void init({MasterDrawerStageCallback? onStageChange}) {
    if (_initialized) return;
    _initialized = true;
    _onStage = onStageChange;

    _drawerSub = ref.listen<MasterDrawerSessionState>(
      masterDrawerSessionProvider,
      (prev, next) => _onStage?.call(prev?.stage, next.stage),
    );
  }

  Future<void> dispose() async {
    _drawerSub?.close();
    _drawerSub = null;
    _onStage = null;
    _initialized = false;
  }

  // ── Çekmece Operasyonları ─────────────────────────────────────────────────

  /// Verilen [assignment] için yeni bir çekmece oturumu başlatır (ana çekmece).
  Future<void> open({required MedicineAssignment assignment}) async {
    await ref.read(masterDrawerSessionProvider.notifier).start(assignment: assignment);
  }

  /// Kübik çekmecede tek bir gözün kapağını açar (lid-by-lid akış).
  Future<void> openCubicLid(MedicineAssignment cellAssignment) async {
    await ref.read(masterDrawerSessionProvider.notifier).openCubicLid(cellAssignment);
  }

  /// Kullanıcı dolumu tamamladı — çekmece kapanması bekleniyor.
  void confirmClose() {
    ref.read(masterDrawerSessionProvider.notifier).confirmClose();
  }

  Future<void> reopen() async {
    await ref.read(masterDrawerSessionProvider.notifier).reopen();
  }

  Future<void> stop() async {
    await ref.read(masterDrawerSessionProvider.notifier).stop();
  }
}
