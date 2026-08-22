import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../dashboard/dashboard.dart';
import 'master_destruction_view.dart';

class DestructionView extends ConsumerWidget {
  const DestructionView({super.key, required this.cabinRouteContext});

  final CabinRouteContext cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;

    return switch (deviceMode) {
      CabinType.master => MasterDestructionView(cabinContext: cabinRouteContext),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
