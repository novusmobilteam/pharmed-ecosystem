import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/drug_type.dart';
import '../notifier/drug_type_form_notifier.dart';

Future<bool> showDrugTypeFormDialog(BuildContext context, {DrugType? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => DrugTypeFormNotifier(
        drugType: initial,
        createDrugTypeUseCase: context.read(),
        updateDrugTypeUseCase: context.read(),
      ),
      child: const DrugTypeFormDialog(),
    ),
  );

  return result ?? false;
}

class DrugTypeFormDialog extends StatefulWidget {
  const DrugTypeFormDialog({super.key});

  @override
  State<DrugTypeFormDialog> createState() => _DrugTypeFormDialogState();
}

class _DrugTypeFormDialogState extends State<DrugTypeFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugTypeFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'İlaç Tipi Ekle' : 'İlaç Tipi Düzenle';
        return RegistrationDialog(
          title: title,
          width: 500,
          isLoading: notifier.isLoading(notifier.submitOp),
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
    return Consumer<DrugTypeFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'İlaç Tipi Adı',
          initialValue: notifier.drugType.name,
          validator: (v) => Validators.cannotBlankValidator(v),
          onChanged: notifier.updateName,
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugTypeFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.drugType.status,
          options: Status.values,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
