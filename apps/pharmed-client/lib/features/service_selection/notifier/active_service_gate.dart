import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/dashboard.dart';
import '../view/service_selection_screen.dart';
import 'active_service_notifier.dart';

/// İstasyon birden fazla servise hizmet
/// veriyorsa dashboard'dan önce servis seçimini zorunlu kılan gate.
class ActiveServiceGate extends ConsumerStatefulWidget {
  const ActiveServiceGate({super.key});

  @override
  ConsumerState<ActiveServiceGate> createState() => _ActiveServiceGateState();
}

class _ActiveServiceGateState extends ConsumerState<ActiveServiceGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(activeServiceNotifierProvider);
      if (notifier.station == null && !notifier.isLoadingServices) {
        notifier.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeService = ref.watch(activeServiceNotifierProvider);

    if (activeService.station == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (activeService.requiresSelection) {
      return const ServiceSelectionScreen();
    }

    return const DashboardScreen();
  }
}
