import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'drug_assignment/view/drug_assignment_view.dart';
import 'bed_assignment/view/bed_assignment_view.dart';

class AssignmentView extends ConsumerWidget {
  const AssignmentView({super.key, required this.cabinRouteContext, required this.stationContext});

  final CabinRouteContext cabinRouteContext;
  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceMode = cabinRouteContext.deviceMode;
    final cabinData = cabinRouteContext.cabinData;

    return switch (deviceMode) {
      CabinType.master => DrugAssignmentView(stationContext: stationContext),
      CabinType.mobile => BedAssignmentView(data: cabinData),
      _ => const Center(child: MedLoadingIndicator()),
    };
  }
}
