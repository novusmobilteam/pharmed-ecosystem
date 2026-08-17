import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../settings/notifier/settings_notifier.dart';
import 'census.dart';

class CensusView extends StatelessWidget {
  const CensusView({super.key, this.cabinData});

  final CabinVisualizerData? cabinData;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return FutureBuilder<CabinType?>(
      // debugCabin değişince future'ı yeniden kur — bkz. DestructionView.
      key: ValueKey(settings.debugCabin?.id),
      future: settings.getDeviceMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        return switch (snapshot.data) {
          CabinType.master =>
            cabinData != null ? MasterCensusView(data: cabinData!) : const Center(child: MedLoadingIndicator()),
          // CabinType.mobile => MobileCensusView(data: cabinData),
          _ => const Center(child: MedLoadingIndicator()),
        };
      },
    );
  }
}
