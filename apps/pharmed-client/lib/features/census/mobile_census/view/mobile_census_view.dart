import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../census.dart';

class MobileCensusView extends ConsumerStatefulWidget {
  const MobileCensusView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MobileCensusView> createState() => _MobileCensusViewState();
}

class _MobileCensusViewState extends ConsumerState<MobileCensusView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MobileCensusView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(mobileCensusNotifierProvider.notifier).init(data);
    });
  }

  Future<void> _onCancelCensus(MobileCensusState state, MobileDrawerStage drawerStage) async {
    final notifier = ref.read(mobileCensusNotifierProvider.notifier);

    // DrawerOpening/Opened → iptal için önce çekmece kapatılmalı
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      MessageUtils.showInfoSnackbar(context, context.l10n.common_cancelInfo_drawerClose);
      return;
    }

    // DrawerClosed → onay dialogu
    if (drawerStage is MobileDrawerClosed) {
      MessageUtils.showConfirmDialog(
        context: context,
        action: ConfirmAction.exit,
        customTitle: context.l10n.census_cancelDialog_title,
        customMessage: context.l10n.census_cancelDialog_message,
        confirmButtonText: context.l10n.common_confirmCancelButton,
        onConfirm: notifier.cancelCensus,
      );
      return;
    }

    // DrawerIdle → direkt iptal
    notifier.cancelCensus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileCensusNotifierProvider);
    final notifier = ref.read(mobileCensusNotifierProvider.notifier);
    final drawerStage = ref.watch(mobileDrawerSessionProvider).stage;

    ref.listen(mobileCensusNotifierProvider, (_, next) {
      if (next is MobileCensusError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
        ref.read(mobileDrawerSessionProvider.notifier).stop();
      } else if (next is MobileCensusSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.census_success_completed);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MobileCensusUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    return MobileDrawerOperationWrapper(
      child: CabinOperationScaffold(
        leftPanel: MobileCabinOverviewPanel(
          slots: state.slots,
          selectedSlotId: state.selectedSlotId,
          mode: CabinOperationMode.census,
          onSlotTap: notifier.onSlotTap,
        ),
        centerPanel: MobileCabinDrawerPanel(
          mode: CabinOperationMode.census,
          slot: state.selectedSlot,
          selectedCell: state.selectedCell,
          onCellTap: notifier.onCellTap,
          assignmentByCoord: state.assignmentByCoord,
        ),
        rightPanel: MobileCensusPanel(
          state: state,
          drawerStage: drawerStage,
          onStartCensus: notifier.startCensus,
          onCompleteCensus: notifier.completeCensus,
          onReopenDrawer: notifier.reopenDrawer,
          onSelectAssignment: notifier.selectAssignment,
          onChangePatient: notifier.clearPatientSelection,
          onToggleItem: notifier.toggleItemSelection,
          onCancelCensus: () => _onCancelCensus(state, drawerStage),
        ),
      ),
    );
  }
}
