import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../dashboard/dashboard.dart';

import '../notifier/refill_list_execution_notifier.dart';
import 'refill_list_table_view.dart';

class RefillListExecutionView extends ConsumerWidget {
  const RefillListExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(refillListExecutionNotifierProvider);

    return CabinOperationExecutionView(
      controller: execution,
      stationContext: stationContext,
      headerValues: (context, target) {
        final detail = execution.detailFor(target);
        if (detail == null) return const [];
        final filledLabel = detail.filledQuantityLabel;
        return [
          CabinExecutionInfoValue(
            label: context.l10n.refillList_column_targetQuantity,
            value: detail.plannedQuantityLabel,
          ),
          if (filledLabel != null)
            CabinExecutionInfoValue(
              label: context.l10n.refillList_column_filledQuantity,
              value: filledLabel,
              valueColor: detail.fillStatus.color,
            ),
        ];
      },
      headerTrailing: (context, target) {
        final status = execution.detailFor(target)?.fillStatus;
        return status != null ? RefillListFillStatusBadge(status: status) : null;
      },
    );
  }
}
