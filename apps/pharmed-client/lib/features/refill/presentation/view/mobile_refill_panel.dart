import 'package:flutter/material.dart';
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
import 'package:pharmed_client/widgets/empty_state_widget.dart';
import 'package:pharmed_client/widgets/operation_panel_base.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../state/mobile_refill_state.dart';
import 'refill_rx_card.dart';

// [SWREQ-CLI-REFILL-002] [IEC 62304 §5.5]
// Mobil kabin dolum sağ paneli.
// Seçili gözdeki hasta bilgisi + reçete listesi gösterilir.
// Dolum başlatma ve tamamlama aksiyonları burada tetiklenir.
// Sınıf: Class B

class MobileRefillPanel extends StatelessWidget {
  const MobileRefillPanel({
    super.key,
    required this.state,
    required this.onStartRefill,
    required this.onCompleteRefill,
  });

  final MobileRefillState state;
  final VoidCallback onStartRefill;
  final VoidCallback onCompleteRefill;

  @override
  Widget build(BuildContext context) {
    return OperationPanelBase(
      mode: CabinOperationMode.refill,
      child: switch (state) {
        MobileRefillUninitialized() ||
        MobileRefillLoading() => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        MobileRefillIdle() ||
        MobileRefillSlotSelected() => const EmptyStateWidget(variant: EmptyStateVariant.noCellSelected),
        MobileRefillNoPatient() => const EmptyStateWidget(variant: EmptyStateVariant.noPatient),
        MobileRefillReady(
          :final patient,
          :final bed,
          :final room,
          :final prescriptionItems,
          :final rfidReadIds,
          :final isRefilling,
          :final allRfidRead,
          :final rfidItemCount,
          :final rfidReadCount,
        ) =>
          Column(
            spacing: 4.0,
            children: [
              _PatientHeader(patient: patient, bed: bed, room: room),
              Expanded(
                child: _PrescriptionList(items: prescriptionItems, rfidReadIds: rfidReadIds, isRefilling: isRefilling),
              ),
              _RefillActionBar(
                isRefilling: isRefilling,
                allRfidRead: allRfidRead,
                rfidItemCount: rfidItemCount,
                rfidReadCount: rfidReadCount,
                onStart: onStartRefill,
                onComplete: onCompleteRefill,
              ),
            ],
          ),
        MobileRefillError(:final previousState) => switch (previousState) {
          MobileRefillReady(
            :final patient,
            :final bed,
            :final room,
            :final prescriptionItems,
            :final rfidReadIds,
            :final isRefilling,
            :final allRfidRead,
            :final rfidItemCount,
            :final rfidReadCount,
          ) =>
            Column(
              children: [
                _PatientHeader(patient: patient, bed: bed, room: room),
                const SizedBox(height: 2),
                Expanded(
                  child: _PrescriptionList(
                    items: prescriptionItems,
                    rfidReadIds: rfidReadIds,
                    isRefilling: isRefilling,
                  ),
                ),
                _RefillActionBar(
                  isRefilling: isRefilling,
                  allRfidRead: allRfidRead,
                  rfidItemCount: rfidItemCount,
                  rfidReadCount: rfidReadCount,
                  onStart: onStartRefill,
                  onComplete: onCompleteRefill,
                ),
              ],
            ),
          _ => const EmptyStateWidget(variant: EmptyStateVariant.noCellSelected),
        },
        MobileRefillSuccess() ||
        MobileRefillSaving() => const EmptyStateWidget(variant: EmptyStateVariant.noCellSelected),
      },
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader({required this.patient, required this.bed, required this.room});

  final Patient patient;
  final Bed? bed;
  final Room? room;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList({required this.items, required this.rfidReadIds, required this.isRefilling});

  final List<PrescriptionItem> items;
  final Set<int> rfidReadIds;
  final bool isRefilling;

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
        return RefillRxCard(item: item, isRfidRead: rfidReadIds.contains(item.id), isRefilling: isRefilling);
      },
    );
  }
}

class _RefillActionBar extends StatelessWidget {
  const _RefillActionBar({
    required this.isRefilling,
    required this.allRfidRead,
    required this.rfidItemCount,
    required this.rfidReadCount,
    required this.onStart,
    required this.onComplete,
  });

  final bool isRefilling;
  final bool allRfidRead;
  final int rfidItemCount;
  final int rfidReadCount;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // RFID sayaç — sadece dolum aktifken ve RFID'li ilaç varsa
        if (isRefilling && rfidItemCount > 0)
          Expanded(
            child: _RfidCounter(readCount: rfidReadCount, totalCount: rfidItemCount),
          )
        else
          const Spacer(),

        // Aksiyon butonu
        if (!isRefilling)
          _ActionButton(label: 'Doluma başla', onTap: onStart)
        else
          _ActionButton(label: 'Dolumu tamamla', enabled: allRfidRead, onTap: onComplete),
      ],
    );
  }
}

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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.enabled = true});

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MedButton(label: label, size: MedButtonSize.sm, onPressed: () => onTap());
  }
}
