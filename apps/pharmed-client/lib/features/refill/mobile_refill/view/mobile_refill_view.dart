// [SWREQ-CLI-REFILL-005] [IEC 62304 §5.5]
// Mobil kabin dolum ekranının root view'ı.
//
// Sorumluluk:
//   - CabinVisualizerData ile MobileRefillNotifier'ı initialize eder
//   - Drawer session stage'ini izler ve panel'e geçirir
//   - Üç-panel scaffold'unu MobileDrawerOperationWrapper ile sarar
//     (sol alt köşede çekmece durum banner'ı için)
//   - Çekmece aktif iken MobileRefillDialog'u açar/kapatır (_syncDialog)
//   - Error / Success state'lerini snackbar olarak gösterir
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../refill.dart';
import 'mobile_refill_dialog.dart';

class MobileRefillView extends ConsumerStatefulWidget {
  const MobileRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileRefillView> createState() => _MobileRefillViewState();
}

class _MobileRefillViewState extends ConsumerState<MobileRefillView> {
  /// Dialog şu an ekranda mı? Çift açma / yanlış pop'lamayı engeller.
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileRefillView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileRefillNotifierProvider.notifier).init(data);
    });
  }

  // ───────────────────────────────────────────────────────────────────────
  // Dialog sync
  //
  // Sadece AÇMA — kapama dialog'un kendi sorumluluğu. Bu önemli: dialog'u
  // dış context'ten manuel `Navigator.pop` ile kapatmaya çalışmak (view'daki
  // showDialog'a denk gelen pop) state geçişleri hızlı olduğunda yarış
  // sorunu yaratıyor:
  //
  //   t0: Saving → Error → Ready (hızlı geçiş)
  //   t1: _syncDialog shouldBeOpen=false sanıp pop atar
  //   t2: pop animasyonu bitmeden state Ready'e döner, _syncDialog yeniden
  //       açar → 2 dialog üst üste birikir
  //
  // Bunun yerine dialog ref.listen ile state'i kendi izliyor, kapanma kararını
  // kendi veriyor. Manuel pop yok, birikme yapısal olarak imkansız.
  // ───────────────────────────────────────────────────────────────────────

  void _syncDialog(BuildContext context) {
    final state = ref.read(mobileRefillNotifierProvider);
    final stage = ref.read(mobileDrawerSessionProvider).stage;
    final shouldBeOpen = state.shouldKeepDialog(stage);

    if (shouldBeOpen && !_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const MobileRefillDialog(),
      ).then((_) => _isDialogOpen = false);
    }
    // Kapama YOK — MobileRefillDialog kendi pop'unu çağırıyor.
  }

  // ───────────────────────────────────────────────────────────────────────
  // Cancel akışı
  //
  //   - DrawerOpening/Opened + RFID yok → bilgi snackbar (çekmeceyi kapatın)
  //   - DrawerClosed + RFID yok          → onay dialogu (geri dönülemez)
  //   - Diğer                            → doğrudan iptal
  // ───────────────────────────────────────────────────────────────────────

  Future<void> _handleCancelRefill(MobileRefillState state, MobileDrawerStage drawerStage) async {
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);
    final rfidReadCount = state is MobileRefillReady ? state.rfidReadCount : 0;

    if ((drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) && rfidReadCount == 0) {
      MessageUtils.showInfoSnackbar(context, context.l10n.common_cancelInfo_drawerClose);
      return;
    }

    if (drawerStage is MobileDrawerClosed && rfidReadCount == 0) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.exit,
        customTitle: context.l10n.refill_cancelDialog_title,
        customMessage: context.l10n.refill_cancelDialog_message,
        confirmButtonText: context.l10n.common_confirmCancelButton,
        onConfirm: notifier.cancelRefill,
      );
      return;
    }

    notifier.cancelRefill();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    // Dialog sync — notifier veya drawer session değişimi her ikisini de tetikler
    ref.listen<MobileRefillState>(mobileRefillNotifierProvider, (_, __) {
      _syncDialog(context);
    });
    ref.listen<MobileDrawerSessionState>(mobileDrawerSessionProvider, (_, __) {
      _syncDialog(context);
    });

    // Error/Success snackbar
    //
    // Error: Dialog açıksa snackbar gösterme — dialog kendi error banner'ını
    // ve "Tekrar Dene / Vazgeç" butonlarını içeride sunar. Dialog kapalıyken
    // (örn. init veya baseline scan fail) snackbar fallback olarak çalışır.
    //
    // Success: snackbar + dismissSuccess (mevcut akış).
    ref.listen(mobileRefillNotifierProvider, (_, next) {
      if (next is MobileRefillError) {
        final stage = ref.read(mobileDrawerSessionProvider).stage;
        if (!next.shouldKeepDialog(stage)) {
          MessageUtils.showErrorSnackbar(context, next.message);
          notifier.dismissError();
        }
      } else if (next is MobileRefillSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.refill_success_completedMobile);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileRefillUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: state.slots,
        selectedSlotId: state.selectedSlotId,
        mode: CabinOperationMode.refill,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.refill,
        slot: state.selectedSlot,
        selectedCell: state.selectedCell,
        onCellTap: notifier.onCellTap,
        assignmentByCoord: state.assignmentByCoord,
      ),
      rightPanel: MobileRefillPanel(
        state: state,
        notifier: notifier,
        drawerStage: drawerStage,
        onStartRefill: notifier.startRefill,
        onCompleteRefill: notifier.completeRefill,
        onReopenDrawer: notifier.reopenDrawer,
        onSelectAssignment: notifier.selectAssignment,
        onChangePatient: notifier.clearPatientSelection,
        onToggleItem: notifier.toggleItemSelection,
        onCancelRefill: () => _handleCancelRefill(state, drawerStage),
      ),
    );
  }
}
