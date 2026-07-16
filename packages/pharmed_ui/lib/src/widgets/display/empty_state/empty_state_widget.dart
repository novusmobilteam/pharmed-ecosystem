import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

export 'empty_state_resolver.dart' show EmptyStateContent;
export 'empty_state_size.dart';
export 'empty_state_variant.dart';

/// Veri bulunamadığında veya bir bağlam henüz oluşmadığında gösterilen
/// genel boş durum bileşeni.
///
/// `pharmed-client` ve `pharmed-manager` uygulamalarında ortak kullanılır.
///
/// ## Boyut
///
/// [size] parametresiyle iki görsel ölçek arasında geçiş yapılır:
///
/// - [EmptyStateSize.normal] — tam sayfa veya büyük panel içleri (varsayılan)
/// - [EmptyStateSize.compact] — dar panel, liste boşluğu veya dialog içleri
///
/// ## Varyant
///
/// [EmptyStateVariant] ile önceden tanımlı senaryolar seçilir.
/// Tüm senaryolar lokalizedir. Özel içerik için [EmptyStateVariant.custom]
/// kullanılır; bu durumda [icon], [title] ve [description] doldurulmalıdır.
///
/// ## Aksiyon butonu
///
/// [action] ile isteğe bağlı bir eylem widget'ı eklenebilir.
/// Yalnızca [EmptyStateSize.normal] modunda gösterilir.
///
/// ## Yeni senaryo ekleme
///
/// Widget dosyasına dokunmak gerekmez. Sırasıyla:
/// 1. [EmptyStateVariant]'a yeni değeri ekle.
/// 2. [EmptyStateResolver.resolve] switch'ine karşılık gelen içeriği ekle.
/// 3. `.arb` dosyalarına lokalizasyon key'lerini ekle.
///
/// Sınıf: Class B
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.variant = EmptyStateVariant.custom,
    this.size = EmptyStateSize.normal,
    this.icon,
    this.title,
    this.description,
    this.action,
  });

  /// Görüntülenecek senaryo. Varsayılan: [EmptyStateVariant.custom].
  final EmptyStateVariant variant;

  /// Görsel ölçek. Varsayılan: [EmptyStateSize.normal].
  final EmptyStateSize size;

  /// [EmptyStateVariant.custom] için ikon. Diğer varyantlarda yoksayılır.
  final IconData? icon;

  /// [EmptyStateVariant.custom] için başlık. Diğer varyantlarda yoksayılır.
  final String? title;

  /// [EmptyStateVariant.custom] için açıklama. Diğer varyantlarda yoksayılır.
  final String? description;

  /// İsteğe bağlı aksiyon widget'ı (genellikle [MedButton]).
  ///
  /// Yalnızca [EmptyStateSize.normal] modunda gösterilir.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final content = EmptyStateResolver(
      context.l10n,
    ).resolve(variant, icon: icon, title: title, description: description);
    final spec = size.spec;

    final hasDescription = content.description.isNotEmpty;

    return Center(
      child: Padding(
        padding: spec.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // FIX: content.icon kullanılıyor — preset varyantların ikonu
            // artık görünüyor (önceden widget.icon'du, sadece custom'da doluydu).
            Icon(content.icon, size: spec.iconSize, color: MedColors.text3),
            SizedBox(height: spec.iconBottomGap),
            Text(
              content.title,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: spec.titleSize,
                fontWeight: FontWeight.w700,
                color: MedColors.text2,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasDescription) ...[
              SizedBox(height: spec.titleBottomGap),
              Text(
                content.description,
                style: MedTextStyles.bodySm(color: MedColors.text3),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null && size == EmptyStateSize.normal) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
