part of 'user_screen.dart';

class UserFormPanel extends StatelessWidget {
  const UserFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final userNotifier = context.watch<UserNotifier>();
    final selectedUser = userNotifier.selectedItem;

    return ChangeNotifierProvider<UserFormNotifier>(
      create: (BuildContext context) => UserFormNotifier(
        user: selectedUser,
        createUserUseCase: context.read(),
        updateUserUseCase: context.read(),
        getStationsUseCase: context.read(),
      ),
      child: Consumer<UserFormNotifier>(
        builder: (context, notifier, _) {
          final title = userNotifier.isEditing ? context.l10n.user_formEditTitle : context.l10n.user_formCreateTitle;
          return SidePanel(
            title: title,
            isLoading: notifier.isLoading(notifier.submitOp),
            onClose: userNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) =>
                      MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
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
                    _RfidCardField(),
                    _EmergenyAccessField(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegistrationNumberField extends StatelessWidget {
  const _RegistrationNumberField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          key: key,
          label: context.l10n.user_registrationNumberLabel,
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
        return MedTextInputField(
          key: key,
          label: context.l10n.user_nameLabel,
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
        return MedTextInputField(
          key: key,
          label: context.l10n.user_surnameLabel,
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
        return MedSelectionField<Role>(
          key: key,
          label: context.l10n.user_roleTypeLabel,
          initialValue: notifier.user.role,
          labelBuilder: (r) => r.name,
          dataSource: (skip, take, search) =>
              context.read<GetRolesUseCase>().call(GetRolesParams(skip: skip, take: take, search: search)),
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
        return MedDropdownInputField<Status>(
          label: context.l10n.common_statusLabel,
          options: Status.values,
          initialValue: notifier.user.status,
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (s) => notifier.changeStatus(s?.isActive),
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
        return MedDropdownInputField<UserType>(
          label: context.l10n.user_usageTypeLabel,
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
        return MedDateInputField(
          label: context.l10n.user_validUntilLabel,
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
        return MedTextInputField(
          key: key,
          label: context.l10n.user_emailLabel,
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
        return MedDropdownInputField<PermissionStatus>(
          label: context.l10n.user_orderPermissionLabel,
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.isNotOrdered),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeOrderPermission(value?.isAllowed),
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
        return MedDropdownInputField<PermissionStatus>(
          label: context.l10n.user_witnessedStationEntryLabel,
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.isWitnessedStationEntry),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeWitnessedEntry(value?.isAllowed),
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
        return MedDropdownInputField<PermissionStatus>(
          label: context.l10n.user_kitPurchaseLabel,
          options: PermissionStatus.values,
          initialValue: permissionStatusFromBool(notifier.user.kitPurchase),
          labelBuilder: (s) => s?.label,
          validator: (s) => Validators.cannotBlankValidator(s?.label),
          onChanged: (value) => notifier.changeKitPurchase(value?.isAllowed),
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
        return MedMultiSelectionField<Station>(
          key: ValueKey(notifier.selectedStations.length),
          label: context.l10n.user_authorizedStationsLabel,
          initialValue: notifier.selectedStations,
          dataSource: (skip, take, search) =>
              context.read<GetStationsUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
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
        return MedTextInputField(
          label: context.l10n.user_usernameLabel,
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
        return MedTextInputField(
          label: context.l10n.auth_passwordLabel,
          obscureText: true,
          onChanged: (value) => notifier.changePassword(value),
        );
      },
    );
  }
}

class _RfidCardField extends StatelessWidget {
  const _RfidCardField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          label: context.l10n.user_badgeCardLabel,
          hint: context.l10n.user_badgeCardHint,
          initialValue: notifier.user.rfidCardData,
          obscureText: true,
          onChanged: (value) => notifier.changeRfidCardData(value),
        );
      },
    );
  }
}

class _EmergenyAccessField extends StatelessWidget {
  const _EmergenyAccessField();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserFormNotifier>(
      builder: (context, notifier, _) {
        return MedToggleField(
          label: context.l10n.user_emergencyAccessLabel,
          value: notifier.user.canCreateEmergencyPatient,
          onChanged: (value) => notifier.toggleEmergencyAccess(value),
        );
      },
    );
  }
}
