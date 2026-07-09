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
        getRoomsUseCase: context.read(),
        getBedsUseCase: context.read(),
        createHospitalizationUseCase: context.read(),
        updateHospitalizationUseCase: context.read(),
        hospitalization: selectedHospitalization,
        patient: selectedHospitalization?.patient ?? hospNotifier.patient,
      ),
      child: Consumer<HospitalizationFormNotifier>(
        builder: (context, notifier, child) {
          final title = notifier.isCreate
              ? context.l10n.hospitalization_formTitleNew
              : context.l10n.hospitalization_formTitleEdit;
          return SidePanel(
            title: title,
            onClose: hospNotifier.closePanel,
            onSave: () {
              if (formKey.currentState!.validate()) {
                notifier.submit(
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  onSuccess: () {
                    MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                    hospNotifier.closePanel();
                    hospNotifier.fetch();
                  },
                );
              }
            },
            isLoading: notifier.isLoading(notifier.submitOp),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
        final label = context.l10n.hospitalization_fieldPatient;
        return MedSelectionField<Patient>(
          label: label,
          title: label,
          initialValue: notifier.patient,
          labelBuilder: (value) => value.fullName,
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          dataSource: (skip, take, search) =>
              context.read<GetPatientsUseCase>().call(GetPatientsParams(skip: skip, take: take, search: search)),
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
        return IgnorePointer(
          ignoring: true,
          child: MedTextInputField(
            label: context.l10n.hospitalization_fieldCode,
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
        final label = context.l10n.hospitalization_fieldDoctor;
        return MedSelectionField<User>(
          label: label,
          title: label,
          initialValue: notifier.doctor,
          labelBuilder: (value) => value.fullName,
          validator: (value) => Validators.cannotBlankValidator(value?.fullName),
          dataSource: (skip, take, search) =>
              context.read<GetDoctorsUseCase>().call(GetDoctorsParams(search: search, skip: skip, take: take)),
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
          final label = context.l10n.hospitalization_fieldPhysicalService;
          return MedSelectionField<HospitalService>(
            label: label,
            title: label,
            initialValue: notifier.hospitalization?.physicalService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            labelBuilder: (s) => s.name ?? '-',
            dataSource: (skip, take, search) =>
                context.read<GetServicesUseCase>().call(PagedQueryParams(searchQuery: search, skip: skip, take: take)),
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
          final label = context.l10n.hospitalization_fieldInpatientService;
          return MedSelectionField<HospitalService>(
            label: label,
            title: label,
            labelBuilder: (s) => s.name ?? '-',
            initialValue: notifier.hospitalization?.inpatientService,
            validator: (s) => Validators.cannotBlankValidator(s?.name),
            dataSource: (skip, take, search) =>
                context.read<GetServicesUseCase>().call(PagedQueryParams(searchQuery: search, skip: skip, take: take)),
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
          return MedSelectionField<Room>(
            key: ValueKey(notifier.selectedRoom?.id ?? 'room_${notifier.selectedService?.id}'),
            label: context.l10n.hospitalization_fieldRoom,
            title: context.l10n.hospitalization_roomDialogTitle,
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
          return MedSelectionField<Bed>(
            key: ValueKey(notifier.selectedBed?.id ?? 'bed_${notifier.selectedRoom?.id}'),
            label: context.l10n.hospitalization_fieldBed,
            title: context.l10n.hospitalization_bedDialogTitle,
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
          return MedDateInputField(
            label: context.l10n.hospitalization_fieldAdmissionDate,
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
          return MedDateInputField(
            label: context.l10n.hospitalization_fieldExitDate,
            onDateSelected: (date) {
              notifier.updateExitDate(date);
            },
          );
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
        return MedTextInputField(
          label: context.l10n.common_descriptionLabel,
          hintText: context.l10n.common_descriptionLabel,
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
        return MedCheckboxField(
          label: context.l10n.hospitalization_checkboxBaby,
          onChanged: (_) => notifier.toggleIsBaby(),
          value: notifier.hospitalization?.isBaby ?? false,
        );
      },
    );
  }
}
