import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/remaining_day_badge.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/expiring_stocks_notifier.dart';

/// S.K.T yaklaşan malzeme listesi ekranı.
class ExpiringStocksScreen extends StatelessWidget {
  const ExpiringStocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          ExpiringStocksNotifier(expiringStocksUsecase: context.read())..getExpiringStocks(),
      child: Consumer<ExpiringStocksNotifier>(
        builder: (context, vm, _) {
          return ResponsiveLayout(
            mobile: const MobileLayout(),
            tablet: const TabletLayout(),
            desktop: DesktopLayout(title: 'S.K.T Yaklaşan Malzeme Listesi', child: _buildChild()),
          );
        },
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<ExpiringStocksNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView(
          data: notifier.filteredItems,
          isLoading: notifier.isFetching,
          enableSearch: true,
          enableExcel: true,
          onSearchChanged: notifier.search,
          cellBuilder: (item, colIndex, value) {
            if (colIndex == 9) {
              return RemainingDayBadge(days: item.remainingDay ?? 0);
            }
            return null;
          },
        );
      },
    );
  }
}
