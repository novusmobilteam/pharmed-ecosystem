import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../../dashboard/dashboard.dart';

import '../notifier/master_refill_execution_notifier.dart';

class MasterRefillExecutionView extends ConsumerWidget {
  const MasterRefillExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterRefillExecutionNotifierProvider);

    return CabinOperationExecutionView(
      controller: execution,
      stationContext: stationContext,
      headerValues: (context, target) => [
        CabinExecutionInfoValue(
          label: context.l10n.inconsistency_quantityLabel,
          value: formatEntryQuantity(target.currentQuantity),
        ),
        CabinExecutionInfoValue(
          label: context.l10n.enumCore_fillingTypeMinimum,
          value: formatEntryQuantity(target.assignment.minQuantity.toDouble()),
        ),
        CabinExecutionInfoValue(
          label: context.l10n.enumCore_fillingTypeCritical,
          value: formatEntryQuantity(target.assignment.criticalQuantity.toDouble()),
        ),
        CabinExecutionInfoValue(
          label: context.l10n.enumCore_fillingTypeMaximum,
          value: formatEntryQuantity(target.assignment.maxQuantity.toDouble()),
        ),
      ],
    );
  }
}
