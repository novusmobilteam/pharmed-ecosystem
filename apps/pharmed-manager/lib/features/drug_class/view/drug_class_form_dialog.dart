import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/drug_class_form_notifier.dart';

Future<bool> showDrugClassFormDialog(BuildContext context, {DrugClass? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => DrugClassFormNotifier(
        drugClass: initial,
        createDrugClassUseCase: context.read(),
        updateDrugClassUseCase: context.read(),
      ),
      child: const DrugClassFormDialog(),
    ),
  );

  return result ?? false;
}

class DrugClassFormDialog extends StatefulWidget {
  const DrugClassFormDialog({super.key});

  @override
  State<DrugClassFormDialog> createState() => _DrugClassFormDialogState();
}

class _DrugClassFormDialogState extends State<DrugClassFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugClassFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'İlaç Sınıfı Ekle' : 'İlaç Sınıfı Düzenle';
        return RegistrationDialog(
          title: title,
          maxHeight: 400,
          width: 400,
          isLoading: notifier.isSubmitting,
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
                },
              );
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [_NameField(), _StatusField()],
            ),
          ),
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugClassFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'İlaç Sınıfı Adı',
          initialValue: vm.drugClass.name,
          validator: (v) => Validators.cannotBlankValidator(v),
          onChanged: vm.updateName,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugClassFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: vm.drugClass.status,
          options: Status.values,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: vm.updateStatus,
        );
      },
    );
  }
}
