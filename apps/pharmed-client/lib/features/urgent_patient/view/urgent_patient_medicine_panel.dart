part of 'urgent_patient_screen.dart';

class UrgentPatientDetailPanel extends StatelessWidget {
  const UrgentPatientDetailPanel({super.key, required this.urgentPatient});

  final UrgentPatient? urgentPatient;

  @override
  Widget build(BuildContext context) {
    final patient = urgentPatient;
    final bool isMedicineTaken = patient?.prescriptionItems?.isNotEmpty ?? false;

    if (patient == null) {
      return Center(
        child: Text(
          context.l10n.urgentPatientTermination_selectHint,
          style: MedTextStyles.bodyMd(color: MedColors.text3),
        ),
      );
    }

    return Container(
      //padding: MedSpacing.panelInsetPadding,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UrgentPatientDetailHeader(patient: patient),
          const SizedBox(height: MedSpacing.lg),
          if (isMedicineTaken)
            Expanded(
              child: Padding(
                padding: MedSpacing.panelInsetPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.urgentPatientTermination_takenMedicinesTitle.toUpperCase(),
                      style: MedTextStyles.bodySm(color: MedColors.text3),
                    ),
                    const SizedBox(height: MedSpacing.sm),
                    Expanded(child: _UrgentPatientMedicineList(items: patient.prescriptionItems!)),
                  ],
                ),
              ),
            ),
          if (!isMedicineTaken)
            Center(
              child: EmptyStateWidget(
                title: context.l10n.urgentPatientTermination_noMedicineEmptyTitle,
                description: context.l10n.urgentPatientTermination_noMedicineEmptyDescription,
              ),
            ),
        ],
      ),
    );
  }
}

class _UrgentPatientDetailHeader extends StatelessWidget {
  const _UrgentPatientDetailHeader({required this.patient});

  final UrgentPatient patient;

  @override
  Widget build(BuildContext context) {
    final bool isMedicineTaken = patient.prescriptionItems?.isNotEmpty ?? false;

    return Container(
      height: 120,
      alignment: Alignment.centerLeft,
      padding: MedSpacing.insetLg * 2,
      decoration: BoxDecoration(
        color: MedColors.redLight,
        borderRadius: const BorderRadius.only(topLeft: MedRadius.md, topRight: MedRadius.md),
      ),
      child: Row(
        children: [
          MedAvatar(initials: 'AH', palette: AvatarPalette.red, size: 48, showBorder: false),

          const SizedBox(width: MedSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(context.l10n.urgentPatientTermination_defaultPatientLabel, style: MedTextStyles.titleMd()),
                  const SizedBox(width: 18),
                  Text(
                    context.l10n.urgentPatientTermination_openRecordChip,
                    style: MedTextStyles.monoSm(color: MedColors.red),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'KOD ${patient.id} · ID ${patient.patient?.id}',
                style: MedTextStyles.monoMd(color: MedColors.text3),
              ),
            ],
          ),
          SizedBox(width: MedSpacing.md),
          Container(
            width: 1,
            height: 48,
            color: MedColors.border,
            margin: const EdgeInsets.symmetric(horizontal: MedSpacing.md),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.urgentPatientTermination_serviceLabel,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
              Text(patient.inpatientService?.name ?? '—', style: MedTextStyles.monoMd()),
            ],
          ),
          SizedBox(width: MedSpacing.xl),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.drugActivity_column_date, style: MedTextStyles.bodySm(color: MedColors.text3)),
              Text(patient.admissionDate.formattedDateTime, style: MedTextStyles.monoMd()),
            ],
          ),

          Spacer(),
          if (isMedicineTaken && patient.prescriptionItems != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(context.l10n.drugActivity_column_quantity, style: MedTextStyles.bodySm(color: MedColors.text3)),
                Text(patient.prescriptionItems!.length.toString(), style: MedTextStyles.titleXl()),
              ],
            ),
        ],
      ),
    );
  }
}

class _UrgentPatientMedicineList extends StatelessWidget {
  const _UrgentPatientMedicineList({required this.items});

  final List<PrescriptionItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items.elementAt(index);
        final dose = '${item.dosePiece?.formatFractional} ${item.medicine?.operationUnitLocalized(context)}';
        return Container(
          margin: EdgeInsets.only(bottom: 8.0),
          padding: MedSpacing.insetXl,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: MedColors.border),
            color: MedColors.surface,
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.medicine?.name ?? '', style: MedTextStyles.titleMd()),
                    Text(item.medicine?.barcode ?? '', style: MedTextStyles.monoMd(color: MedColors.text4)),
                  ],
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.enumCore_cabinInventoryTypeIntakeFieldText,
                      style: MedTextStyles.monoMd(color: MedColors.text4),
                    ),
                    Text(dose, style: MedTextStyles.titleSm()),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.movement_performedBy, style: MedTextStyles.monoMd(color: MedColors.text4)),
                    Text(item.applicationUser?.fullName.toString() ?? '-', style: MedTextStyles.titleSm()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UrgentPatientFooter extends StatelessWidget {
  const UrgentPatientFooter({
    super.key,
    required this.urgentPatient,
    required this.targetPatient,
    required this.isSubmitting,
    required this.onSubmit,
    required this.isDeleting,
    required this.onDelete,
  });

  final UrgentPatient urgentPatient;
  final Hospitalization targetPatient;

  final bool isSubmitting;
  final VoidCallback onSubmit;

  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    bool isMedicineTaken = urgentPatient.prescriptionItems?.isNotEmpty ?? false;

    return Container(
      alignment: Alignment.center,
      padding: MedSpacing.panelInsetPadding,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: MedColors.border),
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
      ),
      child: isMedicineTaken ? buildTerminateView(context) : buildDeleteView(context),
    );
  }

  Widget buildTerminateView(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.urgentPatientTermination_sourceLabel,
                style: MedTextStyles.titleSm(color: MedColors.text3),
              ),
              Text(
                context.l10n.urgentPatientTermination_sourceValue(urgentPatient.id.toString()),
                style: MedTextStyles.monoMd(),
              ),
            ],
          ),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.urgentPatientTermination_targetLabel,
                style: MedTextStyles.titleSm(color: MedColors.text3),
              ),
              Text(
                '${targetPatient.patient?.fullName ?? '—'} · ${targetPatient.inpatientService?.name ?? '—'}',
                style: MedTextStyles.monoMd(),
              ),
            ],
          ),
        ),
        MedButton(
          label: context.l10n.urgentPatientTermination_finalizeButton,
          variant: MedButtonVariant.danger,
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  Widget buildDeleteView(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: MedButton(
        label: context.l10n.common_deleteTooltip,
        variant: MedButtonVariant.danger,
        isLoading: isDeleting,
        onPressed: onDelete,
      ),
    );
  }
}
