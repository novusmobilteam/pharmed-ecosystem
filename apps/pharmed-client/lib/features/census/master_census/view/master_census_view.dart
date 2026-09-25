import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../dashboard/dashboard.dart';
import '../../census.dart';
import '../notifier/master_census_execution_notifier.dart';
import '../notifier/master_census_selection_notifier.dart';

class MasterCensusView extends ConsumerStatefulWidget {
  const MasterCensusView({super.key, required this.cabinContext, required this.stationContext});

  final CabinRouteContext cabinContext;
  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterCensusView> createState() => _MasterCensusViewState();
}

class _MasterCensusViewState extends ConsumerState<MasterCensusView> {
  MasterCensusExecutionNotifier? _executionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterCensusSelectionNotifierProvider).init(widget.cabinContext);
    });

    _executionNotifier = ref.read(masterCensusExecutionNotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      if (!mounted) return;
      ref.read(masterCensusSelectionNotifierProvider).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterCensusSelectionNotifierProvider);
    final isExecuting = ref.watch(masterCensusExecutionNotifierProvider.select((n) => n.isExecuting));

    if (widget.cabinContext.cabinData == null) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }
    if (selection.isLoadingAssignments) {
      return const Center(child: MedLoadingIndicator());
    }
    if (selection.isError) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return isExecuting
        ? MasterCensusExecutionView(stationContext: widget.stationContext)
        : MasterCensusSelectionView(cabinContext: widget.cabinContext);
  }
}
