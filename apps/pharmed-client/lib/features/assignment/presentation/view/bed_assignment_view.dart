// lib/features/assignment/presentation/view/patient_assignment_view.dart
//
// [SWREQ-UI-CAB-006]
// Hasta bazlı atama ekranı — sadece mobil kabin.
//
// Sol panel:  MobileCabinOverviewPanel  — slot listesi
// Orta panel: MobileCabinDetailPanel   — seçili slot grid'i
// Sağ panel:  OperationPanelBase
//               └── PatientAssignmentPanel
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/assignment/presentation/view/bed_assignment_panel.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/bed_assignment_notifier.dart';
import '../state/bed_assignment_state.dart';

class BedAssignmentView extends ConsumerStatefulWidget {
  const BedAssignmentView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<BedAssignmentView> createState() => _BedAssignmentViewState();
}

class _BedAssignmentViewState extends ConsumerState<BedAssignmentView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(BedAssignmentView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(bedAssignmentNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bedAssignmentNotifierProvider);
    final notifier = ref.read(bedAssignmentNotifierProvider.notifier);

    ref.listen(bedAssignmentNotifierProvider, (_, next) {
      if (next is BedAssignmentError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      } else if (next is BedAssignmentSuccess) {
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is BedAssignmentUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is BedAssignmentLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: state.slots,
        selectedSlotId: state.selectedSlotId,
        mode: CabinOperationMode.assign,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.assign,
        slot: state.selectedSlot,
        selectedCell: state.selectedCell,
        onCellTap: state.selectedSlot?.workingStatus == null ? notifier.onCellTap : null,
        assignmentByCoord: state.assignmentByCoord,
      ),
      rightPanel: OperationPanelBase(
        mode: CabinOperationMode.assign,
        child: BedAssignmentPanel(
          state: state,
          onServiceSelected: notifier.onServiceSelected,
          onRoomSelected: notifier.onRoomSelected,
          onBedSelected: notifier.onBedSelected,
          onSave: notifier.saveAssignment,
          onDelete: notifier.deleteAssignment,
        ),
      ),
    );
  }
}
