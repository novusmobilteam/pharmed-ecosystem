part of 'master_intake_selection_view.dart';

class RxOrdersContent extends ConsumerWidget {
  const RxOrdersContent({super.key, required this.menu});

  final MenuItem menu;

  void _openWitnessDialog(BuildContext context, WidgetRef ref, IntakeItem item) {
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    final existing = notifier.resolveExistingWitness(item.id);
    if (existing != null) {
      notifier.addWitness(item.id, existing);
      MessageUtils.showInfoSnackbar(context, context.l10n.witnessDialog_autoAssigned(existing.fullName));
      return;
    }

    showMedDialog<bool>(
      context: context,
      builder: (_) => WitnessLoginView(
        witnesses: item.activeWitnessContext.witnesses, // ← değişti
        selectedWitness: item.activeWitnessContext.witness, // ← değişti
        subtitle: item.medicine?.name,
        onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    // RootScaffold, bu widget'ı yalnızca RootSelection fazındayken build eder
    // — yani MasterIntakeExecuting buraya hiç düşmez, executing dalına
    // ihtiyaç yok. Ama patient seçili değilken (MasterIntakePatientSelection)
    // ve item'lar backend'den gelirken (MasterIntakeLoading benzeri ama
    // hasta seçildikten sonraki ara an) hâlâ ayırt etmemiz gerekiyor.
    final selection = switch (state) {
      MasterIntakeMedicineSelection s => s,
      MasterIntakeError(previousState: MasterIntakeMedicineSelection s) => s,
      _ => null,
    };

    // Hasta henüz seçilmedi — bu bir yükleme değil, gerçek bir boş durum.
    final bool noPatientSelected = selection == null && state is MasterIntakePatientSelection;
    // Hasta seçildi, item'lar backend'den geliyor — gerçek loading burası.
    final bool isItemsLoading = (selection == null && !noPatientSelected) || (selection?.isFetching ?? false);

    final List<IntakeItem> items = selection?.visibleItems ?? const [];
    final Set<int> selectedItemIds = selection?.selectedItemIds ?? const {};
    final Map<int, IntakeCheckState> checkStatuses = selection?.checkStates ?? const {};

    // RxOrdersContent.build() içinde, selection çözüldükten hemen sonra:
    final bool isOrderlessFlow = selection?.intakeType.isOrderless ?? false;

    final patientSelectionState = ref.watch(patientSelectionNotifierProvider);
    final currentFilter = patientSelectionState is PatientSelectionReady
        ? patientSelectionState.filter
        : PatientFilterType.ordersDue;

    return CabinSelectionContentShell(
      menu: menu,
      searchQuery: selection?.search ?? '',
      onSearchQueryChanged: notifier.onSearchChanged,
      searchHint: context.l10n.intake_hint_searchMedicine,
      isLoading: isItemsLoading,
      isEmpty: noPatientSelected || (!isItemsLoading && items.isEmpty),
      emptyMessage: noPatientSelected ? context.l10n.wasteSelectPatient : context.l10n.appException_notFoundGeneric,
      content: (isItemsLoading || noPatientSelected)
          ? null
          : CabinOperationGrid(
              singleColumnThreshold: 0,
              maxColumns: 3,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items.elementAt(i);
                final bool isSelected = selectedItemIds.contains(item.id);
                final checkStatus = checkStatuses[item.id] ?? const CheckIdle();
                final equivalentState = selection?.equivalentStates[item.id] ?? const EquivalentIdle();

                final drug = item.prescriptionItem?.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
                final collectNote = drug?.collectNote?.trim();

                final time = item.time;
                final dose = item.prescriptionDose.formatFractional;
                final unit = item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

                return RxOperationCard2(
                  title: item.medicine?.name ?? '—',
                  subtitle: !isOrderlessFlow
                      ? time != null
                            ? '$dose $unit'
                            : '$dose $unit'
                      : null,
                  barcode: item.medicine?.barcode,
                  isSelected: isSelected,

                  // Stok yok → soluk + kilitli (eski _hasNoStock davranışı)
                  isDimmed: (isOrderlessFlow && currentFilter != PatientFilterType.ordersDue),
                  onTap: (isOrderlessFlow && currentFilter != PatientFilterType.ordersDue)
                      ? null
                      : (item.hasNoStock || item.isRedirected)
                      ? null
                      : () => notifier.toggleItem(item.id),

                  statusChip: time != null
                      ? RxCardChip(label: time.shortRelativeLabelOf(context), tone: MedTone.info)
                      : null,

                  // CheckStatus → durum satırı
                  statusRow: switch (checkStatus) {
                    CheckIdle() => null,
                    CheckLoading() => RxCardStatusRow(
                      leadingText: context.l10n.intake_status_checking,
                      indicator: RxCardIndicator.spinner,
                    ),
                    CheckSuccess() => RxCardStatusRow(
                      leadingText: context.l10n.intake_status_readyToTake,
                      tone: MedTone.success,
                      indicator: RxCardIndicator.check,
                    ),
                    CheckFailed(:final message) => RxCardStatusRow(
                      leadingText: message ?? context.l10n.intake_status_checkFailed,
                      tone: MedTone.error,
                      indicator: RxCardIndicator.warn,
                    ),
                  },
                  isDanger: checkStatus is CheckFailed,

                  witness:
                      (item.needsWitness(currentStation: notifier.currentStation) &&
                          (isSelected || isOrderlessFlow) &&
                          (!item.hasNoStock || item.isEquivalentIntake))
                      ? RxCardWitness(
                          isConfirmed: item.activeWitnessContext.witness != null,
                          label: item.activeWitnessContext.witness != null
                              ? context.l10n.intake_label_witnessName(item.activeWitnessContext.witness!.fullName)
                              : context.l10n.intake_hint_witnessRequired,
                          confirmedName: item.activeWitnessContext.witness?.fullName,
                          actionLabel: context.l10n.auth_loginButton,
                          onTap: () => _openWitnessDialog(context, ref, item),
                        )
                      : null,

                  note: (collectNote != null && collectNote.isNotEmpty)
                      ? RxCardNote(label: context.l10n.medicine_fieldCollectNote, text: collectNote)
                      : null,

                  extras: [
                    if (item.prescriptionItem != null) RxFlagChips(item: item.prescriptionItem!),
                    if (item.hasNoStock && !item.isRedirected)
                      _StockResolutionSection(
                        equivalentState: equivalentState,
                        otherStationState: selection?.otherStationStates[item.id] ?? const OtherStationIdle(),
                        onCheckEquivalent: () => notifier.checkEquivalent(item.id),
                        onSelectEquivalent: (eq) => notifier.toggleEquivalentSelection(item.id, eq),
                        onRedirect: (station) => notifier.redirectToStation(item.id, station),
                      ),
                  ],

                  stepper: ((isSelected || isOrderlessFlow) && !item.hasNoStock)
                      ? RxCardStepper(
                          value: item.dosePiece ?? 1,
                          unit: unit,
                          max: 999,
                          onChanged: (v) => notifier.updateDose(item.id, v),
                        )
                      : null,
                  movements: [
                    if (item.lastMovement case final m?)
                      RxCardMovement(
                        label: m.type.actorLabel(context, isMobile: false),
                        tone: m.type.movementTone,
                        performedBy: m.performedBy?.fullName ?? '—',
                        quantity: '${m.quantity?.formatFractional ?? '-'} $unit',
                        date: m.createdAt?.shortRelativeLabelOf(context) ?? '—',
                      ),
                  ],
                );
              },
            ),
      footer: (selection != null && selection.selectedItems.isNotEmpty)
          ? MedButton(
              label: context.l10n.intake_action_start,
              isLoading: selection.isChecking,
              suffixIcon: Icon(PhosphorIcons.arrowRight()),
              onPressed: selection.canStart ? notifier.startIntake : null,
            )
          : null,
    );
  }
}

class _StockResolutionSection extends StatelessWidget {
  const _StockResolutionSection({
    required this.equivalentState,
    required this.otherStationState,
    required this.onCheckEquivalent,
    required this.onSelectEquivalent,
    required this.onRedirect,
  });

  final EquivalentCheckState equivalentState;
  final OtherStationCheckState otherStationState;
  final VoidCallback onCheckEquivalent;
  final ValueChanged<EquivalentMedicine> onSelectEquivalent;
  final ValueChanged<OtherStationMedicine> onRedirect;

  Widget _loadingRow(BuildContext context, String text) => Row(
    spacing: MedSpacing.xs,
    children: [
      const MedLoadingIndicator(),
      Text(text, style: MedTextStyles.bodySm(color: MedColors.text3)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // 1) Hiç sorgulanmadı — yalnızca "stok yok, muadil kontrol et".
    if (equivalentState is EquivalentIdle) {
      return MedChip(
        label: '${context.l10n.intake_hint_noStock} (${context.l10n.intake_action_checkEquivalent})',
        background: MedColors.red,
        foreground: MedColors.redLight,
        size: MedChipSize.lg,
        showBorder: false,
        onTap: onCheckEquivalent,
      );
    }

    if (equivalentState is EquivalentLoading) {
      return _loadingRow(context, context.l10n.intake_status_checking);
    }
    if (equivalentState case EquivalentFailed(:final message)) {
      return MedChip(label: message ?? context.l10n.intake_status_checkFailed);
    }
    if (equivalentState case EquivalentFound(:final options, :final selected)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: MedSpacing.xs,
        children: [
          Text(context.l10n.intake_label_equivalentOptions, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ...options.map((eq) {
            final isChosen = selected?.materialId == eq.materialId;
            final unit = eq.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;
            final qty = eq.purchaseQuantity ?? 0;
            return InkWell(
              onTap: () => onSelectEquivalent(eq),
              borderRadius: MedRadius.mdAll,
              child: Container(
                padding: MedSpacing.insetMd,
                decoration: BoxDecoration(
                  color: isChosen ? MedColors.blueLight : MedColors.surface2,
                  border: Border.all(color: isChosen ? MedColors.blue : MedColors.border),
                  borderRadius: MedRadius.mdAll,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(eq.materialName ?? '—', style: MedTextStyles.bodyMd())),
                    Text(
                      '${qty == qty.toInt() ? qty.toInt() : qty} $unit',
                      style: MedTextStyles.monoSm(color: MedColors.text3),
                    ),
                    if (isChosen) ...[
                      const SizedBox(width: MedSpacing.xs),
                      Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: MedColors.blue, size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      );
    }

    // 2) Muadil yoktu (EquivalentNotFound) — "muadil bulunamadı" banner'ı
    // GÖSTERİLMEZ, doğrudan diğer kabin sorgusunun durumu gösterilir.
    return switch (otherStationState) {
      OtherStationIdle() ||
      OtherStationLoading() => _loadingRow(context, context.l10n.intake_hint_searchingOtherStations),
      OtherStationFailed(:final message) => MedChip(label: message ?? context.l10n.intake_status_checkFailed),
      OtherStationFound(:final stations) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: MedSpacing.xs,
        children: [
          Text(context.l10n.intake_label_otherStationOptions, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ...stations.map((s) => _OtherStationRow(station: s, onTap: () => onRedirect(s))),
        ],
      ),
      OtherStationRedirecting(:final target) => _OtherStationRow(station: target, isLoading: true),
      // Redirected artık burada gösterilmiyor — _refreshMovement backend'den
      // lastMovement'ı çektiğinde item.isRedirected true olur, kart tamamen
      // kilitlenip statusChip "Yönlendirildi" gösterir; bu bölüm hiç render
      // edilmez (extras koşulu !item.isRedirected).
      OtherStationRedirected() => const SizedBox.shrink(),
      OtherStationRedirectFailed(:final target, :final message) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: MedSpacing.xs,
        children: [
          Text(message ?? context.l10n.intake_status_checkFailed, style: MedTextStyles.bodySm(color: MedColors.red)),
          _OtherStationRow(station: target, onTap: () => onRedirect(target)),
        ],
      ),
      OtherStationNotFound() => MedChip(
        label: context.l10n.intake_hint_noStockAnywhere,
        background: MedColors.red,
        foreground: MedColors.redLight,
        showBorder: false,
      ),
    };
  }
}

class _OtherStationRow extends StatelessWidget {
  const _OtherStationRow({required this.station, this.onTap, this.isLoading = false});

  final OtherStationMedicine station;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.stationName ?? '—', style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold)),
                  if (station.serviceName != null)
                    Text(station.serviceName!, style: MedTextStyles.bodySm(color: MedColors.text3)),

                  if (station.isEquivalent)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: MedChip(
                        label: station.materialName ?? context.l10n.intake_label_equivalentOptions,
                        background: MedColors.purple,
                        foreground: MedColors.greenLight,
                        showBorder: false,
                      ),
                    ),
                ],
              ),
            ),
            if (isLoading)
              const MedLoadingIndicator()
            else
              MedButton(
                label: context.l10n.intake_action_redirect,
                size: MedButtonSize.sm,
                onPressed: onTap,
                variant: MedButtonVariant.secondary,
              ),
          ],
        ),
      ),
    );
  }
}
