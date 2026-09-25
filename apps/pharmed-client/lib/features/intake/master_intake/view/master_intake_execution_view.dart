part of 'master_intake_view.dart';

class MasterIntakeExecutionView extends ConsumerWidget {
  const MasterIntakeExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterIntakeExecutionNotifierProvider);
    final hospitalization = ref.watch(masterIntakeSelectionNotifierProvider.select((n) => n.hospitalization));

    // QR dialog'u — alıma özgü: job tamamlanırken zorunlu kod varsa açılır.
    ref.listen(masterIntakeExecutionNotifierProvider.select((n) => n.qrCodeJob), (previous, next) {
      if (previous == null && next != null) {
        showMedDialog<void>(context: context, barrierDismissible: false, builder: (_) => const IntakeQrCodeDialog());
      }
    });

    return CabinOperationExecutionView(
      controller: execution,
      stationContext: stationContext,
      // // Alımda birim doz derinlik grid'i de anlamlı (hangi gözden alınacak).
      // showDrawerLayout: (_) => true,
      headerValues: (context, target) => [
        if (hospitalization?.patient?.fullName case final name?)
          CabinExecutionInfoValue(label: context.l10n.assignment_patientLabel, value: name),
        if (target.plannedQuantity case final planned?)
          CabinExecutionInfoValue(
            label: context.l10n.enumCore_cabinInventoryTypeIntakeFieldText,
            value: target.assignment.quantityLabel(planned),
          ),
      ],
    );
  }
}
