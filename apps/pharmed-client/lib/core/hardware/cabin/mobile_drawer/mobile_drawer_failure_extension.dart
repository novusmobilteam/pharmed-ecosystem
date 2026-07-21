import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension MobileDrawerFailureX on MobileDrawerFailure {
  String message(BuildContext context, {String? detail}) {
    return context.l10n.mobileDrawer_cabinConnectionErrorMessage;
  }
}
