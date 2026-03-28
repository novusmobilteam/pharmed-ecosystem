import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/clock_view.dart';
import '../../../auth/presentation/view/login_view.dart';

import '../notifier/manager_dashboard_notifier.dart';
import '../widgets/cabin_stat_card.dart';
import '../widgets/critical_stock_card.dart';
import '../widgets/expiring_materials_card.dart';
import '../widgets/refund_materials_card.dart';
import '../widgets/unapplied_qr_card.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ManagerDashboardNotifier(
        getExpiringMaterialsUseCase: context.read(),
        getUnappliedPrescriptionsUseCase: context.read(),
        getRefundsUseCase: context.read(),
        getCriticalStocksUseCase: context.read(),
      )..fetch(),
      child: Consumer<ManagerDashboardNotifier>(
        builder: (context, notifier, child) {
          final rightSideWidgets = [
            CriticalStockCard(items: notifier.criticStocks),
            ExpiringMaterialsCard(items: notifier.expiringMaterials),
            RefundMaterialsCard(items: notifier.refunds),
            UnappliedQrCodeCard(items: notifier.unappliedPrescriptions),
          ];

          return GestureDetector(
            onTap: () => showLoginView(context),
            child: Scaffold(
              body: Padding(
                padding: AppDimensions.pagePadding * 1.5,
                child: Column(
                  children: [
                    // MARK: Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          AppImages.appLogo,
                          height: 40,
                          color: context.colorScheme.primary,
                        ),
                        ClockView.large(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // MARK: Body
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 1.6,
                              ),
                              itemCount: rightSideWidgets.length,
                              itemBuilder: (context, index) => rightSideWidgets[index],
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 320,
                            child: _buildCabinList(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCabinList(BuildContext context) {
    final List<Map<String, dynamic>> cabins = [
      {'name': 'Kabin A', 'heat': 4.2, 'humidity': 45.0, 'isOk': true},
      {'name': 'Kabin B', 'heat': 3.8, 'humidity': 42.1, 'isOk': true},
      {'name': 'Kabin C', 'heat': 5.1, 'humidity': 50.5, 'isOk': false}, // Örn: Isı yüksek
      {'name': 'Kabin D', 'heat': 4.0, 'humidity': 44.2, 'isOk': true},
    ];

    return ListView.separated(
      itemCount: cabins.length,
      separatorBuilder: (c, i) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = cabins[index];
        return CabinStatCard(
          name: item['name'],
          heat: item['heat'],
          humidity: item['humidity'],
          isOk: item['isOk'],
        );
      },
    );
  }
}
