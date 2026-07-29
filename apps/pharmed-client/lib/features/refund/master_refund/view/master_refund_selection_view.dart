import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../notifier/master_refund_notifier.dart';
import '../notifier/master_refund_state.dart';

class MasterRefundSelectionView extends ConsumerWidget {
  const MasterRefundSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(masterRefundNotifierProvider.notifier);

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: PatientSelectionPanel(
        showFilters: false,
        selectedPatient: ref.watch(masterRefundNotifierProvider).hospitalization,
        onPatientSelected: (hospitalization, _) => notifier.selectPatient(hospitalization),
      ),
      right: _buildMedicineContent(context, ref),
    );
  }

  Widget _buildMedicineContent(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterRefundNotifierProvider);
    final notifier = ref.read(masterRefundNotifierProvider.notifier);

    final selection = switch (state) {
      MasterRefundMedicineSelection s => s,
      MasterRefundError(previousState: MasterRefundMedicineSelection s) => s,
      _ => null,
    };

    final bool noPatientSelected = selection == null && state is MasterRefundPatientSelection;
    final bool isItemsLoading = selection == null && !noPatientSelected;

    final items = selection?.visibleItems ?? const [];
    final selectedItemIds = selection?.selectedItemIds ?? const {};
    final checkStatuses = selection?.checkStatuses ?? const {};

    return CabinSelectionContentShell(
      searchQuery: selection?.search ?? '',
      onSearchQueryChanged: notifier.onSearchChanged,
      searchHint: context.l10n.refund_hint_searchMedicine,
      isLoading: isItemsLoading,
      isEmpty: noPatientSelected || (!isItemsLoading && items.isEmpty),
      emptyMessage: noPatientSelected
          ? context.l10n.refund_hint_selectPatientFirst
          : context.l10n.refund_hint_noMedicineFound,
      content: (isItemsLoading || noPatientSelected)
          ? null
          : CabinOperationGrid(
              singleColumnThreshold: 0,
              maxColumns: 3,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int i) {
                final item = items.elementAt(i);
                final bool isSelected = selectedItemIds.contains(item.id);
                final checkStatus = checkStatuses[item.id] ?? const RefundCheckIdle();

                final drug = item.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
                final refundNote = drug?.returnNote?.trim();

                final time = item.time;
                final currentAmount = item.returnQuantity ?? item.appliedQuantity;
                final dose = currentAmount.toDouble().formatFractional;
                final unit = item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

                return RxOperationCard2(
                  title: item.medicine?.name ?? '—',
                  subtitle: time != null ? '$dose $unit (${time.shortRelativeLabelOf(context)})' : '$dose $unit',
                  barcode: item.medicine?.barcode,
                  isSelected: isSelected,
                  onTap: () => notifier.toggleItem(item.id),

                  statusRow: switch (checkStatus) {
                    RefundCheckIdle() => null,
                    RefundCheckLoading() => RxCardStatusRow(
                      leadingText: context.l10n.intake_status_checking,
                      indicator: RxCardIndicator.spinner,
                    ),
                    RefundCheckSuccess() => RxCardStatusRow(
                      leadingText: context.l10n.intake_status_readyToTake,
                      tone: MedTone.success,
                      indicator: RxCardIndicator.check,
                    ),
                    RefundCheckFailed(:final message) => RxCardStatusRow(
                      leadingText: message ?? context.l10n.intake_status_checkFailed,
                      tone: MedTone.error,
                      indicator: RxCardIndicator.warn,
                    ),
                  },

                  isDanger: checkStatus is RefundCheckFailed,
                  note: (refundNote != null && refundNote.isNotEmpty)
                      ? RxCardNote(label: context.l10n.medicine_fieldReturnNote, text: refundNote)
                      : null,

                  stepper: (isSelected)
                      ? RxCardStepper(
                          value: currentAmount.toDouble(),
                          unit: unit,
                          max: item.appliedQuantity.toDouble(),
                          onChanged: (v) => notifier.updateAmount(item.id, v),
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
          ? MedButton(
              label: context.l10n.refund_action_start,
              isLoading: selection.isChecking,
              suffixIcon: Icon(PhosphorIcons.arrowRight()),
              onPressed: selection.canStart ? notifier.startRefund : null,
            )
          : null,
    );
  }
}
