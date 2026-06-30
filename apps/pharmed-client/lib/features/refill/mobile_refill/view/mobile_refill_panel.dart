import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../widgets/widgets.dart';
import '../../refill.dart';

// [SWREQ-CLI-REFILL-002] [IEC 62304 §5.5]
// Mobil kabin dolum sağ paneli.
//
// İki ana görünüm:
//   - Hasta seçilmemişse: kabine atanmış hastaların listesi (CabinPatientPickerList)
//   - Hasta seçilmişse:  hasta başlığı + filtreler + reçete listesi + action bar
//
// Drawer/RFID akışı bu panel'in dışında yönetilir; panel sadece state'ten okur:
//   - drawerStage     → action bar buton seçimi
//   - state.canComplete → "Tamamla" mı yoksa "Devam Et" mi (UNEXPECTED blokajı dahil)
//   - state.isBlockedByUnexpected → UNEXPECTED banner'ı için
//   - state.hasUnplannedMovement  → plan dışı banner'ı için
//
// Sınıf: Class B

class MobileRefillPanel extends StatelessWidget {
  const MobileRefillPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartRefill,
    required this.onCompleteRefill,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelRefill,
  });

  final MobileRefillNotifier notifier;
  final MobileRefillState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartRefill;
  final VoidCallback onCompleteRefill;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelRefill;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.refill,
      child: switch (state) {
        MobileRefillUninitialized() ||
        MobileRefillLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        MobileRefillIdle() ||
        MobileRefillSlotSelected() ||
        MobileRefillNoPatient() ||
        MobileRefillRollbackCompleted() ||
        MobileRefillFatalError() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        _ when state.readyContext != null => _buildReady(context, notifier, state.readyContext!),

        _ => throw StateError('Unhandled MobileRefillState: $state'),
      },
    );
  }

  Widget _buildReady(BuildContext context, MobileRefillNotifier notifier, MobileRefillReady ready) {
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
          options: [null, ...PrescriptionMovementType.refillableTypes],
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
            rfidReadEpcs: ready.rfidReadEpcs,
            selectedItemIds: ready.selectedItemIds,
            isProcessActive: _isSelectionLocked,
            onToggleItem: onToggleItem,
          ),
        ),
        _RefillActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          canComplete: ready.canComplete,
          rfidReadCount: ready.rfidReadCount,
          onStart: onStartRefill,
          onComplete: onCompleteRefill,
          onReopen: onReopenDrawer,
          onCancel: onCancelRefill,
          isSaving: state is MobileRefillSaving,
          isStarting: state is MobileRefillDrawerOpening,
        ),
      ],
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList({
    required this.items,
    required this.rfidReadEpcs,
    required this.selectedItemIds,
    required this.isProcessActive,
    required this.onToggleItem,
  });

  final List<PrescriptionItem> items;
  final Set<String> rfidReadEpcs;
  final Set<int> selectedItemIds;

  /// Süreç aktifken kullanıcı seçim değiştiremez (orchestrator açıkken kilitli).
  final bool isProcessActive;
  final ValueChanged<int> onToggleItem;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }

    // canFill durumundakileri başa, diğerlerini arkaya sırala
    final sortedItems = List<PrescriptionItem>.from(items)
      ..sort((a, b) {
        final aCanFill = a.lastMovement?.type.canFill ?? false;
        final bCanFill = b.lastMovement?.type.canFill ?? false;
        if (aCanFill && !bCanFill) return -1;
        if (!aCanFill && bCanFill) return 1;
        return 0;
      });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 6, right: 2),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];

        final isEligible = item.status?.canFill ?? false;
        final isSelected = item.id != null && selectedItemIds.contains(item.id);
        final rfidStatus = !isProcessActive
            ? null
            : rfidReadEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.present
            : RfidPresenceStatus.absent;

        return RxOperationCard(
          mode: RxOperationCardMode.refill,
          item: item,
          isSelected: isSelected,
          rfidStatus: rfidStatus,
          isEligible: isEligible,
          onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action bar
// ─────────────────────────────────────────────────────────────────────────────

class _RefillActionBar extends StatelessWidget {
  const _RefillActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.canComplete,
    required this.rfidReadCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
    required this.isStarting,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;

  /// Kompozit kural: baselineCompleted && !unexpectedEpcs && allSelectedRfidRead
  /// (state.canComplete'ten gelir)
  final bool canComplete;

  final int rfidReadCount;
  final bool isStarting;
  final bool isSaving;
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

    return switch (drawerStage) {
      MobileDrawerIdle() =>
        isStarting
            ? _ActionButton(label: context.l10n.common_action_connecting, enabled: false, loading: true, onTap: _noop)
            : _ActionButton(label: context.l10n.refill_action_start, enabled: hasSelection, onTap: onStart),
      _ => SizedBox(),
    };
  }
}

void _noop() {}

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
