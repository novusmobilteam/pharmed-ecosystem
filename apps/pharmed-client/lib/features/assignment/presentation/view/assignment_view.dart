// lib/features/cabin/presentation/screen/assignment_view.dart
//
// [SWREQ-UI-CAB-003]
// İlaç atama ekranı router'ı.
//
// AppSettingsCache'den cihaz modunu okur:
//   "mobile"  → PatientAssignmentView (ilerleyen sprint)
//   "master"  → DrugAssignmentView
//   null      → EmptyStateWidget
//
// Bu widget veri taşımaz — doğru view'ı seçmekten sorumludur.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../dashboard/presentation/state/dashboard_ui_state.dart';
import 'drug_assignment_view.dart';
import 'patient_assignment_view.dart';

class AssignmentView extends ConsumerWidget {
  const AssignmentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinData = ref.watch(
      dashboardNotifierProvider.select(
        (s) => switch (s) {
          DashboardLoaded(:final data) => data.cabinVisualizerData,
          DashboardStale(:final data) => data.cabinVisualizerData,
          DashboardPartial(:final data) => data.cabinVisualizerData,
          _ => null,
        },
      ),
    );
    final deviceMode = ref.watch(deviceModeProvider);

    return switch (deviceMode) {
      CabinType.master => DrugAssignmentView(data: cabinData),
      CabinType.mobile => PatientAssignmentView(data: cabinData),
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
