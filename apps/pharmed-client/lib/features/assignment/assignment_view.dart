import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'drug_assignment/view/drug_assignment_view.dart';
import 'bed_assignment/view/bed_assignment_view.dart';

class AssignmentView extends ConsumerWidget {
  const AssignmentView({super.key, this.cabinRouteContext});

  final CabinRouteContext? cabinRouteContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext?.deviceMode;
    final cabin = cabinRouteContext?.cabin;
    final cabinData = cabinRouteContext?.cabinData;
    final menu = cabinRouteContext?.menu;

    return switch (deviceMode) {
      CabinType.master => DrugAssignmentView(cabin: cabin, data: cabinData, menu: menu!),
      CabinType.mobile => BedAssignmentView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
