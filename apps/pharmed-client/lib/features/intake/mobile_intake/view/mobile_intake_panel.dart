import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../intake.dart';

class MobileIntakePanel extends StatelessWidget {
  const MobileIntakePanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartIntake,
    required this.onCompleteIntake,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelIntake,
  });
  final MobileIntakeNotifier notifier;
  final MobileIntakeState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartIntake;
  final VoidCallback onCompleteIntake;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelIntake;

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

        MobileIntakeIdle() ||
        MobileIntakeSlotSelected() ||
        MobileIntakeNoPatient() ||
        MobileIntakeRollbackCompleted() ||
        MobileIntakeFatalError() => CabinPatientPickerList(
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
          labelBuilder: (type) => type?.label ?? context.l10n.filter_all,
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
            takenEpcs: ready.takenEpcs,
            rfidReadEpcs: ready.rfidReadEpcs,
            isDrawerOpen: _isDrawerOpen,
          ),
        ),
        _IntakeActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          onStart: onStartIntake,
          onComplete: onCompleteIntake,
          onReopen: onReopenDrawer,
          onCancel: onCancelIntake,
          isSaving: state is MobileIntakeSaving,
          canComplete: ready.canComplete,
          rfidTakenCount: ready.rfidTakenCount,
          isStarting: state is MobileIntakeCheckInProgress,
        ),
      ],
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList({
    required this.items,
    required this.takenEpcs,
    required this.rfidReadEpcs,
    required this.selectedItemIds,
    required this.isProcessActive,
    required this.onToggleItem,
    required this.isDrawerOpen,
  });

  final List<PrescriptionItem> items;

  /// Kabinden çıkarılmış (alındı sayılan) EPC'ler.
  ///
  /// Alım akışında RFID semantiği dolumun tersidir:
  /// EPC [takenEpcs]'te yoksa ilaç hâlâ kabinde → okundu (yeşil).
  /// EPC [takenEpcs]'e girince kabinden çıktı → alındı.
  final Set<String> takenEpcs;
  final Set<String> rfidReadEpcs;

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

        final rfidStatus = !isProcessActive
            ? null // session başlamadı
            : takenEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.removed
            : rfidReadEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.present
            : RfidPresenceStatus.absent;

        return RxOperationCard(
          mode: RxOperationCardMode.intake,
          item: item,
          isEligible: isEligible,
          isSelected: isSelected,
          rfidStatus: rfidStatus,
          onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}

class _IntakeActionBar extends StatelessWidget {
  const _IntakeActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.canComplete,
    required this.rfidTakenCount,
    required this.isSaving,
    required this.isStarting,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;

  /// Seçili RFID'li tüm item'ların EPC'si takenEpcs'te mi?
  /// [MobileIntakeReady.canComplete] getter'ından gelir.
  final bool canComplete;

  /// Kabinden çıkarılmış (alındı sayılan) EPC sayısı.
  /// [MobileIntakeReady.rfidTakenCount] getter'ından gelir.
  final int rfidTakenCount;

  final bool isSaving;

  /// Check + drawer açılış arasındaki süreçte true.
  /// View'da [_isStarting] local state'i ile yönetilir.
  final bool isStarting;

  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return _buildAction(context);
  }

  Widget _buildAction(BuildContext context) {
    if (isSaving) {
      return _ActionButton(label: context.l10n.common_action_saving, enabled: false, loading: true, onTap: _noop);
    }

    // Check + drawer açılış loading — stage henüz Idle'da ama işlem başladı
    if (isStarting) {
      return _ActionButton(label: context.l10n.intake_action_start, enabled: false, loading: true, onTap: _noop);
    }

    return switch (drawerStage) {
      MobileDrawerIdle() => _ActionButton(
        label: context.l10n.intake_action_start,
        enabled: hasSelection,
        onTap: onStart,
      ),

      _ => SizedBox(),
    };
  }
}

// ignore: avoid_returning_null_for_void — disabled state için placeholder
void _noop() {}

// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true, this.loading = false});

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: MedButton(
        label: label,
        size: MedButtonSize.sm,
        isLoading: loading,
        onPressed: enabled && !loading ? onTap : null,
      ),
    );
  }
}
