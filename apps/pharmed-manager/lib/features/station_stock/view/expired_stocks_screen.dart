import 'package:flutter/material.dart';
import '../../../core/core.dart';

import 'package:provider/provider.dart';

import '../../../core/widgets/remaining_day_badge.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
import '../notifier/expired_stocks_notifier.dart';

class ExpiredStocksScreen extends StatelessWidget {
  const ExpiredStocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'S.K.T Geçmiş Malzemeler',
      child: ChangeNotifierProvider(
        create: (context) => ExpiredStockNotifier(expiredStocksUseCase: context.read())..getExpiredStocks(),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<ExpiredStockNotifier>(
      builder: (context, notifier, _) {
        return UnifiedTableView(
          data: notifier.filteredItems,
          isLoading: notifier.isFetching,
          enableSearch: true,
          onSearchChanged: notifier.search,
          numericColumnIndices: {4, 5, 6, 7},
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
