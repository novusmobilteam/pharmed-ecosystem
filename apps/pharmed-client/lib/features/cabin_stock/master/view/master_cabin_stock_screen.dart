import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';

import '../../../dashboard/dashboard.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../auth/notifier/auth_notifier.dart';
import '../notifier/master_cabin_stock_notifier.dart';
import '../receipts/cabin_stock_receipt.dart';

class MasterCabinStockScreen extends ConsumerStatefulWidget {
  const MasterCabinStockScreen({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

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
      notifier.init(widget.cabinRouteContext);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(masterCabinStockNotifierProvider.select((n) => n.isFetchingStocks));
    final cabinData = widget.cabinRouteContext.cabinData;

    if (cabinData == null) {
      return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }

    if (isLoading) {
      return Center(child: MedLoadingIndicator());
    }

    return MasterCabinStockIdleView(cabinContext: widget.cabinRouteContext);
  }
}

class MasterCabinStockIdleView extends ConsumerWidget {
  const MasterCabinStockIdleView({super.key, required this.cabinContext});

  final CabinRouteContext cabinContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(masterCabinStockNotifierProvider);
    final cabin = cabinContext.cabin;
    final groups = cabinContext.cabinData?.groups;
    final menu = cabinContext.menu;
    final visibleStocks = notifier.visibleStocks;

    return CabinOperationSelectionLayout(
      isLoading: notifier.isFetchingStocks,
      left: Column(
        children: [
          Expanded(
            child: CabinOverviewSelectionPanel(
              cabin: cabin,
              onChangeCabin: () => ref.read(dashboardNotifierProvider.notifier).changeCabin(),
              groups: groups ?? [],
              assignments: notifier.stocks,
              selectedUnitIds: {},
              onDrawerTap: null,
              onCellTap: null,
            ),
          ),
        ],
      ),

      right: CabinSelectionContentShell(
        menu: menu,
        // [SWREQ-PRN-102] Kabindeki tüm atamalar — arama uygulanmadan.
        menuTrailing: ReceiptPrintButton(
          enabled: !notifier.isFetchingStocks && notifier.stocks.isNotEmpty,
          buildReceipt: () => buildCabinStockReceipt(
            cabinName: cabin?.name,
            stocks: notifier.stocks,
            operatorName: ref.read(authNotifierProvider.notifier).currentUser?.fullName,
          ),
        ),
        searchQuery: notifier.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        isEmpty: visibleStocks.isEmpty,
        searchHint: context.l10n.intake_hint_searchMedicine,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: visibleStocks.isEmpty
            ? null
            : CabinAssignmentListView(items: visibleStocks, selectedItemIds: {}, onToggle: null),
      ),
    );
  }
}
