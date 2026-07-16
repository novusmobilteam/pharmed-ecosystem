import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

import '../../../widgets/widgets.dart';
import '../notifier/dashboard_section.dart';
import '../widgets/dashboard_list_panel.dart';

// [SWREQ-MGR-DASH-010]
// Dashboard — ilaç hareketleri kompakt liste paneli.
// Sınıf: Class A

class DrugActivityPanel extends StatelessWidget {
  const DrugActivityPanel({super.key, required this.section, this.onRetry});

  final DashboardSection<List<PrescriptionItemMovement>> section;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItemMovement>[];

    return DashboardListPanel<List<PrescriptionItemMovement>>(
      title: context.l10n.dashboardDrugActivityPanelTitle,
      count: items.length,
      countColor: MedColors.blue,
      countBg: MedColors.blueLight,
      section: section,
      itemCount: items.length,
      emptyTitle: context.l10n.dashboardDrugActivityEmptyTitle,
      onRetry: onRetry,
      itemBuilder: (context, index) => DrugActivityCard(movement: items[index]),
    );
  }
}

class DrugActivityCard extends StatelessWidget {
  const DrugActivityCard({super.key, required this.movement});

  final PrescriptionItemMovement movement;

  String _doseText(BuildContext context) {
    final piece = movement.quantity?.formatFractional ?? '-';
    final unit = movement.prescriptionItem?.medicine?.operationUnit ?? context.l10n.common_defaultUnitFallback;
    return '$piece $unit';
  }

  String get _medicine => movement.prescriptionItem?.medicine?.name ?? '-';

  String get _patient => movement.prescriptionItem?.prescription?.hospitalization?.patient?.fullName ?? '-';

  String get _performedBy => movement.performedBy?.fullName ?? '-';

  String get _dateTime => movement.createdAt?.formattedDateTime ?? '-';

  @override
  Widget build(BuildContext context) {
    final type = movement.type;

    return Container(
      margin: const EdgeInsets.only(bottom: MedSpacing.md, right: MedSpacing.md, left: MedSpacing.md),
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İkon + ilaç adı + doz
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedRectangleIcon(
                icon: type.icon,
                backgroundColor: type.foregroundColor,
                foregroundColor: type.backgroundColor,
                size: const Size(34, 34),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_medicine, style: MedTextStyles.titleSm(), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                _doseText(context),
                style: MedTextStyles.monoSm(color: MedColors.text2, weight: FontWeight.w600),
              ),
            ],
          ),

          // Ayraç
          const SizedBox(height: 12),
          const Divider(height: 1, color: MedColors.border2),
          const SizedBox(height: 12),

          // // Bilgi satırları
          // const MedInfoRow(label: 'HASTA', value: '').runtimeType == Null
          //     ? const SizedBox()
          //     : const SizedBox(), // placeholder kaldırılacak
          // MedInfoRow(label: context.l10n.assignment_patientLabel, value: _patient),
          // const SizedBox(height: 6),
          // MedInfoRow(
          //   label: 'İŞLEMİ YAPAN',
          //   value: _performedBy,
          // ), // TODO(l10n): no all-caps ARB key exists for this label yet; see migration report
          // const SizedBox(height: 6),
          // MedInfoRow(label: context.l10n.dashboardDrugActivityDateTimeLabel, value: _dateTime),
          const SizedBox(height: 12),

          // Hareket tipi chip'i — eylem etiketiyle
          MedRxMovementChip(status: type, useActionLabel: true),
        ],
      ),
    );
  }
}
