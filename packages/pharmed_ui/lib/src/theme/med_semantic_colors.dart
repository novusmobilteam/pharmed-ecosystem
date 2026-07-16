import 'package:flutter/material.dart';

import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedSemanticColors — semantic durum → token renk demeti (TEK KAYNAK)
//
// Şu ana kadar aynı eşleme DÖRT yerde ayrı ayrı yazılmıştı:
//   MedChipStyle, BannerTone, ItemCardColors, StatusBadge
// Hepsi "error/warning/info/success/neutral → (bg, fg)" yapıyordu ama
// üç farklı alpha ile (0.22 / 0.4 / 0.3-0.8). Bu, ayrı ayrı yazıldıkları
// için oluşan tutarsızlıktı.
//
// Artık renk KAYNAĞI tek: MedSemanticColors.of(tone). Alpha'yı her
// tüketici kendi ihtiyacına göre verir (border/muted türetimi), böylece
// mevcut görseller korunur ama base renkler tek yerden gelir.
// ─────────────────────────────────────────────────────────────────

/// Semantik durum tonu. Tüm "durum rengi" ihtiyaçlarının ortak dili.
enum MedTone { error, warning, info, success, neutral }

/// Bir [MedTone] için token renk demeti.
@immutable
class MedSemanticColors {
  const MedSemanticColors({required this.background, required this.foreground});

  /// Açık zemin (…Light token'ı).
  final Color background;

  /// Vurgu/metin (ana ton token'ı).
  final Color foreground;

  /// Kenarlık rengi — foreground'un [alpha] şeffafı. Tüketici alpha'yı seçer.
  Color border({double alpha = 0.3}) => foreground.withValues(alpha: alpha);

  /// Soluk metin rengi — foreground'un [alpha] şeffafı (ItemCard "muted").
  Color muted({double alpha = 0.8}) => foreground.withValues(alpha: alpha);

  /// Tek kaynak: ton → token renk demeti.
  static MedSemanticColors of(MedTone tone) => switch (tone) {
    MedTone.error => const MedSemanticColors(background: MedColors.redLight, foreground: MedColors.red),
    MedTone.warning => const MedSemanticColors(background: MedColors.amberLight, foreground: MedColors.amber),
    MedTone.info => const MedSemanticColors(background: MedColors.blueLight, foreground: MedColors.blue),
    MedTone.success => const MedSemanticColors(background: MedColors.greenLight, foreground: MedColors.green),
    MedTone.neutral => const MedSemanticColors(background: MedColors.surface3, foreground: MedColors.text3),
  };
}
