import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/core.dart';
import '../../../../core/widgets/form/form_inputs/time_input_field.dart';
import '../notifier/update_prescription_item_notifier.dart';

class UpdatePrescriptionItemView extends StatelessWidget {
  const UpdatePrescriptionItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatePrescriptionItemNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          maxHeight: 700,
          title: 'Reçete Düzenle',
          isLoading: notifier.isSubmitting,
          onSave: () async {
            await notifier.submit();

            if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
              MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
              context.pop(true);
            } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
              MessageUtils.showErrorDialog(context, notifier.statusMessage);
            }
          },
          child: Column(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              _DrugNameField(notifier.prescriptionItem.medicine?.name),
              Row(
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _DoseField(),
                  _TimeField(),
                ],
              ),
              Row(
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _ApplicationDateField(),
                  _ApplicationTimeField(),
                ],
              ),
              _DescriptionField(),
              _CheckboxSection(),
            ],
          ),
        );
      },
    );
  }
}

class _DrugNameField extends StatelessWidget {
  const _DrugNameField(this.drugName);

  final String? drugName;

  @override
  Widget build(BuildContext context) {
    return Lockable(
      locked: true,
      child: TextInputField(
        label: 'İlaç Adı',
        initialValue: drugName,
        onChanged: (_) {},
      ),
    );
  }
}

class _DoseField extends StatelessWidget {
  const _DoseField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<UpdatePrescriptionItemNotifier>(builder: (context, vm, _) {
        return TextInputField(
          label: 'Doz',
          initialValue: vm.prescriptionItem.dosePiece.toCustomString(),
          onChanged: (value) => vm.updateDose(value),
        );
      }),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<UpdatePrescriptionItemNotifier>(
        builder: (context, notifier, _) {
          return TimeInputField(
            label: 'Saat',
            initialValue: notifier.prescriptionItem.time.toTimeOfDay,
            onTimeSelected: (time) => notifier.updateTime(time),
          );
        },
      ),
    );
  }
}

class _ApplicationDateField extends StatelessWidget {
  const _ApplicationDateField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<UpdatePrescriptionItemNotifier>(builder: (context, notifier, _) {
        return DateInputField(
          label: 'Uygulama Tarihi',
          onDateSelected: notifier.updateDate,
          initialValue: notifier.prescriptionItem.applicationDate,
        );
      }),
    );
  }
}

class _ApplicationTimeField extends StatelessWidget {
  const _ApplicationTimeField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<UpdatePrescriptionItemNotifier>(
        builder: (context, notifier, _) {
          return TimeInputField(
            label: 'Saat',
            initialValue: notifier.prescriptionItem.time.toTimeOfDay,
            onTimeSelected: notifier.updateApplicationTime,
          );
        },
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatePrescriptionItemNotifier>(builder: (context, vm, _) {
      return TextInputField(
        label: 'Açıklama',
        maxLines: 3,
        initialValue: vm.prescriptionItem.dosePiece.toCustomString(),
        onChanged: (value) => vm.updateDescription(value),
      );
    });
  }
}

class _CheckboxSection extends StatelessWidget {
  const _CheckboxSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatePrescriptionItemNotifier>(builder: (context, vm, _) {
      return Row(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          CustomCheckboxTile(
            label: 'İlk Doz Acil',
            value: vm.prescriptionItem.firstDoseEmergency ?? false,
            onTap: () => vm.toggleEmergency(),
          ),
          CustomCheckboxTile(
            label: 'Doktora Sor',
            value: vm.prescriptionItem.askDoctor ?? false,
            onTap: () => vm.toggleAskDoctor(),
          ),
          CustomCheckboxTile(
            label: 'Lüzumu Halinde',
            value: vm.prescriptionItem.inCaseOfNecessity ?? false,
            onTap: () => vm.toggleNecessity(),
          )
        ],
      );
    });
  }
}
