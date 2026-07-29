// [SWREQ-CLI-MINTAKE-004] [IEC 62304 §5.5]
// İlaç-merkezli master kabin İLAÇ ALIM ekranının seçim paneli.
//
// RootScaffold artık booting (masterIntake + patientSelection senkron hazır
// olma) mekaniğini merkezi olarak yönetiyor — bu panel yalnızca her iki
// provider da hazırken build edilir, kendi _hasBooted/Offstage mantığına
// ihtiyaç duymaz.
//
// SOL: PatientSelectionPanel — hasta listesi + filtreler + acil hasta barı.
// SAĞ: seçili hastaya ait ilaç listesi (dolum/sayım'daki CabinSelection
//      panelleriyle aynı CabinSelectionContentShell iskeleti kullanılıyor).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/widgets/cabin_shell_widgets/selection/patient_selection/view/patient_selection_panel.dart';
import 'package:pharmed_client/widgets/rx_operation_card/rx_operation_card_2.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../widgets/widgets.dart';
import '../../intake.dart';

class MasterIntakeSelectionView extends ConsumerWidget {
  const MasterIntakeSelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    return CabinOperationSelectionLayout(
      leftWidth: 440,
      left: PatientSelectionPanel(
        selectedPatient: ref.watch(masterIntakeNotifierProvider).hospitalization,
        onPatientSelected: (hospitalization, isOrderless) {
          notifier.selectPatient(hospitalization, isOrderless ? IntakeType.orderless : IntakeType.ordered);
        },
      ),
      right: _buildMedicineContent(context, ref),
    );
  }

  Widget _buildMedicineContent(BuildContext context, WidgetRef ref) {
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
    final bool isItemsLoading = selection == null && !noPatientSelected;

    final List<IntakeItem> items = selection?.visibleItems ?? const [];
    final Set<int> selectedItemIds = selection?.selectedItemIds ?? const {};
    final Map<int, IntakeCheckStatus> checkStatuses = selection?.checkStatuses ?? const {};

    return CabinSelectionContentShell(
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

                final drug = item.prescriptionItem?.medicine?.when(drug: (Drug d) => d, consumable: (_) => null);
                final collectNote = drug?.collectNote?.trim();

                final time = item.prescriptionItem?.time;
                final dose = item.prescriptionDose.formatFractional;
                final unit = item.medicine?.operationUnitLocalized(context) ?? context.l10n.common_defaultUnitFallback;

                return RxOperationCard2(
                  title: item.medicine?.name ?? '—',
                  subtitle: time != null ? '$dose $unit (${time.shortRelativeLabelOf(context)})' : '$dose $unit',
                  barcode: item.medicine?.barcode,
                  isSelected: isSelected,

                  // Stok yok → soluk + kilitli (eski _hasNoStock davranışı)
                  isDimmed: item.hasNoStock,
                  onTap: item.hasNoStock ? null : () => notifier.toggleItem(item.id),

                  statusChip: RxCardChip(
                    label: item.lastMovement?.type.label(context) ?? '—',
                    tone: item.lastMovement!.type.movementTone,
                  ),

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
                      (item.needsWitness(currentStation: notifier.currentStation) && isSelected && !item.hasNoStock)
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

                  note: (collectNote != null && collectNote.isNotEmpty)
                      ? RxCardNote(label: context.l10n.medicine_fieldCollectNote, text: collectNote)
                      : null,

                  extras: [
                    if (item.hasNoStock)
                      MedChip(
                        label: context.l10n.intake_hint_noStock,
                        background: MedColors.red,
                        foreground: MedColors.redLight,
                      ),
                    if (item.prescriptionItem != null) RxFlagChips(item: item.prescriptionItem!),
                  ],

                  stepper: (isSelected && !item.hasNoStock)
                      ? RxCardStepper(
                          value: item.dosePiece ?? 0,
                          unit: unit,
                          max: 999,
                          onChanged: (v) => notifier.updateDose(item.id, v),
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
              label: context.l10n.intake_action_start,
              isLoading: selection.isChecking,
              suffixIcon: Icon(PhosphorIcons.arrowRight()),
              onPressed: selection.canStart ? notifier.startIntake : null,
            )
          : null,
    );
  }
}

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
      witnesses: item.witnessContext.witnesses,
      selectedWitness: item.witnessContext.witness,
      subtitle: item.medicine?.name,
      onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user),
    ),
  );
}
