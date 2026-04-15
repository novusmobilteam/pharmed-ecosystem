// [SWREQ-UI-CAB-006]
// Arıza bildirimi ekranı.
//
// Sol panel:  CabinOverviewPanel  — çekmece listesi
// Orta panel: DrawerDetailPanel   — fault modunda göz renkleri arıza durumuna göre
// Sağ panel:  OperationPanelBase
//               └── FaultPanel
//
// ConsumerStatefulWidget kullanım sebebi:
//   - initState / didUpdateWidget → notifier.init(data)
//   - descriptionController lifecycle yönetimi
//   - Göz değişiminde controller temizleme
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../shared/widgets.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

import '../../../../core/enums/cabin_operation_mode.dart';
import '../notifier/fault_notifier.dart';
import '../state/fault_ui_state.dart';
import 'fault_panel.dart';

class FaultView extends ConsumerStatefulWidget {
  const FaultView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  ConsumerState<FaultView> createState() => _FaultViewState();
}

class _FaultViewState extends ConsumerState<FaultView> {
  late final TextEditingController _descriptionController;

  // ── Lifecycle ────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _scheduleInit(widget.data);
  }

  @override
  void didUpdateWidget(FaultView old) {
    super.didUpdateWidget(old);
    if (widget.data != old.data) {
      _scheduleInit(widget.data);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _scheduleInit(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(faultNotifierProvider.notifier).init(data);
    });
  }

  // ── Göz değişiminde controller temizle ──────────────────────────

  void _syncDescriptionController(FaultUiState state) {
    if (state is FaultCellSelected) {
      final newText = state.description ?? '';
      if (_descriptionController.text != newText) {
        _descriptionController.text = newText;
        // İmleci sona taşı
        _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
      }
    } else {
      if (_descriptionController.text.isNotEmpty) {
        _descriptionController.clear();
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faultNotifierProvider);
    final notifier = ref.read(faultNotifierProvider.notifier);

    // Controller'ı state ile senkronize et
    _syncDescriptionController(state);

    // Hata dinle
    ref.listen(faultNotifierProvider, (_, next) {
      if (next is FaultError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: MedColors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        notifier.dismissError();
      }
    });

    if (widget.data == null || state is FaultUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    if (state is FaultLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final groups = _extractGroups(state);
    final selectedSlotId = _extractSelectedSlotId(state);
    final selectedGroup = _extractSelectedGroup(state);
    final selectedUnitId = _extractSelectedUnitId(state);
    //final faults = _extractFaults(state);

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
              mode: CabinOperationMode.fault,
              onDrawerTap: notifier.onDrawerTap,
            ),
          ),

          // ── Orta panel ───────────────────────────────────────────
          Expanded(
            child: DrawerDetailPanel(
              mode: CabinOperationMode.fault,
              group: selectedGroup,
              stocks: const [],
              assignments: const [],
              selectedUnitId: selectedUnitId,
              selectedStepNo: null,
              onCellTap: notifier.onCellTap,
            ),
          ),

          // ── Sağ panel ────────────────────────────────────────────
          SizedBox(
            width: 280,
            child: OperationPanelBase(
              mode: CabinOperationMode.fault,
              child: FaultPanel(
                state: state,
                descriptionController: _descriptionController,
                onStatusChanged: notifier.onStatusChanged,
                onSubmit: () {
                  // Açıklamayı notifier'a yaz, sonra submit
                  notifier.onDescriptionChanged(_descriptionController.text);
                  notifier.submit();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Extract yardımcıları ─────────────────────────────────────────

  List<DrawerGroup> _extractGroups(FaultUiState s) => switch (s) {
    FaultIdle(:final groups) => groups,
    FaultDrawerSelected(:final groups) => groups,
    FaultCellSelected(:final groups) => groups,
    FaultSaving(:final groups) => groups,
    _ => const [],
  };

  int? _extractSelectedSlotId(FaultUiState s) => switch (s) {
    FaultDrawerSelected(:final selectedSlotId) => selectedSlotId,
    FaultCellSelected(:final selectedSlotId) => selectedSlotId,
    FaultSaving(:final selectedGroup) => selectedGroup.slot.id,
    _ => null,
  };

  DrawerGroup? _extractSelectedGroup(FaultUiState s) => switch (s) {
    FaultDrawerSelected(:final selectedGroup) => selectedGroup,
    FaultCellSelected(:final selectedGroup) => selectedGroup,
    FaultSaving(:final selectedGroup) => selectedGroup,
    _ => null,
  };

  int? _extractSelectedUnitId(FaultUiState s) => switch (s) {
    FaultCellSelected(:final selectedUnit) => selectedUnit.id,
    FaultSaving(:final selectedUnit) => selectedUnit.id,
    _ => null,
  };

  // List<Fault> _extractFaults(FaultUiState s) => switch (s) {
  //   FaultIdle(:final faults) => faults,
  //   FaultDrawerSelected(:final faults) => faults,
  //   FaultCellSelected(:final faults) => faults,
  //   FaultSaving(:final faults) => faults,
  //   _ => const [],
  // };
}
