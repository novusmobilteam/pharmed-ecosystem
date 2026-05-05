import 'package:flutter/material.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../l10n/app_localizations.dart';

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

enum EmptyStateVariant {
  /// Kabin verisi henüz yüklenmemiş veya bulunamadı
  cabinData,

  /// Arama/filtre sonucu boş
  noResults,

  /// Göz seçilmemiş
  noCellSelected,

  /// Göze hasta atanmamış
  noPatient,

  /// Hasta var fakat aktif reçetesi yok
  noPrescription,

  /// Genel / özel kullanım — icon, title, description zorunlu
  custom,
}

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
    final l10n = context.l10n;
    final resolved = _resolve(l10n);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(
              resolved.description,
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }

  _ResolvedContent _resolve(AppLocalizations l10n) => switch (variant) {
    EmptyStateVariant.cabinData => _ResolvedContent(
      icon: Icons.inventory_2_outlined,
      title: l10n.emptyStateCabinDataTitle,
      description: l10n.emptyStateCabinDataDescription,
    ),
    EmptyStateVariant.noResults => _ResolvedContent(
      icon: Icons.search_off_rounded,
      title: l10n.emptyStateNoResultsTitle,
      description: l10n.emptyStateNoResultsDescription,
    ),
    EmptyStateVariant.noCellSelected => _ResolvedContent(
      icon: Icons.grid_view_rounded,
      title: l10n.emptyStateNoCellSelectedTitle,
      description: l10n.emptyStateNoCellSelectedDescription,
    ),
    EmptyStateVariant.noPatient => _ResolvedContent(
      icon: Icons.person_off_outlined,
      title: l10n.emptyStateNoPatientTitle,
      description: l10n.emptyStateNoPatientDescription,
    ),
    EmptyStateVariant.noPrescription => _ResolvedContent(
      icon: Icons.receipt_long_outlined,
      title: l10n.emptyStateNoPrescriptionTitle,
      description: l10n.emptyStateNoPrescriptionDescription,
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
