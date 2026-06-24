enum DateRangePreset {
  today,
  last3Days,
  last7Days,
  all;

  ({DateTime? start, DateTime? end}) toRange(DateTime now) => switch (this) {
    DateRangePreset.today => (start: DateTime(now.year, now.month, now.day), end: now),
    DateRangePreset.last3Days => (start: now.subtract(const Duration(days: 3)), end: now),
    DateRangePreset.last7Days => (start: now.subtract(const Duration(days: 7)), end: now),
    DateRangePreset.all => (start: null, end: null),
  };
}
