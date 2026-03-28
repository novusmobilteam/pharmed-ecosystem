import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/firm_form_notifier.dart';

class FirmRegistrationDialog extends StatelessWidget {
  const FirmRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final vm = context.read<FirmFormNotifier>();
    final String title = vm.isCreate ? 'Firma Ekle' : 'Firma Düzenle';

    return RegistrationDialog(
      title: title,
      isLoading: context.select<FirmFormNotifier, bool>((n) => n.isLoading(FirmFormNotifier.submitKey)),
      onSave: () async {
        if (formKey.currentState!.validate()) {
          await vm.submit();

          if (context.mounted && vm.isSuccess(FirmFormNotifier.submitKey)) {
            MessageUtils.showSuccessSnackbar(context, vm.statusMessage);
            context.pop(true);
          } else if (context.mounted && vm.isFailed(FirmFormNotifier.submitKey)) {
            MessageUtils.showErrorDialog(context, vm.statusMessage);
          }
        }
      },
      child: Form(
        key: formKey,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            _NameField(),
            _TaxOfficeField(),
            Row(
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Expanded(child: _TaxNoField()),
                Expanded(child: _FirmTypeField()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmFormNotifier>(
      builder: (context, vm, _) => TextInputField(
        label: 'Firma Adı',
        initialValue: vm.firm.name,
        validator: (v) => Validators.cannotBlankValidator(v),
        onChanged: vm.updateName,
      ),
    );
  }
}

class _TaxNoField extends StatelessWidget {
  const _TaxNoField();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmFormNotifier>(
      builder: (context, vm, _) => TextInputField(
        label: 'Vergi No',
        initialValue: vm.firm.taxNo?.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: vm.updateTaxNo,
        validator: (value) => Validators.taxNoValidator(value),
      ),
    );
  }
}

class _TaxOfficeField extends StatelessWidget {
  const _TaxOfficeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Vergi Dairesi',
          initialValue: vm.firm.taxOffice,
          onChanged: vm.updateTaxOffice,
        );
      },
    );
  }
}

class _FirmTypeField extends StatelessWidget {
  const _FirmTypeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<FirmFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<FirmType>(
          label: 'Firma Tipi',
          initialValue: vm.firm.type,
          options: FirmType.values,
          labelBuilder: (type) => type?.label,
          onChanged: vm.updateFirmType,
        );
      },
    );
  }
}
