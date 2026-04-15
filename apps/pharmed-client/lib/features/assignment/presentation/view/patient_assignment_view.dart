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
import 'package:pharmed_client/features/assignment/presentation/view/patient_assignment_panel.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/providers/providers.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/patient_assignment_notifier.dart';
import '../state/patient_assignment_ui_state.dart';

class PatientAssignmentView extends ConsumerStatefulWidget {
  const PatientAssignmentView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<PatientAssignmentView> createState() => _PatientAssignmentViewState();
}

class _PatientAssignmentViewState extends ConsumerState<PatientAssignmentView> {
  @override
  void initState() {
    super.initState();
    _scheduleInit(widget.data);
  }

  @override
  void didUpdateWidget(PatientAssignmentView old) {
    super.didUpdateWidget(old);
    if (widget.data != old.data) {
      _scheduleInit(widget.data);
    }
  }

  void _scheduleInit(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(patientAssignmentNotifierProvider.notifier).init(data);
    });
  }

  Future<void> _openHospitalizationDialog() async {
    final getHospitalizations = ref.read(getHospitalizationsUseCaseProvider);

    final selected = await SelectionDialog.show<Hospitalization>(
      context,
      title: 'Yatış Seç',
      dataSource: (skip, take, search) =>
          getHospitalizations.call(GetHospitalizationsParams(skip: skip, take: take, search: search)),
      labelBuilder: (h) => h.patient?.fullName ?? '—',
      subtitleBuilder: (h) {
        final room = h.roomId ?? '—';
        final bed = h.bedId ?? '—';
        final service = h.physicalService?.name ?? '—';
        return '$service · Oda $room / $bed';
      },
    );

    if (selected != null && mounted) {
      ref.read(patientAssignmentNotifierProvider.notifier).onHospitalizationSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientAssignmentNotifierProvider);
    final notifier = ref.read(patientAssignmentNotifierProvider.notifier);

    ref.listen(patientAssignmentNotifierProvider, (_, next) {
      if (next is PatientAssignmentError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (widget.data == null || state is PatientAssignmentUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is PatientAssignmentLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final slots = _extractSlots(state);
    final selectedSlotId = _extractSelectedSlotId(state);
    final selectedSlot = _extractSelectedSlot(state);
    final selectedCell = _extractSelectedCell(state);

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: slots,
        selectedSlotId: selectedSlotId,
        mode: CabinOperationMode.assign,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDetailPanel(
        mode: CabinOperationMode.assign,
        slot: selectedSlot,
        selectedCell: selectedCell,
        onCellTap: notifier.onCellTap,
      ),
      rightPanel: OperationPanelBase(
        mode: CabinOperationMode.assign,
        child: PatientAssignmentPanel(
          state: state,
          onSelectHospitalization: _openHospitalizationDialog,
          onSave: notifier.saveAssignment,
          onDelete: notifier.deleteAssignment,
        ),
      ),
    );
  }

  List<MobileSlotVisual> _extractSlots(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentIdle(:final slots) => slots,
    PatientAssignmentSlotSelected(:final slots) => slots,
    PatientAssignmentCellSelected(:final slots) => slots,
    PatientAssignmentSaving(:final slots) => slots,
    _ => const [],
  };

  int? _extractSelectedSlotId(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentSlotSelected(:final selectedSlotId) => selectedSlotId,
    PatientAssignmentCellSelected(:final selectedSlotId) => selectedSlotId,
    PatientAssignmentSaving(:final selectedSlotId) => selectedSlotId,
    _ => null,
  };

  MobileSlotVisual? _extractSelectedSlot(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentSlotSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentCellSelected(:final selectedSlot) => selectedSlot,
    PatientAssignmentSaving(:final selectedSlot) => selectedSlot,
    _ => null,
  };

  MobileCellCoord? _extractSelectedCell(PatientAssignmentUiState s) => switch (s) {
    PatientAssignmentCellSelected(:final selectedCell) => selectedCell,
    _ => null,
  };
}
