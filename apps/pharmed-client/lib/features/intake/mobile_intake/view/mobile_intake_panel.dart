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
    required this.state,
    required this.drawerStage,
    required this.onStartIntake,
    required this.onCompleteIntake,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelIntake,
    required this.onReportMissing,
  });

  final MobileIntakeState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartIntake;
  final VoidCallback onCompleteIntake;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelIntake;
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
      mode: CabinOperationMode.intake,
      child: switch (state) {
        MobileIntakeUninitialized() ||
        MobileIntakeLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // Hasta seçilmediği tüm durumlarda → liste göster
        MobileIntakeIdle() || MobileIntakeSlotSelected() || MobileIntakeNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileIntakeReady ready => _buildReady(ready),

        // Check, kaydetme ve başarı sırasında Ready görünümü korunur
        MobileIntakeCheckInProgress(:final ready) ||
        MobileIntakeSaving(:final ready) ||
        MobileIntakeSuccess(:final ready) => _buildReady(ready),

        MobileIntakeError(:final previousState) => switch (previousState) {
          MobileIntakeReady ready => _buildReady(ready),
          MobileIntakeCheckInProgress(:final ready) => _buildReady(ready),
          _ => CabinPatientPickerList(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
      },
    );
  }

  Widget _buildReady(MobileIntakeReady ready) {
    return Column(
      spacing: 4.0,
      children: [
        CabinActivePatientCard(
          patient: ready.patient,
          bed: ready.bed,
          room: ready.room,
          onChange: _isProcessActive ? null : onChangePatient,
        ),
        Expanded(
          child: _PrescriptionList(
            items: ready.prescriptionItems,
            selectedItemIds: ready.selectedItemIds,
            isProcessActive: _isSelectionLocked,
            onToggleItem: onToggleItem,
            takenEpcs: ready.takenEpcs,
            rfidReadEpcs: ready.rfidReadEpcs,
            onReportMissing: onReportMissing,
            reportingItemIds: ready.reportingItemIds,
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
    required this.onReportMissing,
    required this.reportingItemIds,
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
          // 🆕 Süreç aktifken (orchestrator açık) buton gizlenir
          onReportMissing: isDrawerOpen && item.id != null ? () => onReportMissing(item.id!) : null,
          isReportingMissing: item.id != null && reportingItemIds.contains(item.id),
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

  bool get _isLocked => isSaving || isStarting;

  bool get _showCancel {
    if (_isLocked) return false;
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

    // Check + drawer açılış loading — stage henüz Idle'da ama işlem başladı
    if (isStarting) {
      return _ActionButton(label: context.l10n.intake_action_start, enabled: false, loading: true, onTap: _noop);
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => _ActionButton(
        label: context.l10n.common_action_drawerOpening,
        enabled: false,
        loading: true,
        onTap: _noop,
      ),
      MobileDrawerOpened() => _ActionButton(label: context.l10n.intake_action_drawerOpen, enabled: false, onTap: _noop),
      MobileDrawerClosed() =>
        canComplete
            ? _ActionButton(label: context.l10n.intake_action_complete, onTap: onComplete)
            : _ActionButton(label: context.l10n.intake_action_continue, onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: context.l10n.common_retryButton, onTap: onStart),
      MobileDrawerIdle() => _ActionButton(
        label: context.l10n.intake_action_start,
        enabled: hasSelection,
        onTap: onStart,
      ),
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
