import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'census.dart';

class CensusView extends ConsumerWidget {
  const CensusView({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;
    final cabinData = cabinRouteContext.cabinData;

    return switch (deviceMode) {
      CabinType.master => MasterCensusView(cabinContext: cabinRouteContext),
      CabinType.mobile => MobileCensusView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
