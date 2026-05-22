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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: status.backgroundColor.withAlpha(55)),
      ),
      child: Text(status.label, style: MedTextStyles.monoSm(color: status.foregroundColor)),
    );
  }
}

/// Backward compat alias.
typedef RxStatusChip = MedRxMovementChip;
