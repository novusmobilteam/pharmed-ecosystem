import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension DelayLabelX on int /* delayMinutes */ {
  String delayLabel(BuildContext context) {
    if (this < 60) {
      return context.l10n.dashboard_delayMinutesLabel(this);
    }
    final hours = this ~/ 60;
    final minutes = this % 60;
    return context.l10n.dashboard_delayHoursMinutesLabel(hours, minutes);
  }
}
