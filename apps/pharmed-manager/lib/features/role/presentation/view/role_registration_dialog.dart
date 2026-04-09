part of 'role_screen.dart';

class RoleRegistrationDialog extends StatelessWidget {
  const RoleRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Consumer<RoleFormNotifier>(
      builder: (context, vm, _) {
        final String title = vm.isCreate ? 'Rol Ekle' : 'Rol Düzenle';

        return RegistrationDialog(
          title: title,
          isLoading: vm.isLoading(vm.submitOp),
          onClose: () => Navigator.of(context).pop(),
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await vm.submit();
            }

            if (context.mounted && vm.isSuccess(vm.submitOp)) {
              MessageUtils.showSuccessSnackbar(context, vm.statusMessage);
              context.pop(true);
            } else if (context.mounted && vm.isFailed(vm.submitOp)) {
              MessageUtils.showErrorDialog(context, vm.statusMessage);
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
    return Consumer<RoleFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Rol Adı',
          autoFocus: vm.isCreate,
          initialValue: vm.role.name,
          validator: Validators.cannotBlankValidator,
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
    return Consumer<RoleFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: vm.role.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: vm.updateStatus,
        );
      },
    );
  }
}
