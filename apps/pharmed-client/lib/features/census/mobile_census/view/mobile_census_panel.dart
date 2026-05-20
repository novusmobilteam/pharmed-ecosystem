import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../../../../core/enums/cabin_operation_mode.dart';
import '../../census.dart';

class MobileCensusPanel extends StatelessWidget {
  const MobileCensusPanel({
    super.key,
    required this.state,
    required this.drawerStage,
    required this.onStartCensus,
    required this.onCompleteCensus,
    required this.onReopenDrawer,
    required this.onSelectAssignment,
    required this.onChangePatient,
    required this.onToggleItem,
    required this.onCancelCensus,
  });

  final MobileCensusState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartCensus;
  final VoidCallback onCompleteCensus;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;
  final VoidCallback onCancelCensus;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece açılıyor veya açıkken seçim değiştirilemez.
  bool get _isSelectionLocked => drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.census,
      child: switch (state) {
        MobileCensusUninitialized() ||
        MobileCensusLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),

        // Hasta seçilmediği tüm durumlarda → liste göster
        MobileCensusIdle() || MobileCensusSlotSelected() || MobileCensusNoPatient() => CabinPatientPickerList(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileCensusReady ready => _buildReady(ready),

        // Kaydetme ve başarı sırasında Ready görünümü korunur
        MobileCensusSaving(:final ready) || MobileCensusSuccess(:final ready) => _buildReady(ready),

        MobileCensusError(:final previousState) => switch (previousState) {
          MobileCensusReady ready => _buildReady(ready),
          MobileCensusSaving(:final ready) => _buildReady(ready),
          _ => CabinPatientPickerList(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
      },
    );
  }

  Widget _buildReady(MobileCensusReady ready) {
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
          child: _CensusPrescriptionList(
            items: ready.prescriptionItems,
            selectedItemIds: ready.selectedItemIds,
            isSelectionLocked: _isSelectionLocked,
            rfidReadEpcs: ready.rfidReadEpcs,
            isProcessActive: _isProcessActive,
            onToggleItem: onToggleItem,
          ),
        ),
        _CensusActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          canComplete: ready.canComplete,
          rfidPresentCount: ready.rfidPresentCount,
          isSaving: state is MobileCensusSaving,
          onStart: onStartCensus,
          onComplete: onCompleteCensus,
          onReopen: onReopenDrawer,
          onCancel: onCancelCensus,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _CensusPrescriptionList extends StatelessWidget {
  const _CensusPrescriptionList({
    required this.items,
    required this.selectedItemIds,
    required this.rfidReadEpcs,
    required this.isSelectionLocked,
    required this.isProcessActive,
    required this.onToggleItem,
  });

  final List<PrescriptionItem> items;
  final Set<int> selectedItemIds;

  /// Şu an okuyucu tarafından görülen EPC'ler — kabinde fiziksel olarak mevcut.
  final Set<String> rfidReadEpcs;

  /// Çekmece açılıyor veya açıkken true — seçim kilitli.
  final bool isSelectionLocked;

  /// RFID session aktif mi (çekmece herhangi bir aktif aşamada mı)?
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

        // Sayım semantiği: EPC okunuyorsa ilaç kabinde var (present),
        // okunmuyorsa absent. Alımın tersi: "removed" durumu yok.
        final rfidStatus = !isProcessActive
            ? null // session başlamadı
            : rfidReadEpcs.contains(item.rfidTag)
            ? RfidPresenceStatus.present
            : RfidPresenceStatus.absent;

        return RxOperationCard(
          mode: RxOperationCardMode.census,
          item: item,
          isEligible: isEligible,
          isSelected: isSelected,
          rfidStatus: rfidStatus,
          onTap: isSelectionLocked || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _CensusActionBar extends StatelessWidget {
  const _CensusActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.canComplete,
    required this.rfidPresentCount,
    required this.isSaving,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
    required this.onCancel,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;

  /// Seçili RFID'li tüm item'ların EPC'si şu an okunuyor mu?
  /// [MobileCensusReady.canComplete] getter'ından gelir.
  final bool canComplete;

  /// Şu an okunan (kabinde mevcut) seçili RFID'li ilaç sayısı.
  /// [MobileCensusReady.rfidPresentCount] getter'ından gelir.
  final int rfidPresentCount;

  final bool isSaving;

  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;
  final VoidCallback onCancel;

  bool get _showCancel {
    if (isSaving) return false;
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      return false; // açık çekmecede iptal yok — view snackbar gösterir
    }
    if (drawerStage is MobileDrawerClosed) return rfidPresentCount == 0;
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
      MobileDrawerOpened() => const _ActionButton(label: 'İlaçları sayın', enabled: false, onTap: _noop),
      MobileDrawerClosed() =>
        canComplete
            ? _ActionButton(label: 'Sayımı tamamla', onTap: onComplete)
            : _ActionButton(label: 'Sayıma devam et', onTap: onReopen),
      MobileDrawerFailed() => _ActionButton(label: 'Tekrar dene', onTap: onStart),
      MobileDrawerIdle() => _ActionButton(label: 'Sayıma başla', enabled: hasSelection, onTap: onStart),
    };
  }
}

// ignore: avoid_returning_null_for_void
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
    return MedButton(label: 'İptal', size: MedButtonSize.sm, variant: MedButtonVariant.danger, onPressed: onTap);
  }
}
