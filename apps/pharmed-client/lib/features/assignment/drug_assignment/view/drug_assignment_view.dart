import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../assignment.dart';

part 'assignment_idle_panel.dart';
part 'assignment_edit_panel.dart';

class DrugAssignmentView extends ConsumerStatefulWidget {
  const DrugAssignmentView({super.key, this.data, required this.menu, this.cabin});

  final MenuItem menu;
  final Cabin? cabin;
  final CabinVisualizerData? data;

  @override
  ConsumerState<DrugAssignmentView> createState() => _DrugAssignmentViewState();
}

class _DrugAssignmentViewState extends ConsumerState<DrugAssignmentView> {
  @override
  void initState() {
    super.initState();
    _initialize(widget.data);
  }

  @override
  void didUpdateWidget(DrugAssignmentView old) {
    super.didUpdateWidget(old);
    if (widget.data?.cabinId != old.data?.cabinId) {
      _initialize(widget.data);
    }
  }

  void _initialize(CabinVisualizerData? data) {
    if (data == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(drugAssignmentNotifierProvider.notifier).init(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drugAssignmentNotifierProvider);
    final notifier = ref.read(drugAssignmentNotifierProvider.notifier);

    ref.listen(drugAssignmentNotifierProvider, (_, next) {
      if (next is DrugAssignmentError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    if (widget.data == null || state is DrugAssignmentUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    // Yükleniyor — atamalar çekiliyor
    if (state is DrugAssignmentLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    final groups = _extractGroups(state);
    final selectedUnitId = state is DrugAssignmentCellSelected ? state.selectedUnitId : null;
    final assignments = _assignments(state);

    final idle = switch (state) {
      DrugAssignmentIdle s => s,
      DrugAssignmentError(previous: DrugAssignmentIdle s) => s,
      _ => null,
    };

    return CabinOperationSelectionLayout(
      isLoading: state is DrugAssignmentLoading,
      left: Column(
        spacing: 6.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CabinOverviewSelectionPanel(
              cabin: widget.cabin,
              onChangeCabin: () => ref.read(dashboardNotifierProvider.notifier).changeCabin(),
              groups: groups,
              assignments: assignments,
              selectedUnitIds: selectedUnitId != null ? {selectedUnitId} : const {},
              onCellTap: (unit) => notifier.onCellTap(unit, null),
            ),
          ),
        ],
      ),
      right: switch (state) {
        DrugAssignmentCellSelected s => _AssignmentEditPanel(state: s, notifier: notifier),
        DrugAssignmentSaving() => const Center(child: MedLoadingIndicator()),
        _ => _AssignmentIdlePanel(
          assignments: idle?.visibleAssignments ?? [],
          groups: groups,
          onEdit: notifier.editAssignment,
          menu: widget.menu,
          onAssignmentSearchChanged: (value) => notifier.onAssignmentSearchChanged(value),
        ),
      },
    );
  }

  int? extractSelectedStepNo(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentCellSelected(:final selectedStepNo) => selectedStepNo,
    _ => null,
  };

  List<DrawerGroup> _extractGroups(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentIdle(:final groups) => groups,
    DrugAssignmentCellSelected(:final groups) => groups,
    DrugAssignmentSaving(:final groups) => groups,
    _ => const [],
  };

  List<MedicineAssignment> _assignments(DrugAssignmentUiState s) => switch (s) {
    DrugAssignmentIdle(:final assignments) => assignments,
    DrugAssignmentCellSelected(:final assignments) => assignments,
    DrugAssignmentSaving(:final assignments) => assignments,
    _ => const [],
  };
}
