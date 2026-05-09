// import 'package:flutter/material.dart';
// import '../../../../../pharmed-manager/lib/core/core.dart';

// import 'package:provider/provider.dart';

// import '../../../../../pharmed-manager/lib/core/widgets/unified_table/unified_table_models.dart';
// import '../../../../../pharmed-manager/lib/core/widgets/unified_table/unified_table_view.dart';
// import '../notifier/pharmacy_warehouse_form_notifier.dart';
// import '../notifier/pharmacy_warehouse_notifier.dart';

// import 'pharmacy_warehouse_form_view.dart';

// class PharmacyWarehouseScreen extends StatelessWidget {
//   const PharmacyWarehouseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => PharmacyWarehouseNotifier(
//         getStockTransactionsUseCase: context.read(),
//         deleteStockTransactionUseCase: context.read(),
//       )..getTranscations(),
//       child: ResponsiveLayout(
//         mobile: MobileLayout(),
//         tablet: TabletLayout(),
//         desktop: DesktopLayout(
//           title: 'Eczane Depo İşlemleri',
//           onAddPressed: () => _onAdd(context),
//           child: _buildChild(),
//         ),
//       ),
//     );
//   }

//   Widget _buildChild() {
//     return Consumer<PharmacyWarehouseNotifier>(
//       builder: (context, notifier, _) {
//         if (notifier.isFetching && notifier.isEmpty) {
//           return const Center(child: CircularProgressIndicator.adaptive());
//         }

//         if (notifier.isEmpty) {
//           return CommonEmptyStates.noData();
//         }

//         return Row(
//           spacing: 50,
//           children: [
//             // Expanded(
//             //   child: WarehouseSideListView(
//             //     items: notifier.warehouses,
//             //     activeIndex: notifier.activeIndex,
//             //     onTap: notifier.selectWarehouse,
//             //   ),
//             // ),
//             Expanded(
//               flex: 6,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 spacing: 20,
//                 children: [
//                   SizedBox(
//                     width: 300,
//                     child: PharmedSegmentedButton(
//                       selectedIndex: notifier.selectedTab,
//                       onChanged: notifier.selectTab,
//                       labels: StockTransactionType.values.map((s) => s.label).toList(),
//                     ),
//                   ),
//                   Expanded(
//                     child: StockTransactionTableView(
//                       transactions: notifier.filteredTransactions,
//                       transactionType: notifier.transactionType,
//                       onDelete: (transaction) => _onDelete(context, transaction),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// void _onDelete(BuildContext context, StockTransaction transaction) {
//   MessageUtils.showConfirmDeleteDialog(
//     context: context,
//     onConfirm: () {
//       context.read<PharmacyWarehouseNotifier>().deleteTransaction(transaction);
//     },
//   );
// }

// Future<void> _onAdd(BuildContext context) async {
//   final changed = await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => ChangeNotifierProvider(
//       create: (_) => PharmacyWarehouseFormNotifier(
//         createStockTransactionUseCase: context.read(),
//         warehouse: context.read<PharmacyWarehouseNotifier>().selectedWarehouse!,
//         transactionType: context.read<PharmacyWarehouseNotifier>().transactionType,
//       ),
//       child: PharmacyWarehouseFormView(type: context.read<PharmacyWarehouseNotifier>().transactionType),
//     ),
//   );

//   if (changed == true && context.mounted) {
//     context.read<PharmacyWarehouseNotifier>().getTranscations();
//   }
// }

// class StockTransactionTableView extends StatelessWidget {
//   const StockTransactionTableView({
//     super.key,
//     required this.transactions,
//     required this.transactionType,
//     this.onDelete,
//   });

//   final List<StockTransaction> transactions;
//   final StockTransactionType transactionType;
//   final Function(StockTransaction)? onDelete;

//   List<TableColumnDef> _buildColumnDefs() {
//     final isEntry = transactionType == StockTransactionType.entry;

//     return [
//       TableColumnDef(title: isEntry ? 'Giriş Tarihi' : 'Çıkış Tarihi'),
//       const TableColumnDef(title: 'Malzeme', flex: 1.5),
//       const TableColumnDef(title: 'Son Kullanma Tarihi'),
//       const TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7),
//       const TableColumnDef(title: 'İşlem Tipi'),
//       if (!isEntry) const TableColumnDef(title: 'Gönderilen Servis'),
//     ];
//   }

//   Widget? _buildCell(StockTransaction item, int colIndex, dynamic _) {
//     final isEntry = transactionType == StockTransactionType.entry;

//     return switch (colIndex) {
//       0 => Text(item.sendDate?.formattedDate ?? '-'),
//       1 => Text(item.medicine?.name ?? '-'),
//       2 => Text(item.expirationDate?.formattedDate ?? '-'),
//       3 => Text(item.quantity?.toCustomString() ?? '-'),
//       4 => Text(item.transactionKind?.label ?? '-'),
//       5 when !isEntry => Text(item.service?.name ?? '-'),
//       _ => null,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return UnifiedTableView<StockTransaction>(
//       data: transactions,
//       enableExcel: true,
//       columnDefs: _buildColumnDefs(),
//       cellBuilder: _buildCell,
//       actions: [if (onDelete != null) TableActionItem.delete(onPressed: (item) => onDelete!(item))],
//     );
//   }
// }
