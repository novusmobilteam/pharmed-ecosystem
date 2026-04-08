// lib/features/cabin/presentation/screen/drug_assignment_view.dart
//
// [SWREQ-UI-CAB-005]
// İlaç bazlı atama ekranı.
//
// Sol panel:  CabinOverviewPanel    — çekmece listesi
// Orta panel: DrawerDetailPanel     — seçili çekmece içeriği
// Sağ panel:  OperationPanelBase
//               └── DrugAssignmentPanel
//
// ConsumerStatefulWidget kullanım sebebi:
//   initState      → notifier.init(data) çağrılır
//   didUpdateWidget → data değişirse notifier.init(data) tekrar çağrılır
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/providers/usecase_providers.dart';
import 'package:pharmed_client/features/assignment/presentation/view/drug_assignment_panel.dart';
import 'package:pharmed_client/features/cabin/presentation/state/cabin_operation_mode.dart';
import 'package:pharmed_client/features/cabin/presentation/widgets/cabin_overview_panel.dart';
import 'package:pharmed_client/features/cabin/presentation/widgets/drawer_detail_panel.dart';
import 'package:pharmed_client/features/cabin/presentation/widgets/operation_panel_base.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../notifier/drug_assignment_notifier.dart';
import '../state/drug_assignment_ui_state.dart';

class DrugAssignmentView extends ConsumerStatefulWidget {
  const DrugAssignmentView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<DrugAssignmentView> createState() => _DrugAssignmentViewState();
}

class _DrugAssignmentViewState extends ConsumerState<DrugAssignmentView> {
  // ── Lifecycle ────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _scheduleInit(widget.data);
  }

  @override
  void didUpdateWidget(DrugAssignmentView old) {
    super.didUpdateWidget(old);
    if (widget.data != old.data) {
      _scheduleInit(widget.data);
    }
  }

  void _scheduleInit(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(drugAssignmentNotifierProvider.notifier).init(data);
    });
  }

  // ── İlaç seçim dialogu ───────────────────────────────────────────

  Future<void> _openDrugDialog() async {
    final getDrugs = ref.read(getDrugsUseCaseProvider);

    final selected = await SelectionDialog.show<Medicine>(
      context,
      title: 'İlaç Seç',
      dataSource: (skip, take, search) => getDrugs.call(GetDrugsParams(skip: skip, take: take, search: search)),
      labelBuilder: (m) => m.name ?? '—',
      subtitleBuilder: (m) => m.barcode,
    );

    if (selected != null && mounted) {
      ref.read(drugAssignmentNotifierProvider.notifier).onDrugSelected(selected);
    }
  }

  // ── Hata snackbar ────────────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MedColors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drugAssignmentNotifierProvider);
    final notifier = ref.read(drugAssignmentNotifierProvider.notifier);

    // Hata state'ini dinle — snackbar göster, önceki state'e dön
    ref.listen(drugAssignmentNotifierProvider, (_, next) {
      if (next is DrugAssignmentError) {
        _showError(next.message);
        notifier.dismissError();
      }
    });

    if (widget.data == null || state is DrugAssignmentUninitialized) {
      // return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
      return Center(child: Text('Empty'));
    }

    // Yükleniyor — atamalar çekiliyor
    if (state is DrugAssignmentLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final groups = _extractGroups(state);
    final selectedSlotId = _extractSelectedSlotId(state);
    final selectedGroup = _extractSelectedGroup(state);
    final selectedUnitId = _extractSelectedUnitId(state);

    int? extractSelectedStepNo(DrugAssignmentUiState s) => switch (s) {
      DrugAssignmentCellSelected(:final selectedStepNo) => selectedStepNo,
      _ => null,
    };

    List<CabinAssignment> _extractAssignments(DrugAssignmentUiState s) => switch (s) {
      DrugAssignmentIdle(:final assignments) => assignments,
      DrugAssignmentDrawerSelected(:final assignments) => assignments,
      DrugAssignmentCellSelected(:final assignments) => assignments,
      DrugAssignmentSaving(:final assignments) => assignments,
      _ => const [],
    };

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sol panel ────────────────────────────────────────────
          SizedBox(
            width: 260,
            child: CabinOverviewPanel(
              groups: groups,
              selectedSlotId: selectedSlotId,
              mode: CabinOperationMode.assign,
              onDrawerTap: notifier.onDrawerTap,
            ),
          ),

          // ── Orta panel ───────────────────────────────────────────
          Expanded(
            child: DrawerDetailPanel(
              mode: CabinOperationMode.assign,
              group: selectedGroup,
              assignments: _extractAssignments(state),
              stocks: const [], // assign modunda stok rengi yok
              selectedUnitId: selectedUnitId,
              selectedStepNo: extractSelectedStepNo(state),
              onCellTap: notifier.onCellTap,
            ),
          ),

          // ── Sağ panel ────────────────────────────────────────────
          SizedBox(
            width: 280,
            child: OperationPanelBase(
              mode: CabinOperationMode.assign,
              child: DrugAssignmentPanel(
                state: state,
                onSelectDrug: _openDrugDialog,
                onMinChanged: notifier.onMinQtyChanged,
                onMaxChanged: notifier.onMaxQtyChanged,
                onCriticalChanged: notifier.onCriticalQtyChanged,
                onSave: notifier.saveAssignment,
                onDelete: notifier.deleteAssignment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── State extract yardımcıları ───────────────────────────────────

  List<DrawerGroup> _extractGroups(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentIdle(:final groups) => groups,
    DrugAssignmentDrawerSelected(:final groups) => groups,
    DrugAssignmentCellSelected(:final groups) => groups,
    DrugAssignmentSaving(:final groups) => groups,
    _ => const [],
  };

  int? _extractSelectedSlotId(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentDrawerSelected(:final selectedSlotId) => selectedSlotId,
    DrugAssignmentCellSelected(:final selectedSlotId) => selectedSlotId,
    DrugAssignmentSaving(:final selectedGroup) => selectedGroup.slot.id,
    _ => null,
  };

  DrawerGroup? _extractSelectedGroup(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentDrawerSelected(:final selectedGroup) => selectedGroup,
    DrugAssignmentCellSelected(:final selectedGroup) => selectedGroup,
    DrugAssignmentSaving(:final selectedGroup) => selectedGroup,
    _ => null,
  };

  int? _extractSelectedUnitId(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentCellSelected(:final selectedUnitId) => selectedUnitId,
    _ => null,
  };
}
