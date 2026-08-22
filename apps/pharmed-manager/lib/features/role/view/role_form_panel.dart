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
          final String title = roleNotifier.isEditing ? context.l10n.role_formEditTitle : context.l10n.role_formAddTitle;
          return SidePanel(
            title: title,
            isLoading: notifier.isLoading(notifier.submitOp),
            onClose: roleNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                    roleNotifier.closePanel();
                    roleNotifier.fetch();
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
        return MedTextInputField(
          label: context.l10n.role_formNameLabel,
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
        return MedDropdownInputField<Status>(
          label: context.l10n.common_statusLabel,
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
