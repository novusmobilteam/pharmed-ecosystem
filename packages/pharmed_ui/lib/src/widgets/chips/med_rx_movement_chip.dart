import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedRxMovementChip
// [SWREQ-UI-CHIP-RX-001]
// Kullanım: Reçete kartındaki durum chip'i.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Reçete durum chip'i — PrescriptionStatus extension'ından renk/ikon alır.
///
/// ```dart
/// MedRxMovementChip(status: prescription.status)
/// ```
class MedRxMovementChip extends StatelessWidget {
  const MedRxMovementChip({super.key, required this.status});

  final PrescriptionMovementType status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: status.foregroundColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: status.foregroundColor, shape: BoxShape.circle),
          ),
          // Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 4),
          Text(status.label, style: MedTextStyles.monoSm(color: status.foregroundColor)),
        ],
      ),
    );
  }
}

/// Backward compat alias.
typedef RxStatusChip = MedRxMovementChip;
