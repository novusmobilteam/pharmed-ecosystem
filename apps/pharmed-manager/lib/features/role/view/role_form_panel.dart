part of 'role_screen.dart';

class RoleFormPanel extends StatelessWidget {
  const RoleFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final roleNotifier = context.watch<RoleNotifier>();
    final selectedRole = roleNotifier.selectedItem;

    return ChangeNotifierProvider<RoleFormNotifier>(
      key: ValueKey(selectedRole?.id ?? 'create'),
      create: (context) =>
          RoleFormNotifier(createRoleUseCase: context.read(), updateRoleUseCase: context.read(), role: selectedRole),
      child: Consumer<RoleFormNotifier>(
        builder: (context, notifier, _) {
          final String title = roleNotifier.isEditing ? 'Rol Düzenle' : 'Rol Ekle';
          return SidePanel(
            title: title,
            isLoading: notifier.isLoading(notifier.submitOp),
            onClose: roleNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    roleNotifier.closePanel();
                    roleNotifier.getRoles();
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
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Rol Adı',
          autoFocus: notifier.isCreate,
          initialValue: notifier.role.name,
          validator: Validators.cannotBlankValidator,
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
    return Consumer<RoleFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          initialValue: notifier.role.status,
          options: Status.values,
          labelBuilder: (value) => value?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
          onChanged: notifier.updateStatus,
        );
      },
    );
  }
}
