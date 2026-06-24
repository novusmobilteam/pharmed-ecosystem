// [SWREQ-CLI-REFILL-005] [IEC 62304 §5.5]
// Mobil kabin dolum ekranının root view'ı.
//
// Sorumluluk:
//   - CabinVisualizerData ile MobileRefillNotifier'ı initialize eder
//   - Drawer session stage'ini izler ve panel'e geçirir
//   - Üç-panel scaffold'unu MobileDrawerOperationWrapper ile sarar
//     (sol alt köşede çekmece durum banner'ı için)
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

class MobileRefillView extends ConsumerStatefulWidget {
  const MobileRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileRefillView> createState() => _MobileRefillViewState();
}

class _MobileRefillViewState extends ConsumerState<MobileRefillView> {
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

  Future<void> _handleCancelRefill(MobileRefillState state, MobileDrawerStage drawerStage) async {
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);
    final rfidReadCount = state is MobileRefillReady ? state.rfidReadCount : 0;

    // DrawerOpening/Opened + RFID yok → snackbar, iptal etme
    if ((drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) && rfidReadCount == 0) {
      MessageUtils.showInfoSnackbar(context, context.l10n.common_cancelInfo_drawerClose);
      return;
    }

    // DrawerClosed + RFID yok → onay dialogu
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

    // Diğer durumlar → direkt iptal
    notifier.cancelRefill();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileRefillNotifierProvider);
    final notifier = ref.read(mobileRefillNotifierProvider.notifier);

    // Drawer session stage'i panel'e geçirilecek; ayrıca _RefillActionBar
    // buton seçiminde kullanır.
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    // Error/Success snackbar
    ref.listen(mobileRefillNotifierProvider, (_, next) {
      if (next is MobileRefillError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
        ref.read(mobileDrawerSessionProvider.notifier).stop();
      } else if (next is MobileRefillSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.refill_success_completedMobile);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileRefillUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return MobileDrawerOperationWrapper(
      child: CabinOperationScaffold(
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
      ),
    );
  }
}
