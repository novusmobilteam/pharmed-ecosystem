import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../notifier/stock_transaction_report_notifier.dart';
import 'package:provider/provider.dart';

import '../widgets/stations_list_view.dart';
import '../widgets/stock_transaction_table_view.dart';

class StockTransactionReportScreen extends StatelessWidget {
  const StockTransactionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StockTransactionReportNotifier(
        getCabinStockTransactionsUseCase: context.read(),
      )..getTransactions(),
      child: ResponsiveLayout(
        mobile: MobileLayout(),
        tablet: TabletLayout(),
        desktop: DesktopLayout(
          title: 'İstasyon Hareketleri',
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<StockTransactionReportNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.transactions.isEmpty && notifier.selectedStation == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Row(
          spacing: 30,
          children: [
            Expanded(
              child: StationsSideListView(onStationSelected: notifier.selectStation),
            ),
            Expanded(
              flex: 5,
              child: StockTransactionTableView(
                transactions: notifier.transactions,
                transactionType: StockTransactionType.entry,
              ),
            )
          ],
        );
      },
    );
  }
}
