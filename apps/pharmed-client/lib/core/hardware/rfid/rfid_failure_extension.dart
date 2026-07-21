import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension RfidFailureX on RfidFailure {
  String message(BuildContext context, {String? detail}) {
    return switch (this) {
      RfidFailure.notConnected => context.l10n.rfid_notConnectedError,
      RfidFailure.inventoryStartFailed => context.l10n.rfid_inventoryStartFailedError(detail ?? ''),
      RfidFailure.inventoryStreamError => context.l10n.rfid_inventoryStreamError(detail ?? ''),
    };
  }
}
