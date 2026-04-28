import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../widgets/cabin_stock_view.dart';

class CabinStockDialog extends StatelessWidget {
  const CabinStockDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDialog(title: 'Kabin Stok', maxHeight: context.height, width: context.width, child: CabinStockView());
  }
}
