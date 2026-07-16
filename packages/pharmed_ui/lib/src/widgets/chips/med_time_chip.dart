import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedTimeChip
// [SWREQ-UI-CHIP-TIME-001]
// "Bugün 14:30" / "Yarın 08:00" / "Pzt 09:00" formatı. Sabit amber.
// Formatlama burada; görsel iskelet MedChip'te.
// ─────────────────────────────────────────────────────────────────

/// Zaman chip'i — sonraki uygulama zamanı.
class MedTimeChip extends StatelessWidget {
  const MedTimeChip({super.key, required this.time});

  final DateTime time;

  String _label(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final timeDay = DateTime(time.year, time.month, time.day);

    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    if (timeDay == today) return context.l10n.timeChip_today(timeStr);
    if (timeDay == tomorrow) return context.l10n.timeChip_tomorrow(timeStr);

    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat('E', locale).format(time);
    return '$weekday $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return MedChip(label: _label(context), style: MedChipStyle.warning);
  }
}

/// Backward compat alias.
typedef TimeChip = MedTimeChip;
