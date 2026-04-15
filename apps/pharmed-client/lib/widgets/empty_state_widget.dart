// Veri bulunamadığında gösterilen genel boş durum bileşeni.
// Farklı senaryolar için [EmptyStateVariant] ile özelleştirilebilir.
//
// KULLANIM:
//   EmptyStateWidget(variant: EmptyStateVariant.cabinData)
//
//   EmptyStateWidget(
//     variant: EmptyStateVariant.custom,
//     icon: Icons.search_off,
//     title: 'Sonuç bulunamadı',
//     description: 'Arama kriterlerinizi değiştirmeyi deneyin.',
//   )
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum EmptyStateVariant {
  /// Kabin verisi henüz yüklenmemiş veya bulunamadı
  cabinData,

  /// Arama/filtre sonucu boş
  noResults,

  /// Genel / özel kullanım — icon, title, description zorunlu
  custom,
}

/// Veri bulunamadığında gösterilen genel boş durum bileşeni.
///
/// [variant] parametresine göre varsayılan içerik üretilir.
/// [variant] == [EmptyStateVariant.custom] ise [icon], [title],
/// [description] parametreleri zorunludur.
///
/// [action] opsiyonel — "Yenile" gibi butonlar için kullanılır.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.variant = EmptyStateVariant.custom,
    this.icon,
    this.title,
    this.description,
    this.action,
  });

  final EmptyStateVariant variant;
  final IconData? icon;
  final String? title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final resolved = _resolve();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon konteyner
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: MedColors.surface3,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MedColors.border, width: 1.5),
              ),
              child: Icon(resolved.icon, size: 28, color: MedColors.text3),
            ),
            const SizedBox(height: 16),

            // Başlık
            Text(
              resolved.title,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: MedColors.text2,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Açıklama
            Text(
              resolved.description,
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),

            // Aksiyon
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }

  _ResolvedContent _resolve() => switch (variant) {
    EmptyStateVariant.cabinData => const _ResolvedContent(
      icon: Icons.inventory_2_outlined,
      title: 'Kabin verisi bulunamadı',
      description: 'Kabin henüz yapılandırılmamış olabilir\nveya bağlantı kurulamadı.',
    ),
    EmptyStateVariant.noResults => const _ResolvedContent(
      icon: Icons.search_off_rounded,
      title: 'Sonuç bulunamadı',
      description: 'Arama kriterlerinizi değiştirmeyi deneyin.',
    ),
    EmptyStateVariant.custom => _ResolvedContent(
      icon: icon ?? Icons.info_outline_rounded,
      title: title ?? '',
      description: description ?? '',
    ),
  };
}

final class _ResolvedContent {
  const _ResolvedContent({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}
