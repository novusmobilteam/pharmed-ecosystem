import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../unload.dart';

class MobileUnloadView extends ConsumerStatefulWidget {
  const MobileUnloadView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileUnloadView> createState() => _MobileUnloadViewState();
}

class _MobileUnloadViewState extends ConsumerState<MobileUnloadView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileUnloadView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileUnloadNotifierProvider.notifier).init(data);
    });
  }

  Future<void> _onCancelUnload(MobileUnloadState state, MobileDrawerStage drawerStage) async {
    final notifier = ref.read(mobileUnloadNotifierProvider.notifier);
    final rfidTakenCount = state is MobileUnloadReady ? state.rfidTakenCount : 0;

    // DrawerOpening/Opened + henüz ilaç çıkarılmadı → snackbar
    if ((drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) && rfidTakenCount == 0) {
      MessageUtils.showInfoSnackbar(context, 'İşlemi iptal etmek için çekmeceyi kapatın.');
      return;
    }

    // DrawerClosed + henüz ilaç çıkarılmadı → onay dialogu
    if (drawerStage is MobileDrawerClosed && rfidTakenCount == 0) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.exit,
        customTitle: 'Boşaltmayı İptal Et',
        customMessage: 'Henüz ilaç çıkarılmadı. Boşaltma işlemi iptal edilsin mi?',
        confirmButtonText: 'İptal Et',
        onConfirm: notifier.cancelUnload,
      );
      return;
    }

    notifier.cancelUnload();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileUnloadNotifierProvider);
    final notifier = ref.read(mobileUnloadNotifierProvider.notifier);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    ref.listen(mobileUnloadNotifierProvider, (_, next) {
      if (next is MobileUnloadError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
        ref.read(mobileDrawerSessionProvider.notifier).stop();
      } else if (next is MobileUnloadSuccess) {
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileUnloadUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return MobileDrawerOperationWrapper(
      child: CabinOperationScaffold(
        leftPanel: MobileCabinOverviewPanel(
          slots: state.slots,
          selectedSlotId: state.selectedSlotId,
          mode: CabinOperationMode.unload,
          onSlotTap: notifier.onSlotTap,
        ),
        centerPanel: MobileCabinDrawerPanel(
          mode: CabinOperationMode.unload,
          slot: state.selectedSlot,
          selectedCell: state.selectedCell,
          onCellTap: notifier.onCellTap,
          assignmentByCoord: state.assignmentByCoord,
        ),
        rightPanel: MobileUnloadPanel(
          state: state,
          drawerStage: drawerStage,
          onStartUnload: notifier.startUnload,
          onCompleteUnload: notifier.completeUnload,
          onReopenDrawer: notifier.reopenDrawer,
          onSelectAssignment: notifier.selectAssignment,
          onChangePatient: notifier.clearPatientSelection,
          onToggleItem: notifier.toggleItemSelection,
          onCancelUnload: () => _onCancelUnload(state, drawerStage),
        ),
      ),
    );
  }
}
