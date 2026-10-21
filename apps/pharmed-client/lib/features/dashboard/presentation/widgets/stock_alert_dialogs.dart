// [SWREQ-UI-DASH-ALERT-001] [SWREQ-UI-DASH-ALERT-002] [IEC 62304 §5.5]
// Dashboard app bar stok uyarıları — uyarı butonlarından açılan salt-okunur
// liste dialog'ları:
//  • SKT yaklaşan ilaçlar  (DashboardNotifier.expiringStocks)
//  • Kabin dışı malzemeler (DashboardNotifier.orderedNotLoadedMaterials)
//
// Veriler dashboard periyodik yenilemesinde güncellenir; dialog açıkken
// liste değişirse (ör. boşalırsa) içerik canlı yansır.
//
// Sınıf: Class B (SKT ve order bilgisini temsil eder)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/dashboard_notifier.dart';

Future<void> showExpiringStocksAlertDialog(BuildContext context) =>
    showMedDialog<void>(context: context, builder: (_) => const ExpiringStocksAlertDialog());

Future<void> showOrderedNotLoadedAlertDialog(BuildContext context) =>
    showMedDialog<void>(context: context, builder: (_) => const OrderedNotLoadedAlertDialog());

// ─────────────────────────────────────────────────────────────────
// SKT yaklaşan ilaçlar
// ─────────────────────────────────────────────────────────────────

class ExpiringStocksAlertDialog extends ConsumerWidget {
  const ExpiringStocksAlertDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(dashboardNotifierProvider.select((n) => n.expiringStocks));

    return MedDialog(
      title: context.l10n.dashboard_expiringAlertDialogTitle,
      subtitle: context.l10n.dashboard_expiringAlertDialogSubtitle,
      icon: PhosphorIcons.hourglass(),
      width: 760,
      child: items.isEmpty
          ? EmptyStateWidget(icon: PhosphorIcons.checkCircle(), title: context.l10n.dashboard_expiringAlertEmptyTitle)
          : ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.md),
              itemBuilder: (context, i) => _ExpiringStockRow(stock: items[i]),
            ),
    );
  }
}

class _ExpiringStockRow extends StatelessWidget {
  const _ExpiringStockRow({required this.stock});

  final CabinStock stock;

  @override
  Widget build(BuildContext context) {
    final unit = stock.medicine?.pieceUnitLabel ?? '';
    final location = [
      stock.assignment?.cabin?.name,
      [stock.shelfNo, stock.corpartmentNo].whereType<Object>().join('/'),
    ].whereType<String>().where((e) => e.isNotEmpty).join(' · ');

    return _AlertRowShell(
      title: stock.medicine?.name ?? '—',
      details: [
        if (location.isNotEmpty) location,
        '${stock.quantity.formatFractional} $unit'.trim(),
        if (stock.miadDate != null) stock.miadDate!.formattedDate,
      ],
      trailing: MedRemainingDayChip(days: stock.remainingDay ?? 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Kabin dışı malzemeler (order edilmiş, yüklenmemiş)
// ─────────────────────────────────────────────────────────────────

class OrderedNotLoadedAlertDialog extends ConsumerWidget {
  const OrderedNotLoadedAlertDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(dashboardNotifierProvider.select((n) => n.orderedNotLoadedMaterials));

    return MedDialog(
      title: context.l10n.dashboard_orderedNotLoadedAlertDialogTitle,
      subtitle: context.l10n.dashboard_orderedNotLoadedAlertDialogSubtitle,
      icon: PhosphorIcons.package(),
      width: 760,
      child: items.isEmpty
          ? EmptyStateWidget(
              icon: PhosphorIcons.checkCircle(),
              title: context.l10n.dashboard_orderedNotLoadedAlertEmptyTitle,
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.md),
              itemBuilder: (context, i) => _OrderedNotLoadedRow(item: items[i]),
            ),
    );
  }
}

class _OrderedNotLoadedRow extends StatelessWidget {
  const _OrderedNotLoadedRow({required this.item});

  final OrderedNotLoadedMaterial item;

  @override
  Widget build(BuildContext context) {
    final unit = item.medicine?.pieceUnitLabel ?? '';

    return _AlertRowShell(
      title: item.materialName ?? item.medicine?.name ?? '—',
      details: [
        if (item.patientFullName != null) item.patientFullName!,
        if (item.protocolNo != null) item.protocolNo!,
        if (item.quantity != null) '${item.quantity.formatFractional} $unit'.trim(),
        if (item.orderDate != null) item.orderDate!.formattedDateTime,
      ],
      trailing: item.serviceName == null
          ? null
          : MedChip(
              label: item.serviceName!,
              style: MedChipStyle.warning,
              shape: MedChipShape.pill,
              size: MedChipSize.sm,
              showBorder: false,
              mono: false,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Ortak satır iskeleti — okutulmayan karekod satırıyla aynı görsel dil
// ─────────────────────────────────────────────────────────────────

class _AlertRowShell extends StatelessWidget {
  const _AlertRowShell({required this.title, required this.details, this.trailing});

  final String title;
  final List<String> details;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
                Text(title, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (details.isNotEmpty)
                  Text(
                    details.join('  ·  '),
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
