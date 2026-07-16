import 'package:flutter/material.dart';

/// [EmptyStateWidget] için görsel ölçek seçenekleri.
enum EmptyStateSize {
  /// Tam sayfa veya büyük panel içleri için. (varsayılan)
  ///
  /// İkon: 28px, başlık: 14px, aksiyon butonu görünür.
  normal,

  /// Dar panel, liste boşluğu veya dialog içleri için.
  ///
  /// İkon: 18px, başlık: 12px, aksiyon butonu gizlenir.
  compact;

  /// Boyuta karşılık gelen görsel ölçüler.
  EmptyStateSizeSpec get spec => switch (this) {
    EmptyStateSize.normal => const EmptyStateSizeSpec(
      padding: EdgeInsets.all(32),
      iconSize: 28,
      titleSize: 14,
      iconBottomGap: 16,
      titleBottomGap: 6,
    ),
    EmptyStateSize.compact => const EmptyStateSizeSpec(
      padding: EdgeInsets.all(20),
      iconSize: 18,
      titleSize: 12,
      iconBottomGap: 10,
      titleBottomGap: 4,
    ),
  };
}

/// [EmptyStateSize] varyantlarına karşılık gelen görsel ölçü değerleri.
///
/// Doğrudan kullanılmaz; [EmptyStateSize.spec] getter'ı üzerinden erişilir.
///
/// NOT: Eski sürümdeki `boxSize`/`boxRadius` alanları kaldırıldı — widget
/// ikonu bir kutu içinde değil düz çiziyor, bu alanlar hiç kullanılmıyordu.
final class EmptyStateSizeSpec {
  const EmptyStateSizeSpec({
    required this.padding,
    required this.iconSize,
    required this.titleSize,
    required this.iconBottomGap,
    required this.titleBottomGap,
  });

  final EdgeInsets padding;
  final double iconSize;
  final double titleSize;

  /// İkon ile başlık arası boşluk.
  final double iconBottomGap;

  /// Başlık ile açıklama arası boşluk.
  final double titleBottomGap;
}
