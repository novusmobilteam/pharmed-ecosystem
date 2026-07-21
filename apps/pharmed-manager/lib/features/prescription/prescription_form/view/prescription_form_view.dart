part of 'new_prescription_dialog.dart';

class PrescriptionFormView extends StatefulWidget {
  const PrescriptionFormView({super.key});

  @override
  State<PrescriptionFormView> createState() => PrescriptionFormViewState();
}

class PrescriptionFormViewState extends State<PrescriptionFormView> {
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
      return SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedSelectionField<Medicine>(
            key: ValueKey(notifier.selectedItem),
            label: context.l10n.prescriptionMedicineFieldLabel,
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
                  unit: selected.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback,
                  onChanged: notifier.updateDosePiece,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: MedDropdownInputField<RequestType>(
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
            label: context.l10n.prescriptionDescriptionFieldLabel,
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
          label: context.l10n.common_flagFirstDoseEmergency,
          value: item.firstDoseEmergency ?? false,
          onChanged: (_) => notifier.toggleFirstDoseEmergency(),
          size: MedCheckboxSize.md,
        ),
        MedCheckboxField(
          label: context.l10n.common_flagAskDoctor,
          value: item.askDoctor ?? false,
          onChanged: (_) => notifier.toggleAskDoctor(),
          size: MedCheckboxSize.md,
        ),
        MedCheckboxField(
          label: context.l10n.common_flagInCaseOfNecessity,
          value: item.inCaseOfNecessity ?? false,
          onChanged: (_) => notifier.toggleInCaseOfNecessity(),
          size: MedCheckboxSize.md,
        ),
      ],
    );
  }
}

class _TimesGrid extends StatelessWidget {
  const _TimesGrid({required this.item});

  final PrescriptionItem item;

  String _dayLabel(BuildContext context, DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return context.l10n.date_preset_today;
    if (diff == 1) return context.l10n.prescriptionTomorrowLabel;
    // Aktif locale'e göre kısaltılmış gün adı (ör. tr: "Pzt", en: "Mon").
    // DateTime.weekday (Pzt=1..Paz=7) ile aynı sırayı korur.
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('E', locale).format(dt);
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
              context.l10n.prescriptionTimesLabel,
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
                  dayLabel: _dayLabel(context, dt),
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
              context.l10n.prescriptionAddTimeButton,
              style: MedTextStyles.bodySm(color: MedColors.blue, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
