import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'cabin_stock.dart';

class CabinStockView extends ConsumerWidget {
  const CabinStockView({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;

    return switch (deviceMode) {
      CabinType.master => MasterCabinStockScreen(cabinRouteContext: cabinRouteContext),
      CabinType.mobile => MobileCabinStockScreen(cabinRouteContext: cabinRouteContext),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
