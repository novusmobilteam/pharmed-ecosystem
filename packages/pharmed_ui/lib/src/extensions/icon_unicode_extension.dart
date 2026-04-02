import 'package:flutter/material.dart';

extension IconUnicodeExtensions on String? {
  /// Unicode string değerini (örn: 'e123') IconData'ya dönüştürür.
  IconData? get toIcon {
    if (this == null || this!.isEmpty) return null;

    try {
      return IconData(int.parse(this!), fontFamily: 'PhosphorRegular', fontPackage: 'phosphor_flutter');
    } catch (e) {
      // Hata durumunda log basabilir veya direkt null dönebilirsin
      return null;
    }
  }
}
