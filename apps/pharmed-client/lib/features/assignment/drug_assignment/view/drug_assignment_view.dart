import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/cabin_operation_widget.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_client/widgets/pagination_bar.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/drug_assignment_notifier.dart';
import 'package:provider/provider.dart';

import 'med_labeled_dose_stepper.dart';

part 'assignment_section.dart';
part 'initial_section.dart';

class DrugAssignmentView extends StatelessWidget {
  const DrugAssignmentView({super.key, required this.data});

  final CabinVisualizerData data;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DrugAssignmentNotifier>(
      create: (_) => DrugAssignmentNotifier(
        getAssignments: context.read(),
        createAssignment: context.read(),
        updateAssignment: context.read(),
        deleteAssignment: context.read(),
        getDrugs: context.read(),
      )..init(data),
      child: Consumer<DrugAssignmentNotifier>(
        builder: (BuildContext context, DrugAssignmentNotifier notifier, Widget? child) {
          if (notifier.isLoading(notifier.fetchAssignmentOp) && notifier.assignments.isEmpty) {
            return Center(child: MedLoadingIndicator());
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: CabinOperationWidget(
                  groups: notifier.groups,
                  assignments: notifier.assignments,
                  selectedUnitIds: notifier.selectedUnitId != null ? {notifier.selectedUnitId!} : {},
                  onCellTap: notifier.onCellTap,
                ),
              ),
              VerticalDivider(color: MedColors.border, width: 1, thickness: 1),
              Expanded(
                flex: 7,
                child: Container(
                  margin: MedSpacing.insetXl,
                  child: notifier.isCellSelected
                      ? AssignmentSection(assignment: notifier.selectedAssignment, onClear: notifier.clearSelection)
                      : InitialSection(
                          assignments: notifier.assignments,
                          onRowTap: (unit, stepNo) => notifier.onCellTap(unit),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
