// [SWREQ-CLI-MINTAKE-005] [IEC 62304 §5.5]
// FAZ 0 + FAZ 1 — Sol panel.
//
// Hasta seçimi artık ekran önündeki modal/gateway ile değil, BU PANELDE
// (OperationPanelBase) yapılır. Hasta seçim arayüzünün TAMAMI ortak
// CabinPatientPickerPanel'e devredilmiştir (PatientSelectionNotifier'a bağlı);
// bu panel yalnızca faz yönlendirmesini yapar:
//   - NoPatient → CabinPatientPickerPanel (ortak hasta seçimi).
//   - Selection/Executing → aktif hasta kartı + alım ilaçları (IntakeOperationCard).
//
// Hasta seçilince notifier.selectPatient(hospitalization, intakeType);
// "Hastayı değiştir" → notifier.changePatient() → NoPatient'a döner.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/patient_gateway/master_cabin_patient_picker_panel.dart'
    show CabinPatientPickerPanel;
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../../../widgets/widgets.dart';
import '../../intake.dart';
import 'intake_operation_card.dart';

class MasterIntakeSelectionPanel extends ConsumerWidget {
  const MasterIntakeSelectionPanel({super.key, required this.currentStation, required this.onWitnessTap});

  /// needsWitness kararı için kullanıcı istasyonu.
  final Station? currentStation;

  /// Şahit doğrulama dialog'unu açan callback (view yönetir).
  final ValueChanged<IntakeItem> onWitnessTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    return OperationPanelBase(
      mode: CabinOperationMode.intake,
      child: switch (state) {
        MasterIntakeUninitialized() ||
        MasterIntakeLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // Ortak hasta seçim paneli — mantık PatientSelectionNotifier'da.
        MasterIntakeNoPatient() => CabinPatientPickerPanel(onPatientSelected: notifier.selectPatient),

        // Hasta seçili tüm durumlar (Selection / Executing / Error) → ilaç paneli.
        _ => _MedicineSelectionBody(currentStation: currentStation, onWitnessTap: onWitnessTap),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FAZ 1 — İlaç seçimi (aktif hasta + IntakeOperationCard listesi)
// ═══════════════════════════════════════════════════════════════════════════

class _MedicineSelectionBody extends ConsumerWidget {
  const _MedicineSelectionBody({required this.currentStation, required this.onWitnessTap});

  final Station? currentStation;
  final ValueChanged<IntakeItem> onWitnessTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(masterIntakeNotifierProvider);
    final notifier = ref.read(masterIntakeNotifierProvider.notifier);

    final selection = switch (state) {
      MasterIntakeSelection s => s,
      MasterIntakeError(previousState: MasterIntakeSelection s) => s,
      _ => null,
    };
    final executing = switch (state) {
      MasterIntakeExecuting e => e,
      MasterIntakeError(previousState: MasterIntakeExecuting e) => e,
      _ => null,
    };

    if (selection == null && executing == null) return const SizedBox.shrink();

    final bool isLocked = executing != null || (selection?.isChecking ?? false);
    final hospitalization = selection?.hospitalization ?? executing?.hospitalization;
    final patient = hospitalization?.patient;

    // Görüntülenecek liste + seçim durumu.
    final List<IntakeItem> items;
    final Set<int> selectedItemIds;
    final String search;
    final Map<int, IntakeCheckStatus> checkStatuses;
    if (selection != null) {
      items = selection.visibleItems;
      selectedItemIds = selection.selectedItemIds;
      search = selection.search;
      checkStatuses = selection.checkStatuses;
    } else {
      // Executing: job hedeflerinden item listesi + tümü seçili.
      final targets = executing!.jobs.expand((j) => j.targets.map((t) => t.item)).toList();
      items = targets;
      selectedItemIds = targets.map((it) => it.id).toSet();
      search = '';
      checkStatuses = const {};
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (patient != null)
          CabinActivePatientCard(
            patient: patient,
            bed: hospitalization?.bed,
            room: hospitalization?.bed?.room,
            onChange: isLocked ? null : () => notifier.changePatient(),
          ),
        const SizedBox(height: 12),
        if (selection != null && !isLocked) ...[
          _SearchField(value: search, onChanged: notifier.onSearchChanged),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: IgnorePointer(
            ignoring: isLocked,
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: items.isEmpty
                  ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return IntakeOperationCard(
                          item: item,
                          isSelected: selectedItemIds.contains(item.id),
                          checkStatus: checkStatuses[item.id] ?? const CheckIdle(),
                          currentStation: currentStation,
                          onTap: () => notifier.toggleItem(item.id),
                          onDoseChanged: (v) => notifier.updateDose(item.id, v),
                          onWitnessTap: () => onWitnessTap(item),
                        );
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (isLocked && executing != null)
          _RunningBar(onStop: notifier.stopQueue)
        else
          _StartBar(
            canStart: selection?.canStart ?? false,
            isChecking: selection?.isChecking ?? false,
            onStart: notifier.startIntake,
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return MedTextInputField(
      initialValue: value,
      hintText: 'İlaç ara (ad / barkod)',
      prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: MedColors.text3),
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

class _RunningBar extends StatelessWidget {
  const _RunningBar({required this.onStop});

  final Future<void> Function() onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 6,
            children: [
              Icon(PhosphorIcons.lock(), size: 15, color: MedColors.text3),
              Expanded(
                child: Text('Alım sürüyor — seçim kilitli.', style: MedTextStyles.bodySm(color: MedColors.text3)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        MedButton(label: 'Durdur', variant: MedButtonVariant.danger, size: MedButtonSize.sm, onPressed: () => onStop()),
      ],
    );
  }
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.canStart, required this.isChecking, required this.onStart});

  final bool canStart;
  final bool isChecking;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            spacing: 6,
            children: [
              Icon(PhosphorIcons.info(), size: 15, color: MedColors.text3),
              Expanded(
                child: Text(
                  'Çekmeceler en kısa yol sırasıyla açılacak.',
                  style: MedTextStyles.bodySm(color: MedColors.text3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        MedButton(label: 'Alıma Başla', isLoading: isChecking, onPressed: canStart ? onStart : null),
      ],
    );
  }
}
