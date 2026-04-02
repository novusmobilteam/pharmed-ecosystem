import 'package:flutter/material.dart';

import '../../core/core.dart';

class StockOperationsView extends StatelessWidget {
  const StockOperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final operations = [
      MenuItem(
        label: 'İlaç Dolum',
        //icon: PhosphorIcons.boxArrowUp(),
        // builder: (context) => MedicineRefillView(),
      ),
      MenuItem(
        label: 'İlaç Dolum Listesi',
        //icon: PhosphorIcons.listChecks(),
        // builder: (context) => FillingListView(),
      ),
      MenuItem(
        label: 'İlaç Boşaltma',
        //icon: PhosphorIcons.trayArrowDown(),
        // builder: (context) => MedicineUnloadView(),
      ),
    ];

    return CustomDialog(
      title: 'Stok İşlemleri',
      child: SubGridMenuView(items: operations),
    );
  }
}
