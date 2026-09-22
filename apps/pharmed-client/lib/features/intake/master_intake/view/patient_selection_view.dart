part of 'master_intake_view.dart';

class PatientSelectionView extends ConsumerStatefulWidget {
  const PatientSelectionView({
    super.key,
    this.onPatientSelected,
    this.onUrgentPatientCreated,
    this.onDeleteUrgentPatient,
  });

  final ValueChanged<Hospitalization?>? onPatientSelected;

  /// Acil hasta oluşturulduğunda tetiklenir. [scope], hangi buton tetiklediyse
  /// ona göre free/allCabinMedicines. config.enableUrgentPatient=false ise
  /// hiç tetiklenmez (butonlar zaten gösterilmiyor).
  final void Function(Hospitalization patient, IntakeType type)? onUrgentPatientCreated;

  final VoidCallback? onDeleteUrgentPatient;

  @override
  ConsumerState<PatientSelectionView> createState() => _PatientSelectionViewState();
}

class _PatientSelectionViewState extends ConsumerState<PatientSelectionView> {
  @override
  void initState() {
    super.initState();

    final notifier = ref.read(patientSelection2NotifierProvider.notifier);

    notifier.setCallbacks(
      key: notifier.createUrgentPatientOp,
      onError: (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg);
      },
      onSuccess: (_) {
        if (notifier.urgentPatient != null) {
          widget.onUrgentPatientCreated!(notifier.urgentPatient!, notifier.intakeType);
        }
      },
    );

    notifier.setCallbacks(
      key: notifier.deleteUrgentPatientOp,
      onError: (msg) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, msg);
      },
      onSuccess: (_) => widget.onDeleteUrgentPatient!(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(patientSelection2NotifierProvider.notifier);

    return Container(
      decoration: MedDecoration.panelDecoration,
      child: Builder(
        builder: (BuildContext context) {
          if (notifier.urgentPatient != null) {
            return _UrgentPatientCreatedCard(
              patient: notifier.urgentPatient!,
              isDeleting: notifier.isLoading(notifier.deleteUrgentPatientOp),
              onDelete: () => notifier.deleteUrgentPatient(),
            );
          } else {
            return _HospitalizationListView(notifier: notifier, onPatientSelected: widget.onPatientSelected);
          }
        },
      ),
    );
  }
}

class _UrgentPatientCreatedCard extends StatelessWidget {
  const _UrgentPatientCreatedCard({required this.patient, required this.isDeleting, required this.onDelete});

  final Hospitalization patient;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 40, color: MedColors.red),
          const SizedBox(height: 12.0),
          Text(patient.patient?.fullName ?? '-', style: MedTextStyles.titleSm(), textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg),
            child: Text(
              context.l10n.patientPicker_urgentPatientCardDescription,
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          MedButton(
            label: context.l10n.common_deleteTooltip,
            variant: MedButtonVariant.error,
            isLoading: isDeleting,
            prefixIcon: const Icon(PhosphorIconsBold.trash),
            onPressed: isDeleting ? null : onDelete,
          ),
        ],
      ),
    );
  }
}

class _HospitalizationListView extends StatelessWidget {
  const _HospitalizationListView({required this.notifier, this.onPatientSelected});

  final PatientSelectionNotifier2 notifier;
  final ValueChanged<Hospitalization?>? onPatientSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MedSpacing.insetLg,
          child: Text(context.l10n.myPatients_activeHospitalizationsPanelTitle, style: MedTextStyles.titleSm()),
        ),
        Container(
          padding: MedSpacing.insetMd,
          color: MedColors.border2,
          child: Column(
            children: [
              CabinOperationSearchField(
                onChanged: (query) {
                  notifier.onSearchChanged(query);
                },
                hintText: context.l10n.patientPicker_searchHint,
              ),
              SizedBox(height: MedSpacing.sm),
            ],
          ),
        ),

        SizedBox(height: MedSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetLg.left),
          child: MedSegmentedButton(
            selectedIndex: notifier.selectedIndex,
            onChanged: (index) {
              notifier.selectType(HospitalizationType.values.elementAt(index));
              //widget.onTypeChanged?.call();
            },
            labels: [context.l10n.enumCore_patientFilterAll, context.l10n.patientPicker_myPatientsToggleLabel],
          ),
        ),
        SizedBox(height: MedSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetLg.left),
          child: MedDropdownInputField(
            options: PatientFilterType.values,
            initialValue: notifier.patientFilterType,
            onChanged: (type) => notifier.selectFilterType(type),
            labelBuilder: (type) => type?.label,
          ),
        ),
        if (notifier.isLoading(notifier.fetchHospitalizationsOp))
          Expanded(child: Center(child: MedLoadingIndicator()))
        else
          Expanded(
            child: notifier.filteredHospitalizations.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : Padding(
                    padding: MedSpacing.insetLg,
                    child: ListView.separated(
                      itemCount: notifier.filteredHospitalizations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                      itemBuilder: (context, index) {
                        final hosp = notifier.filteredHospitalizations[index];
                        final isUrgent = hosp.isUrgent;
                        final isRedirected = hosp.isRedirected;
                        final hospId = hosp.id;
                        bool isSelected = notifier.selectedHospitalization?.id == hospId;
                        if (isUrgent) {
                          return SizedBox.shrink();
                        }
                        return PatientSelectionCard(
                          hospitalization: hosp,
                          onTap: () {
                            notifier.selectHospitalization(hosp);
                            onPatientSelected?.call(notifier.selectedHospitalization);
                          },
                          showChevron: false,
                          isSelected: isSelected,
                          isRedirected: isRedirected,
                        );
                      },
                    ),
                  ),
          ),

        Padding(
          padding: MedSpacing.insetLg,
          child: Row(
            spacing: 6.0,
            children: [
              Expanded(
                flex: 2,
                child: MedButton(
                  fullWidth: true,
                  isLoading:
                      notifier.isLoading(notifier.createUrgentPatientOp) && notifier.intakeType == IntakeType.free,
                  label: context.l10n.medicine_checkboxIndependentMaterial,
                  variant: MedButtonVariant.success,
                  size: MedButtonSize.md,
                  onPressed: () => notifier.createUrgentPatient(IntakeType.free),
                ),
              ),
              if (notifier.canCreateUrgentPatient)
                Expanded(
                  flex: 3,
                  child: MedButton(
                    fullWidth: true,
                    size: MedButtonSize.md,
                    isLoading:
                        notifier.isLoading(notifier.createUrgentPatientOp) && notifier.intakeType == IntakeType.urgent,
                    label: context.l10n.patientPicker_createUrgentPatientButton,
                    variant: MedButtonVariant.error,
                    prefixIcon: const Icon(PhosphorIconsBold.plus),
                    onPressed: () => notifier.createUrgentPatient(IntakeType.urgent),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
