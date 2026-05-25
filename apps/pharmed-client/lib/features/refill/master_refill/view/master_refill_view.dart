// lib/features/refill/master_refill/presentation/view/master_refill_view.dart
//
// [SWREQ-CLI-MREFILL-004] [IEC 62304 §5.5]
// Master kabin dolum ekranının root view'ı.
//
// Sorumluluk:
//   - CabinVisualizerData ile MasterRefillNotifier'ı initialize eder
//   - Orchestrator notifier build() içinde yönetilir — view sadece aksiyon callback'lerini iletir
//   - Üç panel scaffold'unu MasterDrawerOperationWrapper ile sarar
//   - Error / Success state'lerini snackbar olarak gösterir
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../../core/enums/cabin_operation_mode.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/cabin_operation/master_drawer/master_drawer_operation_wrapper.dart';
import '../../refill.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(MasterRefillView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterRefillNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(masterRefillNotifierProvider);
    final notifier = ref.read(masterRefillNotifierProvider.notifier);
    final drawerStage = ref.watch(masterDrawerSessionProvider).stage;

    ref.listen(masterRefillNotifierProvider, (_, next) {
      if (next is MasterRefillError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is MasterRefillSuccess) {
        MessageUtils.showSuccessSnackbar(context, context.l10n.refill_success_completedMaster);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is MasterRefillUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is MasterRefillLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return MasterDrawerOperationWrapper(
      child: CabinOperationScaffold(
        leftPanel: MasterCabinOverviewPanel(
          groups: state.groups,
          selectedSlotId: state.selectedSlotId,
          mode: CabinOperationMode.refill,
          onDrawerTap: notifier.onDrawerTap,
        ),
        centerPanel: MasterCabinDrawerPanel(
          mode: CabinOperationMode.refill,
          group: state.selectedGroup,
          assignments: state.assignments,
          stocks: state.stocks,
          faults: state.faults,
          selectedUnitId: state.selectedUnitId,
          selectedStepNo: state.selectedStepNo,
          onCellTap: notifier.onCellTap,
        ),
        rightPanel: MasterRefillPanel(
          state: state,
          drawerStage: drawerStage,
          onFillingQuantityChanged: notifier.onFillingQuantityChanged,
          onCountQuantityChanged: notifier.onCountQuantityChanged,
          onMiadDateChanged: notifier.onMiadDateChanged,
          onStepFillingChanged: notifier.onStepFillingChanged,
          onStepCountChanged: notifier.onStepCountChanged,
          onStepMiadChanged: notifier.onStepMiadChanged,
          onOpenDrawer: notifier.openDrawer,
          onConfirmClose: notifier.confirmClose,
          onSave: notifier.saveRefill,
          onCancelDrawer: notifier.cancelDrawer,
        ),
      ),
    );
  }
}
