import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'refill.dart';

class RefillView extends ConsumerWidget {
  const RefillView({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;
    final cabinData = cabinRouteContext.cabinData;

    return switch (deviceMode) {
      CabinType.master => MasterRefillView(cabinContext: cabinRouteContext),
      CabinType.mobile => MobileRefillView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
