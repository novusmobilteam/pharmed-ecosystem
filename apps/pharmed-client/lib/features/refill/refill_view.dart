import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'master_refill/view/master_refill_view.dart';
import 'mobile_refill/view/mobile_refill_view.dart';

class RefillView extends ConsumerWidget {
  const RefillView({super.key, required this.cabinRouteContext, required this.stationContext});

  final CabinRouteContext cabinRouteContext;
  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;
    final cabinData = cabinRouteContext.cabinData;

    return switch (deviceMode) {
      CabinType.master => MasterRefillView(cabinContext: cabinRouteContext, stationContext: stationContext),
      CabinType.mobile => MobileRefillView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
