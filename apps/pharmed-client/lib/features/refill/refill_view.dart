import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'refill.dart';

class RefillView extends ConsumerWidget {
  const RefillView({super.key, required this.menu, this.cabinData, this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;
  final CabinType? deviceMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (deviceMode) {
      CabinType.master => MasterRefillView(data: cabinData, menu: menu),
      CabinType.mobile => MobileRefillView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
