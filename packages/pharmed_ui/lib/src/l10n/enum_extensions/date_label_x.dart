import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

extension DateTimeLabelX on DateTime {
  String shortRelativeLabelOf(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final thisDay = DateTime(year, month, day);

    final timeStr = DateFormat.Hm(locale).format(this); // "14:30"

    if (thisDay == today) {
      // intl'de built-in "today" yok, bunu l10n'dan almak gerekiyor
      // ama weekday label'ları için intl yeterli
      return '${context.l10n.date_preset_today} $timeStr';
    }
    if (thisDay == tomorrow) {
      return '${context.l10n.date_preset_tomorrow} $timeStr';
    }

    final dayLabel = DateFormat.E(locale).format(this); // "Mon", "Lun", "Pzt"
    return '$dayLabel $timeStr';
  }
}
