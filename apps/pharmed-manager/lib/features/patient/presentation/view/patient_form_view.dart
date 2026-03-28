import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../domain/entity/patient.dart';
import '../notifier/patient_form_notifier.dart';

class PatientFormView extends StatefulWidget {
  const PatientFormView({super.key, this.patient});

  final Patient? patient;

  @override
  State<PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<PatientFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PatientFormNotifier(
        initial: widget.patient,
        createPatientUseCase: context.read(),
        updatePatientUseCase: context.read(),
      ),
      child: Consumer<PatientFormNotifier>(
        builder: (context, notifier, _) {
          final String title = notifier.isCreate ? 'Yeni Hasta Oluştur' : 'Hasta Düzenle';
          return RegistrationDialog(
            maxHeight: context.height * 0.8,
            isLoading: notifier.isLoading(notifier.submitOp),
            title: title,
            onSave: () {
              if (_formKey.currentState!.validate()) {
                notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: (msg) {
                    MessageUtils.showSuccessSnackbar(context, msg);
                    context.pop(notifier.patient);
                  },
                );
              }
            },
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    _IdentityField(),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        _NameField(),
                        _SurnameField(),
                      ],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        _MotherNameField(),
                        _FatherNameField(),
                      ],
                    ),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        _BirthDateField(),
                        _GenderField(),
                        _WeightField(),
                      ],
                    ),
                    _PhoneField(),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [
                        _DescriptionField(),
                        _AddressField(),
                      ],
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
class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

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
