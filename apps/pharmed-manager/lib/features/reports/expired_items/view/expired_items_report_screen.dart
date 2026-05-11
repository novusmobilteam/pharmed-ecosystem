import 'package:flutter/material.dart';
import '../../../../core/core.dart';

import 'package:provider/provider.dart';

import '../notifier/expired_items_report_notifier.dart';

class ExpiredItemsReportScreen extends StatelessWidget {
  const ExpiredItemsReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpiredItemsReportNotifier(expiredStocksUseCase: context.read())..getExpiredStocks(),
      builder: (context, child) {
        return Consumer<ExpiredItemsReportNotifier>(
          builder: (context, notifier, _) {
            return ResponsiveLayout(
              mobile: const MobileLayout(),
              tablet: const TabletLayout(),
              desktop: DesktopLayout(
                title: menu.name ?? 'S.K.T Geçmiş Malzemeler',
                subtitle: menu.description,
                showAddButton: false,
                child: MedTable(
                  data: notifier.filteredItems,
                  isLoading: notifier.isFetching,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  numericColumnIndices: {4, 5, 6, 7},
                  cellBuilder: (item, colIndex, value) {
                    if (colIndex == 9) {
                      return RemainingDayChip(days: item.remainingDay ?? 0);
                    }
                    return null;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
