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

import '../../../../shared/widgets/empty_state_widget.dart';
import 'drug_assignment_view.dart';

class AssignmentView extends ConsumerWidget {
  const AssignmentView({super.key, this.data});

  final CabinVisualizerData? data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceModeAsync = ref.watch(deviceModeProvider);

    return deviceModeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const EmptyStateWidget(variant: EmptyStateVariant.cabinData),
      data: (deviceMode) => switch (deviceMode) {
        'master' => DrugAssignmentView(data: data),
        'mobile' => const _PatientAssignmentPlaceholder(),
        _ => const EmptyStateWidget(variant: EmptyStateVariant.cabinData),
      },
    );
  }
}

class _PatientAssignmentPlaceholder extends StatelessWidget {
  const _PatientAssignmentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      variant: EmptyStateVariant.custom,
      icon: Icons.person_outline_rounded,
      title: 'Hasta bazlı atama',
      description: 'Bu özellik yakında kullanıma açılacak.',
    );
  }
}
