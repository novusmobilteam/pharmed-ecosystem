import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_client/widgets/empty_state_widget.dart';
import 'package:pharmed_client/widgets/operation_panel_base.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cabin_operation/cabin_operation.dart';
import '../notifier/mobile_refill_state.dart';

part '../widgets/patient_picker_list_view.dart';
part '../widgets/patient_card.dart';
part '../widgets/action_bar.dart';

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
        MobileRefillIdle() || MobileRefillSlotSelected() || MobileRefillNoPatient() => _PatientPickerListView(
          assignments: state.availableAssignments,
          onSelected: onSelectAssignment,
        ),

        MobileRefillReady ready => _buildReady(ready),

        MobileRefillSaving(:final ready) || MobileRefillSuccess(:final ready) => _buildReady(ready),

        MobileRefillError(:final previousState) => switch (previousState) {
          MobileRefillReady ready => _buildReady(ready),
          _ => _PatientPickerListView(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },
      },
    );
  }

  Widget _buildReady(MobileRefillReady ready) {
    return Column(
      spacing: 4.0,
      children: [
        _PatientCard(
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
        final isSelected = item.id != null && selectedItemIds.contains(item.id);
        final isRfidRead = item.rfidTag != null && rfidReadEpcs.contains(item.rfidTag);

        return RxRefillCard(
          item: item,
          isSelected: isSelected,
          isRfidRead: isRfidRead,
          onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}
