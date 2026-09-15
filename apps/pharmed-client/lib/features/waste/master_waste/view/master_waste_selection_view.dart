part of 'master_waste_view.dart';

class MasterWasteSelectionView2 extends StatelessWidget {
  const MasterWasteSelectionView2({super.key, required this.menu, required this.notifier});

  final MenuItem menu;
  final MasterWasteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScreenTitle(menu: menu),
        Expanded(
          child: Row(
            spacing: 12.0,
            children: [
              Expanded(flex: 2, child: _LeftPanel(notifier)),
              Expanded(flex: 7, child: _RightPanel(notifier)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel(this.notifier);

  final MasterWasteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return HospitalizationPanel(
      cellBuilder: (hosp) {
        final hospId = hosp.id;
        bool isSelected = notifier.selectedHospitalization?.id == hospId;
        return PatientSelectionCard(
          hospitalization: hosp,
          onTap: () => notifier.selectHospitalization(hosp),
          showChevron: false,
          isSelected: isSelected,
        );
      },
      onTypeChanged: () => notifier.clearSelection(),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel(this.notifier);

  final MasterWasteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final title = notifier.selectedHospitalization != null
        ? notifier.selectedHospitalization?.patient?.fullName ?? '-'
        : 'Hasta Seçilmedi';

    return Container(
      alignment: Alignment.center,
      decoration: MedDecoration.panelDecoration,
      child: Builder(
        builder: (context) {
          if (notifier.isLoading(notifier.fetchDisposablesOp)) return Center(child: MedLoadingIndicator());
          if (notifier.selectedHospitalization == null) return Center(child: NoSelectedHospitalizationView());
          if (notifier.selectedHospitalization != null && notifier.disposables.isEmpty) {
            return Center(
              child: NoDataView(
                title: context.l10n.waste_noWastableDrugs,
                subtitle: context.l10n.waste_selectPatient,
                iconData: PhosphorIcons.trash(),
              ),
            );
          }

          return Column(
            spacing: 4.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MedSpacing.insetXl,
                child: Text(title, style: MedTextStyles.titleSm()),
              ),
              Divider(height: 0),

              if (notifier.selectedHospitalization != null) Expanded(child: _DisposablesListView(notifier)),
            ],
          );
        },
      ),
    );
  }
}

class _DisposablesListView extends StatelessWidget {
  const _DisposablesListView(this.notifier);

  final MasterWasteNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final groups = notifier.groups;
        if (groups.isEmpty) return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData));
        return ListView.separated(
          shrinkWrap: true,
          itemCount: groups.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: MedColors.border),
          itemBuilder: (context, index) =>
              _MedicineGroupCard(key: ValueKey(groups[index].name), notifier: notifier, group: groups[index]),
        );
      },
    );
  }
}

class _MedicineGroupCard extends StatefulWidget {
  const _MedicineGroupCard({super.key, required this.notifier, required this.group});

  final MasterWasteNotifier notifier;
  final WasteMedicineGroup group;

  @override
  State<_MedicineGroupCard> createState() => _MedicineGroupCardState();
}

class _MedicineGroupCardState extends State<_MedicineGroupCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier;
    final group = widget.group;

    final headerItem = group.items.first;
    final hasSelection = group.hasSelection(notifier.selectedItemIds);
    final isWastageSubmitting = notifier.isGroupSubmitting(group.name, DisposeType.wastage);
    final isDestructionSubmitting = notifier.isGroupSubmitting(group.name, DisposeType.destruction);
    final isLocked = notifier.isSubmitting;

    final selectedItems = group.items.where((i) => notifier.selectedItemIds.contains(i.id)).toList();
    final itemsMissingWitness = selectedItems
        .where((i) => notifier.itemNeedsWitness(i) && i.witnessContext.witness == null)
        .toList();
    final missingWitness = itemsMissingWitness.isNotEmpty;
    final witnessTarget = itemsMissingWitness.firstOrNull ?? headerItem;
    final existingPartialWitness = selectedItems
        .firstWhereOrNull((i) => i.witnessContext.witness != null)
        ?.witnessContext
        .witness;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12.0,
            children: [
              MedRectangleIconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                iconData: _isExpanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
                size: 32,
              ),
              Column(
                spacing: 4.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: MedTextStyles.titleSm()),
                  Row(
                    spacing: 6.0,
                    children: [
                      Text(headerItem.medicine?.barcode ?? '', style: MedTextStyles.monoSm()),
                      Text('-', style: MedTextStyles.monoSm()),
                      Text(context.l10n.table_totalRecordCount(group.items.length), style: MedTextStyles.monoSm()),
                    ],
                  ),
                ],
              ),
              if (headerItem.witnessContext.witness != null)
                MedChip(
                  icon: PhosphorIcons.user(),
                  label: context.l10n.intake_label_witnessName(headerItem.witnessContext.witness!.fullName),
                  shape: MedChipShape.pill,
                  background: MedColors.greenLight,
                  foreground: MedColors.green,
                  showBorder: false,
                ),
              Spacer(),
              if (missingWitness)
                _WitnessChip(
                  witness: existingPartialWitness,
                  onTap: () => _openWitnessDialog(context, notifier, witnessTarget),
                )
              else ...[
                MedButton(
                  label: isWastageSubmitting ? context.l10n.common_loadingEllipsis : context.l10n.waste_action_wastage,
                  size: MedButtonSize.sm,
                  variant: MedButtonVariant.danger,
                  prefixIcon: Icon(PhosphorIcons.fire()),
                  isLoading: isWastageSubmitting,
                  onPressed: (!hasSelection || isLocked)
                      ? null
                      : () => notifier.disposeGroup(group, DisposeType.wastage),
                ),
                MedButton(
                  label: isDestructionSubmitting
                      ? context.l10n.common_loadingEllipsis
                      : context.l10n.waste_action_destruction,
                  size: MedButtonSize.sm,
                  variant: MedButtonVariant.error,
                  isLoading: isDestructionSubmitting,
                  prefixIcon: Icon(PhosphorIcons.trash()),
                  onPressed: (!hasSelection || isLocked)
                      ? null
                      : () => notifier.disposeGroup(group, DisposeType.destruction),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.0),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: group.items.map((item) => _DisposableItemRow(notifier: notifier, item: item)).toList(),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _DisposableItemRow extends StatelessWidget {
  const _DisposableItemRow({required this.notifier, required this.item});

  final MasterWasteNotifier notifier;
  final DisposableItem item;

  @override
  Widget build(BuildContext context) {
    final isSelected = notifier.isSelected(item.id);
    final isLocked = notifier.isSubmitting;

    return Container(
      margin: EdgeInsets.only(bottom: 6.0),
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: isSelected ? MedColors.blue : MedColors.border),
      ),
      child: Row(
        spacing: 8.0,
        children: [
          Checkbox(value: isSelected, onChanged: isLocked ? null : (_) => notifier.toggleItem(item.id)),
          Text(
            '${item.dosePiece.formatFractional} ${item.medicine?.operationUnitLocalized(context)}',
            style: MedTextStyles.titleSm(),
          ),
          SizedBox(width: 16.0),
          Text(item.time?.shortRelativeLabelOf(context) ?? '', style: MedTextStyles.monoMd()),
          SizedBox(width: 6.0),
          Text(item.lastMovement?.performedBy?.fullName ?? '', style: MedTextStyles.bodyMd(weight: FontWeight.bold)),
          Spacer(),

          SizedBox(
            width: 130,
            child: MedDoseStepper(
              type: DoseStepperType.compact,
              value: notifier.amountFor(item.id).toDouble(),
              min: 0.01,
              max: notifier.maxAmountFor(item.id).toDouble(),

              onChanged: (v) =>
                  notifier.updateAmount(item.id, v, onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg)),
              unit: item.medicine?.operationUnitLocalized(context) ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

class _WitnessChip extends StatelessWidget {
  const _WitnessChip({required this.witness, required this.onTap});

  final User? witness;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      label: witness != null ? witness!.fullName : context.l10n.intake_hint_witnessRequired,
      background: witness == null ? MedColors.amber : MedColors.green,
      foreground: Colors.white,
      shape: MedChipShape.pill,
      onTap: onTap,
      size: MedChipSize.lg,
      showBorder: false,
    );
  }
}

void _openWitnessDialog(BuildContext context, MasterWasteNotifier notifier, DisposableItem item) {
  final existing = notifier.resolveExistingWitness(item.id);
  if (existing != null) {
    notifier.addWitness(item.id, existing);
    MessageUtils.showInfoSnackbar(context, context.l10n.witnessDialog_autoAssigned(existing.fullName));
    return;
  }

  showMedDialog<bool>(
    context: context,
    builder: (_) => WitnessLoginView(
      witnesses: item.witnessContext.witnesses,
      selectedWitness: item.witnessContext.witness,
      subtitle: item.medicine?.name,
      onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user),
    ),
  );
}
