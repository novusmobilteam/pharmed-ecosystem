part of 'master_intake_view.dart';

class MasterIntakeSelectionView extends StatelessWidget {
  const MasterIntakeSelectionView({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterIntakeNotifier>(
      builder: (context, notifier, _) {
        return Container(
          margin: MedSpacing.insetXl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode, style: MedTextStyles.monoMd(color: MedColors.blueDark)),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(context.l10n.intake_screenTitle, style: MedTextStyles.titleXl().copyWith()),
                  ),
                ],
              ),
              SizedBox(height: 14.0),
              Divider(color: MedColors.border, height: 1, thickness: 2),
              SizedBox(height: 14.0),
              TextField(
                onChanged: notifier.onSearchChanged,
                decoration: InputDecoration(
                  hintText: context.l10n.refill_hint_searchMedicine,
                  hintStyle: MedTextStyles.monoSm(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(child: RxOrdersContentView()),
              Align(
                alignment: Alignment.bottomRight,
                child: MedRectangleButton(
                  width: 250,
                  label: notifier.isChecking
                      ? context.l10n.intake_status_checking
                      : notifier.needsWitnessForSelection
                      ? context.l10n.intake_action_witnessLogin
                      : context.l10n.intake_action_start,
                  onTap: () => (notifier.isChecking || !notifier.canStart)
                      ? null
                      : notifier.needsWitnessForSelection
                      ? notifier.openWitnessFlow()
                      : notifier.startIntake(),
                  isLoading: notifier.isChecking,
                  isActive: notifier.canStart,
                  foregroundColor: Colors.white,
                  suffixIcon: PhosphorIcons.arrowRight(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RxOrdersContentView extends StatelessWidget {
  const RxOrdersContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MasterIntakeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isFetchingItems) {
          return Center(child: MedLoadingIndicator());
        }

        return ListView.separated(
          itemCount: notifier.visibleItems.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider(height: 1, color: MedColors.border, thickness: 1);
          },
          itemBuilder: (BuildContext context, int index) {
            final item = notifier.items.elementAt(index);
            final bool isSelected = notifier.selectedItemIds.contains(item.id);
            final doseText =
                '${item.lastMovement?.quantity.formatFractional} ${item.medicine?.operationUnitLocalized(context)}';
            final lastMovementText =
                '${item.lastMovement?.type.actorLabel(context, isMobile: false)}: ${item.lastMovement?.performedBy?.fullName} - $doseText - ${item.lastMovement?.createdAt?.shortRelativeLabelOf(context)}';

            return GestureDetector(
              onTap: () => notifier.toggleItem(item.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          size: 32,
                          isSelected ? PhosphorIconsFill.checkSquare : PhosphorIcons.square(),
                          color: MedColors.blue,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 12.0,
                            children: [
                              Text(item.medicine?.name ?? '-', style: MedTextStyles.titleMd()),
                              Text(item.medicine?.barcode ?? '-', style: MedTextStyles.monoMd()),
                              if (item.time != null)
                                MedChip(
                                  label: item.time!.shortRelativeLabelOf(context),
                                  size: MedChipSize.md,
                                  style: MedChipStyle.info,
                                ),
                              if (item.needsWitness(currentStation: notifier.currentStation))
                                MedChip(
                                  label: context.l10n.intake_hint_witnessRequired,
                                  background: MedColors.amber,
                                  size: MedChipSize.md,
                                  showBorder: true,
                                  border: MedColors.amber,
                                  foreground: MedColors.amberLight,
                                ),
                            ],
                          ),
                          // TODO : Localization
                          if (item.lastMovement != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Son Hareket',
                                  style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.bold),
                                ),
                                Text(lastMovementText, style: MedTextStyles.bodyMd(weight: FontWeight.bold)),
                              ],
                            ),

                          if (item.hasNoStock && !item.isRedirected)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _StockResolutionSection(
                                equivalentState: notifier.equivalentStateOf(item.id),
                                otherStationState: notifier.otherStationStateOf(item.id),
                                onCheckEquivalent: () => notifier.checkEquivalent(item.id),
                                onSelectEquivalent: (eq) => notifier.toggleEquivalentSelection(item.id, eq),
                                onRedirect: (station) => notifier.redirectToStation(item.id, station),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: MedDoseStepper(
                        value: item.dosePiece ?? 1,
                        unit: item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback,
                        onChanged: (v) => notifier.updateDose(item.id, v),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      // edilmez (kullanım noktasında !item.isRedirected şartı var).
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
