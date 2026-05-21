// [SWREQ-UI-RX-MOVEMENT-BLOCK-001]
// Sınıf: Class A
//
// Bir PrescriptionItem'a ait hareket geçmişini gösterir.
// - Varsayılan: lastMovement tek blok
// - Yükleniyorsa: spinner
// - Yüklendiyse: tüm hareketler, en yeni üstte

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class RxMovementBlock extends StatelessWidget {
  const RxMovementBlock({
    super.key,
    required this.lastMovement,
    required this.medicine,
    this.movements,
    this.isLoading = false,
  });

  final PrescriptionItemMovement? lastMovement;
  final Medicine? medicine;

  /// Null → henüz yüklenmedi (lastMovement gösterilir)
  /// Boş liste → hareket yok
  /// Dolu liste → tüm hareketler gösterilir
  final List<PrescriptionItemMovement>? movements;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(MedSpacing.xl2), child: CircularProgressIndicator()),
      );
    }

    final displayList = movements ?? (lastMovement != null ? [lastMovement!] : []);

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border2, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < displayList.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: MedColors.border2),
            _MovementBlockRow(movement: displayList[i], medicine: medicine),
          ],
        ],
      ),
    );
  }
}

class _MovementBlockRow extends StatelessWidget {
  const _MovementBlockRow({required this.movement, required this.medicine});

  final PrescriptionItemMovement movement;
  final Medicine? medicine;

  @override
  Widget build(BuildContext context) {
    final type = movement.type;

    return Padding(
      padding: const EdgeInsets.all(MedSpacing.xl2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,
        children: [
          Text(type.label.toUpperCase(), style: MedTextStyles.titleMd(color: type.foregroundColor)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FieldColumn(label: 'İşlemi Yapan', value: movement.performedBy?.fullName),
              _FieldColumn(label: 'Tarih', value: movement.createdAt.formattedDateTime),
              if (movement.quantity != null)
                _FieldColumn(
                  label: 'Miktar',
                  value: '${movement.quantity!.formatFractional} ${medicine?.operationUnit ?? ''}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldColumn extends StatelessWidget {
  const _FieldColumn({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.isEmpty) ? '—' : value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: MedTextStyles.monoMd(color: MedColors.text4)),
        const SizedBox(height: 1),
        Text(displayValue, style: MedTextStyles.monoMd()),
      ],
    );
  }
}
