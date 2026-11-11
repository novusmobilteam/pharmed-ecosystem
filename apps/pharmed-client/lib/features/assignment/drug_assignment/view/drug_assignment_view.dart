import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../../assignment.dart';

part 'assignment_idle_panel.dart';
part 'assignment_edit_panel.dart';

class DrugAssignmentView extends ConsumerStatefulWidget {
  const DrugAssignmentView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<DrugAssignmentView> createState() => _DrugAssignmentViewState();
}

class _DrugAssignmentViewState extends ConsumerState<DrugAssignmentView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(drugAssignmentNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
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

    if (widget.stationContext.cabinDataByCabinId.isEmpty || state is DrugAssignmentUninitialized) {
      return const EmptyStateWidget(variant: EmptyStateVariant.cabinData);
    }

    // Yükleniyor — atamalar çekiliyor
    if (state is DrugAssignmentLoading) {
      return const Center(child: MedLoadingIndicator());
    }

    final scope = notifier.scope;
    final groups = _extractGroups(state);
    final selectedUnitId = state is DrugAssignmentCellSelected ? state.selectedUnitId : null;
    final selectedCellId = state is DrugAssignmentCellSelected ? state.selectedCellId : null;
    final assignments = _assignments(state);

    final idle = switch (state) {
      DrugAssignmentIdle s => s,
      DrugAssignmentError(previous: DrugAssignmentIdle s) => s,
      _ => null,
    };

    return CabinOperationSelectionLayout(
      isLoading: state is DrugAssignmentLoading,
      left: StationCabinSelectionPanel(
        cabins: scope.cabins,
        viewedCabinId: scope.viewedCabinId,
        onCabinTap: notifier.viewCabin,
        interior: CabinOverviewSelectionPanel(
          key: ValueKey(scope.viewedCabinId),
          cabin: scope.viewedCabin,
          // State istasyonun tüm gruplarını taşır — yalnızca görüntülenen
          // kabinin çekmeceleri çizilir.
          groups: scope.viewedGroups,
          assignments: assignments,
          // Serumda raf değil avadanlık seçilidir — raf (unit) vurgulanmaz.
          selectedUnitIds: selectedUnitId != null && selectedCellId == null ? {selectedUnitId} : const {},
          selectedCellIds: selectedCellId != null ? {selectedCellId} : const {},
          onCellTap: (unit) => notifier.onCellTap(unit, null),
          onSerumTrayTap: (shelf, tray) {
            final cellId = tray.id;
            if (cellId == null || !tray.size.isOpenShelf) {
              notifier.onSerumTrayTap(shelf, tray);
              return;
            }
            // Açık Raf: raftaki ilaçlardan biri düzenlenir ya da rafa yeni ilaç eklenir.
            showOpenShelfDialog(
              context: context,
              shelfNo: shelf.orderNo ?? 0,
              assignments: AssignmentSelection.serumAssignments(cellId, assignments),
              onOpen: (a) => notifier.onSerumTrayTap(shelf, tray, existing: a),
              onAdd: () => notifier.onSerumTrayTap(shelf, tray),
            );
          },
        ),
      ),
      right: switch (state) {
        DrugAssignmentCellSelected s => _AssignmentEditPanel(state: s, notifier: notifier),
        DrugAssignmentSaving() => const Center(child: MedLoadingIndicator()),
        _ => _AssignmentIdlePanel(
          assignments: scope.filtered(idle?.visibleAssignments ?? const []),
          groups: groups,
          onEdit: notifier.editAssignment,
          menu: widget.stationContext.menu,
          onAssignmentSearchChanged: (value) => notifier.onAssignmentSearchChanged(value),
          cabins: scope.cabins,
          cabinFilter: scope.cabinFilter,
          onCabinFilterChanged: notifier.setCabinFilter,
          cabinLabelOf: scope.cabins.length > 1 ? scope.cabinNameOf : null,
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
