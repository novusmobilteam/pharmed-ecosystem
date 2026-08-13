import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension MasterDrawerFailureX on MasterDrawerFailure {
  String message(BuildContext context, {String? detail}) {
    return switch (this) {
      MasterDrawerFailure.managerNotFound => context.l10n.masterDrawer_error_managerNotFound,
      MasterDrawerFailure.managerConnectFailed => context.l10n.masterDrawer_error_managerConnectFailed,
      MasterDrawerFailure.lockOpenFailed => context.l10n.masterDrawer_error_lockOpenFailed,
      MasterDrawerFailure.lidOpenFailed => context.l10n.masterDrawer_error_lidOpenFailed,
      MasterDrawerFailure.lockOpenTimeout => context.l10n.masterDrawer_error_lockOpenTimeout,
      MasterDrawerFailure.sensorCommunicationLost => context.l10n.masterDrawer_error_sensorCommunicationLost,
    };
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
