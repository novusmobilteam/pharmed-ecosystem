import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../cabin/domain/entity/drawer_unit.dart';
import '../../../cabin/shared/widgets/cabin_editor/cabin_editor_view.dart';
import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../cabin_assignment/presentation/widgets/assignment_cell.dart';
import '../notifier/cabin_stock_notifier.dart';

part 'stock_cell.dart';

class CabinStockView extends StatelessWidget {
  const CabinStockView({super.key, this.stationId, this.onTapUnit, this.selectedAssignments, this.onDataLoaded});

  final int? stationId;

  /// Çekmece içindeki tek bir göze basıldığı zaman yapılacak işlem
  final Function(CabinAssignment assignment)? onTapUnit;
  final List<CabinAssignment>? selectedAssignments;
  final Function(List<CabinAssignment> assignments)? onDataLoaded;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        final notifier = CabinStockNotifier(
          cabinsUseCase: context.read(),
          layoutUseCase: context.read(),
          getAssignmentsUseCase: context.read(),
          getCabinsByStationUseCase: context.read(),
          onDataLoaded: onDataLoaded,
        )..initialize(stationId: stationId);

        return notifier;
      },
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    return Consumer<CabinStockNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.cabins.isEmpty) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (notifier.cabins.isEmpty) {
          return Center(child: CommonEmptyStates.noCabin());
        }

        return CabinEditorView<dynamic>(
          mode: CabinViewMode.stock,
          cabinId: notifier.selectedCabin?.id ?? 0,
          layouts: notifier.layout,
          cabins: notifier.cabins,
          selectedCabin: notifier.selectedCabin,
          onCabinChanged: notifier.onCabinChanged,
          cellData: null,
          cellBuilder: (context, unit, data) {
            final assignment = notifier.getAssignmentForUnit(unit.id);
            return GestureDetector(
              onTap: () {
                if (onTapUnit != null && assignment.totalQuantity > 0) {
                  onTapUnit!(assignment);
                }
              },
              child: StockCell(
                assignment: assignment,
                unit: unit,
                isSelected: selectedAssignments?.contains(assignment) ?? false,
              ),
            );
          },
        );
      },
    );
  }
}
