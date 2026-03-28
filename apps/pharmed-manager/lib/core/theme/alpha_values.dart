// lib/core/constants/alpha_values.dart

import 'dart:ui';

import 'package:flutter/material.dart';

/// ALPHA DEĞERLERİ SABİTLERİ
///
/// Flutter 3.0+ ile withOpacity() deprecated olduğu için
/// withAlpha() veya withValues() kullanmalıyız.
///
/// Alpha değerleri 0-255 arasındadır:
/// - 0: Tamamen şeffaf (%0 opacity)
/// - 255: Tamamen opak (%100 opacity)
///
/// OPACITY -> ALPHA DÖNÜŞÜMÜ:
/// opacity * 255 = alpha değeri
///
/// Örnek:
/// - %100 opacity -> 1.0 * 255 = 255
/// - %50 opacity  -> 0.5 * 255 = 128 (yaklaşık)
/// - %30 opacity  -> 0.3 * 255 = 77
/// - %12 opacity  -> 0.12 * 255 = 30.6 ≈ 30

class AlphaValues {
  // TEMEL OPACITY DEĞERLERİ
  static const int transparent = 0; // %0 opacity - Tamamen şeffaf
  static const int full = 255; // %100 opacity - Tamamen opak

  // YAYGIN KULLANILAN DEĞERLER
  static const int veryLight = 30; // %12 opacity - Çok hafif
  static const int light = 64; // %25 opacity - Hafif
  static const int mediumLight = 77; // %30 opacity - Orta hafif
  static const int medium = 128; // %50 opacity - Orta
  static const int mediumDark = 179; // %70 opacity - Orta koyu
  static const int dark = 204; // %80 opacity - Koyu
  static const int veryDark = 230; // %90 opacity - Çok koyu

  // ÖZEL DURUMLAR İÇİN
  static const int disabled = 128; // %50 opacity (disabled state)
  static const int hint = 179; // %70 opacity (hint text)
  static const int border = 77; // %30 opacity (border)
  static const int overlay = 179; // %70 opacity (overlay/backdrop)
  static const int tooltip = 230; // %90 opacity (tooltip)

  // MATERIAL DESIGN SABİTLERİ (isteğe bağlı)
  static const int materialDisabled = 38; // Material %15
  static const int materialHover = 4; // Material %1.5 (hover)
  static const int materialFocus = 12; // Material %5 (focus)
  static const int materialPressed = 12; // Material %5 (pressed)
  static const int materialDragged = 8; // Material %3 (dragged)

  // OPACITY'TEN ALPHA'YA DÖNÜŞÜM METODLARI
  /// Opacity değerini (0.0-1.0) alpha değerine (0-255) çevirir
  static int fromOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity 0.0-1.0 arasında olmalı');
    return (opacity * 255).round();
  }

  /// Yüzde değerini (%0-%100) alpha değerine (0-255) çevirir
  static int fromPercent(int percent) {
    assert(percent >= 0 && percent <= 100, 'Percent 0-100 arasında olmalı');
    return (percent / 100 * 255).round();
  }

  // KOLAY ERİŞİM İÇİN GETTER'LAR
  /// %12 opacity - Çok hafif şeffaflık
  static int get veryLightOpacity => veryLight;

  /// %25 opacity - Hafif şeffaflık
  static int get lightOpacity => light;

  /// %50 opacity - Orta şeffaflık
  static int get mediumOpacity => medium;

  /// %70 opacity - Belirgin şeffaflık
  static int get mediumDarkOpacity => mediumDark;

  /// %80 opacity - Koyu şeffaflık
  static int get darkOpacity => dark;
}

/// ALPHA DEĞERLERİ EXTENSION'LARI
///
/// Color sınıfına kolaylık metodları ekler
extension AlphaExtensions on Color {
  /// %12 opacity ile renk döndürür (çok hafif)
  Color get veryLight => withAlpha(AlphaValues.veryLight);

  /// %25 opacity ile renk döndürür (hafif)
  Color get light => withAlpha(AlphaValues.light);

  /// %30 opacity ile renk döndürür (orta hafif)
  Color get mediumLight => withAlpha(AlphaValues.mediumLight);

  /// %50 opacity ile renk döndürür (orta)
  Color get medium => withAlpha(AlphaValues.medium);

  /// %70 opacity ile renk döndürür (orta koyu)
  Color get mediumDark => withAlpha(AlphaValues.mediumDark);

  /// %80 opacity ile renk döndürür (koyu)
  Color get dark => withAlpha(AlphaValues.dark);

  /// %90 opacity ile renk döndürür (çok koyu)
  Color get veryDark => withAlpha(AlphaValues.veryDark);

  /// Disabled state için opacity (%50)
  Color get disabled => withAlpha(AlphaValues.disabled);

  /// Hint text için opacity (%70)
  Color get hint => withAlpha(AlphaValues.hint);

  /// Border için opacity (%30)
  Color get border => withAlpha(AlphaValues.border);

  /// Özel opacity değeri ile renk döndürür
  Color withOpacityValue(double opacity) {
    return withAlpha(AlphaValues.fromOpacity(opacity));
  }

  /// Yüzde değeri ile renk döndürür
  Color withPercent(int percent) {
    return withAlpha(AlphaValues.fromPercent(percent));
  }
}
