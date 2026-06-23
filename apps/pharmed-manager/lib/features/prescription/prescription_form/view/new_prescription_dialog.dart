// [SWREQ-MGR-RX-FORM-002] [IEC 62304 §5.5]
// Reçete oluşturma workspace dialog'u — üç-kolon layout.
// Sınıf: Class B (reçete oluşturma akışı)

import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../prescription.dart';

part 'prescription_source_column.dart';
part 'prescription_items_column.dart';

/// Reçete oluşturma dialog'unu açar. Workspace stili — geniş, padding'li,
/// dışa tıklama ile kapanmaz.
Future<void> showPrescriptionFormDialog(BuildContext context, {Hospitalization? hospitalization}) {
  final initial = hospitalization ?? context.read<PrescriptionNotifier>().selectedHospitalization;

  return showMedDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) =>
              PrescriptionFormNotifier(useCase: ctx.read(), hospitalization: initial, authNotifier: ctx.read()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PrescriptionHistoryNotifier(useCase: ctx.read())..setPatient(initial?.patient?.id),
        ),
      ],
      child: const _NewPrescriptionDialog(),
    ),
  );
}

class _NewPrescriptionDialog extends StatelessWidget {
  const _NewPrescriptionDialog();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = (size.width * 0.85).clamp(1200.0, 1600.0);

    return MedDialog(
      title: 'Yeni Reçete',
      subtitle: 'Reçete oluştur veya geçmiş reçeteden içe aktar',
      icon: PhosphorIcons.notepad(),
      width: width,
      maxHeightFactor: 0.85,
      padded: false,
      child: const Column(
        children: [
          _MetaBar(),
          Divider(height: 1, color: MedColors.border2),
          Expanded(child: _ThreeColumnBody()),
          Divider(height: 1, color: MedColors.border2),
          _FooterBar(),
        ],
      ),
    );
  }
}

class _MetaBar extends StatelessWidget {
  const _MetaBar();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: MedColors.surface2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 320, child: _PatientSelector()),
          const SizedBox(width: 16),
          SizedBox(width: 280, child: _DoctorSelector()),
          const Spacer(),
          _MetaInfoChip(icon: PhosphorIcons.calendar(), label: DateTime.now().formattedDate),
          const SizedBox(width: 12),
          _MetaInfoChip(icon: PhosphorIcons.listChecks(), label: '${notifier.items.length} kalem'),
          const SizedBox(width: 12),
          _DraftBadge(),
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

class _MetaInfoChip extends StatelessWidget {
  const _MetaInfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: MedColors.text3),
        const SizedBox(width: 6),
        Text(label, style: MedTextStyles.monoSm(color: MedColors.text2)),
      ],
    );
  }
}

class _DraftBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.xlAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: MedColors.text3, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('Taslak', style: MedTextStyles.monoXs()),
        ],
      ),
    );
  }
}

class _ThreeColumnBody extends StatelessWidget {
  const _ThreeColumnBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 340, child: PrescriptionSourceColumn()),
        const VerticalDivider(width: 1, color: MedColors.border2),
        Expanded(child: PrescriptionItemsColumn()),
        const VerticalDivider(width: 1, color: MedColors.border2),
        SizedBox(width: 440, child: _DetailColumn()),
      ],
    );
  }
}

class _DetailColumn extends StatefulWidget {
  const _DetailColumn();

  @override
  State<_DetailColumn> createState() => _DetailColumnState();
}

class _DetailColumnState extends State<_DetailColumn> {
  late TextEditingController _doseController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final selected = context.read<PrescriptionFormNotifier>().selectedItem;
    _doseController = TextEditingController(text: selected?.dosePiece?.toStringAsFixed(0) ?? '');
    _descriptionController = TextEditingController(text: selected?.description ?? '');
  }

  @override
  void dispose() {
    _doseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PrescriptionFormNotifier>();
    final selected = notifier.selectedItem;

    if (selected == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.cursorClick(), size: 32, color: MedColors.text4),
              const SizedBox(height: 12),
              Text(
                'Düzenlemek için bir kalem seçin',
                textAlign: TextAlign.center,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedSelectionField<Medicine>(
            label: 'İlaç / Malzeme',
            initialValue: selected.medicine,
            labelBuilder: (d) => d.name,
            onSelected: notifier.updateMedicine,
            dataSource: (skip, take, search) =>
                context.read<GetMedicinesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MedDoseStepper(
                  type: DoseStepperType.compact,
                  platform: DoseStepperPlatform.desktop,
                  value: selected.dosePiece?.toDouble() ?? 0,
                  step: selected.medicine?.operationStep ?? 1.0,
                  unit: selected.medicine?.operationUnit ?? 'Adet',
                  onChanged: notifier.updateDosePiece,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MedDropdownInputField<RequestType>(
                  label: 'İstek Tipi',
                  options: RequestType.values,
                  initialValue: selected.requestType,
                  labelBuilder: (t) => t?.label,
                  onChanged: notifier.updateRequestType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CheckboxRow(item: selected),
          const SizedBox(height: 16),
          _TimesGrid(item: selected),
          const SizedBox(height: 12),
          MedTextInputField(
            label: 'Açıklama',
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 3000,
            onChanged: notifier.updateDescription,
          ),
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({required this.item});

  final PrescriptionItem item;

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<PrescriptionFormNotifier>();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        MedCheckboxField(
          label: 'İlk Doz Acil',
          value: item.firstDoseEmergency ?? false,
          onChanged: (_) => notifier.toggleFirstDoseEmergency(),
          size: MedCheckboxSize.sm,
        ),
        MedCheckboxField(
          label: 'Doktora Sor',
          value: item.askDoctor ?? false,
          onChanged: (_) => notifier.toggleAskDoctor(),
          size: MedCheckboxSize.sm,
        ),
        MedCheckboxField(
          label: 'Lüzum Halinde',
          value: item.inCaseOfNecessity ?? false,
          onChanged: (_) => notifier.toggleInCaseOfNecessity(),
          size: MedCheckboxSize.sm,
        ),
      ],
    );
  }
}

class _TimesGrid extends StatelessWidget {
  const _TimesGrid({required this.item});
  final PrescriptionItem item;

  String _dayLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Bugün';
    if (diff == 1) return 'Yarın';
    const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return dayNames[dt.weekday - 1];
  }

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<PrescriptionFormNotifier>();
    final times = item.times ?? const <DateTime>[];
    final canAddMore = times.length < 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Saatler',
              style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            Text('(${times.length}/6)', style: MedTextStyles.monoXs(color: MedColors.text4)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: MedColors.surface2,
            borderRadius: MedRadius.smAll,
            border: Border.all(color: MedColors.border),
          ),
          child: Column(
            children: [
              ...List.generate(times.length, (i) {
                final dt = times[i];
                return _TimeRow(
                  index: i,
                  time: dt.toTimeOfDay,
                  label: _formatTime(dt),
                  dayLabel: _dayLabel(dt),
                  showDivider: i < times.length - 1 || canAddMore,
                  onTimeChanged: (t) => notifier.updateDoseHour(i, t),
                  onRemove: () => notifier.updateDoseHour(i, null),
                );
              }),
              if (canAddMore) _AddRow(onAdd: (t) => notifier.updateDoseHour(times.length, t)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.index,
    required this.time,
    required this.label,
    required this.dayLabel,
    required this.showDivider,
    required this.onTimeChanged,
    required this.onRemove,
  });

  final int index;
  final TimeOfDay? time;
  final String label;
  final String dayLabel;
  final bool showDivider;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: MedColors.border2)) : null,
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
          if (picked != null) onTimeChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(PhosphorIcons.clock(), size: 14, color: MedColors.text3),
              const SizedBox(width: 8),
              Text(
                label,
                style: MedTextStyles.monoMd(color: MedColors.text, weight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.xlAll),
                child: Text(dayLabel, style: MedTextStyles.monoXs(color: MedColors.text2)),
              ),
              const Spacer(),
              InkWell(
                onTap: onRemove,
                borderRadius: MedRadius.smAll,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(PhosphorIcons.x(), size: 14, color: MedColors.text3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.onAdd});

  final ValueChanged<TimeOfDay> onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
        if (picked != null) onAdd(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(PhosphorIcons.plus(), size: 14, color: MedColors.blue),
            const SizedBox(width: 8),
            Text(
              'Saat ekle',
              style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar();

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
              onChanged: (value) {},
              // onChanged: notifier.updateTemplateName,
            ),
          ),
        ],
      ],
    );
  }
}
