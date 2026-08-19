import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'refund.dart';

class RefundView extends ConsumerWidget {
  const RefundView({super.key, required this.menu, this.cabinData, this.deviceMode});

  final MenuItem menu;
  final CabinVisualizerData? cabinData;
  final CabinType? deviceMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (deviceMode) {
      CabinType.master => MasterRefundView(data: cabinData),
      CabinType.mobile => MobileRefundView(menu: menu),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
