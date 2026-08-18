import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/cache/app_settings_cache.dart';
import '../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../dashboard/presentation/notifier/dashboard_state.dart';
import 'census.dart';

class CensusView extends ConsumerWidget {
  const CensusView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinData = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData,
          _ => null,
        },
      ),
    );
    final deviceModeAsync = ref.watch(deviceModeProvider);

    return switch (deviceModeAsync) {
      AsyncData(:final value) => switch (value) {
        CabinType.master => MasterCensusView(data: cabinData, menu: menu),
        CabinType.mobile => MobileCensusView(data: cabinData),
        _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      },
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
