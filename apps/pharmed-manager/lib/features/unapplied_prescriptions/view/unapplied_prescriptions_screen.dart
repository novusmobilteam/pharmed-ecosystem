import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/widgets/unified_table/unified_table_models.dart';
import '../../../core/widgets/unified_table/unified_table_view.dart';
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
      )..getUnappliedPrescriptions(),
      builder: (context, child) {
        return Consumer<UnappliedPrescriptionsNotifier>(
          builder: (context, notifier, child) {
            return ResponsiveLayout(
              mobile: const MobileLayout(),
              tablet: const TabletLayout(),
              desktop: DesktopLayout(
                title: menu.name ?? 'Uygulanmamış Reçeteler',
                subtitle: menu.description,
                showAddButton: false,
                child: UnifiedTableView<Prescription>(
                  data: notifier.filteredItems,
                  isLoading: notifier.isFetching,
                  enableExcel: true,
                  enableDateFilter: true,
                  enableSearch: true,
                  onSearchChanged: notifier.search,
                  onDateRangeChanged: (value) {
                    notifier.setStartDate(value?.start);
                    notifier.setEndDate(value?.end);
                  },

                  // Tablo Satır Aksiyonları
                  actions: [
                    TableActionItem(
                      icon: PhosphorIcons.qrCode(),
                      tooltip: 'Detayları Görüntüle',
                      color: context.colorScheme.onSurface,
                      onPressed: (item) => showPrescriptionDetailView(context, prescription: item),
                    ),
                  ],
                  emptyWidget: CommonEmptyStates.noData(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
