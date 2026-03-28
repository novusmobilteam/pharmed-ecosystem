import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../../core/widgets/unified_table/unified_table_view.dart';
import '../../domain/entity/stock_transaction.dart';

class StockTransactionTableView extends StatelessWidget {
  const StockTransactionTableView({
    super.key,
    required this.transactions,
    required this.transactionType,
    this.onDelete,
  });

  final List<StockTransaction> transactions;
  final StockTransactionType transactionType;
  final Function(StockTransaction)? onDelete;

  List<TableColumnDef> _buildColumnDefs() {
    final isEntry = transactionType == StockTransactionType.entry;

    return [
      TableColumnDef(
        title: isEntry ? 'Giriş Tarihi' : 'Çıkış Tarihi',
      ),
      const TableColumnDef(title: 'Malzeme', flex: 1.5),
      const TableColumnDef(title: 'Son Kullanma Tarihi'),
      const TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7),
      const TableColumnDef(title: 'İşlem Tipi'),
      if (!isEntry) const TableColumnDef(title: 'Gönderilen Servis'),
    ];
  }

  Widget? _buildCell(StockTransaction item, int colIndex, dynamic _) {
    final isEntry = transactionType == StockTransactionType.entry;

    return switch (colIndex) {
      0 => Text(item.sendDate?.formattedDate ?? '-'),
      1 => Text(item.medicine?.name ?? '-'),
      2 => Text(item.expirationDate?.formattedDate ?? '-'),
      3 => Text(item.quantity?.toCustomString() ?? '-'),
      4 => Text(item.transactionKind?.label ?? '-'),
      5 when !isEntry => Text(item.service?.name ?? '-'),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<StockTransaction>(
      data: transactions,
      enableExcel: true,
      columnDefs: _buildColumnDefs(),
      cellBuilder: _buildCell,
      actions: [
        if (onDelete != null) TableActionItem.delete(onPressed: (item) => onDelete!(item)),
      ],
    );
  }
}
