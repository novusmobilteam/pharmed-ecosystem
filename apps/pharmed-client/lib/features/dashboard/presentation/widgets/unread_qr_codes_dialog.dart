// [SWREQ-UI-DASH-QR-001] [IEC 62304 §5.5]
// Okutulmayan karekod uyarısı — dashboard app bar'daki uyarı butonundan açılır.
//
// Kaynak: Dashboard/unReadQrCode (DashboardNotifier.unreadQrCodes). Liste
// manager'da uyarısı açılmış ve oturumdaki kullanıcının uyguladığı kalemlerdir.
// Her satırdan ortak QrScanDialog açılır; okutma sonrası liste sunucudan
// yenilenir, okutulan kalem uyarıdan düşer.
//
// Sınıf: Class B
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/providers.dart';
import '../notifier/dashboard_notifier.dart';

Future<void> showUnreadQrCodesDialog(BuildContext context) =>
    showMedDialog<void>(context: context, builder: (_) => const UnreadQrCodesDialog());

class UnreadQrCodesDialog extends ConsumerWidget {
  const UnreadQrCodesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(dashboardNotifierProvider.select((n) => n.unreadQrCodes));

    return MedDialog(
      title: context.l10n.unscannedBarcodes_alertDialogTitle,
      subtitle: context.l10n.unscannedBarcodes_alertDialogSubtitle,
      icon: PhosphorIcons.qrCode(),
      width: 760,
      child: items.isEmpty
          ? EmptyStateWidget(icon: PhosphorIcons.checkCircle(), title: context.l10n.unscannedBarcodes_alertEmptyTitle)
          : ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.md),
              itemBuilder: (context, i) => _UnreadQrCodeRow(
                item: items[i],
                onScan: () => _scan(context, ref, items[i]),
              ),
            ),
    );
  }

  Future<void> _scan(BuildContext context, WidgetRef ref, PrescriptionItem item) async {
    final patientName = item.prescription?.hospitalization?.patient?.fullName;
    final outcome = await showQrScanDialog(
      context,
      request: QrScanRequest(
        operationLabel: context.l10n.qrScan_operationUnscanned,
        medicineName: item.medicine?.name ?? '—',
        requiredCount: item.requiredQrCount,
        expectedGtin: switch (item.medicine) {
          Drug(:final barcode) => barcode,
          _ => null,
        },
        chips: [if (patientName != null) QrScanChip(patientName)],
        allowPartialSubmit: true,
      ),
      onSubmit: (codes) async {
        if (codes.isEmpty) return const Result.ok(null);
        return ref
            .read(scanQrCodeUseCaseProvider)
            .call(
              ScanQrCodeParams(
                details: [
                  QrCodeDetail(prescriptionDetailId: item.id ?? 0, qrCode: [for (final c in codes) c.raw]),
                ],
              ),
            );
      },
    );
    if (outcome == QrScanOutcome.submitted) {
      await ref.read(dashboardNotifierProvider.notifier).refreshUnreadQrCodes();
    }
  }
}

class _UnreadQrCodeRow extends StatelessWidget {
  const _UnreadQrCodeRow({required this.item, required this.onScan});

  final PrescriptionItem item;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final patientName = item.prescription?.hospitalization?.patient?.fullName ?? '—';
    final appliedAt = item.applicationDate;

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2),
      ),
      child: Row(
        spacing: MedSpacing.lg,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: MedSpacing.xs,
              children: [
                Text(
                  item.medicine?.name ?? '—',
                  style: MedTextStyles.titleSm(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    patientName,
                    item.medicine?.prescriptionDoseText(context, item.dosePiece) ?? item.dosePiece.formatFractional,
                    if (appliedAt != null) appliedAt.formattedDateTime,
                  ].join('  ·  '),
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if ((item.qrCodeCount ?? 0) > 0)
            MedChip(
              label: context.l10n.unscannedBarcodes_scannedCountChip(item.qrCodeCount!),
              style: MedChipStyle.success,
              shape: MedChipShape.pill,
              size: MedChipSize.sm,
              showBorder: false,
              mono: false,
            ),
          MedChip(
            label: context.l10n.unscannedBarcodes_missingCountChip(item.requiredQrCount),
            style: MedChipStyle.warning,
            shape: MedChipShape.pill,
            size: MedChipSize.sm,
            showBorder: false,
            mono: false,
          ),
          MedButton(
            label: context.l10n.unscannedBarcodes_scanButton,
            prefixIcon: Icon(PhosphorIcons.qrCode()),
            size: MedButtonSize.sm,
            onPressed: onScan,
          ),
        ],
      ),
    );
  }
}
