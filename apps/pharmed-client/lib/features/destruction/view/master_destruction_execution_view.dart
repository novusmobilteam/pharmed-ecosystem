import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/widgets.dart';
import '../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../dashboard/dashboard.dart';
import '../notifier/master_destruction_execution_notifier.dart';

class MasterDestructionExecutionView extends ConsumerWidget {
  const MasterDestructionExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterDestructionExecutionNotifierProvider);

    return CabinOperationExecutionView(
      controller: execution,
      stationContext: stationContext,
      headerValues: (context, target) => [
        CabinExecutionInfoValue(
          label: context.l10n.cabinExecution_recordedQuantity,
          value: formatEntryQuantity(target.currentQuantity),
        ),
      ],
    );
  }
}
