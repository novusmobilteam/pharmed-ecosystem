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
part '../widgets/form_section.dart';
part '../widgets/independent_material_field.dart';
part '../widgets/personel_field.dart';
part '../widgets/station_field.dart';
part '../widgets/unit_field.dart';

class DrugFormPanel extends StatefulWidget {
  const DrugFormPanel({super.key});

  @override
  State<DrugFormPanel> createState() => _DrugFormPanelState();
}

class _DrugFormPanelState extends State<DrugFormPanel> {
  // Form key build dışında tutulur; aksi halde MedicineNotifier her
  // tetiklendiğinde yeni key ile form state'i (validasyon) sıfırlanır.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final medicineNotifier = context.watch<MedicineNotifier>();
    final isNew = medicineNotifier.selectedMedicine == null;
    final selectedMedicine = medicineNotifier.selectedMedicine;

    return ChangeNotifierProvider(
      key: ValueKey(selectedMedicine?.id ?? 'create'),
      create: (BuildContext context) => DrugFormNotifier(
        createMedicineUseCase: context.read(),
        updateMedicineUseCase: context.read(),
        getDrugUseCase: context.read(),
        getActiveIngredientsUseCase: context.read(),
        saveIndependentServicesUseCase: context.read(),
        getServicesUseCase: context.read(),
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
              if (_formKey.currentState!.validate()) {
                await formNotifier.submit();

                if (context.mounted && formNotifier.isSuccess(formNotifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, formNotifier.statusMessage);
                  medicineNotifier.closePanel();
                  medicineNotifier.fetch();
                } else if (context.mounted && formNotifier.isFailed(formNotifier.submitOp)) {
                  // İlaç oluşturulup servis kaydı başarısız olduysa ilaç listede
                  // görünmeli; panel açık kalır, tekrar kaydet güncelleme yapar.
                  if (isNew && formNotifier.drug.id != null) medicineNotifier.fetch();
                  MessageUtils.showErrorDialog(context, formNotifier.statusMessage);
                }
              } else {
                MessageUtils.showErrorDialog(context, context.l10n.common_requiredFieldsError);
              }
            },
            child: Form(key: _formKey, child: _dialogBody(context, formNotifier)),
          );
        },
      ),
    );
  }

  Widget _dialogBody(BuildContext context, DrugFormNotifier vm) {
    if (vm.isFetching) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return _formBody(context);
  }

  // Yerleşim 4 eşit sütunlu bir ızgaraya oturur. Bir anahtarın (checkbox /
  // seçim) kilitlediği alanlar her zaman görünür kalır, anahtar kapalıyken
  // kilitli (disabled) gösterilir — satır düzeni anahtara göre zıplamaz.
  // SidePanel zaten kaydırma sağladığı için burada ayrıca scroll yoktur.
  Widget _formBody(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MedSpacing.xl3,
      children: [
        _FormSection(
          title: l10n.medicine_section_basicInfoTitle,
          rows: [
            _FormRow(children: [_definitionNameField(), _nameField()]),
            _FormRow(children: [_manifacturerField(), _statusField(), _barcodeField(), _codeField()]),
            _FormRow(
              children: [_atcCodeField(), _equivalentCodeField(), _qrCodeCheckbox(), _pieceField()],
            ),
          ],
        ),
        _FormSection(
          title: l10n.medicine_section_classificationTitle,
          rows: [
            _FormRow(children: [_prescriptionTypeField(), _drugTypeField(), _drugClassField(), _dosageFormField()]),
            _FormRow(children: [_buildActiveIngredientField()]),
          ],
        ),
        _FormSection(
          title: l10n.medicine_section_doseUnitTitle,
          rows: [
            _FormRow(children: [_doseField(), _doseUnitField(), _volumeField(), _volumeUnitField()]),
            _FormRow(
              children: [_measurementCheckbox(), _measurementDoseField(), _measurementUnitField(), _maxUsageField()],
            ),
          ],
        ),
        _FormSection(
          title: l10n.medicine_section_purchaseReturnTitle,
          rows: [
            _FormRow(flexes: const [1, 3], children: [_purchaseTypeField(), _orderlessUsersField()]),
            _FormRow(
              flexes: const [1, 3],
              children: [_independentMaterialCheckbox(), const _IndependentServicesField()],
            ),
            _FormRow(
              children: [_countTypeField(), _returnTypeField(), _serumMaxValueCheckbox(), _cubicMaxValueCheckbox()],
            ),
          ],
        ),
        _FormSection(
          title: l10n.medicine_section_witnessTitle,
          rows: [
            _FormRow(
              flexes: const [1, 3],
              children: [_witnessedPurchaseCheckbox(), _witnessedPurchaseFields()],
            ),
            _FormRow(
              flexes: const [1, 3],
              children: [_wastageWitnessedCheckbox(), _wastageWitnessedFields()],
            ),
            _FormRow(
              flexes: const [1, 3],
              children: [_destroyableCheckbox(), _destroyableUsersField()],
            ),
          ],
        ),
        _FormSection(title: l10n.medicine_section_cabinBehaviorTitle, rows: const [CheckboxSection()]),
        _FormSection(
          title: l10n.medicine_section_notesTitle,
          rows: [
            _FormRow(children: [_buildCollectNoteField(), _buildReturnNoteField(), _buildDestructionNoteField()]),
          ],
        ),
      ],
    );
  }
}

// ── Temel Bilgiler ────────────────────────────────────────────────

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

Widget _atcCodeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldAtcCode,
        onChanged: vm.updateAtcCode,
        initialValue: vm.drug.atcCode,
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

// ── Sınıflandırma ─────────────────────────────────────────────────

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

// ── Doz ve Birim ──────────────────────────────────────────────────

Widget _doseField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDose,
        initialValue: vm.drug.dose.toCustomString(),
        keyboardType: TextInputType.number,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: (value) => vm.updateDose(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _doseUnitField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return UnitField(
        key: ObjectKey(vm.drug.doseUnit),
        unit: vm.drug.doseUnit,
        onChanged: (value) => vm.updateDoseUnit(value),
        isRequired: true,
      );
    },
  );
}

Widget _volumeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldVolume,
        onChanged: vm.updateVolume,
        initialValue: vm.drug.volume.toCustomString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) => Validators.cannotBlankValidator(value),
      );
    },
  );
}

Widget _volumeUnitField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return UnitField(
        key: ObjectKey(vm.drug.volumeUnit),
        unit: vm.drug.volumeUnit,
        onChanged: vm.updateVolumeUnit,
        isRequired: true,
      );
    },
  );
}

Widget _measurementCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxUseMeasurementUnit,
          value: vm.drug.isMeasureUnit,
          onChanged: (_) => vm.toggleMeasurement(),
        ),
      );
    },
  );
}

/// "Ölçü Birimi Kullan" kapalıyken kilitli.
Widget _measurementDoseField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final enabled = vm.drug.isMeasureUnit;
      return MedTextInputField(
        key: ValueKey('measureDose-$enabled'),
        label: context.l10n.medicine_fieldDose,
        enabled: enabled,
        initialValue: vm.drug.doseMeasureUnit.toCustomString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: enabled ? Validators.cannotBlankValidator : null,
        onChanged: vm.updateMeasurementDose,
      );
    },
  );
}

/// "Ölçü Birimi Kullan" kapalıyken kilitli. Doz birimiyle aynı birimi kullanır.
Widget _measurementUnitField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final enabled = vm.drug.isMeasureUnit;
      return IgnorePointer(
        ignoring: !enabled,
        child: UnitField(
          key: ObjectKey(vm.drug.doseUnit),
          unit: vm.drug.doseUnit,
          enabled: enabled,
          onChanged: (value) => vm.updateDoseUnit(value),
          isRequired: enabled,
        ),
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

// ── Alım ve İade ──────────────────────────────────────────────────

Widget _purchaseTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<PurchaseType>(
        label: context.l10n.medicine_fieldPurchaseType,
        options: PurchaseType.values,
        initialValue: vm.drug.purchaseType,
        labelBuilder: (type) => type?.label,
        onChanged: vm.updatePurchaseType,
      );
    },
  );
}

/// Alım şekli "Order'lı" iken kilitli; diğer alım şekillerinde zorunlu.
Widget _orderlessUsersField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final enabled = vm.drug.purchaseType != PurchaseType.ordered;
      return PersonelField(
        key: ValueKey(vm.drug.materialOrderlessTakingUsers),
        enabled: enabled,
        requireValidation: enabled,
        initialValue: vm.drug.materialOrderlessTakingUsers,
        onChanged: vm.updateOrderlessUsers,
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

Widget _qrCodeCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxQrCode,
          value: vm.drug.isQrCode,
          onChanged: (_) => vm.toggleQr(),
        ),
      );
    },
  );
}

/// "Karekodlu" kapalıyken kilitli.
Widget _pieceField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField(
        key: ValueKey('piece-${vm.drug.isQrCode}'),
        label: context.l10n.medicine_fieldPieceCountLabel,
        enabled: vm.drug.isQrCode,
        initialValue: vm.drug.piece?.toInt() ?? 1,
        onChanged: vm.updatePiece,
        options: [1, 2, 3, 4, 5],
        labelBuilder: (count) => count?.toString() ?? '1',
        validator: (count) => Validators.cannotBlankValidator(count.toString()),
      );
    },
  );
}

Widget _independentMaterialCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxIndependentMaterial,
          value: vm.drug.isIndependentMaterial,
          onChanged: (_) => vm.toggleIndependentMaterial(),
        ),
      );
    },
  );
}

Widget _returnTypeField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<ReturnType>(
        label: context.l10n.medicine_fieldReturnType,
        options: ReturnType.values,
        initialValue: vm.drug.returnType,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.label),
        onChanged: vm.updateReturnType,
      );
    },
  );
}

/// İade şekli "Kaynağına" değilse kilitli.
Widget _serumMaxValueCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxSerumMaxValue,
          enabled: vm.drug.returnType == ReturnType.toOrigin,
          value: vm.drug.isNotSerumCabinetMaxValue,
          onChanged: (_) => vm.toggleSerumMaxValue(),
        ),
      );
    },
  );
}

/// İade şekli "Kaynağına" değilse kilitli.
Widget _cubicMaxValueCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxCubicMaxValue,
          enabled: vm.drug.returnType == ReturnType.toOrigin,
          value: vm.drug.isNotCubicDrawrMaxValue,
          onChanged: (_) => vm.toggleCubicMaxValue(),
        ),
      );
    },
  );
}

// ── Şahitli İşlemler ve İmha ──────────────────────────────────────

Widget _witnessedPurchaseCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxWitnessedPurchase,
          value: vm.drug.isWitnessedPurchase,
          onChanged: (_) => vm.toggleWitnessedPurchase(),
        ),
      );
    },
  );
}

/// "Şahitli Alım" kapalıyken kilitli.
Widget _witnessedPurchaseFields() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final enabled = vm.drug.isWitnessedPurchase;
      return _FormRow(
        children: [
          PersonelField(
            key: ValueKey(vm.drug.witnessedPurchaseUsers),
            enabled: enabled,
            initialValue: vm.drug.witnessedPurchaseUsers,
            onChanged: vm.updateWitnessedPurchaseUsers,
          ),
          StationField(
            key: ValueKey(vm.drug.witnessedPurchaseStations),
            initialValue: vm.drug.witnessedPurchaseStations,
            enabled: enabled,
            requireValidation: enabled,
            onChanged: vm.updateWitnessedPurchaseStations,
          ),
        ],
      );
    },
  );
}

Widget _wastageWitnessedCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxWastageWitnessed,
          value: vm.drug.isWastageWitnessedPurchase,
          onChanged: (_) => vm.toggleWastageWitnessedPurchase(),
        ),
      );
    },
  );
}

/// "Fire/İmha Şahitli" kapalıyken kilitli.
Widget _wastageWitnessedFields() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      final enabled = vm.drug.isWastageWitnessedPurchase;
      return _FormRow(
        children: [
          PersonelField(
            key: ValueKey(vm.drug.wastageWitnessedPurchaseUsers),
            enabled: enabled,
            initialValue: vm.drug.wastageWitnessedPurchaseUsers,
            onChanged: vm.updateWastageWitnessedPurchaseUsers,
          ),
          StationField(
            key: ValueKey(vm.drug.wastageWitnessedPurchaseStations),
            enabled: enabled,
            requireValidation: enabled,
            initialValue: vm.drug.wastageWitnessedPurchaseStations,
            onChanged: vm.updateWastageWitnessedPurchaseStations,
          ),
        ],
      );
    },
  );
}

Widget _destroyableCheckbox() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return _InlineToggle(
        child: MedCheckboxField(
          label: context.l10n.medicine_checkboxDestroyable,
          value: vm.drug.isDestroyable,
          onChanged: (_) => vm.toggleIsDestroyable(),
        ),
      );
    },
  );
}

/// "İmha Edilebilir" kapalıyken kilitli.
Widget _destroyableUsersField() {
  return Consumer<DrugFormNotifier>(
    builder: (context, vm, _) {
      return PersonelField(
        key: ValueKey(vm.drug.destroyableUsers),
        enabled: vm.drug.isDestroyable,
        initialValue: vm.drug.destroyableUsers,
        onChanged: vm.updateDestroyableUsers,
      );
    },
  );
}

// ── Notlar ────────────────────────────────────────────────────────

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
        initialValue: vm.drug.returnNote,
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
