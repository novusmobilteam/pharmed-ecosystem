import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/dose_stepper.dart';
import '../../../../core/widgets/form/form_inputs/time_input_field.dart';

import 'package:provider/provider.dart';

import '../../../../core/widgets/info_chip.dart';

import '../notifier/new_prescription_notifier.dart';
import '../widgets/prescription_item_card.dart';

// Yeni Reçete Oluşturma işleminde kullanılan view
class NewPrescriptionView extends StatefulWidget {
  const NewPrescriptionView({super.key});

  @override
  State<NewPrescriptionView> createState() => _NewPrescriptionViewState();
}

class _NewPrescriptionViewState extends State<NewPrescriptionView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _doseController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _timeControllers;

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController();
    _descriptionController = TextEditingController();
    _timeControllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  void dispose() {
    _doseController.dispose();
    _descriptionController.dispose();
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Yeni Reçete Oluşturma',
          saveButtonText: 'Kaydet',
          width: context.width * 0.7,
          maxHeight: context.height,
          onClose: () => _onClose(context, notifier),
          isButtonActive: notifier.prescriptionItems.isNotEmpty,
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () {
            if (notifier.prescriptionItems.isNotEmpty) {
              notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
                },
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      _PatientField(),
                      _DoctorField(),
                      _DrugField(),
                      Row(
                        spacing: AppDimensions.registrationDialogSpacing,
                        children: [
                          Expanded(child: _DosePieceField(_doseController)),
                          Expanded(flex: 2, child: _RequestTypeField()),
                        ],
                      ),
                      _TimesRow(_timeControllers),
                      _DescriptionField(_descriptionController),
                      _ChecboxField(),
                      Spacer(),
                      SizedBox(
                        width: 200,
                        child: PharmedButton(
                          onPressed: () => _onAdd(context, notifier),
                          isActive: notifier.isButtonActive,
                          label: 'Ekle',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 3, child: _prescriptionListView(notifier)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _prescriptionListView(NewPrescriptionNotifier notifier) {
    if (notifier.prescriptionItems.isEmpty) {
      return Center(
        child: CommonEmptyStates.generic(
          iconSize: 32,
          icon: PhosphorIcons.receipt(),
          message: 'Reçete detayları\nburada görüntülenecektir.',
          messageStyle: context.textTheme.bodyMedium,
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: notifier.prescriptionItems.length,
        itemBuilder: (BuildContext context, int index) {
          final item = notifier.prescriptionItems.elementAt(index);
          return PrescriptionItemCard(item: item, index: index, onDelete: (index) => notifier.removeItemAt(index));
        },
      );
    }
  }

  void _onClose(BuildContext context, NewPrescriptionNotifier notifier) {
    if (notifier.prescriptionItems.isNotEmpty) {
      MessageUtils.showConfirmExitDialog(context: context, onConfirm: context.pop);
    } else {
      context.pop();
    }
  }

  void _onAdd(BuildContext context, NewPrescriptionNotifier notifier) {
    if (_formKey.currentState!.validate()) {
      notifier.addCurrentItem();
      notifier.resetForm();

      _doseController.clear();
      _descriptionController.clear();

      for (var controller in _timeControllers) {
        controller.clear();
      }
    }
  }
}

class _PatientField extends StatelessWidget {
  const _PatientField();

  @override
  Widget build(BuildContext context) {
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, vm, _) {
        return Lockable(
          locked: !vm.isPatientSelectionEnabled,
          child: DialogInputField<Hospitalization>(
            label: 'Hasta',
            initialValue: vm.hospitalization,
            labelBuilder: (u) => u?.patient?.fullName,
            onSelected: (u) => vm.updatePatient(u),
            validator: (u) => Validators.cannotBlankValidator(u?.patient?.fullName),
            future: () => context.read<GetHospitalizationsUseCase>().call(GetHospitalizationsParams()),
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
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, vm, _) {
        return DialogInputField<User>(
          label: 'Doktor',
          initialValue: vm.currentItem.doctor,
          labelBuilder: (u) => u?.fullName,
          onSelected: (u) => vm.updateDoctor(u),
          validator: (u) => Validators.cannotBlankValidator(u?.fullName),
          future: () => context.read<GetUsersUseCase>().call(const GetUsersParams()),
        );
      },
    );
  }
}

class _DrugField extends StatelessWidget {
  const _DrugField();

  @override
  Widget build(BuildContext context) {
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, vm, _) {
        return DialogInputField<Medicine>(
          key: ValueKey('drug_${vm.currentItem.medicine?.id}'),
          label: 'İlaç / Malzeme',
          labelBuilder: (d) => d?.name,
          initialValue: vm.currentItem.medicine,
          onSelected: (d) => vm.updateMaterial(d),
          validator: (d) => Validators.cannotBlankValidator(d?.name),
          future: () => context.read<IMedicineRepository>().getMedicines(),
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
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, vm, _) {
        return DoseStepper(
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
    return Consumer<NewPrescriptionNotifier>(
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
    return Consumer<NewPrescriptionNotifier>(
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
                controller: controller,
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
    return Consumer<NewPrescriptionNotifier>(
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

class _ChecboxField extends StatelessWidget {
  const _ChecboxField();

  @override
  Widget build(BuildContext context) {
    return Consumer<NewPrescriptionNotifier>(
      builder: (context, vm, _) {
        return Row(
          spacing: 8,
          children: [
            CustomCheckboxTile(
              label: 'İlk Doz Acil',
              value: vm.currentItem.firstDoseEmergency ?? false,
              onTap: () => vm.toggleFirstDoseEmergency(),
            ),
            CustomCheckboxTile(
              label: 'Doktora Sor',
              value: vm.currentItem.askDoctor ?? false,
              onTap: () => vm.toggleAskDoctor(),
            ),
            CustomCheckboxTile(
              label: 'Lüzum Halinde',
              value: vm.currentItem.inCaseOfNecessity ?? false,
              onTap: () => vm.toggleInCaseOfNecessity(),
            ),
          ],
        );
      },
    );
  }
}
