import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/hospitalization_form_notifier.dart';

part 'patient_info_view.dart';

Future<bool?> showHospitalizationFormView(
  BuildContext context, {
  Hospitalization? hospitalization,
  Patient? patient,
}) async {
  final result = await showDialog(
    context: context,
    builder: (context) => ChangeNotifierProvider(
      create: (context) => HospitalizationFormNotifier(
        patient: patient,
        hospitalization: hospitalization,
        createHospitalizationUseCase: context.read(),
        updateHospitalizationUseCase: context.read(),
      ),
      child: HospitalizationFormView(),
    ),
  );

  return result;
}

class HospitalizationFormView extends StatefulWidget {
  const HospitalizationFormView({super.key});

  @override
  State<HospitalizationFormView> createState() => _HospitalizationFormViewState();
}

class _HospitalizationFormViewState extends State<HospitalizationFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _admissionDateController;
  late TextEditingController _exitDateController;

  @override
  void initState() {
    super.initState();
    _admissionDateController = TextEditingController();
    _exitDateController = TextEditingController();
  }

  @override
  void dispose() {
    _admissionDateController.dispose();
    _exitDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, child) {
        final title = notifier.isCreate ? 'Yeni Yatış Gir' : 'Yatış Düzenle';
        return RegistrationDialog(
          title: title,
          onSave: () {
            if (_formKey.currentState!.validate()) {
              notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
                },
              );
            }
          },
          isLoading: notifier.isLoading(notifier.submitOp),
          actions: [_PatientButton()],
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  _CodeField(),
                  _DoctorField(),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [_PhysicalServiceField(), _InpatientServiceField()],
                  ),
                  Row(spacing: AppDimensions.registrationDialogSpacing, children: [_RoomField(), _BedField()]),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [_AdmissionDateField(_admissionDateController), _ExitDateField(_exitDateController)],
                  ),
                  _DescriptionField(),
                  _BabyToggle(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, _) {
        return Lockable(
          locked: true,
          child: TextInputField(
            label: 'Yatış Kodu',
            initialValue: notifier.hospitalization?.code.toString(),
            onChanged: (_) {},
          ),
        );
      },
    );
  }
}

class _DoctorField extends StatelessWidget {
  const _DoctorField();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, _) {
        return DialogInputField<User>(
          label: 'Doktor',
          initialValue: notifier.doctor,
          labelBuilder: (value) => value?.fullName,
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          future: () => context.read<GetUsersUseCase>().call(const GetUsersParams()),
          onSelected: (value) => notifier.selectDoctor(value),
        );
      },
    );
  }
}

class _PhysicalServiceField extends StatelessWidget {
  const _PhysicalServiceField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return DialogInputField<HospitalService>(
            label: 'Fiziki Servis',
            initialValue: notifier.hospitalization?.physicalService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            labelBuilder: (s) => s?.name,
            future: () => context.read<IServiceRepository>().getServices(),
            onSelected: (s) => notifier.selectPhysicalService(s),
          );
        },
      ),
    );
  }
}

class _InpatientServiceField extends StatelessWidget {
  const _InpatientServiceField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return DialogInputField<HospitalService>(
            label: 'Yatış Servis',
            labelBuilder: (s) => s?.name,
            initialValue: notifier.hospitalization?.inpatientService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            future: () => context.read<IServiceRepository>().getServices(),
            onSelected: (s) => notifier.selectInpatientService(s),
          );
        },
      ),
    );
  }
}

class _RoomField extends StatelessWidget {
  const _RoomField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Oda No',
            initialValue: notifier.hospitalization?.roomNo,
            validator: Validators.cannotBlankValidator,
            onChanged: (v) => notifier.updateRoom(v),
          );
        },
      ),
    );
  }
}

// * Yatak No (hospitalization.bedNo)
class _BedField extends StatelessWidget {
  const _BedField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return TextInputField(
            label: 'Yatak No',
            initialValue: notifier.hospitalization?.bedNo,
            validator: Validators.cannotBlankValidator,
            onChanged: (v) => notifier.updateBed(v),
          );
        },
      ),
    );
  }
}

// * Yatış Tarihi (hospitalization.admissionDate)
class _AdmissionDateField extends StatelessWidget {
  const _AdmissionDateField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return DateInputField(
            label: 'Yatış Tarihi',
            initialValue: notifier.hospitalization?.admissionDate,
            //controller: controller,
            onDateSelected: notifier.updateAdmissionDate,
          );
        },
      ),
    );
  }
}

// * Çıkış Tarihi (hospitalization.exitDate)
class _ExitDateField extends StatelessWidget {
  const _ExitDateField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return DateInputField(label: 'Çıkış Tarihi', onDateSelected: notifier.updateExitDate);
        },
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Açıklama',
          hintText: 'Açıklama',
          maxLines: 3,
          initialValue: notifier.hospitalization?.description,
          onChanged: notifier.updateDescription,
        );
      },
    );
  }
}

class _BabyToggle extends StatelessWidget {
  const _BabyToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, _) {
        return CustomCheckboxTile(
          label: 'Bebek',
          onTap: () => notifier.toggleIsBaby(),
          value: notifier.hospitalization?.isBaby ?? false,
        );
      },
    );
  }
}
