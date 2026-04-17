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
import '../state/patient_assignment_state.dart';

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
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(PatientAssignmentView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(patientAssignmentNotifierProvider.notifier).init(data);
    });
  }

  Future<void> _openHospitalizationDialog() async {
    final getHospitalizations = ref.read(getHospitalizationsUseCaseProvider);

    // Önceden hazırla
    final rooms = ref.read(allRoomsProvider).valueOrNull ?? [];
    final beds = ref.read(allBedsProvider).valueOrNull ?? [];
    final services = ref.read(allServicesProvider).valueOrNull ?? [];
    final roomById = {for (final r in rooms) r.id: r};
    final bedById = {for (final b in beds) b.id: b};
    final serviceById = {for (final s in services) s.id: s};

    final selected = await SelectionDialog.show<Hospitalization>(
      context,
      title: 'Yatış Seç',
      dataSource: (skip, take, search) =>
          getHospitalizations.call(GetHospitalizationsParams(skip: skip, take: take, search: search)),
      labelBuilder: (h) => h.patient?.fullName ?? '—',
      subtitleBuilder: (h) {
        final room = roomById[h.roomId];
        final bed = bedById[h.bedId];
        final service = serviceById[h.physicalServiceId] ?? (room != null ? serviceById[room.serviceId] : null);
        return '${service?.name ?? '—'} · ${room?.name ?? '—'} / ${bed?.name ?? '—'}';
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
      } else if (next is PatientAssignmentSuccess) {
        MessageUtils.showSuccessSnackbar(context, next.message);
        notifier.dismissSuccess();
      }
    });

    if (widget.data == null || state is PatientAssignmentUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is PatientAssignmentLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final slots = state.slots;
    final selectedSlotId = state.selectedSlotId;
    final selectedSlot = state.selectedSlot;
    final selectedCell = state.selectedCell;

    return CabinOperationScaffold(
      leftPanel: MobileCabinOverviewPanel(
        slots: slots,
        selectedSlotId: selectedSlotId,
        mode: CabinOperationMode.assign,
        onSlotTap: notifier.onSlotTap,
      ),
      centerPanel: MobileCabinDrawerPanel(
        mode: CabinOperationMode.assign,
        slot: selectedSlot,
        selectedCell: selectedCell,
        onCellTap: selectedSlot?.workingStatus == null ? notifier.onCellTap : null,
        assignmentByCoord: state.assignmentByCoord,
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
}
