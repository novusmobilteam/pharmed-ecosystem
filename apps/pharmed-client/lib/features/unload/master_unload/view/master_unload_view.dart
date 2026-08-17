import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/hardware/cabin/master_drawer/master_drawer_orchestrator_2.dart';
import '../../../../widgets/cabin_operation_selection_view.dart';
import '../../../../widgets/cabin_operation_widget.dart';
import '../../../../widgets/med_rectangle_button.dart';
import '../../../../widgets/widgets.dart';
import '../notifier/master_unload_notifier.dart';
import 'package:provider/provider.dart';

part 'selection_view.dart';
part 'execution_view.dart';

class MasterUnloadView extends StatefulWidget {
  const MasterUnloadView({super.key, required this.data});

  final CabinVisualizerData data;

  @override
  State<MasterUnloadView> createState() => _MasterUnloadViewState();
}

class _MasterUnloadViewState extends State<MasterUnloadView> {
  late final MasterUnloadNotifier _notifier;
  bool _snackbarScheduled = false;

  @override
  void initState() {
    super.initState();
    _notifier = MasterUnloadNotifier(
      getAssignments: context.read(),
      orchestrator: MasterDrawerOrchestrator(
        startSession: context.read(),
        openCubicLid: context.read(),
        monitorClosure: context.read(),
      ),
      completeUnload: context.read(),
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
    return ChangeNotifierProvider<MasterUnloadNotifier>.value(
      value: _notifier,
      child: Consumer<MasterUnloadNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading(notifier.fetchAssignmentOp) && notifier.assignments.isEmpty) {
            return Center(child: MedLoadingIndicator());
          }

          if (notifier.isExecuting) {
            return MasterUnloadExecutionView(allGroups: widget.data.groups);
          }

          return MasterUnloadSelectionView();
        },
      ),
    );
  }
}
