import 'package:flutter/material.dart';
import 'package:pharmed_ui/src/l10n/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'empty_state_variant.dart';

/// Çözümlenmiş boş durum içeriği.
///
/// [EmptyStateResolver.resolve] tarafından üretilir ve
/// [EmptyStateWidget] tarafından tüketilir.
final class EmptyStateContent {
  const EmptyStateContent({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}

/// [EmptyStateVariant] değerlerini lokalize [EmptyStateContent]'e çevirir.
///
/// Widget katmanını lokalizasyon bağımlılığından ayırmak için
/// [EmptyStateWidget] dışında tutulur. Yeni bir varyant eklendiğinde
/// yalnızca bu dosya güncellenir.
///
/// ## Kullanım
///
/// Doğrudan kullanılmaz; [EmptyStateWidget] tarafından içsel olarak
/// çağrılır:
///
/// ```dart
/// final content = EmptyStateResolver(l10n).resolve(variant);
/// ```
///
/// ## Yeni varyant ekleme
///
/// 1. [EmptyStateVariant]'a yeni değeri ekle.
/// 2. `resolve` switch'ine karşılık gelen `EmptyStateContent`'i ekle.
/// 3. `.arb` dosyalarına lokalizasyon key'lerini ekle.
final class EmptyStateResolver {
  const EmptyStateResolver(this._l10n);

  final AppLocalizations _l10n;

  /// [variant] için lokalize [EmptyStateContent] döndürür.
  ///
  /// [EmptyStateVariant.custom] kullanıldığında [icon], [title] ve
  /// [description] parametreleri zorunludur; eksik gelenler varsayılan
  /// değerlerle doldurulur.
  EmptyStateContent resolve(EmptyStateVariant variant, {IconData? icon, String? title, String? description}) =>
      switch (variant) {
        EmptyStateVariant.cabinData => EmptyStateContent(
          icon: PhosphorIcons.dresser(),
          title: _l10n.emptyStateCabinDataTitle,
          description: _l10n.emptyStateCabinDataDescription,
        ),
        EmptyStateVariant.noResults => EmptyStateContent(
          icon: PhosphorIcons.magnifyingGlass(),
          title: _l10n.emptyStateNoResultsTitle,
          description: _l10n.emptyStateNoResultsDescription,
        ),
        EmptyStateVariant.noCellSelected => EmptyStateContent(
          icon: PhosphorIcons.gridFour(),
          title: _l10n.emptyStateNoCellSelectedTitle,
          description: _l10n.emptyStateNoCellSelectedDescription,
        ),
        EmptyStateVariant.noPatient => EmptyStateContent(
          icon: PhosphorIcons.userFocus(),
          title: _l10n.emptyStateNoPatientTitle,
          description: _l10n.emptyStateNoPatientDescription,
        ),
        EmptyStateVariant.noPrescription => EmptyStateContent(
          icon: PhosphorIcons.receipt(),
          title: _l10n.emptyStateNoPrescriptionTitle,
          description: _l10n.emptyStateNoPrescriptionDescription,
        ),
        EmptyStateVariant.noCabin => EmptyStateContent(
          icon: PhosphorIcons.dresser(),
          title: _l10n.emptyStateNoCabinTitle,
          description: _l10n.emptyStateNoCabinDescription,
        ),
        EmptyStateVariant.networkError => EmptyStateContent(
          icon: PhosphorIcons.wifiSlash(),
          title: _l10n.emptyStateNetworkErrorTitle,
          description: _l10n.emptyStateNetworkErrorDescription,
        ),
        EmptyStateVariant.serverError => EmptyStateContent(
          icon: PhosphorIcons.cloudSlash(),
          title: _l10n.emptyStateServerErrorTitle,
          description: _l10n.emptyStateServerErrorDescription,
        ),
        EmptyStateVariant.error => EmptyStateContent(
          icon: PhosphorIcons.warningCircle(),
          title: _l10n.emptyStateErrorTitle,
          description: _l10n.emptyStateErrorDescription,
        ),
        EmptyStateVariant.custom => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: title ?? '',
          description: description ?? '',
        ),
        EmptyStateVariant.noRefundableDrugs => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.refundNoRefundableDrugs,
          description: '',
        ),

        EmptyStateVariant.refundSelectPatient => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.refundSelectPatient,
          description: '',
        ),
      };
}
