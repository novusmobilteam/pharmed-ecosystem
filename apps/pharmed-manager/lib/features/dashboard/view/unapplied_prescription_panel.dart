import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';
import '../dashboard.dart';

// [SWREQ-MGR-DASH-007]
// Dashboard — uygulanmamış reçeteler kompakt liste paneli.
// Sınıf: Class A

class UnappliedPrescriptionPanel extends StatelessWidget {
  const UnappliedPrescriptionPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItem>> section;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItem>[];

    return DashboardListPanel<List<PrescriptionItem>>(
      key: const ValueKey('unapplied_panel'),
      useCarousel: true,
      title: context.l10n.dashboardUnappliedPrescriptionsPanelTitle,
      count: items.length,
      countColor: MedColors.amber,
      countBg: MedColors.amberLight,
      section: section,
      itemCount: items.length,
      emptyTitle: context.l10n.dashboardUnappliedPrescriptionsEmptyTitle,
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardRxItemCard(
          item: item,
          showFlags: true,
          showStatusChip: false,
          showTimeChip: true,
          infoRows: [
            MedInfoRow(
              label: context.l10n.assignment_patientLabel,
              value: item.prescription?.hospitalization?.patient?.fullName ?? '-',
            ),
            MedInfoRow(label: context.l10n.dashboardDoctorLabel, value: item.doctor?.fullName ?? '-'),
            MedInfoRow(label: 'SERVİS', value: item.prescription?.hospitalization?.physicalService?.name ?? '-'), // TODO(l10n): no all-caps ARB key exists for this label yet; see migration report
            MedInfoRow(
              label: context.l10n.dashboardRoomBedLabel,
              value: [
                item.prescription?.hospitalization?.room?.name,
                item.prescription?.hospitalization?.bed?.name,
              ].whereType<String>().join(' / '),
            ),
          ],
        );
      },
    );
  }
}
