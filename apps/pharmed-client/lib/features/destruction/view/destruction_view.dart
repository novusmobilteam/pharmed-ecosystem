import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../settings/notifier/settings_notifier.dart';
import 'master_destruction_view.dart';

class DestructionView extends StatelessWidget {
  const DestructionView({super.key});

  @override
  Widget build(BuildContext context) {
    final cabinData = context.watch<DashboardNotifier>().cabinVisualizerData;
    final settings = context.watch<SettingsNotifier>();

    return FutureBuilder<CabinType?>(
      key: ValueKey(settings.debugCabin?.id),
      future: settings.getDeviceMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: MedLoadingIndicator());
        }

        return switch (snapshot.data) {
          CabinType.master => MasterDestructionView(data: cabinData),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
