import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../settings/notifier/settings_notifier.dart';
import 'intake.dart';

class IntakeView extends StatefulWidget {
  const IntakeView({super.key, this.cabinData});
  final CabinVisualizerData? cabinData;

  @override
  State<IntakeView> createState() => _IntakeViewState();
}

class _IntakeViewState extends State<IntakeView> {
  late Future<CabinType?> _deviceModeFuture;
  int? _debugCabinId;

  @override
  void initState() {
    super.initState();
    _debugCabinId = context.read<SettingsNotifier>().debugCabin?.id;
    _deviceModeFuture = context.read<SettingsNotifier>().getDeviceMode();
  }

  @override
  Widget build(BuildContext context) {
    // Sadece debugCabin GERÇEKTEN değiştiğinde future'ı yenile — select
    // build()'ı yalnızca bu değer farklı olduğunda tekrar tetikler, o
    // yüzden burada ekstra bir setState'e gerek yok.
    final debugCabinId = context.select<SettingsNotifier, int?>((s) => s.debugCabin?.id);
    if (debugCabinId != _debugCabinId) {
      _debugCabinId = debugCabinId;
      _deviceModeFuture = context.read<SettingsNotifier>().getDeviceMode();
    }

    return FutureBuilder<CabinType?>(
      future: _deviceModeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: MedLoadingIndicator());
        }
        return switch (snapshot.data) {
          CabinType.master =>
            widget.cabinData != null
                ? MasterIntakeView(data: widget.cabinData!)
                : const Center(child: MedLoadingIndicator()),
          _ => const Center(child: MedLoadingIndicator()),
        };
      },
    );
  }
}
