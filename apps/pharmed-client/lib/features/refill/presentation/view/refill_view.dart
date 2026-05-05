import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../dashboard/presentation/state/dashboard_ui_state.dart';
import '../../refill.dart';

class RefillView extends ConsumerWidget {
  const RefillView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinData = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData,
          DashboardStale(:final data) => data.cabinVisualizerData,
          DashboardPartial(:final data) => data.cabinVisualizerData,
          _ => null,
        },
      ),
    );
    final deviceModeAsync = ref.watch(deviceModeProvider);

    return switch (deviceModeAsync) {
      AsyncData(:final value) => switch (value) {
        CabinType.master => MobileRefillView(data: cabinData),
        CabinType.mobile => MobileRefillView(data: cabinData),
        _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      },
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
