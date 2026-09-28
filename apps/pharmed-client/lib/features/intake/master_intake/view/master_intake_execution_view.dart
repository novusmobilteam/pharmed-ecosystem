part of 'master_intake_view.dart';

class MasterIntakeExecutionView extends ConsumerWidget {
  const MasterIntakeExecutionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final execution = ref.read(masterIntakeExecutionNotifierProvider.notifier);
    final hospitalization = ref.watch(masterIntakeSelectionNotifierProvider.select((n) => n.hospitalization));

    // QR dialog'u — alıma özgü: karekodlu ilacın hedefi tamamlanınca
    // (kapak/çekmece kapanıp kayıt atıldıktan sonra) açılır.
    ref.listen(masterIntakeExecutionNotifierProvider.select((n) => n.qrCodeTarget), (previous, next) async {
      if (previous != null || next == null) return;
      final requirement = execution.qrCodeRequirements.firstOrNull;
      if (requirement == null) return execution.finishQrCodes();

      await showQrScanDialog(
        context,
        request: QrScanRequest(
          operationLabel: context.l10n.qrScan_operationIntake,
          medicineName: requirement.medicineName,
          requiredCount: requirement.requiredCount,
          expectedGtin: requirement.expectedGtin,
          chips: [if (hospitalization?.patient?.fullName case final name?) QrScanChip(name)],
        ),
        onSubmit: execution.submitQrCodes,
      );
      await execution.finishQrCodes();
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
