import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';

class MobileIntakeView extends ConsumerStatefulWidget {
  const MobileIntakeView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileIntakeViewState();
}

class _MobileIntakeViewState extends ConsumerState<MobileIntakeView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileIntakeView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileIntakeNotifierProvider.notifier).init(data);
    });
  }

  Future<void> _onCancelIntake(MobileIntakeState state, MobileDrawerStage drawerStage) async {
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);
    final rfidTakenCount = state is MobileIntakeReady ? state.rfidTakenCount : 0;

    // DrawerOpening/Opened + henüz ilaç alınmadı → snackbar, iptal etme
    if ((drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) && rfidTakenCount == 0) {
      MessageUtils.showInfoSnackbar(context, context.l10n.common_cancelInfo_drawerClose);
      return;
    }

    // DrawerClosed + henüz ilaç alınmadı → onay dialogu
    if (drawerStage is MobileDrawerClosed && rfidTakenCount == 0) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.exit,
        customTitle: context.l10n.intake_cancelDialog_title,
        customMessage: context.l10n.intake_cancelDialog_message,
        confirmButtonText: context.l10n.common_confirmCancelButton,
        onConfirm: notifier.cancelIntake,
      );
      return;
    }

    // Diğer durumlar → direkt iptal
    notifier.cancelIntake();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileIntakeNotifierProvider);
    final notifier = ref.read(mobileIntakeNotifierProvider.notifier);

    // Drawer session stage'i panel'e geçirilecek; ayrıca _RefillActionBar
    // buton seçiminde kullanır.
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    // Error/Success snackbar
    ref.listen(mobileIntakeNotifierProvider, (_, next) {
      if (next is MobileIntakeError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
        ref.read(mobileDrawerSessionProvider.notifier).stop();
      } else if (next is MobileIntakeSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.intake_success_completed);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileIntakeUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return MobileDrawerOperationWrapper(
      child: CabinOperationScaffold(
        leftPanel: MobileCabinOverviewPanel(
          slots: state.slots,
          selectedSlotId: state.selectedSlotId,
          mode: CabinOperationMode.intake,
          onSlotTap: notifier.onSlotTap,
        ),
        centerPanel: MobileCabinDrawerPanel(
          mode: CabinOperationMode.intake,
          slot: state.selectedSlot,
          selectedCell: state.selectedCell,
          onCellTap: notifier.onCellTap,
          assignmentByCoord: state.assignmentByCoord,
        ),
        rightPanel: MobileIntakePanel(
          notifier: notifier,
          state: state,
          drawerStage: drawerStage,
          onStartIntake: notifier.startIntake,
          onCompleteIntake: notifier.completeIntake,
          onReopenDrawer: notifier.reopenDrawer,
          onSelectAssignment: notifier.selectAssignment,
          onChangePatient: notifier.clearPatientSelection,
          onToggleItem: notifier.toggleItemSelection,
          onCancelIntake: () => _onCancelIntake(state, drawerStage),
          onReportMissing: notifier.reportMissingStock,
        ),
      ),
    );
  }
}
