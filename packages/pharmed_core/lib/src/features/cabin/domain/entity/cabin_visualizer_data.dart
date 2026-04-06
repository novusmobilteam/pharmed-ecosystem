import 'package:pharmed_core/pharmed_core.dart';

class CabinVisualizerData {
  const CabinVisualizerData({
    required this.cabinId,
    required this.slots,
    required this.isStale,
    required this.groups,
    required this.stocks,
  });

  final int cabinId;
  final List<DrawerSlotVisual> slots;
  final List<DrawerGroup> groups;
  final List<CabinStock> stocks;
  final bool isStale;

  List<DrawerStatus> get _allCells => slots
      .expand(
        (s) => switch (s) {
          KubicSlotVisual(:final cells) => cells,
          UnitDoseSlotVisual(:final cells) => cells,
          SerumSlotVisual(:final status) => [status],
        },
      )
      .toList();

  int get totalDrawers => _allCells.length;
  int get fullDrawers => _allCells.where((s) => s == DrawerStatus.full).length;
  int get emptyDrawers => _allCells.where((s) => s == DrawerStatus.empty).length;
  int get criticalCount => _allCells.where((s) => s == DrawerStatus.critical).length;
}
