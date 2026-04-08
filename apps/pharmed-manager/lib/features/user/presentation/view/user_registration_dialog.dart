part of 'user_screen.dart';

class UserRegistrationDialog extends StatelessWidget {
  const UserRegistrationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        final title = notifier.isCreate ? 'Kullanıcı Oluştur' : 'Kullanıcı Düzenle';
        return RegistrationDialog(
          maxHeight: 900,
          title: title,
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
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _RegistrationNumberField(),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _NameField()),
                      Expanded(child: _SurnameField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _RoleField()),
                      Expanded(child: _StatusField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _UsageKindField()),
                      Expanded(child: _ExpirationDateField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _EmailField()),
                      Expanded(child: _OrderStatusField()),
                    ],
                  ),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _WitnessedStationField()),
                      Expanded(child: _PurchaseKitField()),
                    ],
                  ),
                  _StationsField(),
                  _UsernameField(),
                  if (notifier.isCreate) _PasswordField(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RegistrationNumberField extends StatelessWidget {
  const _RegistrationNumberField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          key: key,
          label: 'Kurum Sicil No',
          initialValue: notifier.user.registrationNumber,
          onChanged: (text) => notifier.changeRegistrationNumber(text),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          key: key,
          label: 'Adı',
          initialValue: notifier.user.name,
          onChanged: (v) => notifier.changeName(v),
          validator: Validators.cannotBlankValidator,
        );
      },
    );
  }
}

class _SurnameField extends StatelessWidget {
  const _SurnameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          key: key,
          label: 'Soyadı',
          initialValue: notifier.user.surname,
          onChanged: (v) => notifier.changeSurname(v),
          validator: Validators.cannotBlankValidator,
        );
      },
    );
  }
}

class _RoleField extends StatelessWidget {
  const _RoleField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return SelectionField<Role>(
          key: key,
          label: 'Meslek Tipi',
          initialValue: notifier.user.role,
          labelBuilder: (r) => r.name,
          dataSource: (skip, take, search) => context.read<IRoleRepository>().getRoles(),
          onSelected: (role) => notifier.changeRole(role),
          validator: (r) => Validators.cannotBlankValidator(r?.name),
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<Status>(
          label: 'Durumu',
          options: Status.values,
          initialValue: notifier.user.status,
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (s) => notifier.changeStatus(s.isActive),
        );
      },
    );
  }
}

class _UsageKindField extends StatelessWidget {
  const _UsageKindField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<UserType>(
          label: 'Kullanım Türü',
          options: UserType.values,
          initialValue: notifier.user.type,
          labelBuilder: (t) => t?.label,
          validator: (t) => Validators.cannotBlankValidator(t?.label),
          onChanged: (t) => notifier.changeUserType(t),
        );
      },
    );
  }
}

class _ExpirationDateField extends StatelessWidget {
  const _ExpirationDateField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DateInputField(
          label: 'Son Geçerlilik Tarihi',
          firstDate: DateTime.now(),
          initialValue: notifier.user.validUntil,
          onDateSelected: (value) => notifier.changeValidUntil(value),
        );
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          key: key,
          label: 'Email',
          initialValue: notifier.user.email,
          onChanged: (value) => notifier.changeEmail(value),
          validator: Validators.emailValidator,
        );
      },
    );
  }
}

class _OrderStatusField extends StatelessWidget {
  const _OrderStatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<PermissionStatus>(
          label: 'Ordersız Alım',
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.isNotOrdered),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeOrderPermission(value.isAllowed),
        );
      },
    );
  }
}

class _WitnessedStationField extends StatelessWidget {
  const _WitnessedStationField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<PermissionStatus>(
          label: 'İstasyon Şahitli Giriş',
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.isWitnessedStationEntry),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeWitnessedEntry(value.isAllowed),
        );
      },
    );
  }
}

class _PurchaseKitField extends StatelessWidget {
  const _PurchaseKitField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return DropdownInputField<PermissionStatus>(
          label: 'Kit Alım',
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.kitPurchase),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeKitPurchase(value.isAllowed),
        );
      },
    );
  }
}

class _StationsField extends StatelessWidget {
  const _StationsField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return MultiSelectionField<Station>(
          key: ValueKey(notifier.selectedStations.length),
          label: 'Yetki İstasyonlar',
          initialValue: notifier.selectedStations,
          dataSource: (skip, take, search) => context.read<IStationRepository>().getStations(),
          labelBuilder: (s) => s.name,
          onSelected: (stations) => notifier.changeStations(stations ?? []),
          // validator: (value) => Validators.cannotBlankValidator(
          //   (value == null || value.isEmpty) ? null : value.first.name,
          // ),
        );
      },
    );
  }
}

class _UsernameField extends StatelessWidget {
  const _UsernameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Kullanıcı Adı',
          initialValue: notifier.user.userName,
          onChanged: (value) => notifier.changeUsername(value),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(label: 'Şifre', obscureText: true, onChanged: (value) => notifier.changePassword(value));
      },
    );
  }
}
