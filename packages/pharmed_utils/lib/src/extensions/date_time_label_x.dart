// packages/pharmed_utils/lib/src/extensions/date_time_label_x.dart

extension DateTimeLabelX on DateTime {
  /// Bugün/Yarın/haftanın günü + saat olarak kısa label.
  /// Örn: "Bugün 14:30", "Yarın 09:00", "Çar 16:45".
  ///
  /// Lokalizasyon gerekiyorsa `relativeDayLabel(l10n)` kullanın.
  String get shortRelativeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final thisDay = DateTime(year, month, day);

    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    if (thisDay == today) return 'Bugün $timeStr';
    if (thisDay == tomorrow) return 'Yarın $timeStr';

    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${days[weekday - 1]} $timeStr';
  }
}
