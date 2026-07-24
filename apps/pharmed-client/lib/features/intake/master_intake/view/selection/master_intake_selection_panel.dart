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
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/providers/providers.dart';
import '../../../../../widgets/widgets.dart';
import '../../../../auth/auth.dart';
import '../../../intake.dart';

part 'witness_login_view.dart';
part 'intake_operation_card.dart';

class MasterIntakeSelectionPanel extends ConsumerWidget {
  const MasterIntakeSelectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    return CabinOperationPanelLayout(
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
          : CabinOperationCellGrid(
              singleColumnThreshold: 0,
              maxColumns: 3,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items.elementAt(i);
                return IntakeOperationCard(
                  item: item,
                  isSelected: selectedItemIds.contains(item.id),
                  checkStatus: checkStatuses[item.id] ?? const CheckIdle(),
                  currentStation: notifier.currentStation,
                  onTap: () => notifier.toggleItem(item.id),
                  onDoseChanged: (v) => notifier.updateDose(item.id, v),
                  onWitnessTap: () => _openWitnessDialog(context, ref, item),
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
    MessageUtils.showInfoSnackbar(context, context.l10n.intake_info_witnessAutoAssigned(existing.fullName));
    return;
  }

  showMedDialog<bool>(
    context: context,
    builder: (_) => WitnessLoginView(item: item, onWitnessLoggedIn: (user) => notifier.addWitness(item.id, user)),
  );
}
