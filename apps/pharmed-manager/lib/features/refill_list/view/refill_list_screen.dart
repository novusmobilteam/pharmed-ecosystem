import 'package:flutter/material.dart';
import 'package:pharmed_manager/widgets/side_panel.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../widgets/medicine_filling_card.dart';
import '../notifier/new_refill_list_notifier.dart';
import '../notifier/refill_list_notifier.dart';

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
              title: menu.name ?? 'Dolum Listesi',
              subtitle: menu.description,
              actions: [
                MedButton(label: 'Yeni Dolum Listesi', size: MedButtonSize.sm, onPressed: () => notifier.openPanel()),
              ],

              child: SidePanelWrapper(
                isOpen: notifier.isPanelOpen,
                width: 700,
                panel: RefillListFormPanel(station: notifier.selectedStation, refillList: notifier.selectedItem),
                child: MedTable<RefillList>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isTableLoading,
                  enableExcel: true,
                  enableSearch: true,
                  categories: notifier.tableCategories,
                  onSearchChanged: notifier.search,
                  categoryTitle: 'İstasyonlar',
                  onCategoryChanged: (id) =>
                      notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
                  selectedCategoryId: notifier.selectedStationId,
                  cellBuilder: (item, colIndex, value) {
                    if (colIndex == 3) {
                      final text = value == true ? 'Evet' : 'Hayır';
                      return Text(text);
                    }
                    return null;
                  },
                  actions: [
                    TableActionItem.edit(onPressed: (item) => notifier.openPanel),
                    TableActionItem(
                      icon: PhosphorIcons.arrowClockwise(),
                      tooltip: 'Durum Güncelle',
                      onPressed: (record) => notifier.updateRefillListStatus(
                        record,
                        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                      ),
                    ),
                    TableActionItem(
                      icon: PhosphorIcons.x(),
                      tooltip: 'İptal',
                      onPressed: (record) => notifier.cancelRefillList(
                        record,
                        onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                        onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
