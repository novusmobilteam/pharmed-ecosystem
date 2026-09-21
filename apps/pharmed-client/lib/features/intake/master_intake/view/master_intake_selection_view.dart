part of 'master_intake_view.dart';

class MasterIntakeSelectionView extends StatelessWidget {
  const MasterIntakeSelectionView({
    super.key,
    required this.stationContext,
    required this.notifier,
    required this.intakeSelectionNotifier,
    required this.executionNotifier,
  });

  final StationCabinsContext stationContext;
  final PatientSelectionNotifier2 notifier;
  final MasterIntakeSelectionNotifier intakeSelectionNotifier;
  final MasterIntakeExecutionNotifier executionNotifier;

  @override
  Widget build(BuildContext context) {
    final menu = stationContext.menu;
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(
                flex: 2,
                child: PatientSelectionView(
                  onPatientSelected: (hosp) => intakeSelectionNotifier.onPatientSelected(hosp),
                  onUrgentPatientCreated: (hosp, type) => intakeSelectionNotifier.onUrgentPatientCreated(hosp, type),
                  onDeleteUrgentPatient: () => intakeSelectionNotifier.onUrgentPatientDeleted(),
                ),
              ),
              Expanded(
                flex: 7,
                child: RightPanel(
                  notifier: notifier,
                  intakeSelectionNotifier: intakeSelectionNotifier,
                  executionNotifier: executionNotifier,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RightPanel extends StatelessWidget {
  const RightPanel({
    super.key,
    required this.notifier,
    required this.intakeSelectionNotifier,
    required this.executionNotifier,
  });

  final PatientSelectionNotifier2 notifier;
  final MasterIntakeSelectionNotifier intakeSelectionNotifier;
  final MasterIntakeExecutionNotifier executionNotifier;

  @override
  Widget build(BuildContext context) {
    final hosp = notifier.selectedHospitalization;
    final urgent = notifier.urgentPatient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hasta Bilgisi
        if (hosp != null)
          _StandartHospitalizationInfo(key: Key(hosp.toString()), notifier: intakeSelectionNotifier, hosp: hosp),
        if (urgent != null) _UrgentHospitalizationInfo(key: Key(urgent.toString()), urgent: urgent),

        // Order Status
        if (hosp != null && !hosp.isRedirected)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Opacity(
              opacity: intakeSelectionNotifier.freeDrugStatus ? 0.4 : 1,
              child: IgnorePointer(
                ignoring: intakeSelectionNotifier.freeDrugStatus,
                child: SizedBox(
                  width: 250,
                  child: MedSegmentedButton(
                    selectedIndex: intakeSelectionNotifier.orderStatusIndex,
                    onChanged: (_) {
                      intakeSelectionNotifier.toggleOrderlessStatus();
                    },
                    labels: [
                      context.l10n.patientPicker_orderedToggleLabel,
                      context.l10n.patientPicker_orderlessToggleLabel,
                    ],
                  ),
                ),
              ),
            ),
          ),

        Expanded(
          child: Container(
            padding: MedSpacing.insetLg,
            decoration: MedDecoration.panelDecoration,
            child: IntakeItemsListView(notifier: intakeSelectionNotifier),
          ),
        ),

        if (intakeSelectionNotifier.canStart) ...[
          SizedBox(height: 6.0),
          Container(
            padding: MedSpacing.insetLg,
            alignment: Alignment.centerRight,
            decoration: MedDecoration.panelDecoration,
            child: MedButton(
              label: context.l10n.intake_action_start,
              suffixIcon: Icon(PhosphorIcons.arrowRight()),
              onPressed: intakeSelectionNotifier.canStart
                  ? () => showMedDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => IntakeCheckDialog(
                        onQueueReady: (jobs) {
                          executionNotifier.start(
                            jobs,
                            intakeType: intakeSelectionNotifier.intakeType,
                            hospitalizationId: intakeSelectionNotifier.hospitalization?.id,
                          );
                        },
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _StandartHospitalizationInfo extends StatelessWidget {
  const _StandartHospitalizationInfo({super.key, required this.notifier, required this.hosp});

  final Hospitalization hosp;
  final MasterIntakeSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final desc = '${hosp.inpatientService?.name} - ${hosp.bed?.room?.name} - ${hosp.bed?.name}';

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration,
      child: Row(
        spacing: 12.0,
        children: [
          MedAvatar(
            initials: hosp.patient?.initials ?? '',
            palette: AvatarPalette.blue,
            size: 48,
            shape: BoxShape.rectangle,
          ),
          Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hosp.patient?.fullName ?? '', style: MedTextStyles.titleLg()),
              Text(desc, style: MedTextStyles.monoMd()),
            ],
          ),
          Spacer(),
          if (!hosp.isRedirected)
            Container(
              padding: MedSpacing.insetLg,
              decoration: BoxDecoration(
                color: MedColors.surface2,
                borderRadius: MedRadius.mdAll,
                border: Border.all(color: MedColors.border),
              ),
              child: MedToggleField(
                value: notifier.freeDrugStatus,
                onChanged: (_) {
                  notifier.toggleFreeDrugStatus();
                },
                label: 'Serbest İlaç',
              ),
            ),
        ],
      ),
    );
  }
}

class _UrgentHospitalizationInfo extends StatelessWidget {
  const _UrgentHospitalizationInfo({super.key, required this.urgent});

  final Hospitalization urgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration.copyWith(color: MedColors.redLight),
      child: Row(
        spacing: 12.0,
        children: [
          MedAvatar(
            initials: urgent.patient?.initials ?? '',
            palette: AvatarPalette.red,
            size: 48,
            shape: BoxShape.rectangle,
          ),
          Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(urgent.patient?.fullName ?? '', style: MedTextStyles.titleLg(color: MedColors.red))],
          ),
        ],
      ),
    );
  }
}

class IntakeItemsListView extends StatelessWidget {
  const IntakeItemsListView({super.key, required this.notifier});

  final MasterIntakeSelectionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    (String, String) emptyStateTexts(BuildContext context, IntakeType type) => switch (type) {
      IntakeType.ordered => (
        context.l10n.emptyState_noPrescriptionTitle,
        context.l10n.emptyState_noPrescriptionDescription,
      ),
      IntakeType.orderless => (
        context.l10n.emptyState_noOrderlessMedicineTitle,
        context.l10n.emptyState_noOrderlessMedicineDescription,
      ),
      IntakeType.free => (
        context.l10n.emptyState_noFreeMedicineTitle,
        context.l10n.emptyState_noFreeMedicineDescription,
      ),
      IntakeType.urgent => (
        context.l10n.emptyState_noUrgentMedicineTitle,
        context.l10n.emptyState_noUrgentMedicineDescription,
      ),
    };

    if (notifier.isLoading(notifier.fetchIntakeItemsOp)) {
      return Center(child: MedLoadingIndicator());
    }
    if (notifier.hospitalization == null) {
      return NoSelectedHospitalizationView();
    }

    if (notifier.intakeItems.isEmpty) {
      final (title, subtitle) = emptyStateTexts(context, notifier.intakeType);

      return NoDataView(title: title, subtitle: subtitle, iconData: PhosphorIcons.receiptX());
    }

    return ListView.separated(
      itemCount: notifier.intakeItems.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1, color: MedColors.border);
      },
      itemBuilder: (BuildContext context, int index) {
        final item = notifier.intakeItems.elementAt(index);

        if (notifier.intakeType == IntakeType.ordered) {
          return IntakeOrderedItemCard(key: Key(item.id.toString()), notifier: notifier, item: item);
        } else {
          return IntakeOrderlessItemCard(key: Key(item.id.toString()), notifier: notifier, item: item);
        }
      },
    );
  }
}

/// Bir kalem için şahit girişi akışını başlatır — ordered ve orderless
/// kartlarının ortak kullandığı tek nokta. Oturumda zaten uygun bir şahit
/// varsa (resolveExistingWitness) dialog açmadan otomatik atar, yoksa
/// giriş dialog'unu açar.
void openIntakeWitnessDialog(BuildContext context, MasterIntakeSelectionNotifier notifier, IntakeItem item) {
  final existing = notifier.resolveExistingWitness(item);
  if (existing != null) {
    notifier.addWitness(item.id, existing);
    MessageUtils.showInfoSnackbar(context, context.l10n.witnessDialog_autoAssigned(existing.fullName));
    return;
  }

  final witnessContext = notifier.witnessContextOf(item);
  showMedDialog<bool>(
    context: context,
    builder: (_) => WitnessLoginView(
      witnesses: witnessContext.witnesses,
      selectedWitness: witnessContext.witness,
      subtitle: item.medicine?.name,
      onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user),
    ),
  );
}
