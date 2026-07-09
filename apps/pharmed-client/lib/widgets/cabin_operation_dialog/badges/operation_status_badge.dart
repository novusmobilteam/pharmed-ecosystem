import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/cabin_operation/cabin_operation.dart';
import 'status_badge.dart';

enum OperationPhase { normal, saving, error, fatal, rollback }

/// Dialog üst durum rozeti için tip-agnostik state özeti.
class OperationStatusInput {
  const OperationStatusInput({
    required this.phase,
    required this.drawerStage,
    required this.baselineCompleted,
    required this.canComplete,
    this.rollbackSettling = false, // rollback'te sonlanma anı (rfid boş)
  });

  final OperationPhase phase;
  final MobileDrawerStage drawerStage;
  final bool baselineCompleted;
  final bool canComplete;
  final bool rollbackSettling;
}

class OperationStatusBadge extends StatelessWidget {
  const OperationStatusBadge({super.key, required this.input});

  final OperationStatusInput input;

  @override
  Widget build(BuildContext context) {
    final (label, icon, bg, fg) = _resolve(context, input);
    return StatusBadge(bg: bg, fg: fg, icon: icon, label: label);
  }

  (String, IconData, Color, Color) _resolve(BuildContext context, OperationStatusInput i) {
    final stage = i.drawerStage;
    final l10n = context.l10n;

    // ── Özel fazlar ──
    if (i.phase == OperationPhase.fatal) {
      return (
        l10n.operationStatus_fatalErrorLabel,
        PhosphorIcons.warningOctagon(PhosphorIconsStyle.bold),
        MedColors.redLight,
        MedColors.red,
      );
    }
    if (i.phase == OperationPhase.saving) {
      return (
        l10n.common_action_saving,
        PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }
    if (i.phase == OperationPhase.error) {
      return (
        l10n.operationStatus_errorLabel,
        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        MedColors.redLight,
        MedColors.red,
      );
    }
    if (i.phase == OperationPhase.rollback) {
      if (stage is MobileDrawerOpening) {
        return (
          l10n.common_action_drawerOpening,
          PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      if (stage is MobileDrawerOpened) {
        return (
          l10n.operationStatus_rollingBackLabel,
          PhosphorIcons.handPalm(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      if (stage is MobileDrawerClosed && i.rollbackSettling) {
        return (
          l10n.operationStatus_finalizingLabel,
          PhosphorIcons.clock(PhosphorIconsStyle.bold),
          MedColors.amberLight,
          MedColors.amber,
        );
      }
      return (
        l10n.operationStatus_drugsStillInCabinetLabel,
        PhosphorIcons.warning(PhosphorIconsStyle.bold),
        MedColors.amberLight,
        MedColors.amber,
      );
    }

    // ── Normal (Ready ailesi) — drawerStage'e göre ──
    if (stage is MobileDrawerOpening) {
      return (
        l10n.common_action_drawerOpening,
        PhosphorIcons.circleNotch(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }
    if (stage is MobileDrawerClosed) {
      return i.canComplete
          ? (
              l10n.common_action_drawerClosed,
              PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
              MedColors.greenLight,
              MedColors.green,
            )
          : (
              l10n.operationStatus_incompleteLabel,
              PhosphorIcons.warning(PhosphorIconsStyle.bold),
              MedColors.amberLight,
              MedColors.amber,
            );
    }
    if (!i.baselineCompleted) {
      return (
        l10n.operationStatus_scanningLabel,
        PhosphorIcons.tag(PhosphorIconsStyle.bold),
        MedColors.blueLight,
        MedColors.blue,
      );
    }
    return (
      l10n.refill_status_drawerOpen,
      PhosphorIcons.lockOpen(PhosphorIconsStyle.bold),
      MedColors.greenLight,
      MedColors.green,
    );
  }
}
