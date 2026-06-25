part of 'new_prescription_dialog.dart';

class MetadataBar extends StatelessWidget {
  const MetadataBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: MedColors.surface2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _PatientSelector()),
          const SizedBox(width: 16),
          Expanded(child: _DoctorSelector()),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PatientSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final form = context.watch<PrescriptionFormNotifier>();
    return IgnorePointer(
      ignoring: !form.isPatientSelectionEnabled,
      child: MedSelectionField<Hospitalization>(
        label: 'Hasta',
        initialValue: form.hospitalization,
        labelBuilder: (h) => h.patient?.fullName,
        onSelected: (h) {
          form.updatePatient(h);
          context.read<PrescriptionHistoryNotifier>().setPatient(h?.patient?.id);
        },
        dataSource: (skip, take, search) => context.read<GetHospitalizationsUseCase>().call(
          PagedQueryParams(searchQuery: search, skip: skip, take: take),
        ),
      ),
    );
  }
}

class _DoctorSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();
    return MedSelectionField<User>(
      label: 'Doktor',
      initialValue: notifier.doctor,
      labelBuilder: (u) => u.fullName,
      onSelected: notifier.updateDoctor,
      dataSource: (skip, take, search) =>
          context.read<GetDoctorsUseCase>().call(GetDoctorsParams(skip: skip, take: take, search: search)),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: MedColors.surface2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TemplateToggle(),
          const Spacer(),
          MedButton(label: 'İptal', variant: MedButtonVariant.ghost, onPressed: () => _onClose(context, notifier)),
          const SizedBox(width: 12),
          MedButton(
            label: 'Reçeteyi Kaydet',
            variant: MedButtonVariant.primary,
            prefixIcon: Icon(PhosphorIcons.check()),
            isActive: notifier.canSave,
            isLoading: notifier.isSubmitting,
            onPressed: () => _onSave(context, notifier),
          ),
        ],
      ),
    );
  }

  void _onClose(BuildContext context, PrescriptionFormNotifier notifier) {
    if (notifier.items.isNotEmpty) {
      MessageUtils.showConfirmExitDialog(context: context, onConfirm: () => Navigator.of(context).pop());
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSave(BuildContext context, PrescriptionFormNotifier notifier) {
    notifier.submit(
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) {
        MessageUtils.showSuccessSnackbar(context, msg ?? '');
        Navigator.of(context).pop();
      },
    );
  }
}

class _TemplateToggle extends StatelessWidget {
  const _TemplateToggle();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MedCheckboxField(
          label: 'Şablon olarak da kaydet',
          value: notifier.saveAsTemplate,
          onChanged: (_) => notifier.toggleSaveAsTemplate(),
          size: MedCheckboxSize.sm,
        ),
        if (notifier.saveAsTemplate) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 240,
            child: MedTextInputField(
              hintText: 'Şablon Adı',
              initialValue: notifier.templateName,
              onChanged: (name) => notifier.updateTemplateName(name),
            ),
          ),
        ],
      ],
    );
  }
}
