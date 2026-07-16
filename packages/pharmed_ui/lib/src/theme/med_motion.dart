import 'package:flutter/animation.dart';

// ─────────────────────────────────────────────────────────────────
// MedMotion — Animasyon süre ve eğri sabitleri
// Tüm geçiş süreleri ve curve'ler buradan gelir; hiçbir widget
// inline Duration/Curve tanımlamaz. MedColors/MedRadius ile aynı
// "tek kaynak" felsefesi.
// ─────────────────────────────────────────────────────────────────
abstract final class MedMotion {
  /// 100ms — buton basma geri bildirimi (press-in/out).
  static const Duration instant = Duration(milliseconds: 100);

  /// 150ms — opaklık geçişleri (disabled fade).
  static const Duration quick = Duration(milliseconds: 150);

  /// 180ms — seçilebilir eleman geçişi (chip/segment/toggle renk değişimi).
  static const Duration fast = Duration(milliseconds: 180);

  /// 250ms — panel/segment kayan arkaplan gibi daha belirgin hareketler.
  static const Duration medium = Duration(milliseconds: 250);

  /// Standart geçiş eğrisi — seçim ve vurgu değişimleri.
  static const Curve standard = Curves.fastOutSlowIn;
}
