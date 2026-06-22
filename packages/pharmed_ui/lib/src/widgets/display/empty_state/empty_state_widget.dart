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
    this.card = false, // <-- yeni
  });

  final EmptyStateVariant variant;
  final EmptyStateSize size;
  final IconData? icon;
  final String? title;
  final String? description;
  final Widget? action;

  /// `true` olduğunda boş durum içeriği bir kart yüzeyi (surface + border +
  /// gölge) üzerinde gösterilir. Geniş boş alanlarda daha düzenli görünür.
  final bool card; // <-- yeni

  @override
  Widget build(BuildContext context) {
    final content = EmptyStateResolver(
      context.l10n,
    ).resolve(variant, icon: icon, title: title, description: description);
    final spec = size.spec;

    final inner = Column(
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
        SizedBox(height: spec.titleBottomGap / 2),
        Text(
          content.description,
          style: MedTextStyles.bodyMd(color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
        if (action != null && size == EmptyStateSize.normal) ...[const SizedBox(height: 20), action!],
      ],
    );

    // Kart modu — içeriği surface yüzeyine sar
    if (card) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            margin: const EdgeInsets.all(MedSpacing.xl),
            padding: spec.padding,
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: MedColors.border),
              borderRadius: MedRadius.lgAll,
              boxShadow: MedShadows.sm,
            ),
            child: inner,
          ),
        ),
      );
    }

    // Varsayılan — kartsız
    return Center(
      child: Padding(padding: spec.padding, child: inner),
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
