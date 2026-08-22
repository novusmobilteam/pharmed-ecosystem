import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'intake.dart';

class IntakeView extends ConsumerWidget {
  const IntakeView({super.key, this.stationContext});

  final StationCabinsContext? stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = stationContext?.deviceMode;

    if (stationContext == null) return const Center(child: MedLoadingIndicator());

    return switch (deviceMode) {
      CabinType.master => MasterIntakeView(stationContext: stationContext!),
      CabinType.mobile => MobileIntakeView(data: stationContext!.dataFor(stationContext!.cabins.firstOrNull?.id)),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
