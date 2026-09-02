import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';

import '../notifier/drawer_refund_notifier.dart';

part 'drawer_table_view.dart';

class DrawerRefundScreen extends StatelessWidget {
  const DrawerRefundScreen({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DrawerRefundNotifier(getStationsUseCase: context.read(), getRefundsUseCase: context.read())..getStations(),
      child: Consumer<DrawerRefundNotifier>(
        builder: (context, notifier, _) {
          return MedResponsiveLayout(
            mobile: const MedMobileLayout(),
            tablet: const MedTabletLayout(),
            desktop: MedDesktopLayout(
              menu: menu,
              //isLoading: notifier.isLoading(notifier.fetchRefundsOp),
              child: TableView(notifier: notifier),
            ),
          );
        },
      ),
    );
  }
}
