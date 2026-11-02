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
                categories: notifier.tableCategories,
                categoryTitle: context.l10n.report_stationsCategoryTitle,
                onCategoryChanged: (id) =>
                    notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
                selectedCategoryId: notifier.selectedStationId,

                actions: [
                  TableActionItem.edit(
                    context: context,
                    onPressed: (item) => _openForm(context, notifier, item: item),
                  ),
                  TableActionItem(
                    icon: PhosphorIcons.printer(),
                    tooltip: context.l10n.refillList_printTooltip,
                    onPressed: (item) =>
                        printRefillList(context: context, list: item, station: notifier.selectedStation),
                  ),
                  TableActionItem(
                    icon: PhosphorIcons.arrowClockwise(),
                    tooltip: context.l10n.refillList_updateStatusTooltip,
                    onPressed: (record) => notifier.updateRefillListStatus(
                      record,
                      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                      onSuccess: (_) =>
                          MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage),
                    ),
                  ),

                  TableActionItem(
                    icon: PhosphorIcons.x(),
                    tooltip: context.l10n.common_cancelButton,
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
    TableColumnDef(title: context.l10n.common_statusLabel, displayValue: (item) => item.status?.label),
    TableColumnDef(
      title: context.l10n.common_cancelButton,
      displayValue: (item) =>
          item.isCancel ? context.l10n.refillList_cellValueYes : context.l10n.refillList_cellValueNo,
    ),
  ];
}
