import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../dashboard/dashboard.dart';
import '../notifier/master_refill_execution_notifier.dart';
import '../notifier/master_refill_selection_notifier.dart';
import 'master_refill_execution_view.dart';
import 'master_refill_selection_view.dart';

class MasterRefillView extends ConsumerStatefulWidget {
  const MasterRefillView({super.key, required this.cabinContext, required this.stationContext});

  final CabinRouteContext cabinContext;
  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterRefillView> createState() => _MasterRefillViewState();
}

class _MasterRefillViewState extends ConsumerState<MasterRefillView> {
  MasterRefillExecutionNotifier? _executionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterRefillSelectionNotifierProvider).init(widget.cabinContext);
    });

    _executionNotifier = ref.read(masterRefillExecutionNotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      if (!mounted) return;
      ref.read(masterRefillSelectionNotifierProvider).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterRefillSelectionNotifierProvider);
    final isExecuting = ref.watch(masterRefillExecutionNotifierProvider.select((n) => n.isExecuting));

    if (widget.cabinContext.cabinData == null) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }
    if (selection.isLoadingAssignments) return const Center(child: MedLoadingIndicator());
    if (selection.isError) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return isExecuting
        ? MasterRefillExecutionView(stationContext: widget.stationContext)
        : MasterRefillSelectionView(cabinContext: widget.cabinContext);
  }
}
