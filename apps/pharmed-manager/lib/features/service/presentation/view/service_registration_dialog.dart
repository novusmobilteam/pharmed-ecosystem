import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../branch/presentation/view/branch_list_view.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../../../../core/widgets/form/form_inputs/base_display_field.dart';
import '../../../user/user.dart';

import '../notifier/service_form_notifier.dart';

class ServiceRegistrationDialog extends StatelessWidget {
  const ServiceRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final notifier = context.read<ServiceFormNotifier>();
    final String title = notifier.isCreate ? 'Yeni Servis' : 'Servis Düzenle';

    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: title,
          width: 600,
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
                Row(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    Expanded(child: _BranchField()),
                    Expanded(child: _UserField()),
                  ],
                ),
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
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Servis Adı',
          initialValue: notifier.service.name,
          onChanged: notifier.updateName,
          validator: (v) => Validators.cannotBlankValidator(v),
        );
      },
    );
  }
}

class _BranchField extends StatelessWidget {
  const _BranchField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return BaseDisplayField(
          label: 'Branş',
          displayText: notifier.service.branch?.name ?? '',
          onTap: () async {
            final w = await showBranchListView(context);
            notifier.updateBranch(w);
          },
        );
      },
    );
  }
}

class _UserField extends StatelessWidget {
  const _UserField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return DialogInputField<User>(
          label: 'Kullanıcı',
          initialValue: notifier.service.user,
          labelBuilder: (user) => user?.fullName,
          onSelected: notifier.updateUser,
          future: () => context.read<IUserRepository>().getUsers(),
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          options: Status.values,
          initialValue: notifier.service.status,
          onChanged: notifier.updateStatus,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
        );
      },
    );
  }
}
