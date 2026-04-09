import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_manager/features/firm/notifier/firm_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../core/widgets/side_panel.dart';
import '../notifier/firm_form_notifier.dart';

class FirmFormPanel extends StatelessWidget {
  const FirmFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final firmNotifier = context.watch<FirmNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = firmNotifier.selectedFirm == null;
    final selectedFirm = firmNotifier.selectedFirm;

    return ChangeNotifierProvider(
      key: ValueKey(selectedFirm?.id ?? 'create'),
      create: (BuildContext context) =>
          FirmFormNotifier(createFirmUseCase: context.read(), updateFirmUseCase: context.read(), firm: selectedFirm),
      child: Consumer<FirmFormNotifier>(
        builder: (context, formNotifier, _) {
          return SidePanel(
            title: isNew ? 'Yeni Firma' : 'Firma Düzenle',
            subtitle: isNew ? 'Firma bilgilerini doldurun' : 'Firma bilgilerini güncelleyin',
            isLoading: formNotifier.isSubmitting,
            onClose: firmNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await formNotifier.submit();

                if (context.mounted && formNotifier.isSuccess(formNotifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, formNotifier.statusMessage);
                  firmNotifier.closePanel();
                  firmNotifier.getFirms();
                } else if (context.mounted && formNotifier.isFailed(formNotifier.submitOp)) {
                  MessageUtils.showErrorDialog(context, formNotifier.statusMessage);
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
        },
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
        maxLength: 11,
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
        return TextInputField(label: 'Vergi Dairesi', initialValue: vm.firm.taxOffice, onChanged: vm.updateTaxOffice);
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
