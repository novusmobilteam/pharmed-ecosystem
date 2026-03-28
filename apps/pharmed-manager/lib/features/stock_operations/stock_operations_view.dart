import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/core.dart';
import '../filling_list/presentation/view/filling_list_view.dart';
import '../medicine_refill/presentation/view/medicine_refill_view.dart';
import '../medicine_unload/presentation/view/medicine_unload_view.dart';
import '../menu/menu.dart';

class StockOperationsView extends StatelessWidget {
  const StockOperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final operations = [
      MenuItem(
        label: 'İlaç Dolum',
        icon: PhosphorIcons.boxArrowUp(),
        builder: (context) => MedicineRefillView(),
      ),
      MenuItem(
        label: 'İlaç Dolum Listesi',
        icon: PhosphorIcons.listChecks(),
        builder: (context) => FillingListView(),
      ),
      MenuItem(
        label: 'İlaç Boşaltma',
        icon: PhosphorIcons.trayArrowDown(),
        builder: (context) => MedicineUnloadView(),
      ),
    ];

    return CustomDialog(
      title: 'Stok İşlemleri',
      child: SubGridMenuView(items: operations),
    );
  }
}
