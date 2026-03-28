import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/refund.dart';
import '../notifier/drawer_refund_notifier.dart';

class DrawerRefundScreen extends StatefulWidget {
  const DrawerRefundScreen({super.key});

  @override
  State<DrawerRefundScreen> createState() => _DrawerRefundScreenState();
}

class _DrawerRefundScreenState extends State<DrawerRefundScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DrawerRefundNotifier(
        getDrawerRefundsUseCase: context.read(),
      )..getRefunds(),
      child: Consumer<DrawerRefundNotifier>(
        builder: (context, notifier, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(
              title: 'İade Çekmece Kontrol',
              showAddButton: false,
              child: _DrawerRefundTableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}

class _DrawerRefundTableView extends StatelessWidget {
  const _DrawerRefundTableView({required this.notifier});

  final DrawerRefundNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Refund>(
      data: notifier.categoryFilteredItems,
      isLoading: notifier.isFetching,
      categories: notifier.tableCategories,
      selectedCategoryId: notifier.selectedCategoryId,
      onCategoryChanged: notifier.selectCategory,
      enableSearch: true,
      onSearchChanged: notifier.search,
      enableExcel: true,
      emptyWidget: notifier.hasNoSearchResults ? CommonEmptyStates.searchNotFound() : CommonEmptyStates.noData(),
    );
  }
}
