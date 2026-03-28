import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/dosage_form.dart';
import '../notifier/dosage_form_registration_notifier.dart';

Future<bool> showDosageFormRegistrationDialog(BuildContext context, {DosageForm? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => DosageFormRegistrationNotifier(
        createDosageFormUseCase: context.read(),
        updateDosageFormUseCase: context.read(),
      ),
      child: const DosageFormRegistrationDialog(),
    ),
  );

  return result ?? false;
}

class DosageFormRegistrationDialog extends StatefulWidget {
  const DosageFormRegistrationDialog({super.key});

  @override
  State<DosageFormRegistrationDialog> createState() => _DosageFormRegistrationDialogState();
}

class _DosageFormRegistrationDialogState extends State<DosageFormRegistrationDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<DosageFormRegistrationNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Dozaj Formu Oluştur' : 'Dozaj Formu Düzenle';

        return RegistrationDialog(
          title: title,
          isLoading: notifier.isSubmitting,
          onSave: () {
            notifier.submit(
              onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
              onSuccess: (message) {
                MessageUtils.showSuccessSnackbar(context, message);
                context.pop(true);
              },
            );
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [
                _NameField(),
                _StatusField(),
              ],
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
    return Consumer<DosageFormRegistrationNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Adı',
          autoFocus: notifier.isCreate,
          initialValue: notifier.dosageForm.name,
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
    return Consumer<DosageFormRegistrationNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.dosageForm.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
