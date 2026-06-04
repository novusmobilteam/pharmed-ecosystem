import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_manager/features/dashboard/dashboard.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../widgets/widgets.dart';

// [SWREQ-MGR-DASH-008]
// Dashboard — yaklaşan tedaviler kompakt liste paneli.
// Sınıf: Class A

class UpcomingTreatmentPanel extends StatelessWidget {
  const UpcomingTreatmentPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItem>> section;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItem>[];

    return DashboardListPanel(
      title: 'YAKLAŞAN TEDAVİLER',
      count: items.length,
      countColor: MedColors.blue,
      countBg: MedColors.blueLight,
      section: section,
      itemCount: items.length,
      emptyTitle: 'Yaklaşan tedavi yok',
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardRxItemCard(
          item: item,
          showFlags: true,
          showStatusChip: true,
          showTimeChip: true,
          infoRows: [
            MedInfoRow(label: 'HASTA', value: item.prescription?.hospitalization?.patient?.fullName ?? '-'),
            MedInfoRow(label: 'SERVİS', value: item.physicalService?.name ?? '-'),
          ],
        );
      },
    );
  }
}
