import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../active_ingredient/domain/entity/active_ingredient.dart';
import '../../../active_ingredient/domain/repository/i_active_ingredient_repository.dart';
import '../../../dosage_form/presentation/view/dosage_form_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';

import '../../../drug_class/domain/entity/drug_class.dart';
import '../../../drug_class/domain/repository/i_drug_class_repository.dart';
import '../../../drug_type/domain/entity/drug_type.dart';
import '../../../drug_type/domain/repository/i_drug_type_repository.dart';
import '../../../firm/domain/entity/firm.dart';
import '../../../firm/domain/repository/i_firm_repository.dart';
import '../../../station/domain/entity/station.dart';
import '../../../station/domain/usecase/get_stations_usecase.dart';
import '../../../unit/domain/entity/unit.dart';
import '../../../unit/presentation/view/unit_view.dart';
import '../../domain/entity/medicine.dart';
import '../notifier/drug_form_notifier.dart';

part '../widgets/checkbox_section.dart';
part '../widgets/personel_field.dart';
part '../widgets/station_field.dart';
part '../widgets/unit_field.dart';

Future<bool> showDrugFormView(BuildContext context, {Drug? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => DrugFormNotifier(
        drug: initial,
        getActiveIngredientsUseCase: context.read(),
        userRepository: context.read(),
        stationRepository: context.read(),
        createMedicineUseCase: context.read(),
        updateMedicineUseCase: context.read(),
        getDrugUseCase: context.read(),
      ),
      child: DrugFormView(),
    ),
  );

  return result ?? false;
}

class DrugFormView extends StatefulWidget {
  const DrugFormView({super.key});

  @override
  State<DrugFormView> createState() => _DrugFormViewState();
}

class _DrugFormViewState extends State<DrugFormView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (BuildContext context, notifier, _) {
        return RegistrationDialog(
          title: 'İlaç Ekle/Düzenle',
          width: context.width * 0.9,
          maxHeight: context.height * 0.9,
          isLoading: notifier.isSubmitting,
          onSave: () {
            if (!formKey.currentState!.validate()) {
              MessageUtils.showErrorDialog(context, 'Lütfen zorunlu alanları doldurunuz.');
            } else {
              notifier.submit(
                onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
                onSuccess: (message) {
                  MessageUtils.showSuccessSnackbar(context, message);
                  context.pop(true);
                },
              );
            }
          },
          child: Form(key: formKey, child: _dialogBody(notifier)),
        );
      },
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
  final label = 'Tanım Adı';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.drug.definition,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateDefinitionName(value),
      );
    },
  );
}

Widget _barcodeField() {
  final label = 'Barkod';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.drug.barcode,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateBarcode(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _nameField() {
  final label = 'İlaç Adı';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.drug.name,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateName(value),
      );
    },
  );
}

Widget _codeField() {
  final label = 'İlaç Kodu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.drug.code,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateCode(value),
      );
    },
  );
}

Widget _prescriptionTypeField() {
  final label = 'Reçete Tipi';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<PrescriptionType>(
        label: label,
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
  final label = 'Doz';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Row(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Expanded(
            child: TextInputField(
              label: label,
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
  final label = 'Üretici Firma';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DialogInputField<Firm>(
        label: label,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        initialValue: vm.drug.firm,
        labelBuilder: (value) => value?.name,
        future: () => context.read<IFirmRepository>().getFirms(),
        onSelected: vm.updateFirm,
      );
    },
  );
}

// Kabinden ilaç alım yapılırken bu miktardan fazla ilaç verilmeyecek.
// Birimi, ilacın birimiyle aynı olacak. ml -> ml
Widget _maxUsageField() {
  final label = 'Günlük Maks. Kullanım Miktarı';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
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
  final label = 'İlaç Tipi';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DialogInputField<DrugType>(
        label: label,
        initialValue: vm.drug.drugType,
        labelBuilder: (value) => value?.name,
        onSelected: vm.updateDrugType,
        future: () => context.read<IDrugTypeRepository>().getDrugTypes(),
        validator: (value) => Validators.cannotBlankValidator(value?.name),
      );
    },
  );
}

Widget _returnTypeField() {
  final label = 'İade Şekli';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          DropdownInputField<ReturnType>(
            label: label,
            options: ReturnType.values,
            initialValue: vm.drug.returnType,
            labelBuilder: (value) => value?.label,
            validator: (value) => Validators.cannotBlankValidator(value?.label),
            onChanged: vm.updateReturnType,
          ),
          if (vm.drug.returnType == ReturnType.toOrigin)
            Column(
              spacing: AppDimensions.registrationDialogSpacing / 2,
              children: [
                CustomCheckboxTile(
                  label: 'Serum kabininde maks. değere bakma',
                  value: vm.drug.isNotSerumCabinetMaxValue,
                  onTap: vm.toggleSerumMaxValue,
                ),
                CustomCheckboxTile(
                  label: 'Kübik çekmecede maks. değere bakma',
                  value: vm.drug.isNotCubicDrawrMaxValue,
                  onTap: vm.toggleCubicMaxValue,
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
            child: CustomCheckboxTile(label: 'Karekodlu', value: vm.drug.isQrCode, onTap: () => vm.toggleQr()),
          ),
          Expanded(
            child: DropdownInputField(
              label: 'Adet',
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
  final label = 'İlaç Sınıfı';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DialogInputField<DrugClass>(
        label: label,
        initialValue: vm.drug.drugClass,
        labelBuilder: (value) => value?.name,
        future: () => context.read<IDrugClassRepository>().getDrugClasses(),
        onSelected: vm.updateDrugClass,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
      );
    },
  );
}

Widget _purchaseTypeField() {
  final label = 'Alım Şekli';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.purchaseType != PurchaseType.ordered;
      return Column(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          DropdownInputField<PurchaseType>(
            label: label,
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
  final label = 'Ölçü Birimi Kullan';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool isRequired = vm.drug.isMeasureUnit;
      return Row(
        children: [
          Expanded(
            child: CustomCheckboxTile(label: label, value: vm.drug.isMeasureUnit, onTap: vm.toggleMeasurement),
          ),
          Expanded(
            child: Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'Doz',
                    enabled: isRequired,
                    initialValue: vm.drug.doseMeasureUnit.toCustomString(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: vm.drug.isMeasureUnit ? Validators.cannotBlankValidator : null,
                    onChanged: vm.updateMeasurementDose,
                  ),
                ),
                Expanded(
                  child: Lockable(
                    locked: !isRequired,
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
  final label = 'Hacim';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return Row(
        spacing: AppDimensions.registrationDialogSpacing,
        children: [
          Expanded(
            child: TextInputField(
              label: label,
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
  final label = 'Dozaj Formu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        key: ObjectKey(vm.drug.dosageForm),
        label: label,
        validator: (value) => Validators.cannotBlankValidator(value),
        readOnly: true,
        suffix: Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: context.colorScheme.onSurfaceVariant),
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
  final label = 'Durumu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<Status>(
        label: label,
        options: Status.values,
        initialValue: statusFromBool(vm.drug.isActive),
        labelBuilder: (value) => value?.label,
        onChanged: vm.updateStatus,
      );
    },
  );
}

Widget _countTypeField() {
  final label = 'Sayım Tipi';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<CountType>(
        label: label,
        options: CountType.values,
        initialValue: vm.drug.countType,
        labelBuilder: (value) => value?.label,
        onChanged: vm.updateCountType,
      );
    },
  );
}

Widget _atcCodeField() {
  final label = 'ATC Kodu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        onChanged: vm.updateAtcCode,
        initialValue: vm.drug.atcCode.toCustomString(),
        validator: Validators.cannotBlankValidator,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _equivalentCodeField() {
  final label = 'Eşdeğer Kod';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(label: label, onChanged: vm.updateEquivalentCode, initialValue: vm.drug.equivalentCode);
    },
  );
}

Widget _buildWitnessedPurchaseField() {
  final label = 'Şahitli Alım';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isWitnessedPurchase;
      return Row(
        children: [
          Expanded(
            child: CustomCheckboxTile(
              label: label,
              value: vm.drug.isWitnessedPurchase,
              onTap: vm.toggleWitnessedPurchase,
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
  final label = 'Fire/İmha Şahitli';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isWastageWitnessedPurchase;
      return Row(
        children: [
          Expanded(
            child: CustomCheckboxTile(
              label: label,
              value: vm.drug.isWastageWitnessedPurchase,
              onTap: vm.toggleWastageWitnessedPurchase,
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
  final label = 'İmha Edilebilir';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      bool enabled = vm.drug.isDestroyable;
      return Row(
        children: [
          Expanded(
            child: CustomCheckboxTile(label: label, value: vm.drug.isDestroyable, onTap: vm.toggleIsDestroyable),
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
  final label = 'Etken Madde';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MultiDialogInputField<ActiveIngredient>(
        key: ObjectKey(vm.activeIngredients),
        label: label,
        initialValue: vm.activeIngredients,
        labelBuilder: (value) => value?.name,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            return Validators.cannotBlankValidator(value.first.name);
          } else {
            return Validators.cannotBlankValidator(null);
          }
        },
        future: () => context.read<IActiveIngredientRepository>().getActiveIngredients(),
        onSelected: vm.updateActiveIngredients,
      );
    },
  );
}

Widget _buildCollectNoteField() {
  final label = 'Alım Notu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(label: label, initialValue: vm.drug.collectNote, onChanged: vm.updateCollectNote);
    },
  );
}

Widget _buildReturnNoteField() {
  final label = 'İade Notu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(label: label, initialValue: vm.drug.collectNote, onChanged: vm.updateReturnNote);
    },
  );
}

Widget _buildDestructionNoteField() {
  final label = 'İmha Notu';

  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(label: label, initialValue: vm.drug.destructionNote, onChanged: vm.updateDestructionNote);
    },
  );
}
