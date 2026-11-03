import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../widgets/refill_object_card.dart';
import '../notifier/refill_list_form_notifier.dart';
import '../notifier/refill_list_notifier.dart';
import '../print/refill_list_print.dart';

part 'refill_list_form_panel.dart';

class RefillListScreen extends StatelessWidget {
  const RefillListScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RefillListNotifier(
        getStations: context.read(),
        getRefillLists: context.read(),
        updateRefillListStatus: context.read(),
        cancelRefillList: context.read(),
      )..getStations(),
      child: Consumer<RefillListNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              actions: [
                MedButton(
                  label: context.l10n.refillList_newButtonLabel,
                  size: MedButtonSize.sm,
                  prefixIcon: Icon(PhosphorIcons.plus(), size: 16),
                  onPressed: () => _openForm(context, notifier),
                ),
              ],

              child: MedTable<RefillList>(
                data: notifier.items,
                isLoading: notifier.isTableLoading,
                enableExcel: true,
                enableSearch: false,
                enableDateFilter: true,
                onDateRangeChanged: notifier.setDateRange,
                rowColor: (item) => _RefillListTone.of(item).row,
                // Araç çubuğu yüksekliği dar ve genişliği sınırsız — MedSegmentedButton
                // (genişliğe yayılan, 50 px) burada çalışmıyor; sekmeler chip.
                toolbarActions: [
                  for (final tab in RefillListTab.values)
                    Padding(
                      padding: const EdgeInsets.only(right: MedSpacing.sm),
                      child: MedChip(
                        label: _tabLabel(context, tab),
                        count: notifier.countOf(tab),
                        size: MedChipSize.sm,
                        mono: false,
                        style: notifier.tab == tab ? MedChipStyle.info : MedChipStyle.neutral,
                        onTap: () => notifier.selectTab(tab),
                      ),
                    ),
                ],
                categories: notifier.tableCategories,
                categoryTitle: context.l10n.report_stationsCategoryTitle,
                onCategoryChanged: (id) =>
                    notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
                selectedCategoryId: notifier.selectedStationId,

                actions: [
                  TableActionItem(
                    icon: PhosphorIcons.pencilSimple(),
                    tooltip: context.l10n.common_editTooltip,
                    color: MedColors.blue,
                    onPressed: (item) => _openForm(context, notifier, item: item),
                  ),
                  TableActionItem(
                    icon: PhosphorIcons.printer(),
                    tooltip: context.l10n.refillList_printTooltip,
                    color: MedColors.text2,
                    onPressed: (item) =>
                        printRefillList(context: context, list: item, station: notifier.selectedStation),
                  ),
                  // İptal edilen listede durum ilerletilemez, tekrar iptal edilemez.
                  TableActionItem(
                    icon: PhosphorIcons.arrowCircleRight(),
                    tooltip: context.l10n.refillList_updateStatusTooltip,
                    color: MedColors.green,
                    isVisible: (item) => !item.isCancel,
                    onPressed: (record) => notifier.updateRefillListStatus(
                      record,
                      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      onSuccess: (_) =>
                          MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
                    ),
                  ),
                  TableActionItem(
                    icon: PhosphorIcons.xCircle(),
                    tooltip: context.l10n.common_cancelButton,
                    color: MedColors.red,
                    isVisible: (item) => !item.isCancel,
                    onPressed: (record) => notifier.cancelRefillList(
                      record,
                      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      onSuccess: (_) =>
                          MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
                    ),
                  ),
                ],
                columnDefs: _buildColumnDefs(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, RefillListNotifier notifier, {RefillList? item}) async {
    final saved = await showRefillListFormDialog(context, station: notifier.selectedStation, initial: item);
    if (saved) notifier.getRefillLists();
  }

  List<TableColumnDef<RefillList>> _buildColumnDefs(BuildContext context) => [
    TableColumnDef(title: context.l10n.movement_dateLabel, displayValue: (item) => item.date?.formattedDate),
    TableColumnDef(title: context.l10n.refillList_fieldAssignedUser, displayValue: (item) => item.user?.fullName),
    TableColumnDef(
      title: context.l10n.common_statusLabel,
      displayValue: (item) => _statusLabel(context, item),
      cellBuilder: (item) {
        final tone = _RefillListTone.of(item);
        return MedChip(
          label: _statusLabel(context, item),
          size: MedChipSize.sm,
          background: tone.chipBg,
          foreground: tone.chipFg,
          border: tone.chipFg.withValues(alpha: 0.35),
          mono: false,
        );
      },
    ),
  ];
}

String _tabLabel(BuildContext context, RefillListTab tab) => switch (tab) {
  RefillListTab.all => context.l10n.filter_all,
  RefillListTab.active => context.l10n.refillList_tab_waiting,
  RefillListTab.completed => context.l10n.refillList_tab_completed,
  RefillListTab.cancelled => context.l10n.refillList_tab_cancelled,
};

/// İptal edilen liste durumundan bağımsız "İptal Edildi" görünür.
String _statusLabel(BuildContext context, RefillList item) =>
    item.isCancel ? context.l10n.refillList_badge_cancelled : (item.status?.label ?? '-');

/// Liste durumuna göre renk: satır zemini + durum rozeti.
///   Toplanacak → nötr · Toplandı → turuncu · Gönderildi → mavi ·
///   Kısmen tamamlandı → açık yeşil · Tamamlandı → yeşil · İptal → kırmızı
class _RefillListTone {
  const _RefillListTone(this.row, this.chipBg, this.chipFg);

  final Color? row;
  final Color chipBg;
  final Color chipFg;

  static const _partialFg = Color(0xFF4D7C0F);

  static _RefillListTone of(RefillList item) {
    if (item.isCancel) return const _RefillListTone(MedColors.redLight, MedColors.redLight, MedColors.red);
    return switch (item.status) {
      RefillListStatus.collected => const _RefillListTone(MedColors.amberLight, MedColors.amberLight, MedColors.amber),
      RefillListStatus.send => const _RefillListTone(MedColors.blueLight, MedColors.blueLight, MedColors.blue),
      RefillListStatus.partiallyCompleted => const _RefillListTone(
        Color(0xFFF4FAEC),
        Color(0xFFEAF5DC),
        _partialFg,
      ),
      RefillListStatus.completed => const _RefillListTone(MedColors.greenLight, MedColors.greenLight, MedColors.green),
      RefillListStatus.toBeCollected || null => const _RefillListTone(null, MedColors.surface3, MedColors.text2),
    };
  }
}
