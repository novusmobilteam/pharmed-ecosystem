part of 'pharmacy_refund_screen.dart';

class CompletedRefundsView extends StatelessWidget {
  const CompletedRefundsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletedPharmacyRefundNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          title: 'Tamamlanmış İadeler',
          width: context.width * 0.9,
          maxHeight: 800,
          child: _buildContent(context, notifier),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, CompletedPharmacyRefundNotifier notifier) {
    if (notifier.isFetching && notifier.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (notifier.isEmpty) {
      return CommonEmptyStates.generic(
        icon: PhosphorIcons.receipt(),
        message: 'İade bulunamadı',
        subMessage: 'Alınmış iade kaydı bulunmuyor',
      );
    }

    return _CompletedRefundsTableView(notifier: notifier);
  }
}

class _CompletedRefundsTableView extends StatelessWidget {
  const _CompletedRefundsTableView({required this.notifier});

  final CompletedPharmacyRefundNotifier notifier;

  List<TableColumnDef> _buildColumnDefs() => const [
        TableColumnDef(title: 'Hasta Kodu', flex: 0.8), // colIndex: 0
        TableColumnDef(title: 'Hasta', flex: 1.2), // colIndex: 1
        TableColumnDef(title: 'Kullanıcı'), // colIndex: 2
        TableColumnDef(title: 'Malzeme', flex: 1.5), // colIndex: 3
        TableColumnDef(title: 'Miktar', numeric: true, flex: 0.7), // colIndex: 4
        TableColumnDef(title: 'Tarih'), // colIndex: 5
        TableColumnDef(title: 'İade Alan Kullanıcı'), // colIndex: 6
        TableColumnDef(title: 'İade Alma Tarihi'), // colIndex: 7
        TableColumnDef(title: 'Açıklama', flex: 1.5), // colIndex: 8
      ];

  Widget? _buildCell(Refund item, int colIndex, dynamic _) {
    return switch (colIndex) {
      0 => Text(item.patient?.id?.toString() ?? '-'),
      1 => Text(item.patient?.fullName ?? '-'),
      2 => Text(item.user ?? '-'),
      3 => Text(item.medicine?.name ?? '-'),
      4 => Text(item.quantity?.formatFractional ?? '-'),
      5 => Text(item.receiveDate?.formattedDate ?? '-'),
      6 => Text(item.receiveUser?.fullName ?? '-'),
      7 => Text(item.receiveDate?.formattedDate ?? '-'),
      8 => Text(item.description ?? '-'),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedTableView<Refund>(
      data: notifier.filteredItems,
      isLoading: notifier.isFetching,
      horizontalScroll: true,
      minTableWidth: 2000,
      enableExcel: true,
      enableSearch: true,
      enableDateFilter: true,
      onSearchChanged: notifier.search,
      onDateRangeChanged: (range) {
        notifier.setStartDate(range?.start);
        notifier.setEndDate(range?.end);
      },
      columnDefs: _buildColumnDefs(),
      cellBuilder: _buildCell,
      emptyWidget: notifier.hasNoSearchResults ? CommonEmptyStates.searchNotFound() : CommonEmptyStates.noData(),
    );
  }
}
