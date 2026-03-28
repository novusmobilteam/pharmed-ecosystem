import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../../../firm/data/repository/firm_repository.dart';
import '../../../firm/domain/entity/firm.dart';
import '../../../material_type/domain/entity/material_type.dart';
import '../../../material_type/domain/repository/i_material_type_repository.dart';
import '../../domain/entity/medicine.dart';
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
          title: 'Tıbbi Sarf Malzemesi Ekle/Düzenle',
          width: context.width * 0.8,
          maxHeight: 800,
          isLoading: notifier.isSubmitting,
          onSave: () async {
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
  final label = 'Malzeme Adı';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.name,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateName,
      );
    },
  );
}

Widget _buildBarcodeField() {
  final label = 'Barkod';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.barcode,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateBarcode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildInstitutionCodeField() {
  final label = 'Kurum Kodu';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.institutionCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateInstitutionCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildSUTCodeField() {
  final label = 'SUT Kodu/Eki';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.sutCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateSutCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildUBBCodeField() {
  final label = 'UBB Kodu';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.ubbCode?.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateUbbCode,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      );
    },
  );
}

Widget _buildMaterialTypeField() {
  final label = 'Malzeme Tipi';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DialogInputField<MaterialType>(
        label: label,
        initialValue: vm.mc.materialType,
        labelBuilder: (value) => value?.name,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        future: () => context.read<IMaterialTypeRepository>().getMaterialTypes(),
        onSelected: vm.updateMaterialType,
      );
    },
  );
}

Widget _buildFirmField() {
  final label = 'Üretici Firma';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DialogInputField<Firm>(
        label: label,
        initialValue: vm.mc.firm,
        labelBuilder: (value) => value?.name,
        validator: (value) => Validators.cannotBlankValidator(value?.name),
        future: () => context.read<FirmRepository>().getFirms(),
        onSelected: vm.updateFirm,
      );
    },
  );
}

Widget _buildCountTypeField() {
  final label = 'Sayım Tipi';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<CountType>(
        label: label,
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
  final label = 'Günlük Maks. Kullanım Miktarı';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.dailyMaxUsage.toCustomString(),
        validator: (value) => Validators.cannotBlankValidator(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: vm.updateDailyUsage,
      );
    },
  );
}

Widget _buildPurchaseTypeField() {
  final label = 'Alım Şekli';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<PurchaseType>(
        label: label,
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
  final label = 'İade Şekli';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<ReturnType>(
        label: label,
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
  final label = 'Alım Notu';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.collectNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateCollectNote,
      );
    },
  );
}

Widget _buildReturnNoteField() {
  final label = 'İade Notu';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.returnNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateReturnNote,
      );
    },
  );
}

Widget _buildDesctructionNoteField() {
  final label = 'İmha Notu';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return TextInputField(
        label: label,
        initialValue: vm.mc.destructionNote,
        validator: (value) => Validators.cannotBlankValidator(value),
        onChanged: vm.updateReturnNote,
      );
    },
  );
}

Widget _buildStatusField() {
  final label = 'Durum';

  return Consumer<MedicalConsumableFormNotifier>(
    builder: (context, vm, _) {
      return DropdownInputField<Status>(
        label: label,
        options: Status.values,
        initialValue: vm.mc.status,
        labelBuilder: (value) => value?.label,
        validator: (value) => Validators.cannotBlankValidator(value?.label),
        onChanged: vm.updateStatus,
      );
    },
  );
}
