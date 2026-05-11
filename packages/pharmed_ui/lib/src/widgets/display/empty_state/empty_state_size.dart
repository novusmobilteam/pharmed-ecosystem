import 'package:flutter/material.dart';

/// [EmptyStateWidget] için görsel ölçek seçenekleri.
enum EmptyStateSize {
  /// Tam sayfa veya büyük panel içleri için. (varsayılan)
  ///
  /// İkon kutusu: 64×64, başlık: 14px, aksiyon butonu görünür.
  normal,

  /// Dar panel, liste boşluğu veya dialog içleri için.
  ///
  /// İkon kutusu: 40×40, başlık: 12px, aksiyon butonu gizlenir.
  compact;

  /// Boyuta karşılık gelen görsel ölçüler.
  EmptyStateSizeSpec get spec => switch (this) {
    EmptyStateSize.normal => const EmptyStateSizeSpec(
      padding: EdgeInsets.all(32),
      boxSize: 64,
      iconSize: 28,
      boxRadius: 16,
      titleSize: 14,
      iconBottomGap: 16,
      titleBottomGap: 6,
    ),
    EmptyStateSize.compact => const EmptyStateSizeSpec(
      padding: EdgeInsets.all(20),
      boxSize: 40,
      iconSize: 18,
      boxRadius: 10,
      titleSize: 12,
      iconBottomGap: 10,
      titleBottomGap: 4,
    ),
  };
}

/// [EmptyStateSize] varyantlarına karşılık gelen görsel ölçü değerleri.
///
/// Doğrudan kullanılmaz; [EmptyStateSize.spec] getter'ı üzerinden erişilir.
final class EmptyStateSizeSpec {
  const EmptyStateSizeSpec({
    required this.padding,
    required this.boxSize,
    required this.iconSize,
    required this.boxRadius,
    required this.titleSize,
    required this.iconBottomGap,
    required this.titleBottomGap,
  });

  final EdgeInsets padding;
  final double boxSize;
  final double iconSize;
  final double boxRadius;
  final double titleSize;
  final double iconBottomGap;
  final double titleBottomGap;
}
