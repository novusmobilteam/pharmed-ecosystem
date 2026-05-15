import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedRxStatusChip
// [SWREQ-UI-CHIP-RX-001]
// Kullanım: Reçete kartındaki durum chip'i.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Reçete durum chip'i — PrescriptionStatus extension'ından renk/ikon alır.
///
/// ```dart
/// MedRxStatusChip(status: prescription.status)
/// ```
class MedRxStatusChip extends StatelessWidget {
  const MedRxStatusChip({super.key, required this.status});

  final PrescriptionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: status.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          // Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 4),
          Text(status.label, style: MedTextStyles.monoSm(color: status.color)),
        ],
      ),
    );
  }
}

/// Backward compat alias.
typedef RxStatusChip = MedRxStatusChip;
