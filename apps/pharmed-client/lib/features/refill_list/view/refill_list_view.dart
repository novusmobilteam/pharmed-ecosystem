import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/empty_widgets/empty_selection_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/hardware/hardware.dart';
import '../../../widgets/widgets.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/refill_list_execution_notifier.dart';
import '../notifier/refill_list_selection_notifier.dart';
import 'refill_list_execution_view.dart';
import 'refill_list_table_view.dart';
import 'refill_list_card.dart';

part 'refill_list_selection_view.dart';

class RefillListView extends ConsumerStatefulWidget {
  const RefillListView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<RefillListView> createState() => _RefillListViewState();
}

class _RefillListViewState extends ConsumerState<RefillListView> {
  RefillListExecutionNotifier? _executionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(refillListSelectionNotifierProvider).init(widget.stationContext);
    });

    _executionNotifier = ref.read(refillListExecutionNotifierProvider);
    _executionNotifier!.onQueueFinished = () {
      if (!mounted) return;
      ref.read(refillListSelectionNotifierProvider).refreshAfterQueue();
    };
  }

  @override
  void dispose() {
    _executionNotifier?.onQueueFinished = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(refillListSelectionNotifierProvider);
    final isExecuting = ref.watch(refillListExecutionNotifierProvider.select((n) => n.isExecuting));

    if (selection.isLoading(selection.fetchListOp)) {
      return const Center(child: MedLoadingIndicator());
    }

    if (selection.isError) {
      return const Center(child: EmptyStateWidget(variant: EmptyStateVariant.networkError));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isExecuting
          ? RefillListExecutionView(key: const ValueKey('execution'), stationContext: widget.stationContext)
          : RefillListSelectionView(
              key: const ValueKey('selection'),
              selectionNotifier: selection,
              executionNotifier: ref.read(refillListExecutionNotifierProvider),
              menu: widget.stationContext.menu,
            ),
    );
  }
}
