import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/medical_consumable_form_notifier.dart';

Future<bool> showMedicalConsumableFormView(BuildContext context, {MedicalConsumable? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => MedicalConsumableFormNotifier(
        medicalConsumable: initial,
        createMedicineUseCase: context.read(),
        updateMedicineUseCase: context.read(),
      ),
      child: MedicalConsumableFormView(),
    ),
  );

  return result ?? false;
}

class MedicalConsumableFormView extends StatefulWidget {
  const MedicalConsumableFormView({super.key});

  @override
  State<MedicalConsumableFormView> createState() => _MedicalConsumableFormViewState();
}

class _MedicalConsumableFormViewState extends State<MedicalConsumableFormView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalConsumableFormNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: context.l10n.medicalConsumable_dialogTitle,
          width: context.width * 0.5,
          maxHeight: 800,
          isLoading: notifier.isSubmitting,
          onSave: () async {
            if (!formKey.currentState!.validate()) {
              MessageUtils.showErrorDialog(context, context.l10n.common_requiredFieldsError);
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
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _buildNameField(),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _buildBarcodeField()),
                      Expanded(child: _buildInstitutionCodeField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _buildSUTCodeField()),
                      Expanded(child: _buildUBBCodeField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _buildMaterialTypeField()),
                      Expanded(child: _buildFirmField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _buildCountTypeField()),
                      Expanded(child: _buildDailyMaxUsageField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _buildPurchaseTypeField()),
                      Expanded(child: _buildReturnTypeField()),
                    ],
                  ),
                  _buildCollectNoteField(),
                  _buildReturnNoteField(),
                  _buildDesctructionNoteField(),
                  _buildStatusField(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildNameField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicalConsumable_fieldName,
        initialValue: vm.mc.name,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateName,
      );
    },
  );
}

Widget _buildBarcodeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldBarcode,
        initialValue: vm.mc.barcode,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateBarcode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildInstitutionCodeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicalConsumable_fieldInstitutionCode,
        initialValue: vm.mc.institutionCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateInstitutionCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildSUTCodeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicalConsumable_fieldSutCode,
        initialValue: vm.mc.sutCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateSutCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildUBBCodeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicalConsumable_fieldUbbCode,
        initialValue: vm.mc.ubbCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateUbbCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildMaterialTypeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      final label = context.l10n.medicalConsumable_fieldMaterialType;
      return MedSelectionField<MaterialType>(
        label: label,
        title: label,
        initialValue: vm.mc.materialType,
        labelBuilder: (value) => value.name,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        dataSource: (skip, take, search) =>
            context.read<GetMaterialTypesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
        onSelected: vm.updateMaterialType,
      );
    },
  );
}

Widget _buildFirmField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedSelectionField<Firm>(
        label: context.l10n.medicine_fieldManufacturer,
        initialValue: vm.mc.firm,
        labelBuilder: (value) => value.name,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        dataSource: (skip, take, search) =>
            context.read<GetFirmsUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
        onSelected: vm.updateFirm,
      );
    },
  );
}

Widget _buildCountTypeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<CountType>(
        label: context.l10n.medicine_fieldCountType,
        options: CountType.values,
        initialValue: vm.mc.countType,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        onChanged: vm.updateCountType,
      );
    },
  );
}

Widget _buildDailyMaxUsageField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDailyMaxUsage,
        initialValue: vm.mc.dailyMaxUsage.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: vm.updateDailyUsage,
      );
    },
  );
}

Widget _buildPurchaseTypeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<PurchaseType>(
        label: context.l10n.medicine_fieldPurchaseType,
        options: PurchaseType.values,
        initialValue: vm.mc.purchaseType,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        onChanged: vm.updatePurchaseType,
      );
    },
  );
}

Widget _buildReturnTypeField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<ReturnType>(
        label: context.l10n.medicine_fieldReturnType,
        options: ReturnType.values,
        initialValue: vm.mc.returnType,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        onChanged: vm.updateReturnType,
      );
    },
  );
}

Widget _buildCollectNoteField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldCollectNote,
        initialValue: vm.mc.collectNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateCollectNote,
      );
    },
  );
}

Widget _buildReturnNoteField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldReturnNote,
        initialValue: vm.mc.returnNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateReturnNote,
      );
    },
  );
}

Widget _buildDesctructionNoteField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedTextInputField(
        label: context.l10n.medicine_fieldDestructionNote,
        initialValue: vm.mc.destructionNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateReturnNote,
      );
    },
  );
}

Widget _buildStatusField() {
  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return MedDropdownInputField<Status>(
        label: context.l10n.medicalConsumable_fieldStatus,
        options: Status.values,
        initialValue: vm.mc.status,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.label),
        onChanged: vm.updateStatus,
      );
    },
  );
}
