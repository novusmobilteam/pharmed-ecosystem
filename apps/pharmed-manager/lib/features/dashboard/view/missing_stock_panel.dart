import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../widgets/widgets.dart';
import '../dashboard.dart';

class MissingStockPanel extends StatelessWidget {
  const MissingStockPanel({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DashboardNotifier>();
    final section = notifier.shortage;
    final items = section.data ?? const <PrescriptionItem>[];

    return DashboardListPanel<List<PrescriptionItem>>(
      title: 'EKSİK STOK BİLDİRİMLERİ',
      count: items.length,
      countColor: MedColors.red,
      countBg: MedColors.redLight,
      section: section,
      itemCount: items.length,
      emptyTitle: 'Eksik stok bildirimi yok',
      onRetry: () => context.read<DashboardNotifier>().retryShortage(),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item.id;
        return DashboardRxItemCard(
          item: item,
          showFlags: true,
          showStatusChip: true,
          infoRows: [
            MedInfoRow(label: 'HASTA', value: item.prescription?.hospitalization?.patient?.fullName ?? '-'),
            MedInfoRow(label: 'SERVİS', value: item.physicalService?.name ?? '-'),
            MedInfoRow(label: 'İŞLEMİ YAPAN', value: item.activityUser?.fullName ?? '-'),
            MedInfoRow(label: 'SAAT', value: item.activityDate?.formattedDateTime ?? '-'),
          ],
          actions: (isLoggedIn && item.status == PrescriptionMovementType.shortageReported)
              ? Row(
                  children: [
                    Expanded(
                      child: MedButton(
                        label: 'Onayla',
                        size: MedButtonSize.sm,
                        variant: MedButtonVariant.success,
                        fullWidth: true,
                        isLoading: id != null && notifier.isProcessing(id),
                        onPressed: (id == null || notifier.isProcessing(id))
                            ? null
                            : () => context.read<DashboardNotifier>().approveMissingStock(id),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MedButton(
                        label: 'Reddet',
                        size: MedButtonSize.sm,
                        variant: MedButtonVariant.danger,
                        fullWidth: true,
                        onPressed: (id == null || notifier.isProcessing(id))
                            ? null
                            : () => context.read<DashboardNotifier>().rejectMissingStock(id),
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
