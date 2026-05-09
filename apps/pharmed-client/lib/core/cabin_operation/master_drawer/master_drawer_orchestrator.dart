// pharmed-client/lib/core/cabin_operation/master_drawer_orchestrator.dart
//
// [SWREQ-CLI-CABIN-OP-013] [IEC 62304 §5.5]
// Master kabin çekmece oturumunu feature notifier'larla birleştiren helper.
//
// Sorumluluk:
//   - masterDrawerSessionProvider'a subscribe olur
//   - Stage geçişlerini feature notifier'a callback ile bildirir
//   - open / confirmClose / reopen / stop API'lerini sarmalar
//
// RFID yok — MobileDrawerOrchestrator'dan farklı olarak EPC stream yok.
//
// Kullanım:
//   Feature notifier build() içinde instance oluşturur, init() çağırır.
//   ref.onDispose içinde dispose() çağırır.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

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

  /// Listener'ları başlatır. Feature notifier build() içinde çağırmalı.
  ///
  /// [onStageChange] her stage geçişinde çağrılır.
  void init({MasterDrawerStageCallback? onStageChange}) {
    if (_initialized) {
      MedLogger.warn(
        unit: 'MasterDrawerOrchestrator',
        swreq: 'SWREQ-CLI-CABIN-OP-013',
        message: 'init() zaten çağrılmış, yeniden başlatma atlandı',
      );
      return;
    }
    _initialized = true;
    _onStage = onStageChange;

    _drawerSub = ref.listen<MasterDrawerSessionState>(
      masterDrawerSessionProvider,
      (prev, next) => _onStage?.call(prev?.stage, next.stage),
    );
  }

  /// Tüm subscription'ları kapatır. Feature notifier ref.onDispose'da çağırmalı.
  Future<void> dispose() async {
    _drawerSub?.close();
    _drawerSub = null;
    _onStage = null;
    _initialized = false;
  }

  // ── Çekmece Operasyonları ─────────────────────────────────────────────────

  /// Verilen [assignment] için yeni bir çekmece oturumu başlatır.
  ///
  /// [openCubicLid] false geçilirse kübik çekmecelerde kapak açılmaz
  /// (iade modunda kullanılır).
  Future<void> open({required MedicineAssignment assignment, bool openCubicLid = true}) async {
    await ref.read(masterDrawerSessionProvider.notifier).start(assignment: assignment, openCubicLid: openCubicLid);
  }

  /// Kullanıcı dolumu tamamladı — çekmece kapanması bekleniyor.
  /// [MasterDrawerOpened] state'inde çağrılmalıdır.
  void confirmClose() {
    ref.read(masterDrawerSessionProvider.notifier).confirmClose();
  }

  /// Aynı assignment ile çekmeceyi yeniden açar (Closed/Failed sonrası).
  Future<void> reopen() async {
    await ref.read(masterDrawerSessionProvider.notifier).reopen();
  }

  /// Çekmece oturumunu sıfırlar. Banner kaybolur.
  Future<void> stop() async {
    await ref.read(masterDrawerSessionProvider.notifier).stop();
  }
}
