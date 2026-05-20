import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../../cabin_inventory/view/cabin_inventory_view.dart';
import '../../cabin_process/view/cabin_process_wrapper.dart';
import '../notifier/cabin_assignment_picker_notifier.dart';

part 'ratio_progress_indicator.dart';
part 'medicine_list_view.dart';
part 'selected_medicines_list_view.dart';

class CabinAssignmentPickerView extends StatelessWidget {
  const CabinAssignmentPickerView({super.key, required this.type});

  final CabinInventoryType type;

  static const Duration _kProcessCompletedDelay = Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return CabinProcessWrapper(
      onDrawerReady: (ctx, initial) async {
        final notifier = context.read<CabinAssignmentPickerNotifier>();

        final item = notifier.externalAssignments?.where((i) => i.id == initial.id).first;
        final fillingQuantity = item?.fillingQuantity?.toDouble();
        final result = await showCabinInventoryView(
          context,
          inventoryType: type,
          initial: initial,
          quantity: initial.totalQuantity,
          plannedQuantity: fillingQuantity,
          onSave: (inputs) => notifier.onSave(inputs),
        );
        notifier.isProcessCompleted = result;
        return result;
      },
      onProcessCompleted: (assignment, isSuccess) async {
        final notifier = context.read<CabinAssignmentPickerNotifier>();

        if (assignment != null) {
          notifier.markCurrentAsDone(assignment, isSuccess: isSuccess);
        }
        await Future.delayed(_kProcessCompletedDelay);
        if (notifier.isAutoProcessing) {
          notifier.proceedToNext();
        } else {
          notifier.getAssignments();
        }
      },
      child: Consumer<CabinAssignmentPickerNotifier>(
        builder: (context, notifier, _) {
          notifier.onExecuteNext = (assignment) {
            //context.read<CabinStatusNotifier>().startOperation(assignment);
          };

          return Row(
            spacing: 16,
            children: [
              Expanded(flex: 4, child: MedicineListView(type: type)),
              Container(width: 1, color: context.colorScheme.outlineVariant.withAlpha(60)),
              Expanded(flex: 2, child: SelectedMedicinesListView(type: type)),
            ],
          );
        },
      ),
    );
  }
}
