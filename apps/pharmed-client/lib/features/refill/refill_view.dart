import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../settings/notifier/settings_notifier.dart';
import 'master_refill/view/master_refill_view.dart';

class RefillView extends StatelessWidget {
  const RefillView({super.key, this.cabinData});

  final CabinVisualizerData? cabinData;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return FutureBuilder<CabinType?>(
      key: ValueKey(settings.debugCabin?.id),
      future: settings.getDeviceMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: MedLoadingIndicator());
        }

        return switch (snapshot.data) {
          CabinType.master =>
            cabinData != null ? MasterRefillView(data: cabinData!) : const Center(child: MedLoadingIndicator()),
          // CabinType.mobile => MobileRefillView(data: cabinData),
          _ => const Center(child: MedLoadingIndicator()),
        };
      },
    );
  }
}
