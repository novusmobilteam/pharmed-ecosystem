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

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

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

        MobileIntakeSaving(:final ready) || MobileIntakeSuccess(:final ready) => _buildReady(ready),

        MobileIntakeError(:final previousState) => switch (previousState) {
          MobileIntakeReady ready => _buildReady(ready),
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
            rfidReadEpcs: ready.rfidReadEpcs,
            selectedItemIds: ready.selectedItemIds,
            isProcessActive: _isSelectionLocked,
            onToggleItem: onToggleItem,
          ),
        ),
        _IntakeActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          allSelectedRfidRead: ready.allSelectedRfidRead,
          onStart: onStartIntake,
          onComplete: onCompleteIntake,
          onReopen: onReopenDrawer,
          onCancel: onCancelIntake,
          rfidReadCount: ready.rfidReadCount,
          isSaving: state is MobileIntakeSaving,
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

    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 2),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        final isEligible = item.status == PrescriptionStatus.purchasePending;
        final isSelected = item.id != null && selectedItemIds.contains(item.id);
        final isRfidRead = item.rfidTag != null && rfidReadEpcs.contains(item.rfidTag);

        return RxRefillCard(
          item: item,
          isEligible: isEligible,
          isSelected: isSelected,
          isRfidRead: isRfidRead,
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
    required this.allSelectedRfidRead,
    required this.rfidReadCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;
  final bool allSelectedRfidRead;
  final int rfidReadCount;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  bool get _showCancel {
    if (isSaving) return false;
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      return rfidReadCount == 0;
    }
    if (drawerStage is MobileDrawerClosed) return rfidReadCount == 0;
    if (drawerStage is MobileDrawerIdle) return hasSelection;
    if (drawerStage is MobileDrawerFailed) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_showCancel) _CancelButton(onTap: onCancel) else const Spacer(),
        Spacer(),
        _buildAction(),
      ],
    );
  }

  Widget _buildAction() {
    if (isSaving) {
      return _ActionButton(label: 'Kaydediliyor', enabled: false, loading: true, onTap: () {});
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => _ActionButton(label: 'Çekmece açılıyor', enabled: false, loading: true, onTap: () {}),
      MobileDrawerOpened() => _ActionButton(label: 'İlaçları alın', enabled: false, onTap: () {}),
      MobileDrawerClosed() =>
        allSelectedRfidRead
            ? _ActionButton(label: 'Alımı tamamla', onTap: onComplete)
            : _ActionButton(label: 'Alıma devam et', onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: 'Tekrar dene', onTap: onStart),
      MobileDrawerIdle() => _ActionButton(label: 'Alıma başla', enabled: hasSelection, onTap: onStart),
    };
  }
}

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
    return MedButton(label: 'İptal', size: MedButtonSize.sm, variant: MedButtonVariant.danger, onPressed: onTap);
  }
}
