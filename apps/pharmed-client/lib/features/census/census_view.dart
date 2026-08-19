import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'census.dart';

class CensusView extends ConsumerWidget {
  const CensusView({super.key, required this.menu, this.cabinData, this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;
  final CabinType? deviceMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (deviceMode) {
      CabinType.master => MasterCensusView(data: cabinData, menu: menu),
      CabinType.mobile => MobileCensusView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
