extension DateTimeBoundaryX on DateTime {
  /// Aynı günün 23:59:59.999 anı — backend `<=` filtreleri için.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Aynı günün 00:00:00.000 anı — backend `>=` filtreleri için.
  DateTime get startOfDay => DateTime(year, month, day);
}
