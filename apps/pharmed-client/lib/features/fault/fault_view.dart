import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dashboard/dashboard.dart';
import 'master_fault/notifier/master_fault_notifier.dart';
import 'mobile_fault/notifier/mobile_fault_notifier.dart';
import 'fault_panel_state.dart';
import 'master_fault/notifier/master_fault_state.dart';
import 'mobile_fault/notifier/mobile_fault_state.dart';

part 'master_fault/view/master_fault_view.dart';
part 'mobile_fault/view/mobile_fault_view.dart';
part 'fault_panel.dart';

class FaultView extends StatelessWidget {
  const FaultView({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  Widget build(BuildContext context) {
    final deviceMode = cabinRouteContext?.deviceMode;
    final cabinData = cabinRouteContext?.cabinData;

    return switch (deviceMode) {
      CabinType.master => MasterFaultView(data: cabinData),
      CabinType.mobile => MobileFaultView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
