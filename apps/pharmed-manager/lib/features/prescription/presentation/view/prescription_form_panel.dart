part of 'prescription_screen.dart';

// Yeni Reçete Oluşturma işleminde kullanılan view
class PrescriptionFormPanel extends StatefulWidget {
  const PrescriptionFormPanel({super.key});

  @override
  State<PrescriptionFormPanel> createState() => _PrescriptionFormPanelState();
}

class _PrescriptionFormPanelState extends State<PrescriptionFormPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _doseController;
  late final TextEditingController _descriptionController;
  late final List<TextEditingController> _timeControllers;

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController();
    _descriptionController = TextEditingController();
    _timeControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    _doseController.dispose();
    _descriptionController.dispose();
    for (final c in _timeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presNotifier = context.watch<PrescriptionNotifier>();
    final selectedHospitalization = presNotifier.selectedHospitalization;

    return ChangeNotifierProvider(
      key: ValueKey(selectedHospitalization?.id ?? 'create'),
      create: (BuildContext context) =>
          PrescriptionFormNotifier(useCase: context.read(), hospitalization: selectedHospitalization),
      child: Consumer<PrescriptionFormNotifier>(
        builder: (context, notifier, _) {
          return SidePanel(
            title: 'Yeni Reçete Oluşturma',
            subtitle: 'REÇETE FORMU',
            onClose: () => _onClose(context, notifier),
            onSave: () => _onSave(context, notifier),
            isLoading: notifier.isSubmitting,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppDimensions.registrationDialogSpacing,
                children: [
                  const _PatientField(),
                  const _DoctorField(),
                  const _DrugField(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      _DosePieceField(_doseController),
                      Expanded(flex: 2, child: _RequestTypeField()),
                    ],
                  ),
                  _ChecboxField(),
                  _TimesRow(_timeControllers),

                  _DescriptionField(_descriptionController),
                  MedButton(
                    label: 'Reçeteye Ekle',
                    variant: MedButtonVariant.secondary,
                    fullWidth: true,
                    isActive: notifier.isButtonActive,
                    onPressed: () => _onAdd(context, notifier),
                  ),
                  _PrescriptionList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onClose(BuildContext context, PrescriptionFormNotifier notifier) {
    if (notifier.prescriptionItems.isNotEmpty) {
      MessageUtils.showConfirmExitDialog(
        context: context,
        onConfirm: () => context.read<PrescriptionNotifier>().closePanel(),
      );
    } else {
      context.read<PrescriptionNotifier>().closePanel();
    }
  }

  void _onSave(BuildContext context, PrescriptionFormNotifier notifier) {
    if (notifier.prescriptionItems.isEmpty) return;
    notifier.submit(
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) {
        MessageUtils.showSuccessSnackbar(context, msg ?? '');
        context.read<PrescriptionNotifier>().closePanel();
      },
    );
  }

  void _onAdd(BuildContext context, PrescriptionFormNotifier notifier) {
    if (_formKey.currentState!.validate()) {
      notifier.addCurrentItem();
      notifier.resetForm();
      _doseController.clear();
      _descriptionController.clear();
      for (final c in _timeControllers) {
        c.clear();
      }
    }
  }
}

class _PatientField extends StatelessWidget {
  const _PatientField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return Lockable(
          locked: !vm.isPatientSelectionEnabled,
          child: SelectionField<Hospitalization>(
            label: 'Hasta',
            initialValue: vm.hospitalization,
            labelBuilder: (u) => u.patient?.fullName,
            onSelected: (u) => vm.updatePatient(u),
            validator: (u) => Validators.cannotBlankValidator(u?.patient?.fullName),
            dataSource: (skip, take, search) =>
                context.read<GetHospitalizationsUseCase>().call(GetHospitalizationsParams()),
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
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return SelectionField<User>(
          label: 'Doktor',
          initialValue: vm.currentItem.doctor,
          labelBuilder: (u) => u.fullName,
          onSelected: (u) => vm.updateDoctor(u),
          validator: (u) => Validators.cannotBlankValidator(u?.fullName),
          dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(const GetUsersParams()),
        );
      },
    );
  }
}

class _DrugField extends StatelessWidget {
  const _DrugField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return SelectionField<Medicine>(
          key: ValueKey('drug_${vm.currentItem.medicine?.id}'),
          label: 'İlaç / Malzeme',
          labelBuilder: (d) => d.name,
          initialValue: vm.currentItem.medicine,
          onSelected: (d) => vm.updateMaterial(d),
          validator: (d) => Validators.cannotBlankValidator(d?.name),
          dataSource: (skip, take, search) => context.read<IMedicineRepository>().getMedicines(),
        );
      },
    );
  }
}

class _DosePieceField extends StatelessWidget {
  const _DosePieceField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return DoseStepper(
          type: DoseStepperType.compact,
          platform: DoseStepperPlatform.desktop,
          value: vm.currentItem.dosePiece?.toDouble() ?? 0,

          step: vm.currentItem.medicine?.operationStep ?? 1.0,
          unit: vm.currentItem.medicine?.operationUnit ?? 'Adet',
          onChanged: (newVal) => vm.updateDosePiece(newVal),
        );
      },
    );
  }
}

class _RequestTypeField extends StatelessWidget {
  const _RequestTypeField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return DropdownInputField<RequestType>(
          label: 'İstek Tipi',
          options: RequestType.values,
          labelBuilder: (t) => t?.label,
          initialValue: vm.currentItem.requestType,
          onChanged: (t) => vm.updateRequestType(t),
          validator: (t) => Validators.cannotBlankValidator(t?.label),
        );
      },
    );
  }
}

class _TimesRow extends StatelessWidget {
  const _TimesRow(this.controllers);

  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppDimensions.registrationDialogSpacing / 3,
      children: List.generate(6, (index) {
        return Expanded(
          child: _TimeBox(
            index: index,
            controller: controllers[index], // İlgili controller'ı gönder
          ),
        );
      }),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.index, required this.controller});

  final int index;
  final TextEditingController controller;

  String _dayLabel(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = targetDay.difference(today).inDays;

    const dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final dayName = dayNames[dateTime.weekday - 1];

    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Yarın';
    return dayName;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        final times = vm.currentItem.times;
        final currentTime = times?.elementAtOrNull(index).toTimeOfDay;
        final currentDateTime = times?.elementAtOrNull(index);

        final dayLabel = _dayLabel(currentDateTime);

        return SizedBox(
          height: 95,
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TimeInputField(
                key: ValueKey('time_${index}_${currentTime?.hashCode}'),
                label: 'Saat',
                //controller: controller,
                initialValue: currentTime,
                //dayHint: dayLabel.isEmpty ? 'Bugün' : dayLabel,
                onTimeSelected: (time) => vm.updateDoseHour(index, time),
              ),
              if (dayLabel.isNotEmpty)
                SizedBox(
                  width: context.width * 0.6,
                  child: InfoChip(info: dayLabel),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return TextInputField(
          label: 'Açıklama',
          controller: controller,
          maxLines: 3,
          initialValue: vm.currentItem.description,
          onChanged: (v) => vm.updateDescription(v),
        );
      },
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();
    final items = notifier.prescriptionItems;

    if (items.isEmpty) {
      return SizedBox();
    }

    return Column(
      spacing: 6,
      children: items.asMap().entries.map((entry) {
        return PrescriptionItemCard(item: entry.value, index: entry.key, onDelete: notifier.removeItemAt);
      }).toList(),
    );
  }
}

class _ChecboxField extends StatelessWidget {
  const _ChecboxField();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionFormNotifier>(
      builder: (context, vm, _) {
        return Row(
          spacing: 8,
          children: [
            CheckboxField(
              label: 'İlk Doz Acil',
              value: vm.currentItem.firstDoseEmergency ?? false,
              onChanged: (_) => vm.toggleFirstDoseEmergency(),
            ),
            CheckboxField(
              label: 'Doktora Sor',
              value: vm.currentItem.askDoctor ?? false,
              onChanged: (_) => vm.toggleAskDoctor(),
            ),
            CheckboxField(
              label: 'Lüzum Halinde',
              value: vm.currentItem.inCaseOfNecessity ?? false,
              onChanged: (_) => vm.toggleInCaseOfNecessity(),
            ),
          ],
        );
      },
    );
  }
}
