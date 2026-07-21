import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension MobileDrawerFailureX on MobileDrawerFailure {
  String message(BuildContext context, {String? detail}) {
    return switch (this) {
      MobileDrawerFailure.managerNotFound => context.l10n.core_cabinConn_managerNotFoundError,
      MobileDrawerFailure.managerConnectFailed => context.l10n.common_error_managerConnectFailedWithDetail(
        detail ?? '',
      ),
      MobileDrawerFailure.openCommandFailed => context.l10n.mobileDrawer_openCommandFailedError(detail ?? ''),
      MobileDrawerFailure.statusTimeout => context.l10n.mobileDrawer_statusTimeoutError,
      MobileDrawerFailure.openNotConfirmed => context.l10n.mobileDrawer_openNotConfirmedError,
      MobileDrawerFailure.statusReadError => context.l10n.mobileDrawer_statusReadError(detail ?? ''),
    };
  }
}
