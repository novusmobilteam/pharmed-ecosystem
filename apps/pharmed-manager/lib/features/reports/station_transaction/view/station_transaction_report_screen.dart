import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../notifier/station_transaction_report_notifier.dart';
import 'package:provider/provider.dart';

class StationTransactionReportScreen extends StatelessWidget {
  const StationTransactionReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StationTransactionReportNotifier(
        getCabinStockTransactionsUseCase: context.read(),
        getStationsUseCase: context.read(),
      )..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          title: menu.name ?? 'İstasyon Hareketleri',
          subtitle: menu.description,
          child: Consumer<StationTransactionReportNotifier>(
            builder: (context, notifier, _) {
              return MedTable(
                isLoading: notifier.isFetching,
                enableSearch: true,
                onSearchChanged: notifier.search,
                enableExcel: true,
                data: notifier.transactions,
                categories: notifier.tableCategories,
                selectedCategoryId: notifier.selectedCategoryId,
                onCategoryChanged: (id) =>
                    notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
              );
            },
          ),
        ),
      ),
    );
  }
}
