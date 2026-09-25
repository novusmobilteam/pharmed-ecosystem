import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../dashboard/dashboard.dart';
import '../notifier/master_unload_execution_notifier.dart';
import '../notifier/master_unload_selection_notifier.dart';
import 'master_unload_execution_view.dart';
import 'master_unload_selection_view.dart';

class MasterUnloadView extends ConsumerStatefulWidget {
  const MasterUnloadView({super.key, required this.cabinContext, required this.stationContext});

  final CabinRouteContext cabinContext;
  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterUnloadView> createState() => _MasterUnloadViewState();
}

class _MasterUnloadViewState extends ConsumerState<MasterUnloadView> {
  MasterUnloadExecutionNotifier? _executionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterUnloadSelectionNotifierProvider).init(widget.cabinContext);
    });

    _executionNotifier = ref.read(masterUnloadExecutionNotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      if (!mounted) return;
      ref.read(masterUnloadSelectionNotifierProvider).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterUnloadSelectionNotifierProvider);
    final isExecuting = ref.watch(masterUnloadExecutionNotifierProvider.select((n) => n.isExecuting));

    if (widget.cabinContext.cabinData == null) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }
    if (selection.isLoadingAssignments) return const Center(child: MedLoadingIndicator());
    if (selection.isError) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return isExecuting
        ? MasterUnloadExecutionView(stationContext: widget.stationContext)
        : MasterUnloadSelectionView(cabinContext: widget.cabinContext);
  }
}
