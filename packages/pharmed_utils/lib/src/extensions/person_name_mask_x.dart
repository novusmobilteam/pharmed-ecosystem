/// [SWREQ-UI-PRIV-001] Oturum açık değilken hasta kimliği maskelenir.
extension PersonNameMaskX on String? {
  static const _mask = '***';

  /// "Ayşe Nur Yılmaz" → "A*** N*** Y***"
  /// Yıldız sayısı sabittir; isim uzunluğu bilgisi sızmaz.
  String maskedPersonName({String fallback = '-'}) {
    final value = this?.trim();
    if (value == null || value.isEmpty) return fallback;

    return value.split(RegExp(r'\s+')).map((part) => '${part.substring(0, 1)}$_mask').join(' ');
  }
}
