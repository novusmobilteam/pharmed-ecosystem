import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/drawer_refund_notifier.dart';

class DrawerRefundScreen extends StatelessWidget {
  const DrawerRefundScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DrawerRefundNotifier(getDrawerRefundsUseCase: context.read())..getRefunds(),
      child: Consumer<DrawerRefundNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: menu.name ?? 'İade Çekmece Kontrol',
              subtitle: menu.description,
              showAddButton: false,
              child: UnifiedTableView<Refund>(
                data: notifier.categoryFilteredItems,
                isLoading: notifier.isFetching,
                categories: notifier.tableCategories,
                selectedCategoryId: notifier.selectedCategoryId,
                onCategoryChanged: notifier.selectCategory,
                enableSearch: true,
                onSearchChanged: notifier.search,
                enableExcel: true,
                emptyWidget: notifier.hasNoSearchResults
                    ? CommonEmptyStates.searchNotFound()
                    : CommonEmptyStates.noData(),
              ),
            ),
          );
        },
      ),
    );
  }
}
