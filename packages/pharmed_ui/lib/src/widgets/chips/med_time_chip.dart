import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedTimeChip
// [SWREQ-UI-CHIP-TIME-001]
// Kullanım: Reçete kartındaki sonraki uygulama zamanı chip'i.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Zaman chip'i — "Bugün 14:30", "Yarın 08:00", "Pzt 09:00" formatı.
///
/// ```dart
/// MedTimeChip(time: nextDoseDateTime)
/// ```
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

    // Aktif locale'e göre kısaltılmış gün adı (ör. tr: "Pzt", en: "Mon").
    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat('E', locale).format(time);
    return '$weekday $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(_label(context), style: MedTextStyles.monoSm(color: MedColors.amber))],
      ),
    );
  }
}

/// Backward compat alias.
typedef TimeChip = MedTimeChip;
