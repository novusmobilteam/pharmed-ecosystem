// [SWREQ-UI-CAB-006]
// Arıza bildirimi ekranı.
//
// Sol panel:  CabinOverviewPanel  — çekmece listesi
// Orta panel: DrawerDetailPanel   — fault modunda göz renkleri arıza durumuna göre
// Sağ panel:  OperationPanelBase
//               └── FaultPanel
//
// ConsumerStatefulWidget kullanım sebebi:
//   - initState / didUpdateWidget → notifier.init(data)
//   - descriptionController lifecycle yönetimi
//   - Göz değişiminde controller temizleme
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cache/app_settings_cache.dart';
import '../../../../l10n/l10n_ext.dart';
import '../../../../widgets/widgets.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../dashboard/presentation/notifier/dashboard_notifier.dart';
import '../../../dashboard/presentation/state/dashboard_ui_state.dart';
import '../notifier/master_fault_notifier.dart';
import '../notifier/mobile_fault_notifier.dart';
import '../state/fault_panel_state.dart';
import '../state/master_fault_state.dart';
import '../state/mobile_fault_state.dart';

part 'master_fault_view.dart';
part 'mobile_fault_view.dart';
part 'fault_panel.dart';

class FaultView extends ConsumerWidget {
  const FaultView({super.key});

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
    final deviceModeAsync = ref.watch(deviceModeProvider);

    return switch (deviceModeAsync) {
      AsyncData(:final value) => switch (value) {
        CabinType.master => MasterFaultView(data: cabinData),
        CabinType.mobile => MobileFaultView(data: cabinData),
        _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      },
      _ => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    };
  }
}
