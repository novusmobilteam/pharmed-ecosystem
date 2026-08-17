import 'package:flutter/material.dart';
import 'package:pharmed_client/core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import 'package:pharmed_client/widgets/cabin_operation_widget.dart';
import 'package:pharmed_client/widgets/cabin_operation_selection_view.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/widgets.dart';
import '../../../settings/notifier/settings_notifier.dart';
import '../notifier/master_refill_notifier.dart';

part 'selection_view.dart';
part 'execution_view.dart';

class MasterRefillView extends StatefulWidget {
  const MasterRefillView({super.key, required this.data});

  final CabinVisualizerData data;

  @override
  State<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends State<MasterRefillView> {
  late final MasterRefillNotifier _notifier;
  bool _snackbarScheduled = false;

  @override
  void initState() {
    super.initState();
    _notifier = MasterRefillNotifier(
      getAssignments: context.read(),
      orchestrator: MasterDrawerOrchestrator(
        startSession: context.read(),
        openCubicLid: context.read(),
        monitorClosure: context.read(),
      ),
      refillCabin: context.read(),
    )..init(widget.data);
    _notifier.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _notifier.dispose();
    super.dispose();
  }

  void _onNotifierChanged() {
    final error = _notifier.transientSaveError;
    if (error == null || _snackbarScheduled) return;
    _snackbarScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _snackbarScheduled = false;
      if (!mounted) return;
      MessageUtils.showErrorSnackbar(context, error.message);
      _notifier.dismissTransientSaveError();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MasterRefillNotifier>.value(
      value: _notifier,
      child: Consumer<MasterRefillNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading(notifier.fetchAssignmentOp) && notifier.assignments.isEmpty) {
            return Center(child: MedLoadingIndicator());
          }

          if (notifier.isExecuting) {
            return MasterRefillExecutionView(allGroups: widget.data.groups);
          }

          return MasterRefillSelectionView();
        },
      ),
    );
  }
}
