extension ToStringExtension on num? {
  String toCustomString() => this != null ? toString() : '';

  /// Eğer sayı tam sayı ise (örn: 5.0) "5" olarak,
  /// ondalıklı ise (örn: 5.5) "5.5" olarak döndürür.
  String get formatFractional {
    if (this == null) return '-';
    return this! % 1 == 0 ? this!.toInt().toString() : toString();
  }
}

extension ToCustomStringExtension on int? {
  String toCustomString() => this != null ? toString() : '';
}

extension DoubleFormatter on double {
  /// Eğer sayı tam sayı ise (örn: 5.0) "5" olarak,
  /// ondalıklı ise (örn: 5.5) "5.5" olarak döndürür.
  String get formatFractional {
    return this % 1 == 0 ? toInt().toString() : toString();
  }
}
