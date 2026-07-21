import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../widgets/side_panel.dart';
import '../../dosage_form/view/dosage_form_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../../unit/view/unit_view.dart';

import '../notifier/drug_form_notifier.dart';
import '../notifier/medicine_notifier.dart';

part '../widgets/checkbox_section.dart';
part '../widgets/personel_field.dart';
part '../widgets/station_field.dart';
part '../widgets/unit_field.dart';

class DrugFormPanel extends StatelessWidget {
  const DrugFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final medicineNotifier = context.watch<MedicineNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = medicineNotifier.selectedMedicine == null;
    final selectedMedicine = medicineNotifier.selectedMedicine;

    return ChangeNotifierProvider(
      key: ValueKey(selectedMedicine?.id ?? 'create'),
      create: (BuildContext context) => DrugFormNotifier(
        createMedicineUseCase: context.read(),
        updateMedicineUseCase: context.read(),
        getDrugUseCase: context.read(),
        getActiveIngredientsUseCase: context.read(),
        userRepository: context.read(),
        stationRepository: context.read(),
        drug: selectedMedicine as Drug?,
      ),
      child: Consumer<DrugFormNotifier>(
        builder: (context, formNotifier, _) {
          return SidePanel(
            title: isNew ? context.l10n.medicine_formTitleNew : context.l10n.medicine_formTitleEdit,
            subtitle: isNew ? context.l10n.medicine_formSubtitleNew : context.l10n.medicine_formSubtitleEdit,
            isLoading: formNotifier.isSubmitting,
            onClose: medicineNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await formNotifier.submit();

                if (context.mounted && formNotifier.isSuccess(formNotifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, formNotifier.statusMessage);
                  medicineNotifier.closePanel();
                  medicineNotifier.fetch();
                } else if (context.mounted && formNotifier.isFailed(formNotifier.submitOp)) {
                  MessageUtils.showErrorDialog(context, formNotifier.statusMessage);
                }
              } else {
                MessageUtils.showErrorDialog(context, context.l10n.common_requiredFieldsError);
              }
            },
            child: Form(key: formKey, child: _dialogBody(formNotifier)),
          );
        },
      ),
    );
  }

  Widget _dialogBody(DrugFormNotifier vm) {
    if (vm.isFetching) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return _formBody(5, 2);
  }

  Widget _formBody(int firstColumnFlex, int secondColumnFlex) {
    return SingleChildScrollView(
      child: Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(
                flex: firstColumnFlex,
                child: Column(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    _definitionNameField(),
                    _nameField(),
                    _prescriptionTypeField(),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        Expanded(child: _drugTypeField()),
                        Expanded(child: _drugClassField()),
                      ],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        Expanded(child: _doseField()),
                        Expanded(child: _volumeField()),
                      ],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        Expanded(child: _measurementUnitField()),
                        Expanded(child: _maxUsageField()),
                      ],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        Expanded(child: _qrCodeField()),
                        Expanded(child: _dosageFormField()),
                      ],
                    ),
                    _buildWitnessedPurchaseField(),
                    _buildWastageWitnessedPurchaseField(),
                    _buildDestroyableField(),
                    CheckboxSection(),
                  ],
                ),
              ),
              Expanded(
                flex: secondColumnFlex,
                child: Column(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    _barcodeField(),
                    _codeField(),
                    _atcCodeField(),
                    _equivalentCodeField(),
                    _manifacturerField(),
                    _countTypeField(),
                    _statusField(),
                    _buildActiveIngredientField(),
                    _purchaseTypeField(),
                    _returnTypeField(),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: AppDimensions.registrationDialogSpacing,
            children: [
              Expanded(child: _buildCollectNoteField()),
              Expanded(child: _buildReturnNoteField()),
              Expanded(child: _buildDestructionNoteField()),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _definitionNameField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDefinitionName,
        initialValue: vm.drug.definition,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateDefinitionName(value),
      );
    },
  );
}

Widget _barcodeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldBarcode,
        initialValue: vm.drug.barcode,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateBarcode(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _nameField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldName,
        initialValue: vm.drug.name,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateName(value),
      );
    },
  );
}

Widget _codeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldCode,
        initialValue: vm.drug.code,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateCode(value),
      );
    },
  );
}

Widget _prescriptionTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<PrescriptionType>(
        label: context.l10n.medicine_fieldPrescriptionType,
        options: PrescriptionType.values,
        initialValue: vm.drug.prescriptionType,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.label),
        onChanged: (value) => vm.updatePrescriptionType(value),
      );
    },
  );
}

Widget _doseField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Row(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Expanded(
            child: MedTextInputField(
              label: context.l10n.medicine_fieldDose,
              initialValue: vm.drug.dose.toCustomString(),
              keyboardType: TextInputType.number,
              validator: (value) => Validators.cannotBlankValidator(value),
              onChanged: (value) => vm.updateDose(value),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          Expanded(
            child: UnitField(
              key: ObjectKey(vm.drug.doseUnit),
              unit: vm.drug.doseUnit,
              onChanged: (value) => vm.updateDoseUnit(value),
              isRequired: true,
            ),
          ),
        ],
      );
    },
  );
}

Widget _manifacturerField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final label = context.l10n.medicine_fieldManufacturer;
      return MedSelectionField<Firm>(
        label: label,
        title: label,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        initialValue: vm.drug.firm,
        labelBuilder: (value) => value.name,
        dataSource: (skip, take, search) =>
            context.read<GetFirmsUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
        onSelected: vm.updateFirm,
      );
    },
  );
}

// Kabinden ilaç alım yapılırken bu miktardan fazla ilaç verilmeyecek.
// Birimi, ilacın birimiyle aynı olacak. ml -> ml
Widget _maxUsageField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDailyMaxUsage,
        suffix: Text(vm.drug.doseUnit?.title.toLowerCase() ?? ''),
        keyboardType: const TextInputType.numberWithOptions(),
        initialValue: vm.drug.dailyMaxUsage.toCustomString(),
        onChanged: vm.updateDailyUsage,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _drugTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final label = context.l10n.medicine_fieldDrugType;
      return MedSelectionField<DrugType>(
        label: label,
        title: label,
        initialValue: vm.drug.drugType,
        labelBuilder: (value) => value.name,
        onSelected: vm.updateDrugType,
        dataSource: (skip, take, search) =>
            context.read<GetDrugTypesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
        validator: (value) => Validators.cannotBlankValidator(value?.name),
      );
    },
  );
}

Widget _returnTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          MedDropdownInputField<ReturnType>(
            label: context.l10n.medicine_fieldReturnType,
            options: ReturnType.values,
            initialValue: vm.drug.returnType,
            labelBuilder: (value) => value?.label,
            validator: (value) => Validators.cannotBlankValidator(value?.label),
            onChanged: vm.updateReturnType,
          ),
          if (vm.drug.returnType == ReturnType.toOrigin)
            Column(
              children: [
                MedCheckboxField(
                  label: context.l10n.medicine_checkboxSerumMaxValue,
                  value: vm.drug.isNotSerumCabinetMaxValue,
                  onChanged: (_) => vm.toggleSerumMaxValue(),
                ),
                MedCheckboxField(
                  label: context.l10n.medicine_checkboxCubicMaxValue,
                  value: vm.drug.isNotCubicDrawrMaxValue,
                  onChanged: (_) => vm.toggleCubicMaxValue(),
                ),
              ],
            ),
        ],
      );
    },
  );
}

Widget _qrCodeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: MedCheckboxField(
              label: context.l10n.medicine_checkboxQrCode,
              value: vm.drug.isQrCode,
              onChanged: (_) => vm.toggleQr(),
            ),
          ),
          Expanded(
            child: MedDropdownInputField(
              label: context.l10n.medicine_fieldPieceCountLabel,
              enabled: vm.drug.isQrCode,
              initialValue: vm.drug.piece?.toInt() ?? 1,
              onChanged: vm.updatePiece,
              options: [1, 2, 3, 4, 5],
              labelBuilder: (count) => count?.toString() ?? '1',
              validator: (count) => Validators.cannotBlankValidator(count.toString()),
            ),
          ),
        ],
      );
    },
  );
}

Widget _drugClassField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final label = context.l10n.medicine_fieldDrugClass;
      return MedSelectionField<DrugClass>(
        label: label,
        title: label,
        initialValue: vm.drug.drugClass,
        labelBuilder: (value) => value.name,
        dataSource: (skip, take, search) =>
            context.read<GetDrugClassUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
        onSelected: vm.updateDrugClass,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
      );
    },
  );
}

Widget _purchaseTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.purchaseType != PurchaseType.ordered;
      return Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          MedDropdownInputField<PurchaseType>(
            label: context.l10n.medicine_fieldPurchaseType,
            options: PurchaseType.values,
            initialValue: vm.drug.purchaseType,
            labelBuilder: (type) => type?.label,
            onChanged: vm.updatePurchaseType,
          ),
          if (enabled)
            PersonelField(
              key: ValueKey(vm.drug.materialOrderlessTakingUsers),
              enabled: enabled,
              requireValidation: enabled,
              initialValue: vm.drug.materialOrderlessTakingUsers,
              onChanged: vm.updateOrderlessUsers,
            ),
        ],
      );
    },
  );
}

Widget _measurementUnitField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool isRequired = vm.drug.isMeasureUnit;
      return Row(
        children: [
          Expanded(
            child: MedCheckboxField(
              label: context.l10n.medicine_checkboxUseMeasurementUnit,
              value: vm.drug.isMeasureUnit,
              onChanged: (_) => vm.toggleMeasurement(),
            ),
          ),
          Expanded(
            child: Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  child: MedTextInputField(
                    label: context.l10n.medicine_fieldDose,
                    enabled: isRequired,
                    initialValue: vm.drug.doseMeasureUnit.toCustomString(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: vm.drug.isMeasureUnit ? Validators.cannotBlankValidator : null,
                    onChanged: vm.updateMeasurementDose,
                  ),
                ),
                Expanded(
                  child: IgnorePointer(
                    ignoring: !isRequired,
                    child: UnitField(
                      key: ObjectKey(vm.drug.doseMeasureUnit),
                      unit: vm.drug.unitMeasure,
                      enabled: vm.drug.isMeasureUnit,
                      onChanged: (value) => vm.updateDoseUnit(value),
                      isRequired: isRequired,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Widget _volumeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Row(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Expanded(
            child: MedTextInputField(
              label: context.l10n.medicine_fieldVolume,
              onChanged: vm.updateVolume,
              initialValue: vm.drug.volume.toCustomString(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => Validators.cannotBlankValidator(value),
            ),
          ),
          Expanded(
            child: UnitField(
              key: ObjectKey(vm.drug.volumeUnit),
              unit: vm.drug.volumeUnit,
              onChanged: vm.updateVolumeUnit,
              isRequired: true,
            ),
          ),
        ],
      );
    },
  );
}

Widget _dosageFormField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        key: ObjectKey(vm.drug.dosageForm),
        label: context.l10n.medicine_fieldDosageForm,
        validator: (value) => Validators.cannotBlankValidator(value),
        readOnly: true,
        initialValue: vm.drug.dosageForm?.name,
        onTap: () async {
          final df = await showDosageFormView(context);
          vm.updateDosageForm(df);
        },
        onChanged: (String? value) {},
      );
    },
  );
}

Widget _statusField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<Status>(
        label: context.l10n.medicine_fieldStatus,
        options: Status.values,
        initialValue: statusFromBool(vm.drug.isActive),
        labelBuilder: (value) => value?.label,
        onChanged: vm.updateStatus,
      );
    },
  );
}

Widget _countTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<CountType>(
        label: context.l10n.medicine_fieldCountType,
        options: CountType.values,
        initialValue: vm.drug.countType,
        labelBuilder: (value) => value?.label,
        onChanged: vm.updateCountType,
      );
    },
  );
}

Widget _atcCodeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldAtcCode,
        onChanged: vm.updateAtcCode,
        initialValue: vm.drug.atcCode.toCustomString(),
        validator: Validators.cannotBlankValidator,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _equivalentCodeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldEquivalentCode,
        onChanged: vm.updateEquivalentCode,
        initialValue: vm.drug.equivalentCode,
      );
    },
  );
}

Widget _buildWitnessedPurchaseField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isWitnessedPurchase;
      return Row(
        children: [
          Expanded(
            child: MedCheckboxField(
              label: context.l10n.medicine_checkboxWitnessedPurchase,
              value: vm.drug.isWitnessedPurchase,
              onChanged: (_) => vm.toggleWitnessedPurchase(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  child: PersonelField(
                    key: ValueKey(vm.drug.witnessedPurchaseUsers),
                    enabled: enabled,
                    initialValue: vm.drug.witnessedPurchaseUsers,
                    onChanged: vm.updateWitnessedPurchaseUsers,
                  ),
                ),
                Expanded(
                  child: StationField(
                    key: ValueKey(vm.drug.witnessedPurchaseStations),
                    initialValue: vm.drug.witnessedPurchaseStations,
                    enabled: enabled,
                    requireValidation: vm.drug.isWitnessedPurchase,
                    onChanged: vm.updateWitnessedPurchaseStations,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildWastageWitnessedPurchaseField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isWastageWitnessedPurchase;
      return Row(
        children: [
          Expanded(
            child: MedCheckboxField(
              label: context.l10n.medicine_checkboxWastageWitnessed,
              value: vm.drug.isWastageWitnessedPurchase,
              onChanged: (_) => vm.toggleWastageWitnessedPurchase(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  child: PersonelField(
                    key: ValueKey(vm.drug.wastageWitnessedPurchaseUsers),
                    enabled: enabled,
                    initialValue: vm.drug.wastageWitnessedPurchaseUsers,
                    onChanged: vm.updateWastageWitnessedPurchaseUsers,
                  ),
                ),
                Expanded(
                  child: StationField(
                    key: ValueKey(vm.drug.wastageWitnessedPurchaseStations),
                    enabled: enabled,
                    requireValidation: vm.drug.isWastageWitnessedPurchase,
                    initialValue: vm.drug.wastageWitnessedPurchaseStations,
                    onChanged: vm.updateWastageWitnessedPurchaseStations,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildDestroyableField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isDestroyable;
      return Row(
        children: [
          Expanded(
            child: MedCheckboxField(
              label: context.l10n.medicine_checkboxDestroyable,
              value: vm.drug.isDestroyable,
              onChanged: (_) => vm.toggleIsDestroyable(),
            ),
          ),
          Expanded(
            flex: 3,
            child: PersonelField(
              key: ValueKey(vm.drug.destroyableUsers),
              enabled: enabled,
              initialValue: vm.drug.destroyableUsers,
              onChanged: vm.updateDestroyableUsers,
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildActiveIngredientField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final label = context.l10n.medicine_fieldActiveIngredient;
      return MedMultiSelectionField<ActiveIngredient>(
        key: ObjectKey(vm.activeIngredients),
        label: label,
        title: label,
        initialValue: vm.activeIngredients,
        labelBuilder: (value) => value.name,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            return Validators.cannotBlankValidator(value.first.name);
          } else {
            return Validators.cannotBlankValidator(null);
          }
        },
        dataSource: (skip, take, search) => context.read<GetActiveIngredientsUseCase>().call(
          PagedQueryParams(skip: skip, take: take, searchQuery: search),
        ),
        onSelected: vm.updateActiveIngredients,
      );
    },
  );
}

Widget _buildCollectNoteField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldCollectNote,
        initialValue: vm.drug.collectNote,
        onChanged: vm.updateCollectNote,
      );
    },
  );
}

Widget _buildReturnNoteField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldReturnNote,
        initialValue: vm.drug.collectNote,
        onChanged: vm.updateReturnNote,
      );
    },
  );
}

Widget _buildDestructionNoteField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDestructionNote,
        initialValue: vm.drug.destructionNote,
        onChanged: vm.updateDestructionNote,
      );
    },
  );
}
