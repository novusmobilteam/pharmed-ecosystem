import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/intake/master_intake/notifier/master_intake_selection_notifier.dart';
import 'package:pharmed_client/widgets/empty_widgets/no_selected_hospitalization_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/empty_widgets/no_data_view.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_intake_execution_notifier.dart';
import '../notifier/patient_selection_notifier.dart';
import '../widgets/drawer_stage_status_banner.dart';
import '../widgets/intake_active_medicine_card.dart';
import '../widgets/intake_check_dialog.dart';
import '../widgets/intake_ordered_item_card.dart';
import '../widgets/intake_orderless_item_card.dart';

part 'patient_selection_view.dart';
part 'master_intake_selection_view.dart';
part 'master_intake_execution_view.dart';
part 'intake_qr_code_dialog.dart';

class MasterIntakeView extends ConsumerStatefulWidget {
  const MasterIntakeView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterIntakeView> createState() => _MasterIntakeView2State();
}

class _MasterIntakeView2State extends ConsumerState<MasterIntakeView> {
  MasterIntakeExecutionNotifier? _executionNotifier;
  PatientSelectionNotifier2? _patientSelectionNotifier;

  @override
  void initState() {
    super.initState();
    ref.read(masterIntakeSelectionNotifierProvider.notifier).init(widget.stationContext);

    _executionNotifier = ref.read(masterIntakeExecutionNotifierProvider);
    _patientSelectionNotifier = ref.read(patientSelection2NotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      // Kuyruk bitişi asenkron (sensör event'i) tetiklendiği için, bu
      // callback widget dispose OLDUKTAN SONRA da ateşlenebilir — ref'i
      // kullanmadan önce mutlaka mounted kontrolü yap.
      if (!mounted) return;
      ref.read(masterIntakeSelectionNotifierProvider.notifier).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    _patientSelectionNotifier?.clearSelections();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(patientSelection2NotifierProvider);
    final intakeSelectionNotifier = ref.watch(masterIntakeSelectionNotifierProvider);
    final executionNotifier = ref.watch(masterIntakeExecutionNotifierProvider);

    final isExecuting = ref.watch(masterIntakeExecutionNotifierProvider.select((n) => n.isExecuting));

    if (isExecuting) {
      return MasterIntakeExecutionView(stationContext: widget.stationContext);
    }

    return MasterIntakeSelectionView(
      stationContext: widget.stationContext,
      notifier: notifier,
      intakeSelectionNotifier: intakeSelectionNotifier,
      executionNotifier: executionNotifier,
    );
  }
}
