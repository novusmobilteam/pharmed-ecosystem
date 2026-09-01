import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';

import '../../../dashboard/dashboard.dart';
import '../notifier/master_cabin_stock_notifier.dart';
import '../notifier/master_cabin_stock_state.dart';

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
    final state = ref.watch(masterCabinStockNotifierProvider);
    final isLoading = state is MasterCabinStockLoading;
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
    final state = ref.watch(masterCabinStockNotifierProvider);
    final notifier = ref.read(masterCabinStockNotifierProvider.notifier);
    final cabin = cabinContext.cabin;
    final groups = cabinContext.cabinData?.groups;
    final menu = cabinContext.menu;

    final idle = switch (state) {
      MasterCabinStockIdle s => s,
      MasterCabinStockError(previousState: MasterCabinStockIdle s) => s,
      _ => null,
    };

    if (idle == null) return const SizedBox.shrink();

    return CabinOperationSelectionLayout(
      isLoading: state is MasterCabinStockLoading,
      left: Column(
        children: [
          Expanded(
            child: CabinOverviewSelectionPanel(
              cabin: cabin,
              //onChangeCabin: () => ref.read(dashboardNotifierProvider.notifier).changeCabin(),
              groups: groups ?? [],
              assignments: idle.stocks,
              selectedUnitIds: {},
              onDrawerTap: null,
              onCellTap: null,
            ),
          ),
        ],
      ),

      right: CabinSelectionContentShell(
        menu: menu,
        searchQuery: idle.search,
        onSearchQueryChanged: notifier.onSearchChanged,
        isEmpty: idle.visibleStocks.isEmpty,
        searchHint: context.l10n.intake_hint_searchMedicine,
        emptyMessage: context.l10n.refill_hint_noMedicines,
        content: idle.visibleStocks.isEmpty
            ? null
            : CabinAssignmentListView(items: idle.visibleStocks, selectedItemIds: {}, onToggle: null),
      ),
    );
  }
}
