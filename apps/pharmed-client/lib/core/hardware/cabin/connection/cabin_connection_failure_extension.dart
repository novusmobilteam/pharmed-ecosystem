import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension CabinConnectionFailureX on CabinConnectionFailure {
  String message(BuildContext context, {String? detail}) {
    return switch (this) {
      CabinConnectionFailure.managerNotFound => context.l10n.core_cabinConn_managerNotFoundError,
      CabinConnectionFailure.disconnected => context.l10n.core_cabinConn_disconnectedError,
      CabinConnectionFailure.managerConnectFailed => context.l10n.common_error_managerConnectFailedWithDetail(
        detail ?? '',
      ),
      CabinConnectionFailure.unknown => context.l10n.common_genericErrorMessage,
    };
  }
}
