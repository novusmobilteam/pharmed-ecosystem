import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
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
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              title: menu.name ?? 'İade Çekmece Kontrol',
              subtitle: menu.description,
              showAddButton: false,
              child: MedTable<Refund>(
                data: notifier.categoryFilteredItems,
                isLoading: notifier.isFetching,
                categories: notifier.tableCategories,
                selectedCategoryId: notifier.selectedCategoryId,
                onCategoryChanged: notifier.selectCategory,
                enableSearch: true,
                onSearchChanged: notifier.search,
                enableExcel: true,
                emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),
              ),
            ),
          );
        },
      ),
    );
  }
}
