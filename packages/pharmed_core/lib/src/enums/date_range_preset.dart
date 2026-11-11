enum DateRangePreset {
  today,
  last3Days,
  last7Days,
  all;

  /// [now]: hastane saatiyle şu an — `ServerClock.now()` verilmeli, cihaz
  /// saati (`DateTime.now()`) değil. Aralık sonu bugünün sonudur (23:59:59.999),
  /// "şu an" değil: gün içinde ileri saatli kayıtlar da dahil olur.
  ({DateTime? start, DateTime? end}) toRange(DateTime now) {
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    return switch (this) {
      DateRangePreset.today => (start: DateTime(now.year, now.month, now.day), end: endOfToday),
      DateRangePreset.last3Days => (start: now.subtract(const Duration(days: 3)), end: endOfToday),
      DateRangePreset.last7Days => (start: now.subtract(const Duration(days: 7)), end: endOfToday),
      DateRangePreset.all => (start: null, end: null),
    };
  }
}
