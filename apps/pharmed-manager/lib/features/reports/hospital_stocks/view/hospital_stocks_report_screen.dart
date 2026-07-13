import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/hospital_stocks_report_notifier.dart';

class HospitalStocksReportScreen extends StatelessWidget {
  const HospitalStocksReportScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          HospitalStocksReportNotifier(getStationsUseCase: context.read(), getHospitalStocksUseCase: context.read())
            ..getStations(),
      child: MedResponsiveLayout(
        mobile: MedMobileLayout(),
        tablet: MedTabletLayout(),
        desktop: MedDesktopLayout(
          title: menu.name ?? context.l10n.report_hospitalStocksTitleFallback,
          subtitle: menu.description,
          child: Consumer<HospitalStocksReportNotifier>(
            builder: (context, notifier, _) {
              return MedTable(
                data: notifier.items,
                isLoading: notifier.isFetching,
                enableExcel: true,
                enableSearch: true,
                enablePDF: true,
                enableDateFilter: false,

                // Pagination
                enablePagination: true,
                pageSize: notifier.pageSize,
                currentPage: notifier.currentPage,
                serverTotalCount: notifier.totalCount,
                onPageChanged: notifier.setPage,

                onSearchChanged: notifier.search,

                // Kategori
                categories: notifier.tableCategories,
                selectedCategoryId: notifier.selectedCategoryId,
                onCategoryChanged: (id) =>
                    notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
                categoryTitle: context.l10n.report_stationsCategoryTitle,
              );
            },
          ),
        ),
      ),
    );
  }
}
