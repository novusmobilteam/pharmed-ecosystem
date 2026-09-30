part of 'master_refund_view.dart';

class MasterRefundExecutionView extends ConsumerWidget {
  const MasterRefundExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterRefundExecutionNotifierProvider);
    final hospitalization = ref.watch(masterRefundSelectionNotifierProvider.select((n) => n.selectedHospitalization));

    return CabinOperationExecutionView(
      controller: execution,
      stationContext: stationContext,
      headerValues: (context, target) => [
        if (hospitalization?.patient?.fullName case final name?)
          CabinExecutionInfoValue(label: context.l10n.assignment_patientLabel, value: name),
        CabinExecutionInfoValue(
          label: context.l10n.tableCore_prescriptionReturnQuantityColumn,
          value: target.assignment.quantityLabel(execution.refundQuantityOf(target)),
        ),
      ],
    );
  }
}
