part of 'urgent_patient_screen.dart';

class UrgentPatientPanel extends StatelessWidget {
  const UrgentPatientPanel({
    super.key,
    required this.urgentPatients,
    required this.selected,
    required this.isLoading,
    required this.onSelected,
  });

  final List<UrgentPatient> urgentPatients;
  final UrgentPatient? selected;
  final bool isLoading;
  final ValueChanged<UrgentPatient> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.panelInsetPadding,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(context.l10n.urgentPatientTermination_listTitle, style: MedTextStyles.titleSm()),
              const Spacer(),
              MedChip(
                label: '${urgentPatients.length}',
                size: MedChipSize.sm,
                style: MedChipStyle.danger,
                showBorder: false,
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: isLoading
                ? const Center(child: MedLoadingIndicator())
                : urgentPatients.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : ListView.separated(
                    itemCount: urgentPatients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                    itemBuilder: (context, i) {
                      final p = urgentPatients[i];
                      return _UrgentPatientListItem(
                        patient: p,
                        isSelected: selected?.id == p.id,
                        onTap: () => onSelected(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UrgentPatientListItem extends StatelessWidget {
  const _UrgentPatientListItem({required this.patient, required this.isSelected, required this.onTap});

  final UrgentPatient patient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    bool isMedicineTaken = patient.prescriptionItems?.isNotEmpty ?? false;
    final label = isMedicineTaken
        ? context.l10n.urgentPatientTermination_medicineTakenChip
        : context.l10n.urgentPatientTermination_medicineNotTakenChip;
    final chipColor = isMedicineTaken ? MedColors.amber : MedColors.border;
    final foregroundColor = isMedicineTaken ? MedColors.amberLight : MedColors.text3;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetLg,
        decoration: BoxDecoration(
          color: isSelected ? MedColors.redLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.red : MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${patient.id}', style: MedTextStyles.monoSm()),
                const SizedBox(height: 4),
                Text(patient.inpatientService?.name ?? '—', style: MedTextStyles.bodyMd(weight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(patient.admissionDate?.formattedDateTime ?? '—', style: MedTextStyles.monoMd()),
              ],
            ),
            Column(
              children: [
                MedChip(
                  label: label,
                  background: chipColor,
                  foreground: foregroundColor,
                  showBorder: false,
                  size: MedChipSize.md,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
