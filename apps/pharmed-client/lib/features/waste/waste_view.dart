import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../dashboard/presentation/notifier/dashboard_state.dart';
import 'waste.dart';

class WasteView extends ConsumerWidget {
  const WasteView({super.key, required this.menu});

  final MenuItem menu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceModeAsync = ref.watch(deviceModeProvider);
    final cabinData = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData,
          _ => null,
        },
      ),
    );

    return switch (deviceModeAsync) {
      AsyncData(:final value) => switch (value) {
        CabinType.master => MasterWasteView(data: cabinData),
        CabinType.mobile => MobileWasteView(menu: menu),
        _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      },
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
