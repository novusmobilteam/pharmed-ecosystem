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
      title: 'UYGULANMAMIŞ REÇETELER',
      count: items.length,
      countColor: MedColors.amber,
      countBg: MedColors.amberLight,
      section: section,
      itemCount: items.length,
      emptyTitle: 'Uygulanmamış reçete yok',
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardRxItemCard(
          item: item,
          infoRows: [
            MedInfoRow(label: 'HASTA', value: item.prescription?.hospitalization?.patient?.fullName ?? '-'),
            MedInfoRow(label: 'DOKTOR', value: item.doctor?.fullName ?? '-'),
            MedInfoRow(label: 'SERVİS', value: item.physicalService?.name ?? '-'),
            MedInfoRow(
              label: 'ODA / YATAK',
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
