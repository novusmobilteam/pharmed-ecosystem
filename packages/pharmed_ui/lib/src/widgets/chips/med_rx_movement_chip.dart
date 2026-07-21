import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedRxMovementChip
// [SWREQ-UI-CHIP-RX-001]
// Reçete durum chip'i — PrescriptionMovementType extension'ından
// renk/label alır, MedChip'e delege eder.
// ─────────────────────────────────────────────────────────────────

/// Reçete durum chip'i.
class MedRxMovementChip extends StatelessWidget {
  const MedRxMovementChip({super.key, required this.status, this.useActionLabel = false});

  final PrescriptionMovementType status;

  /// `true` → actionLabel (yapılan eylem), `false` → label (mevcut durum).
  final bool useActionLabel;

  @override
  Widget build(BuildContext context) {
    return MedChip(
      border: Colors.transparent,
      label: useActionLabel ? status.actionLabel(context) : status.label(context),
      background: status.backgroundColor,
      foreground: status.foregroundColor,
    );
  }
}

/// Backward compat alias.
typedef RxStatusChip = MedRxMovementChip;
