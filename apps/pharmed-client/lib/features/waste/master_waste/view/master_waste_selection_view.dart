// [SWREQ-CLI-MWASTE-003] [IEC 62304 §5.5]
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/notifier/patient_selection_config.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../widgets/widgets.dart';
import '../../../../widgets/rx_operation_card/rx_operation_card_2.dart';
import '../notifier/master_waste_notifier.dart';
import '../notifier/master_waste_state.dart';

class MasterWasteSelectionView extends ConsumerWidget {
  const MasterWasteSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(masterWasteNotifierProvider.notifier);

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: PatientSelectionPanel(
        selectedPatient: ref.watch(masterWasteNotifierProvider).hospitalization,
        onPatientSelected: (hospitalization, _, _) => notifier.selectPatient(hospitalization),
        config: PatientSelectionConfig(showFilters: false),
      ),
      right: _buildMedicineContent(context, ref),
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

    return CabinSelectionContentShell(
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
          : CabinOperationGrid(
              singleColumnThreshold: 0,
              maxColumns: 3,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items.elementAt(i);
                final bool isSelected = selectedItemIds.contains(item.id);

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

                  stepper: (isSelected)
                      ? RxCardStepper(
                          value: item.dosePiece.toDouble(),
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
              },
            ),
      footer: (selection != null && selection.selectedItems.isNotEmpty)
          ? Row(
              spacing: 12.0,
              children: [
                MedButton(
                  label: context.l10n.waste_action_wastage,
                  isLoading: selection.isSubmitting,
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
                  isLoading: selection.isSubmitting,
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
