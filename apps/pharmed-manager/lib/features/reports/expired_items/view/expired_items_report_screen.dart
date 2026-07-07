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
      create: (context) =>
          ExpiredItemsReportNotifier(getExpiredStocksUseCase: context.read(), getStationsUseCase: context.read())
            ..getStations(),
      builder: (context, child) {
        return Consumer<ExpiredItemsReportNotifier>(
          builder: (context, notifier, _) {
            return MedResponsiveLayout(
              mobile: const MedMobileLayout(),
              tablet: const MedTabletLayout(),
              desktop: MedDesktopLayout(
                title: menu.name ?? 'S.K.T Geçmiş Malzemeler',
                subtitle: menu.description,
                showAddButton: false,
                child: MedTable<CabinStock>(
                  data: notifier.items,
                  isLoading: notifier.isFetching,
                  enableExcel: true,
                  enableSearch: true,
                  enablePDF: true,
                  enableDateFilter: true,
                  // Pagination
                  enablePagination: true,
                  pageSize: notifier.pageSize,
                  currentPage: notifier.currentPage,
                  serverTotalCount: notifier.totalCount,
                  onPageChanged: notifier.setPage,

                  // Filter & Search
                  initialDateRange: notifier.dateRange,
                  onDateRangeChanged: notifier.setDateRange,
                  onSearchChanged: notifier.search,

                  // Kategori
                  categories: notifier.tableCategories,
                  selectedCategoryId: notifier.selectedCategoryId,
                  onCategoryChanged: (id) =>
                      notifier.selectStation(notifier.stations.firstWhere((s) => s.id.toString() == id)),
                  categoryTitle: 'İstasyonlar',

                  // Cell
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
