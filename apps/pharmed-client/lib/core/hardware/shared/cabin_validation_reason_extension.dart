import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum CabinValidationReason {
  witnessRequired,
  noValidTargets,
  noDrawerFound,
  closedWithInvalidEntry,
  // ileride eklenecekler buraya
}

extension CabinValidationReasonX on CabinValidationReason {
  String message(BuildContext context) {
    return switch (this) {
      CabinValidationReason.witnessRequired => context.l10n.intake_error_witnessRequired,
      CabinValidationReason.noValidTargets => context.l10n.intake_error_noValidTargets,
      CabinValidationReason.noDrawerFound => context.l10n.intake_error_noDrawerFound,
      CabinValidationReason.closedWithInvalidEntry => context.l10n.intake_error_noValidTargets,
    };
  }
}
