import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/dashboard.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../widgets/widgets.dart';
import '../../../../widgets/rx_operation_card/rx_operation_card_2.dart';
import '../notifier/master_waste_notifier.dart';
import '../notifier/master_waste_state.dart';
import 'waste_medicine_group.dart';

class MasterWasteSelectionView extends ConsumerStatefulWidget {
  const MasterWasteSelectionView({super.key, required this.stationContext});

  final StationCabinsContext stationContext;

  @override
  ConsumerState<MasterWasteSelectionView> createState() => _MasterWasteSelectionViewState();
}

class _MasterWasteSelectionViewState extends ConsumerState<MasterWasteSelectionView> {
  // Saf UI state — hangi ilaç grupları açık. Notifier'a hiç yansımaz,
  // seçim/miktar mantığını etkilemez.
  final Set<String> _expandedGroups = {};

  void _toggleGroup(String groupName) {
    setState(() {
      if (!_expandedGroups.remove(groupName)) {
        _expandedGroups.add(groupName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(masterWasteNotifierProvider.notifier);

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          flex: 2,
          child: PatientSelectionPanel(
            currentStation: widget.stationContext.station!,
            selectedPatient: ref.watch(masterWasteNotifierProvider).hospitalization,
            onPatientSelected: (hospitalization, _, _) => notifier.selectPatient(hospitalization),
            config: PatientSelectionConfig(showFilters: false),
          ),
        ),
        Expanded(flex: 7, child: _buildMedicineContent(context, ref)),
      ],
    );
  }

  Widget _buildMedicineContent(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterWasteNotifierProvider);
    final notifier = ref.read(masterWasteNotifierProvider.notifier);

    final selection = switch (state) {
      MasterWasteMedicineSelection s => s,
      MasterWasteError(previousState: MasterWasteMedicineSelection s) => s,
      _ => null,
    };

    final bool noPatientSelected = selection == null && state is MasterWastePatientSelection;
    final bool isItemsLoading = selection == null && !noPatientSelected;

    final items = selection?.visibleItems ?? const [];
    final selectedItemIds = selection?.selectedItemIds ?? const {};
    final bool isSearching = (selection?.search ?? '').trim().isNotEmpty;

    return CabinSelectionContentShell(
      menu: widget.stationContext.menu,
      searchQuery: selection?.search ?? '',
      onSearchQueryChanged: notifier.onSearchChanged,
      searchHint: context.l10n.waste_hint_searchMedicine,
      isLoading: isItemsLoading,
      isEmpty: noPatientSelected || (!isItemsLoading && items.isEmpty),
      emptyMessage: noPatientSelected
          ? context.l10n.waste_hint_selectPatientFirst
          : context.l10n.waste_hint_noMedicineFound,
      content: (isItemsLoading || noPatientSelected)
          ? null
          : isSearching
          // Arama aktifken düz liste (eski davranış) — sonucu görmek için
          // önce grup açmaya gerek kalmasın.
          ? CabinOperationGrid(
              singleColumnThreshold: 0,
              maxColumns: 3,
              itemCount: items.length,
              itemBuilder: (context, i) => _buildMedicineCard(context, ref, selection!, notifier, items.elementAt(i)),
            )
          : _buildGroupedList(context, ref, selection!, notifier, items, selectedItemIds),
      footer: (selection != null && selection.selectedItems.isNotEmpty)
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12.0,
              children: [
                MedButton(
                  label: context.l10n.waste_action_wastage,
                  isLoading: selection.submittingType == DisposeType.wastage,
                  suffixIcon: Icon(PhosphorIcons.arrowRight()),
                  variant: MedButtonVariant.secondary,
                  onPressed: selection.canStart
                      ? () => notifier.startWasteOperation(
                          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                          type: DisposeType.wastage,
                        )
                      : null,
                ),
                MedButton(
                  label: context.l10n.waste_action_destruction,
                  isLoading: selection.submittingType == DisposeType.destruction,
                  variant: MedButtonVariant.secondary,
                  suffixIcon: Icon(PhosphorIcons.arrowRight()),
                  onPressed: selection.canStart
                      ? () => notifier.startWasteOperation(
                          onSuccess: (msg) => MessageUtils.showSuccessSnackbar(context, msg),
                          type: DisposeType.destruction,
                        )
                      : null,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    MasterWasteMedicineSelection selection,
    MasterWasteNotifier notifier,
    Iterable<DisposableItem> items,
    Set<int> selectedItemIds,
  ) {
    final groups = WasteMedicineGroup.groupByMedicineName(items.toList());

    // CabinSelectionContentShell zaten kendi içinde scroll sağlıyor
    // (orijinal kod yüzlerce item'lık CabinOperationGrid'i hiç ek bir
    // scroll sarmalayıcısına almadan direkt content'e veriyordu) — bu
    // yüzden burada ikinci bir scrollable EKLENMİYOR, sade bir Column
    // yeterli.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in groups)
            Padding(
              padding: const EdgeInsets.only(bottom: MedSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WasteMedicineGroupHeader(
                    name: group.name,
                    count: group.count,
                    isExpanded: _expandedGroups.contains(group.name),
                    hasSelection: group.hasSelection(selectedItemIds),
                    onTap: () => _toggleGroup(group.name),
                  ),
                  if (_expandedGroups.contains(group.name))
                    Padding(
                      padding: const EdgeInsets.only(top: MedSpacing.sm),
                      child: CabinOperationGrid(
                        singleColumnThreshold: 0,
                        maxColumns: 3,
                        itemCount: group.items.length,
                        itemBuilder: (context, i) =>
                            _buildMedicineCard(context, ref, selection, notifier, group.items[i]),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(
    BuildContext context,
    WidgetRef ref,
    MasterWasteMedicineSelection selection,
    MasterWasteNotifier notifier,
    DisposableItem item,
  ) {
    final bool isSelected = selection.selectedItemIds.contains(item.id);

    final drug = item.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
    final wasteNote = drug?.destructionNote?.trim();

    final time = item.time;
    final dose = item.dosePiece.toDouble().formatFractional;
    final unit = item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

    return RxOperationCard2(
      title: item.medicine?.name ?? '—',
      subtitle: time != null ? '$dose $unit (${time.shortRelativeLabelOf(context)})' : '$dose $unit',
      barcode: item.medicine?.barcode,
      isSelected: isSelected,
      onTap: () => notifier.toggleItem(item.id),

      note: (wasteNote != null && wasteNote.isNotEmpty)
          ? RxCardNote(label: context.l10n.medicine_fieldDestructionNote, text: wasteNote)
          : null,

      statusChip: time != null ? RxCardChip(label: time.shortRelativeLabelOf(context), tone: MedTone.info) : null,

      stepper: (isSelected)
          ? RxCardStepper(
              value: (selection.amounts[item.id] ?? item.dosePiece).toDouble(),
              unit: unit,
              max: item.dosePiece.toDouble(),
              onChanged: (v) => notifier.updateAmount(item.id, v),
            )
          : null,

      witness: (item.needsWitness(currentStation: notifier.currentStation) && isSelected)
          ? RxCardWitness(
              isConfirmed: item.witnessContext.witness != null,
              label: item.witnessContext.witness != null
                  ? context.l10n.intake_label_witnessName(item.witnessContext.witness!.fullName)
                  : context.l10n.intake_hint_witnessRequired,
              confirmedName: item.witnessContext.witness?.fullName,
              actionLabel: context.l10n.auth_loginButton,
              onTap: () => _openWitnessDialog(context, ref, item),
            )
          : null,

      movements: [
        if (item.lastMovement case final m?)
          RxCardMovement(
            label: m.type.actorLabel(context),
            tone: m.type.movementTone,
            performedBy: m.performedBy?.fullName ?? '—',
            quantity: '${m.quantity?.formatFractional ?? '-'} $unit',
            date: m.createdAt?.shortRelativeLabelOf(context) ?? '—',
          ),
      ],
    );
  }
}

class _WasteMedicineGroupHeader extends StatelessWidget {
  const _WasteMedicineGroupHeader({
    required this.name,
    required this.count,
    required this.isExpanded,
    required this.hasSelection,
    required this.onTap,
  });

  final String name;
  final int count;
  final bool isExpanded;
  final bool hasSelection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: hasSelection ? MedColors.blue : MedColors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(PhosphorIcons.caretRight(), size: 18, color: MedColors.blue),
            ),
            const SizedBox(width: MedSpacing.sm),
            Expanded(
              child: Text(name, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: MedSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm, vertical: 2),
              decoration: BoxDecoration(color: MedColors.bg, borderRadius: MedRadius.xlAll),
              child: Text(context.l10n.waste_label_groupRecordCount(count), style: MedTextStyles.monoXs()),
            ),
          ],
        ),
      ),
    );
  }
}

void _openWitnessDialog(BuildContext context, WidgetRef ref, DisposableItem item) {
  final notifier = ref.read(masterWasteNotifierProvider.notifier);

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
