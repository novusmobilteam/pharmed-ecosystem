import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

export 'empty_state_resolver.dart' show EmptyStateContent;
export 'empty_state_size.dart';
export 'empty_state_variant.dart';

/// Veri bulunamadığında, bir bağlam henüz oluşmadığında veya bir bölüm
/// yüklenemediğinde gösterilen genel durum bileşeni.
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
/// [EmptyStateVariant] ile önceden tanımlı senaryolar seçilir (boş durumlar
/// ve hata durumları — [EmptyStateVariant.networkError], `serverError`,
/// `error` dahil). Tüm senaryolar lokalizedir. Özel içerik için
/// [EmptyStateVariant.custom] kullanılır; bu durumda [icon], [title] ve
/// [description] doldurulmalıdır.
///
/// ## Yeniden dene
///
/// [onRetry] verilirse bir "yeniden dene" butonu gösterilir. Etiketi
/// [retryLabel] ile verilir (pharmed_ui l10n bilmez):
///
/// - [EmptyStateSize.normal] → içeriğin altında normal buton.
/// - [EmptyStateSize.compact] → ikon + metin ile aynı satırda, sağda compact
///   buton (panel içi hata satırı). Eski `_SectionError` bu moddur.
///
/// [onRetry] ile [action] birlikte verilmemelidir; ikisi de varsa [onRetry]
/// önceliklidir.
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
    this.onRetry,
    this.retryLabel,
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
  /// Yalnızca [EmptyStateSize.normal] modunda ve [onRetry] yokken gösterilir.
  final Widget? action;

  /// Verilirse "yeniden dene" butonu gösterilir. [retryLabel] ile birlikte
  /// kullanılmalıdır.
  final VoidCallback? onRetry;

  /// Yeniden dene butonu etiketi.
  final String? retryLabel;

  bool get _hasRetry => onRetry != null && retryLabel != null;

  @override
  Widget build(BuildContext context) {
    final content = EmptyStateResolver(
      context.l10n,
    ).resolve(variant, icon: icon, title: title, description: description);
    final spec = size.spec;

    // Compact + retry → panel içi yatay hata satırı.
    if (size == EmptyStateSize.compact && _hasRetry) {
      return _CompactErrorRow(content: content, retryLabel: retryLabel!, onRetry: onRetry!);
    }

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
            if (size == EmptyStateSize.normal) ...[
              if (_hasRetry) ...[
                const SizedBox(height: 20),
                MedRetryButton(label: retryLabel!, onTap: onRetry!),
              ] else if (action != null) ...[
                const SizedBox(height: 20),
                action!,
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact + retry: ikon + başlık/açıklama + sağda compact "yeniden dene".
/// Eski dashboard `_SectionError` bileşeninin yerini alır.
class _CompactErrorRow extends StatelessWidget {
  const _CompactErrorRow({required this.content, required this.retryLabel, required this.onRetry});

  final EmptyStateContent content;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasDescription = content.description.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        children: [
          Icon(content.icon, size: 18, color: MedColors.text3),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(content.title, style: MedTextStyles.bodySm(color: MedColors.text3)),
                if (hasDescription) Text(content.description, style: MedTextStyles.monoXs(color: MedColors.text4)),
              ],
            ),
          ),
          const SizedBox(width: MedSpacing.md),
          MedRetryButton(label: retryLabel, onTap: onRetry, compact: true),
        ],
      ),
    );
  }
}
