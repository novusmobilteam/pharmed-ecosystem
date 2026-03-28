import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../warehouse/domain/entity/warehouse.dart';

class WarehouseSideListView extends StatelessWidget {
  final List<Warehouse> items;
  final int activeIndex;
  final Function(Warehouse) onTap;

  const WarehouseSideListView({
    required this.items,
    required this.activeIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PharmedSideListView<Warehouse>(
      title: 'Depolar',
      items: items,
      activeIndex: activeIndex,
      onTap: onTap,
      labelBuilder: (w) => w.name,
    );
  }
}
