import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

import '../notifier/unapplied_prescriptions_notifier.dart';

part 'prescription_detail_view.dart';

class UnappliedPrescriptionsScreen extends StatelessWidget {
  const UnappliedPrescriptionsScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UnappliedPrescriptionsNotifier(
        getUnappliedPrescriptionsUseCase: context.read(),
        getUnappliedPrescriptionDetailUseCase: context.read(),
      )..fetch(),
      builder: (context, child) {
        return Consumer<UnappliedPrescriptionsNotifier>(
          builder: (context, notifier, child) {
            return MedResponsiveLayout(
              mobile: const MedMobileLayout(),
              tablet: const MedTabletLayout(),
              desktop: MedDesktopLayout(
                title: menu.name ?? 'Uygulanmamış Reçeteler',
                subtitle: menu.description,
                showAddButton: false,
                child: MedTable<Prescription>(
                  data: notifier.items,
                  isLoading: notifier.isFetching,
                  enableExcel: true,
                  enableDateFilter: true,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  onDateRangeChanged: notifier.setDateRange,

                  // Tablo Satır Aksiyonları
                  actions: [
                    TableActionItem(
                      icon: PhosphorIcons.qrCode(),
                      tooltip: 'Detayları Görüntüle',
                      color: context.colorScheme.onSurface,
                      onPressed: (item) => showPrescriptionDetailView(context, prescription: item),
                    ),
                  ],
                  emptyWidget: EmptyStateWidget(variant: EmptyStateVariant.noResults),

                  enablePagination: true,
                  pageSize: notifier.pageSize,
                  currentPage: notifier.currentPage,
                  onPageChanged: (page) => notifier.setPage(page),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
