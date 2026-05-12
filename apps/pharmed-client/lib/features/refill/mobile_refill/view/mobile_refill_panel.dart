import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_client/widgets/operation_panel_base.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../notifier/mobile_refill_state.dart';

// [SWREQ-CLI-REFILL-002] [IEC 62304 §5.5]
// Mobil kabin dolum sağ paneli.
// Hasta seçilmemişse: o kabine atanmış hastaların listesi (arama dahil)
// Hasta seçilmişse: hasta başlığı + reçete listesi + dolum aksiyonları
//
// Drawer/RFID akışı bu panel'in dışında yönetilir; panel sadece bilgi alır:
//   - drawerStage: işlem aktif mi, kapanmış mı
//   - state.rfidReadEpcs / rfidExpectedCount / rfidReadCount / allSelectedRfidRead
//
// Sınıf: Class B

class MobileRefillPanel extends StatelessWidget {
  const MobileRefillPanel({
    super.key,
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

        // Hasta seçilmediği tüm durumlarda → liste göster
        MobileRefillIdle() || MobileRefillSlotSelected() || MobileRefillNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileRefillReady ready => _buildReady(ready),

        // Drawer başlatma, kaydetme ve başarı sırasında Ready görünümü korunur
        MobileRefillDrawerStarting(:final ready) ||
        MobileRefillSaving(:final ready) ||
        MobileRefillSuccess(:final ready) => _buildReady(ready),

        MobileRefillError(:final previousState) => switch (previousState) {
          MobileRefillReady ready => _buildReady(ready),
          MobileRefillDrawerStarting(:final ready) => _buildReady(ready),
          _ => CabinPatientPickerList(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
      },
    );
  }

  Widget _buildReady(MobileRefillReady ready) {
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
        _RefillActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          allSelectedRfidRead: ready.allSelectedRfidRead,
          onStart: onStartRefill,
          onComplete: onCompleteRefill,
          onReopen: onReopenDrawer,
          onCancel: onCancelRefill,
          rfidReadCount: ready.rfidReadCount,
          isSaving: state is MobileRefillSaving,
          isStarting: state is MobileRefillDrawerStarting,
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

        final isEligible = item.status == PrescriptionStatus.filledWaiting;
        final isSelected = item.id != null && selectedItemIds.contains(item.id);
        final rfidStatus = !isProcessActive
            ? null // session başlamadı
            : rfidReadEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.present
            : RfidPresenceStatus.absent;

        MedLogger.info(
          unit: 'MobileRefillPanel',
          swreq: 'SWREQ-CLI-REFILL-001',
          message: 'isRfidRead kontrolü',
          context: {'itemRfidTag': item.rfidTag, 'rfidReadEpcs': rfidReadEpcs.toList(), 'rfidStatus': rfidStatus},
        );

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

class _RefillActionBar extends StatelessWidget {
  const _RefillActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.allSelectedRfidRead,
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
  final bool allSelectedRfidRead;
  final int rfidReadCount;
  final bool isStarting;
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
        const Spacer(),
        _buildAction(),
      ],
    );
  }

  Widget _buildAction() {
    if (isSaving) {
      return const _ActionButton(label: 'Kaydediliyor', enabled: false, loading: true, onTap: _noop);
    }

    return switch (drawerStage) {
      MobileDrawerOpening() => const _ActionButton(
        label: 'Çekmece açılıyor',
        enabled: false,
        loading: true,
        onTap: _noop,
      ),
      MobileDrawerOpened() => const _ActionButton(label: 'İlaçları yerleştirin', enabled: false, onTap: _noop),
      MobileDrawerClosed() =>
        allSelectedRfidRead
            ? _ActionButton(label: 'Dolumu tamamla', onTap: onComplete)
            : _ActionButton(label: 'Doluma devam et', onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: 'Tekrar dene', onTap: onStart),
      MobileDrawerIdle() =>
        isStarting
            ? const _ActionButton(label: 'Bağlantı kuruluyor', enabled: false, loading: true, onTap: _noop)
            : _ActionButton(label: 'Doluma başla', enabled: hasSelection, onTap: onStart),
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
