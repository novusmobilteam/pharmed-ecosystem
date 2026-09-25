import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../dashboard/dashboard.dart';

import '../notifier/master_destruction_execution_notifier.dart';
import '../notifier/master_destruction_selection_notifier.dart';
import 'master_destruction_execution_view.dart';
import 'master_destruction_selection_view.dart';

class MasterDestructionView extends ConsumerStatefulWidget {
  const MasterDestructionView({super.key, required this.cabinContext, required this.stationContext});

  final CabinRouteContext cabinContext;
  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterDestructionView> createState() => _MasterDestructionViewState();
}

class _MasterDestructionViewState extends ConsumerState<MasterDestructionView> {
  MasterDestructionExecutionNotifier? _executionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(masterDestructionSelectionNotifierProvider).init(widget.cabinContext);
    });

    _executionNotifier = ref.read(masterDestructionExecutionNotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      if (!mounted) return;
      ref.read(masterDestructionSelectionNotifierProvider).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(masterDestructionSelectionNotifierProvider);
    final isExecuting = ref.watch(masterDestructionExecutionNotifierProvider.select((n) => n.isExecuting));

    if (widget.cabinContext.cabinData == null) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.noCabin));
    }
    if (selection.isLoadingAssignments) return const Center(child: MedLoadingIndicator());
    if (selection.isError) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return isExecuting
        ? MasterDestructionExecutionView(stationContext: widget.stationContext)
        : MasterDestructionSelectionView(cabinContext: widget.cabinContext);
  }
}
