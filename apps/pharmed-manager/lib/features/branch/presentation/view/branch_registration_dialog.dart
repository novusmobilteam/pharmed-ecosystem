import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../notifier/branch_form_notifier.dart';

class BranchRegistrationDialog extends StatelessWidget {
  const BranchRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Consumer<BranchFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Branş Ekle' : 'Branş Düzenle';

        return RegistrationDialog(
          title: title,
          isLoading: notifier.isSubmitting,
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit();

              if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                context.pop(true);
              } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
                MessageUtils.showErrorDialog(context, notifier.statusMessage);
              }
            }
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
    return Consumer<BranchFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Branş Adı',
          autoFocus: vm.isCreate,
          initialValue: vm.branch.name,
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
    return Consumer<BranchFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: vm.branch.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: vm.updateStatus,
        );
      },
    );
  }
}
