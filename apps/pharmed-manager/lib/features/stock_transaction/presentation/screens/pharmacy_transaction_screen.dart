import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../notifier/stock_transaction_form_notifier.dart';

import 'package:provider/provider.dart';

import '../../domain/entity/stock_transaction.dart';
import '../notifier/pharmacy_transaction_notifier.dart';
import '../widgets/stock_transaction_registration_dialog.dart';
import '../widgets/stock_transaction_table_view.dart';
import '../widgets/warehouse_list_view.dart';

class PharmacyTransactionScreen extends StatelessWidget {
  const PharmacyTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PharmacyTransactionNotifier(
        getStockTransactionsUseCase: context.read(),
        deleteStockTransactionUseCase: context.read(),
      )..getTranscations(),
      child: ResponsiveLayout(
        mobile: MobileLayout(),
        tablet: TabletLayout(),
        desktop: DesktopLayout(
          title: 'Eczane Depo İşlemleri',
          onAddPressed: () => _onAdd(context),
          child: _buildChild(),
        ),
      ),
    );
  }

  Widget _buildChild() {
    return Consumer<PharmacyTransactionNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetching && notifier.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (notifier.isEmpty) {
          return CommonEmptyStates.noData();
        }

        return Row(
          spacing: 50,
          children: [
            Expanded(
              child: WarehouseSideListView(
                items: notifier.warehouses,
                activeIndex: notifier.activeIndex,
                onTap: notifier.selectWarehouse,
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  SizedBox(
                    width: 300,
                    child: PharmedSegmentedButton(
                      selectedIndex: notifier.selectedTab,
                      onChanged: notifier.selectTab,
                      labels: StockTransactionType.values.map((s) => s.label).toList(),
                    ),
                  ),
                  Expanded(
                    child: StockTransactionTableView(
                      transactions: notifier.filteredTransactions,
                      transactionType: notifier.transactionType,
                      onDelete: (transaction) => _onDelete(context, transaction),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

void _onDelete(BuildContext context, StockTransaction transaction) {
  MessageUtils.showConfirmDeleteDialog(
    context: context,
    onConfirm: () {
      context.read<PharmacyTransactionNotifier>().deleteTransaction(transaction);
    },
  );
}

Future<void> _onAdd(BuildContext context) async {
  final changed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => StockTransactionFormNotifier(
        createStockTransactionUseCase: context.read(),
        warehouse: context.read<PharmacyTransactionNotifier>().selectedWarehouse!,
        transactionType: context.read<PharmacyTransactionNotifier>().transactionType,
      ),
      child: StockTransactionRegistrationDialog(
        type: context.read<PharmacyTransactionNotifier>().transactionType,
      ),
    ),
  );

  if (changed == true && context.mounted) {
    context.read<PharmacyTransactionNotifier>().getTranscations();
  }
}
