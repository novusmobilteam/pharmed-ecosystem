import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';

import '../../../dashboard/dashboard.dart';
import '../../../auth/notifier/auth_notifier.dart';
import '../notifier/master_cabin_stock_notifier.dart';
import '../receipts/cabin_stock_receipt.dart';

class MasterCabinStockScreen extends ConsumerStatefulWidget {
  const MasterCabinStockScreen({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterCabinStockScreen> createState() => MasterCabinStockScreenState();
}

class MasterCabinStockScreenState extends ConsumerState<MasterCabinStockScreen> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(masterCabinStockNotifierProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      notifier.init(widget.stationContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(masterCabinStockNotifierProvider.select((n) => n.isFetchingStocks));

    if (widget.stationContext.cabinDataByCabinId.isEmpty) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }

    if (isLoading) {
      return Center(child: MedLoadingIndicator());
    }

    return MasterCabinStockIdleView(menu: widget.stationContext.menu);
  }
}

/// İstasyon geneli stok: solda kabin şeridi + görüntülenen kabinin iç
/// yerleşimi (yalnızca bilgi), sağda tüm kabinlerin stok listesi.
class MasterCabinStockIdleView extends ConsumerWidget {
  const MasterCabinStockIdleView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(masterCabinStockNotifierProvider);
    final scope = notifier.scope;
    final visibleStocks = notifier.visibleStocks;
    final printed = notifier.filteredStocks;
    final filterCabin = scope.cabins.where((c) => c.id == scope.cabinFilter).firstOrNull;

    return CabinOperationSelectionLayout(
      isLoading: notifier.isFetchingStocks,
      left: StationCabinSelectionPanel(
        cabins: scope.cabins,
        viewedCabinId: scope.viewedCabinId,
        onCabinTap: notifier.viewCabin,
        interior: CabinOverviewSelectionPanel(
          key: ValueKey(scope.viewedCabinId),
          cabin: scope.viewedCabin,
          groups: scope.viewedGroups,
          assignments: notifier.stocks,
          selectedUnitIds: const {},
        ),
      ),
      right: CabinSelectionContentShell(
        menu: menu,
        // [SWREQ-PRN-102] Filtredeki kabin(ler)in tüm atamaları — arama
        // uygulanmadan. Filtre "Tümü" iken istasyondaki tüm kabinler basılır.
        menuTrailing: ReceiptPrintButton(
          enabled: !notifier.isFetchingStocks && printed.isNotEmpty,
          buildReceipt: () => buildCabinStockReceipt(
            cabinName: filterCabin?.name ?? (scope.cabins.length == 1 ? scope.cabins.first.name : null),
            stocks: printed,
            operatorName: ref.read(authNotifierProvider.notifier).currentUser?.fullName,
          ),
        ),
        extra: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: StationCabinFilterBar(
            cabins: scope.cabins,
            selectedCabinId: scope.cabinFilter,
            onChanged: notifier.setCabinFilter,
          ),
        ),
        searchQuery: notifier.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        isEmpty: visibleStocks.isEmpty,
        searchHint: context.l10n.intake_hint_searchMedicine,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: visibleStocks.isEmpty
            ? null
            : CabinAssignmentListView(
                items: visibleStocks,
                selectedItemIds: const {},
                onToggle: null,
                cabinLabelOf: scope.cabins.length > 1 ? scope.cabinNameOf : null,
              ),
      ),
    );
  }
}
