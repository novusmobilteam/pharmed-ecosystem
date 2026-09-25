import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../widgets/cabin_operation_execution/cabin_operation_execution.dart';
import '../../../../widgets/widgets.dart';
import '../../../dashboard/dashboard.dart';
import '../notifier/master_unload_execution_notifier.dart';

class MasterUnloadExecutionView extends ConsumerWidget {
  const MasterUnloadExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterUnloadExecutionNotifierProvider);

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
