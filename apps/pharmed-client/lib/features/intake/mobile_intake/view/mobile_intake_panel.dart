import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/hardware/hardware.dart';
import '../../intake.dart';

class MobileIntakePanel extends StatelessWidget {
  const MobileIntakePanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartIntake,
    required this.onCompleteIntake,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
  });
  final MobileIntakeNotifier notifier;
  final MobileIntakeState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartIntake;
  final VoidCallback onCompleteIntake;

  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

  /// Eksik stok bildirimi yalnızca çekmece fiziksel olarak açıkken yapılabilir.
  bool get _isDrawerOpen => drawerStage is MobileDrawerOpened;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.intake,
      child: switch (state) {
        MobileIntakeUninitialized() ||
        MobileIntakeLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        MobileIntakeIdle() || MobileIntakeSlotSelected() || MobileIntakeNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        _ when state.readyContext != null => _buildReady(context, notifier, state.readyContext!),

        _ => throw StateError('Unhandled MobileIntakeState: $state'),
      },
    );
  }

  Widget _buildReady(BuildContext context, MobileIntakeNotifier notifier, MobileIntakeReady ready) {
    return Column(
      spacing: 8.0,
      children: [
        CabinActivePatientCard(
          patient: ready.patient,
          bed: ready.bed,
          room: ready.room,
          onChange: _isProcessActive ? null : onChangePatient,
        ),
        MedFilterChipGroup<PrescriptionMovementType?>(
          options: [null, ...PrescriptionMovementType.intakeableTypes],
          selected: ready.statusFilter,
          onChanged: notifier.onStatusFilterChanged,
          labelBuilder: (type) => type?.label(context) ?? context.l10n.filter_all,
          bgColor: ready.statusFilter?.backgroundColor,
        ),
        MedFilterChipGroup<DateRangePreset>(
          options: DateRangePreset.values,
          selected: ready.datePreset,
          labelBuilder: (p) => p.label(context.l10n),
          onChanged: notifier.onDatePresetChanged,
        ),
        Expanded(
          child: _PrescriptionList(
            items: ready.prescriptionItems,
            selectedItemIds: ready.selectedItemIds,
            isProcessActive: _isSelectionLocked,
            onToggleItem: onToggleItem,
            isDrawerOpen: _isDrawerOpen,
          ),
        ),
        _IntakeActionBar(
          state: ready,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          onStart: onStartIntake,
          drawerStage: drawerStage,
          baselineCompleted: ready.baselineCompleted,
        ),
      ],
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList({
    required this.items,
    required this.selectedItemIds,
    required this.isProcessActive,
    required this.onToggleItem,
    required this.isDrawerOpen,
  });

  final List<PrescriptionItem> items;

  final Set<int> selectedItemIds;

  /// Süreç aktifken kullanıcı seçim değiştiremez (orchestrator açıkken kilitli).
  final bool isProcessActive;
  final ValueChanged<int> onToggleItem;

  final bool isDrawerOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }

    // 1. Listeyi kopyalayıp çift kriterli (Durum + Saat) sıralıyoruz.
    final sortedItems = List<PrescriptionItem>.from(items)
      ..sort((a, b) {
        // Kriter 2: Durumlar aynıysa saate göre sırala (Erken olan üste)
        if (a.time != null && b.time != null) {
          return a.time!.compareTo(b.time!); // Artan sırada (08:00, 09:00...)
        }

        // Saat null kontrolü koruması (Saati olmayanları alta iter)
        if (a.time != null && b.time == null) return -1;
        if (a.time == null && b.time != null) return 1;

        return 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 6, right: 2),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];

        final isEligible = item.status == PrescriptionMovementType.purchasePending;
        final isSelected = item.id != null && selectedItemIds.contains(item.id);

        return RxOperationCard(
          mode: RxOperationCardMode.intake,
          item: item,
          isEligible: isEligible,
          isSelected: isSelected,
          onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}

class _IntakeActionBar extends StatelessWidget {
  const _IntakeActionBar({
    required this.state,
    required this.drawerStage,
    required this.hasSelection,
    required this.baselineCompleted,
    required this.onStart,
  });

  final MobileIntakeState state;
  final MobileDrawerStage drawerStage;
  final bool hasSelection;
  final bool baselineCompleted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    // Loading: check yapılıyor VEYA çekmece açılıyor VEYA açık ama baseline yok.
    final isBusy =
        state is MobileIntakeCheckInProgress ||
        drawerStage is MobileDrawerOpening ||
        (drawerStage is MobileDrawerOpened && !baselineCompleted);

    if (isBusy) {
      return SizedBox(
        width: context.width,
        child: MedButton(
          label: context.l10n.intake_action_start,
          onPressed: null,
          isLoading: true,
          size: MedButtonSize.sm,
        ),
      );
    }

    // Ready + çekmece aktif değil (Idle/Failed/Closed sonrası reset) → başlat.
    final drawerInactive = drawerStage is MobileDrawerIdle || drawerStage is MobileDrawerFailed;
    if (state is MobileIntakeReady && drawerInactive) {
      return SizedBox(
        width: context.width,
        child: MedButton(
          label: context.l10n.intake_action_start,
          onPressed: hasSelection ? onStart : null,
          size: MedButtonSize.sm,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
