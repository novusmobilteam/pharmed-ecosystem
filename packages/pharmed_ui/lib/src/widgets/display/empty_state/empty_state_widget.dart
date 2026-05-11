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
/// ## Örnekler
///
/// ```dart
/// // Önceden tanımlı varyant
/// EmptyStateWidget(variant: EmptyStateVariant.cabinData)
///
/// // Compact mod
/// EmptyStateWidget(
///   variant: EmptyStateVariant.noResults,
///   size: EmptyStateSize.compact,
/// )
///
/// // Özel içerik
/// EmptyStateWidget(
///   variant: EmptyStateVariant.custom,
///   icon: PhosphorIcons.wifiSlash(),
///   title: 'Bağlantı yok',
///   description: 'Lütfen ağ bağlantınızı kontrol edin.',
/// )
///
/// // Aksiyonlu
/// EmptyStateWidget(
///   variant: EmptyStateVariant.noPatient,
///   action: MedButton.primary(label: 'Hasta Seç', onPressed: _pick),
/// )
/// ```
///
/// ## Yeni senaryo ekleme
///
/// Widget dosyasına dokunmak gerekmez. Sırasıyla:
/// 1. [EmptyStateVariant]'a yeni değeri ekle.
/// 2. [EmptyStateResolver.resolve] switch'ine karşılık gelen içeriği ekle.
/// 3. `.arb` dosyalarına lokalizasyon key'lerini ekle.
///
/// ## Konum
///
/// `pharmed_ui/lib/src/widgets/display/empty_state/`
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

    return Center(
      child: Padding(
        padding: spec.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconBox(icon: content.icon, spec: spec),
            SizedBox(height: spec.iconBottomGap),
            Text(
              content.title,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: spec.titleSize,
                fontWeight: FontWeight.w700,
                color: MedColors.text2,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spec.titleBottomGap),
            Text(
              content.description,
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            if (action != null && size == EmptyStateSize.normal) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.spec});

  final IconData icon;
  final EmptyStateSizeSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spec.boxSize,
      height: spec.boxSize,
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: BorderRadius.circular(spec.boxRadius),
        border: Border.all(color: MedColors.border, width: 1.5),
      ),
      child: Icon(icon, size: spec.iconSize, color: MedColors.text3),
    );
  }
}
