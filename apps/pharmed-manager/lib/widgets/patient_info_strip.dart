// [SWREQ-MGR-RX-004] [IEC 62304 §5.5]
// Hasta/yatış bilgi şeridi — protokol no, servis, oda/yatak, yatış tarihi.
// Reçete işlemleri ve Uygulanmamış Reçeteler detay panellerinin üstünde
// ortak kullanılır. Değeri olmayan alan gösterilmez.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_manager/core/core.dart';

class PatientInfoStrip extends StatelessWidget {
  const PatientInfoStrip({super.key, required this.hospitalization});

  final Hospitalization hospitalization;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hosp = hospitalization;
    final room = hosp.bed?.room?.name ?? hosp.room?.name;
    final bed = hosp.bed?.name;
    final entries = <(IconData, String, String)>[
      if (hosp.patient?.protocolNo != null)
        (PhosphorIcons.identificationCard(), l10n.patient_fieldProtocolNo, hosp.patient!.protocolNo!),
      if (hosp.physicalService?.name != null)
        (PhosphorIcons.buildings(), l10n.tableCore_serviceColumn, hosp.physicalService!.name!),
      if (room != null || bed != null)
        (
          PhosphorIcons.bed(),
          '${l10n.unappliedPrescription_table_roomColumn} / ${l10n.unappliedPrescription_table_bedColumn}',
          [room ?? '—', bed ?? '—'].join(' / '),
        ),
      if (hosp.admissionDate != null)
        (PhosphorIcons.calendarCheck(), l10n.hospitalization_fieldAdmissionDate, hosp.admissionDate!.formattedDate),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 10,
        children: [
          for (final (icon, label, value) in entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(icon, size: 16, color: MedColors.text3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: MedTextStyles.monoXs(color: MedColors.text3)),
                    Text(value, style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
