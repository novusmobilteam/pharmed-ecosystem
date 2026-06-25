import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../unload.dart';

class MobileUnloadPanel extends StatelessWidget {
  const MobileUnloadPanel({
    super.key,
    required this.notifier,
    required this.state,
    required this.drawerStage,
    required this.onStartUnload,
    required this.onCompleteUnload,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelUnload,
    required this.onReportMissing,
  });

  final MobileUnloadNotifier notifier;
  final MobileUnloadState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartUnload;
  final VoidCallback onCompleteUnload;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelUnload;
  final ValueChanged<int> onReportMissing;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

  /// Eksik stok bildirimi yalnızca çekmece fiziksel olarak açıkken yapılabilir.
  bool get _isDrawerOpen => drawerStage is MobileDrawerOpened;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.unload,
      child: switch (state) {
        MobileUnloadUninitialized() ||
        MobileUnloadLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        MobileUnloadIdle() || MobileUnloadSlotSelected() || MobileUnloadNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileUnloadReady ready => _buildReady(context, notifier, ready),

        MobileUnloadSaving(:final ready) || MobileUnloadSuccess(:final ready) => _buildReady(context, notifier, ready),

        MobileUnloadError(:final previousState) => switch (previousState) {
          MobileUnloadReady ready => _buildReady(context, notifier, ready),
          MobileUnloadSaving(:final ready) => _buildReady(context, notifier, ready),
          _ => CabinPatientPickerList(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
      },
    );
  }

  Widget _buildReady(BuildContext context, MobileUnloadNotifier notifier, MobileUnloadReady ready) {
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
          child: _UnloadPrescriptionList(
            items: ready.prescriptionItems,
            selectedItemIds: ready.selectedItemIds,
            isSelectionLocked: _isSelectionLocked,
            isProcessActive: _isProcessActive,
            takenEpcs: ready.takenEpcs,
            rfidReadEpcs: ready.rfidReadEpcs,
            onToggleItem: onToggleItem,
            onReportMissing: onReportMissing,
            reportingItemIds: ready.reportingItemIds,
            isDrawerOpen: _isDrawerOpen,
          ),
        ),
        _UnloadActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          canComplete: ready.canComplete,
          rfidTakenCount: ready.rfidTakenCount,
          isSaving: state is MobileUnloadSaving,
          onStart: onStartUnload,
          onComplete: onCompleteUnload,
          onReopen: onReopenDrawer,
          onCancel: onCancelUnload,
        ),
      ],
    );
  }
}

class _UnloadPrescriptionList extends StatelessWidget {
  const _UnloadPrescriptionList({
    required this.items,
    required this.selectedItemIds,
    required this.takenEpcs,
    required this.rfidReadEpcs,
    required this.isSelectionLocked,
    required this.isProcessActive,
    required this.onToggleItem,
    required this.onReportMissing,
    required this.reportingItemIds,
    required this.isDrawerOpen,
  });

  final List<PrescriptionItem> items;
  final Set<int> selectedItemIds;
  final Set<String> takenEpcs;
  final Set<String> rfidReadEpcs;
  final bool isSelectionLocked;
  final bool isProcessActive;
  final ValueChanged<int> onToggleItem;

  final ValueChanged<int> onReportMissing;
  final Set<int> reportingItemIds;
  final bool isDrawerOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(variant: EmptyStateVariant.noPrescription);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 2),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // Boşaltma için yalnızca 'purchasePending' (Alım Bekliyor) seçilebilir
        final isEligible = item.status == PrescriptionMovementType.purchasePending;
        final isSelected = item.id != null && selectedItemIds.contains(item.id);

        // Alımla aynı RFID semantiği:
        // takenEpcs → kabinden çıkarıldı (removed/yeşil)
        // rfidReadEpcs → hâlâ kabinde (present/mavi)
        // ikisinde de yok → absent/kırmızı
        final rfidStatus = !isProcessActive
            ? null
            : takenEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.removed
            : rfidReadEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.present
            : RfidPresenceStatus.absent;

        return RxOperationCard(
          mode: RxOperationCardMode.intake, // alımla aynı renk matrisi
          item: item,
          isEligible: isEligible,
          isSelected: isSelected,
          rfidStatus: rfidStatus,
          onTap: isSelectionLocked || !isEligible || item.id == null ? null : () => onToggleItem(item.id!),
          onReportMissing: isDrawerOpen && item.id != null ? () => onReportMissing(item.id!) : null,
          isReportingMissing: item.id != null && reportingItemIds.contains(item.id),
        );
      },
    );
  }
}

class _UnloadActionBar extends StatelessWidget {
  const _UnloadActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.canComplete,
    required this.rfidTakenCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;
  final bool canComplete;
  final int rfidTakenCount;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  bool get _showCancel {
    if (isSaving) return false;
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      return rfidTakenCount == 0;
    }
    if (drawerStage is MobileDrawerClosed) return rfidTakenCount == 0;
    if (drawerStage is MobileDrawerIdle) return hasSelection;
    if (drawerStage is MobileDrawerFailed) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_showCancel) _CancelButton(onTap: onCancel) else const Spacer(),
        const Spacer(),
        _buildAction(context),
      ],
    );
  }

  Widget _buildAction(BuildContext context) {
    if (isSaving) {
      return _ActionButton(label: context.l10n.common_action_saving, enabled: false, loading: true, onTap: _noop);
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => _ActionButton(
        label: context.l10n.common_action_drawerOpening,
        enabled: false,
        loading: true,
        onTap: _noop,
      ),
      MobileDrawerOpened() => _ActionButton(label: context.l10n.unload_action_drawerOpen, enabled: false, onTap: _noop),
      MobileDrawerClosed() =>
        canComplete
            ? _ActionButton(label: context.l10n.unload_action_complete, onTap: onComplete)
            : _ActionButton(label: context.l10n.unload_action_continue, onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: context.l10n.common_retryButton, onTap: onStart),
      MobileDrawerIdle() => _ActionButton(
        label: context.l10n.unload_action_start,
        enabled: hasSelection,
        onTap: onStart,
      ),
    };
  }
}

// ignore: avoid_returning_null_for_void
void _noop() {}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true, this.loading = false});

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: label,
      size: MedButtonSize.sm,
      isLoading: loading,
      onPressed: enabled && !loading ? onTap : null,
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MedButton(
      label: context.l10n.common_cancelButton,
      size: MedButtonSize.sm,
      variant: MedButtonVariant.danger,
      onPressed: onTap,
    );
  }
}
