import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'unload.dart';

class UnloadView extends ConsumerWidget {
  const UnloadView({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;
    final cabinData = cabinRouteContext.cabinData;

    return switch (deviceMode) {
      CabinType.master => MasterUnloadView(cabinContext: cabinRouteContext),
      CabinType.mobile => MobileUnloadView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
