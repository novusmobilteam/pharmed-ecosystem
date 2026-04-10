part of 'hospitalization_screen.dart';

class PatientFormPanel extends StatelessWidget {
  const PatientFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final hospNotifier = context.watch<HospitalizationNotifier>();
    final formKey = GlobalKey<FormState>();
    final selectedPatient = hospNotifier.patient;

    return ChangeNotifierProvider(
      key: ValueKey(selectedPatient?.id ?? 'create'),
      create: (BuildContext context) => PatientFormNotifier(
        initial: selectedPatient,
        createPatientUseCase: context.read(),
        updatePatientUseCase: context.read(),
      ),
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          final String title = notifier.isCreate ? 'Yeni Hasta Oluştur' : 'Hasta Düzenle';
          return SidePanel(
            title: title,
            isLoading: notifier.isLoading(notifier.submitOp),
            onClose: hospNotifier.closePanel,
            onSave: () {
              if (formKey.currentState!.validate()) {
                notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    hospNotifier.closePanel();
                    hospNotifier.getHospitalizations();
                  },
                );
              }
            },
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    _IdentityField(),
                    Row(spacing: AppDimensions.registrationDialogSpacing, children: [_NameField(), _SurnameField()]),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [_MotherNameField(), _FatherNameField()],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [_BirthDateField(), _GenderField(), _WeightField()],
                    ),
                    _PhoneField(),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [_PatientDescriptionField(), _AddressField()],
                    ),
                    _ProtocolField(),
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

// * T.C Kimlik (patient.tcNo)
class _IdentityField extends StatelessWidget {
  const _IdentityField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'T.C Kimlik No',
          maxLength: 11,
          initialValue: notifier.patient?.tcNo,
          validator: (value) => Validators.tcValidator(value),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => notifier.updateIdentity(value),
        );
      },
    );
  }
}

// * Adı (patient.name)
class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Adı',
            initialValue: notifier.patient?.name,
            validator: (value) => Validators.cannotBlankValidator(value),
            onChanged: (value) => notifier.updateName(value),
          );
        },
      ),
    );
  }
}

// * Soyadı (patient.sruname)
class _SurnameField extends StatelessWidget {
  const _SurnameField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Soyadı',
            initialValue: notifier.patient?.surname,
            validator: (value) => Validators.cannotBlankValidator(value),
            onChanged: (value) => notifier.updateSurname(value),
          );
        },
      ),
    );
  }
}

// * Doğum Tarihi (patient.birthDate)
class _BirthDateField extends StatelessWidget {
  const _BirthDateField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return DateInputField(
            label: 'Doğum Tarihi',
            validator: (value) => Validators.cannotBlankValidator(value?.formattedDate),
            initialValue: notifier.patient?.birthDate,
            onDateSelected: (value) => notifier.updateBirthdate(value),
          );
        },
      ),
    );
  }
}

// * Cinsiyet (patient.gender)
class _GenderField extends StatelessWidget {
  const _GenderField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return DropdownInputField<Gender>(
            label: 'Cinsiyet',
            initialValue: notifier.patient?.gender,
            options: Gender.values,
            labelBuilder: (value) => value?.label,
            onChanged: (value) => notifier.updateGender(value),
          );
        },
      ),
    );
  }
}

// * Cinsiyet (patient.gender)
class _WeightField extends StatelessWidget {
  const _WeightField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Kilo',
            initialValue: notifier.patient?.weight?.toCustomString(),
            onChanged: (value) => notifier.updateWeight(value),
          );
        },
      ),
    );
  }
}

// * Anne Adı (patient.motherName)
class _MotherNameField extends StatelessWidget {
  const _MotherNameField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Anne Adı',
            initialValue: notifier.patient?.motherName,
            onChanged: (value) => notifier.updateMother(value),
          );
        },
      ),
    );
  }
}

// * Baba Adı (patient.fatherName)
class _FatherNameField extends StatelessWidget {
  const _FatherNameField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Baba Adı',
            initialValue: notifier.patient?.fatherName,
            onChanged: (value) => notifier.updateFather(value),
          );
        },
      ),
    );
  }
}

// * Telefon (patient.phone)
class _PhoneField extends StatelessWidget {
  const _PhoneField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Telefon',
          maxLength: 11,
          initialValue: notifier.patient?.phone?.toString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => notifier.updatePhone(value),
        );
      },
    );
  }
}

// * Açıklama (hospitalization.description)
class _PatientDescriptionField extends StatelessWidget {
  const _PatientDescriptionField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Açıklama',
            maxLines: 3,
            initialValue: notifier.patient?.description?.toString(),
            onChanged: (value) => notifier.updateDescription(value),
          );
        },
      ),
    );
  }
}

// * Adres (patient.address)
class _AddressField extends StatelessWidget {
  const _AddressField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Adres',
            maxLines: 3,
            initialValue: notifier.patient?.address?.toString(),
            onChanged: (value) => notifier.updateAddress(value),
          );
        },
      ),
    );
  }
}

class _ProtocolField extends StatelessWidget {
  const _ProtocolField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Protokol No',
          initialValue: notifier.patient?.protocolNo,
          onChanged: notifier.updateProtocolNo,
        );
      },
    );
  }
}
