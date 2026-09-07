import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/assignment/notifier/drug_assignment_form_notifier.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

class DrugAssignmentFormDialog extends StatelessWidget {
  const DrugAssignmentFormDialog({
    super.key,
    required this.cabinId,
    required this.unit,
    this.existingAssignment,
    required this.onSuccess,
  });

  final int cabinId;
  final DrawerUnit unit;
  final MedicineAssignment? existingAssignment;
  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context) {
    final suffixText =
        existingAssignment?.medicine?.fillingUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    final suffix = Text(
      suffixText,
      style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
    );

    return ChangeNotifierProvider(
      create: (context) => DrugAssignmentFormNotifier(
        createAssignmentUseCase: context.read(),
        updateAssignmentUseCase: context.read(),
        assignment: existingAssignment,
        cabinId: cabinId,
        unitId: unit.id,
      ),
      child: Consumer<DrugAssignmentFormNotifier>(
        builder: (context, notifier, _) {
          return MedDialog(
            title: context.l10n.assignment_idle_title,
            width: 550,
            maxHeightFactor: 0.35,
            onClose: () => Navigator.of(context).pop(),
            child: Column(
              spacing: 6.0,
              children: [
                MedSelectionField(
                  label: context.l10n.assignment_idle_columnDrug,
                  initialValue: notifier.assignment?.medicine,
                  dataSource: (_, _, _) => context.read<GetMedicinesUseCase>().call(PagedQueryParams()),
                  labelBuilder: (medicine) => medicine.name,
                  onSelected: notifier.updateMedicine,
                ),
                Row(
                  spacing: 6.0,
                  children: [
                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.common_minLabel,
                        initialValue: notifier.assignment?.minQuantityFromBackend.formatFractional,
                        onChanged: (value) => notifier.updateMinQuantity(value),
                        suffix: suffix,
                      ),
                    ),

                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.common_criticalLabel,
                        initialValue: notifier.assignment?.critQuantityFromBackend.formatFractional,
                        onChanged: (value) => notifier.updateCritQuantity(value),
                        suffix: suffix,
                      ),
                    ),

                    Expanded(
                      child: MedTextInputField(
                        label: context.l10n.common_maxLabel,
                        initialValue: notifier.assignment?.maxQuantityFromBackend.formatFractional,
                        onChanged: (value) => notifier.updateMaxQuantity(value),
                        suffix: suffix,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                MedButton(
                  label: context.l10n.assignment_edit_saveButton,
                  fullWidth: true,
                  isActive: notifier.canSave,
                  isLoading: notifier.isSubmitting,
                  onPressed: () {
                    notifier.submit(
                      onSuccess: () {
                        MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                        Navigator.of(context).pop();
                        onSuccess.call();
                      },
                      onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
