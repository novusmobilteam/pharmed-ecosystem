import 'package:flutter/material.dart';
import 'package:pharmed_client/features/assignment/drug_assignment/view/drug_assignment_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../settings/notifier/settings_notifier.dart';

class AssignmentView extends StatelessWidget {
  const AssignmentView({super.key});

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
          CabinType.master =>
            cabinData != null ? DrugAssignmentView(data: cabinData) : const Center(child: MedLoadingIndicator()),
          // CabinType.mobile => MobileAssignmentView(data: cabinData),
          _ => const Center(child: MedLoadingIndicator()),
        };
      },
    );
  }
}
