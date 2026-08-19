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

import 'master_destruction_view.dart';

class DestructionView extends ConsumerWidget {
  const DestructionView({super.key, required this.menu, this.cabinData, this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;
  final CabinType? deviceMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (deviceMode) {
      CabinType.master => MasterDestructionView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
