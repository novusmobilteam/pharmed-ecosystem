import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Hareket tipi → renk eşlemesi. Enum sırasına bağlı olduğu için
/// tüm grafiklerde ve filtre chip'lerinde aynı tip hep aynı renkte görünür.
abstract final class StockMovementPalette {
  static final List<Color> _colors = [
    MedColors.blue,
    MedColors.green,
    MedColors.amber,
    MedColors.red,
    const Color(0xFF7C3AED),
    const Color(0xFF0891B2),
    const Color(0xFFDB2777),
    const Color(0xFF64748B),
  ];

  static Color of(StationTransactionType type) => _colors[type.index % _colors.length];

  static const Color tooltipBg = Color(0xFF1A2332);
}

/// Grafik eksenleri ve başlıklar için tarih biçimleri (intl bağımlılığı olmadan).
abstract final class StockMovementDateFormat {
  static String _two(int v) => v.toString().padLeft(2, '0');

  static String dayMonth(DateTime d) => '${_two(d.day)}.${_two(d.month)}';

  static String hour(DateTime d) => '${_two(d.hour)}:00';

  static String full(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';
}
