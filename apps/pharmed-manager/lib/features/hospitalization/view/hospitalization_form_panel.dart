part of 'hospitalization_screen.dart';

class HospitalizationPanel extends StatelessWidget {
  const HospitalizationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final hospNotifier = context.watch<HospitalizationNotifier>();
    final formKey = GlobalKey<FormState>();
    final selectedHospitalization = hospNotifier.selectedHospitalization;

    return ChangeNotifierProvider<HospitalizationFormNotifier>(
      key: ValueKey(selectedHospitalization?.id ?? 'create'),
      create: (BuildContext context) => HospitalizationFormNotifier(
        createHospitalizationUseCase: context.read(),
        updateHospitalizationUseCase: context.read(),
        hospitalization: selectedHospitalization,
        patient: selectedHospitalization?.patient ?? hospNotifier.patient,
      ),
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, child) {
          final title = notifier.isCreate ? 'Yeni Yatış Gir' : 'Yatış Düzenle';
          return SidePanel(
            title: title,
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
            isLoading: notifier.isLoading(notifier.submitOp),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    _CodeField(),
                    _PatientField(),
                    _DoctorField(),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [_PhysicalServiceField(), _InpatientServiceField()],
                    ),
                    Row(spacing: AppDimensions.registrationDialogSpacing, children: [_RoomField(), _BedField()]),
                    Row(
                      spacing: AppDimensions.registrationDialogSpacing,
                      children: [_AdmissionDateField(), _ExitDateField()],
                    ),
                    _DescriptionField(),
                    _BabyToggle(),
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

class _PatientField extends StatelessWidget {
  const _PatientField();

  @override
  Widget build(BuildContext context) {
    return Consumer<HospitalizationFormNotifier>(
      builder: (context, notifier, _) {
        return SelectionField<Patient>(
          label: 'Hasta',
          title: 'Hasta',
          initialValue: notifier.patient,
          labelBuilder: (value) => value.fullName,
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          dataSource: (skip, take, search) => context.read<GetPatientsUseCase>().call(GetPatientsParams()),
          onSelected: (value) => notifier.selectPatient(value),
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
        return SelectionField<User>(
          label: 'Doktor',
          title: 'Doktor',
          initialValue: notifier.doctor,
          labelBuilder: (value) => value.fullName,
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(const GetUsersParams()),
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
          return SelectionField<HospitalService>(
            label: 'Fiziki Servis',
            title: 'Fiziki Servis',
            initialValue: notifier.hospitalization?.physicalService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            labelBuilder: (s) => s.name ?? '-',
            dataSource: (skip, take, search) => context.read<IServiceRepository>().getServices(),
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
          return SelectionField<HospitalService>(
            label: 'Yatış Servis',
            title: 'Yatış Servis',
            labelBuilder: (s) => s.name ?? '-',
            initialValue: notifier.hospitalization?.inpatientService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            dataSource: (skip, take, search) => context.read<IServiceRepository>().getServices(),
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
          return SelectionField<Room>(
            label: 'Oda',
            title: 'Oda Seç',
            enabled: notifier.isRoomEnabled,
            initialValue: notifier.selectedRoom,
            validator: (r) => Validators.cannotBlankValidator(r?.name),
            labelBuilder: (r) => r.name ?? '-',
            dataSource: (skip, take, search) async {
              final filtered = search == null || search.isEmpty
                  ? notifier.rooms
                  : notifier.rooms.where((r) => (r.name ?? '').toLowerCase().contains(search.toLowerCase())).toList();
              return Result.ok(ApiResponse(data: filtered, totalCount: filtered.length));
            },
            onSelected: (r) => notifier.selectRoom(r),
          );
        },
      ),
    );
  }
}

class _BedField extends StatelessWidget {
  const _BedField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return SelectionField<Bed>(
            label: 'Yatak',
            title: 'Yatak Seç',
            enabled: notifier.isBedEnabled,
            initialValue: notifier.selectedBed,
            validator: (b) => Validators.cannotBlankValidator(b?.name),
            labelBuilder: (b) => b.name ?? '-',
            dataSource: (skip, take, search) async {
              final filtered = search == null || search.isEmpty
                  ? notifier.beds
                  : notifier.beds.where((b) => (b.name ?? '').toLowerCase().contains(search.toLowerCase())).toList();
              return Result.ok(ApiResponse(data: filtered, totalCount: filtered.length));
            },
            onSelected: (b) => notifier.selectBed(b),
          );
        },
      ),
    );
  }
}

// * Yatış Tarihi (hospitalization.admissionDate)
class _AdmissionDateField extends StatelessWidget {
  const _AdmissionDateField();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, _) {
          return DateInputField(
            label: 'Yatış Tarihi',
            firstDate: DateTime.now(),
            initialValue: notifier.hospitalization?.admissionDate,
            onDateSelected: notifier.updateAdmissionDate,
          );
        },
      ),
    );
  }
}

// * Çıkış Tarihi (hospitalization.exitDate)
class _ExitDateField extends StatelessWidget {
  const _ExitDateField();

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
        return CheckboxField(
          label: 'Bebek',
          onChanged: (_) => notifier.toggleIsBaby(),
          value: notifier.hospitalization?.isBaby ?? false,
        );
      },
    );
  }
}
