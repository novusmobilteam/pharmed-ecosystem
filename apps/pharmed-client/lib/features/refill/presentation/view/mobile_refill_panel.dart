import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_client/widgets/empty_state_widget.dart';
import 'package:pharmed_client/widgets/operation_panel_base.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../state/mobile_refill_state.dart';
import 'refill_rx_card.dart';

part 'patient_picker_list_view.dart';

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
  });

  final MobileRefillState state;
  final MobileDrawerStage drawerStage;
  final VoidCallback onStartRefill;
  final VoidCallback onCompleteRefill;
  final VoidCallback onReopenDrawer;
  final ValueChanged<BedAssignment> onSelectAssignment;
  final VoidCallback onChangePatient;
  final ValueChanged<int> onToggleItem;

  /// Süreç aktif (Opening/Opened/Closed) mı?
  bool get _isProcessActive => drawerStage.isActive;

  /// Çekmece kapatılmış mı? (Tamamla butonu bu durumda aktif olabilir.)
  bool get _isDrawerClosed => drawerStage is MobileDrawerClosed;

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

        MobileRefillError(:final previousState) => switch (previousState) {
          MobileRefillReady ready => _buildReady(ready),
          _ => _PatientPickerListView(assignments: previousState.availableAssignments, onSelected: onSelectAssignment),
        },

        MobileRefillSuccess() ||
        MobileRefillSaving() => const EmptyStateWidget(variant: EmptyStateVariant.noCellSelected),
      },
    );
  }

  Widget _buildReady(MobileRefillReady ready) {
    return Column(
      spacing: 4.0,
      children: [
        _PatientHeader(
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
            isProcessActive: _isProcessActive,
            onToggleItem: onToggleItem,
          ),
        ),
        _RefillActionBar(
          drawerStage: drawerStage,
          hasSelection: ready.selectedItemIds.isNotEmpty,
          allSelectedRfidRead: ready.allSelectedRfidRead,
          rfidExpectedCount: ready.rfidExpectedCount,
          rfidReadCount: ready.rfidReadCount,
          onStart: onStartRefill,
          onComplete: onCompleteRefill,
          onReopen: onReopenDrawer,
        ),
      ],
    );
  }
}

// ── _PatientHeader ───────────────────────────────────────────────────────────

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient, required this.bed, required this.room, required this.onChange});

  final Patient patient;
  final Bed? bed;
  final Room? room;
  final VoidCallback? onChange;

  String get _initials {
    final parts = patient.fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
        boxShadow: MedShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: MedColors.blueLight, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  _initials,
                  style: MedTextStyles.bodyMd(color: MedColors.blue, weight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (room?.name != null || bed?.name != null)
                    Text(
                      [if (room?.name != null) room!.name!, if (bed?.name != null) bed!.name!].join(' · '),
                      style: MedTextStyles.monoXs(),
                    ),
                ],
              ),
            ),
            // Başka hasta seç (sadece süreç aktif değilse)
            if (onChange != null)
              IconButton(
                icon: Icon(PhosphorIcons.userSwitch(), size: 18, color: MedColors.text2),
                tooltip: 'Başka hasta seç',
                onPressed: onChange,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }
}

// ── _PrescriptionList ────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.id != null && selectedItemIds.contains(item.id);
        final isRfidRead = item.rfidTag != null && rfidReadEpcs.contains(item.rfidTag);

        return RefillRxCard(
          item: item,
          isSelected: isSelected,
          isRfidRead: isRfidRead,
          onTap: isProcessActive || item.id == null ? null : () => onToggleItem(item.id!),
        );
      },
    );
  }
}

// ── _RefillActionBar ─────────────────────────────────────────────────────────

class _RefillActionBar extends StatelessWidget {
  const _RefillActionBar({
    required this.drawerStage,
    required this.hasSelection,
    required this.allSelectedRfidRead,
    required this.rfidExpectedCount,
    required this.rfidReadCount,
    required this.onStart,
    required this.onComplete,
    required this.onReopen,
  });

  final MobileDrawerStage drawerStage;
  final bool hasSelection;
  final bool allSelectedRfidRead;
  final int rfidExpectedCount;
  final int rfidReadCount;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sayaç — süreç aktifken ve seçili RFID'li ilaç varsa
        if (drawerStage.isActive && rfidExpectedCount > 0)
          Expanded(
            child: _RfidCounter(readCount: rfidReadCount, totalCount: rfidExpectedCount),
          )
        else
          const Spacer(),

        // Aksiyon butonu — drawerStage'e göre 4 durum
        ..._buildAction(),
      ],
    );
  }

  List<Widget> _buildAction() {
    // Süreç başlamadı (Idle) veya hata aldı (Failed) → "Doluma başla"
    if (drawerStage is MobileDrawerIdle || drawerStage is MobileDrawerFailed) {
      return [_ActionButton(label: 'Doluma başla', enabled: hasSelection, onTap: onStart)];
    }

    // Çekmece açılıyor / açık → pasif "İşlem devam ediyor"
    if (drawerStage is MobileDrawerOpening || drawerStage is MobileDrawerOpened) {
      return [_ActionButton(label: 'İşlem devam ediyor', enabled: false, onTap: () {})];
    }

    // Çekmece kapandı
    if (drawerStage is MobileDrawerClosed) {
      // Tüm RFID'ler okundu → tamamla
      if (allSelectedRfidRead) {
        return [_ActionButton(label: 'Dolumu tamamla', onTap: onComplete)];
      }
      // Eksik etiket var → tekrar aç
      return [_ActionButton(label: 'Doluma devam et', onTap: onReopen)];
    }

    return [const SizedBox.shrink()];
  }
}

// ── _RfidCounter ─────────────────────────────────────────────────────────────

class _RfidCounter extends StatelessWidget {
  const _RfidCounter({required this.readCount, required this.totalCount});

  final int readCount;
  final int totalCount;

  bool get _allRead => readCount >= totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          PhosphorIcons.tag(PhosphorIconsStyle.duotone),
          size: 14,
          color: _allRead ? MedColors.green : MedColors.amber,
        ),
        const SizedBox(width: 6),
        Text(
          '$readCount / $totalCount etiket okundu',
          style: MedTextStyles.monoSm(color: _allRead ? MedColors.green : MedColors.text2, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── _ActionButton ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true});

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MedButton(label: label, size: MedButtonSize.sm, onPressed: enabled ? () => onTap() : null);
  }
}
