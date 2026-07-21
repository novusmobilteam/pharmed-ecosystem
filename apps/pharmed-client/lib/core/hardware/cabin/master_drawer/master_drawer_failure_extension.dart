import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension MasterDrawerFailureX on MasterDrawerFailure {
  String message(BuildContext context, {String? detail}) {
    return context.l10n.mobileDrawer_cabinConnectionErrorMessage;
  }
}

extension MasterDrawerOpeningStepX on MasterDrawerOpeningStep {
  String message(BuildContext context) {
    return switch (this) {
      MasterDrawerOpeningStep.devicePreparing => context.l10n.common_action_devicePreparing,
      MasterDrawerOpeningStep.lockOpening => context.l10n.common_action_lockOpening,
    };
  }
}
