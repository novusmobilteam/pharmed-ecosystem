// destruction_view.dart
// Üst seviye dispatcher — dashboard'dan CabinVisualizerData'yı izler, cihaz
// modunu kontrol eder. İmha SADECE master kabinde var (mobilde fire/imha
// akışı farklı bir ekrandan yürüyor), bu yüzden CensusView'daki gibi
// master/mobile switch'i yok — sadece master için render eder, mobilde
// (ya da mod belirsizken) bekleme/placeholder gösterir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/cache/app_settings_cache.dart';
import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../dashboard/presentation/notifier/dashboard_state.dart';
import 'master_destruction_view.dart';

class DestructionView extends ConsumerWidget {
  const DestructionView({super.key});

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
        CabinType.master => MasterDestructionView(data: cabinData),
        _ => const SizedBox.shrink(),
      },
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
