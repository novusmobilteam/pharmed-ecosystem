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
          title: _l10n.emptyState_cabinDataTitle,
          description: _l10n.emptyState_cabinDataDescription,
        ),
        EmptyStateVariant.noResults => EmptyStateContent(
          icon: PhosphorIcons.magnifyingGlass(),
          title: _l10n.emptyState_noResultsTitle,
          description: _l10n.emptyState_noResultsDescription,
        ),
        EmptyStateVariant.noCellSelected => EmptyStateContent(
          icon: PhosphorIcons.gridFour(),
          title: _l10n.emptyState_noCellSelectedTitle,
          description: _l10n.emptyState_noCellSelectedDescription,
        ),
        EmptyStateVariant.noPatient => EmptyStateContent(
          icon: PhosphorIcons.userFocus(),
          title: _l10n.emptyState_noPatientTitle,
          description: _l10n.emptyState_noPatientDescription,
        ),
        EmptyStateVariant.noPrescription => EmptyStateContent(
          icon: PhosphorIcons.receipt(),
          title: _l10n.emptyState_noPrescriptionTitle,
          description: _l10n.emptyState_noPrescriptionDescription,
        ),
        EmptyStateVariant.noCabin => EmptyStateContent(
          icon: PhosphorIcons.dresser(),
          title: _l10n.emptyState_noCabinTitle,
          description: _l10n.emptyState_noCabinDescription,
        ),
        EmptyStateVariant.networkError => EmptyStateContent(
          icon: PhosphorIcons.wifiSlash(),
          title: _l10n.emptyState_networkErrorTitle,
          description: _l10n.emptyState_networkErrorDescription,
        ),
        EmptyStateVariant.serverError => EmptyStateContent(
          icon: PhosphorIcons.cloudSlash(),
          title: _l10n.emptyState_serverErrorTitle,
          description: _l10n.emptyState_serverErrorDescription,
        ),
        EmptyStateVariant.error => EmptyStateContent(
          icon: PhosphorIcons.warningCircle(),
          title: _l10n.emptyState_errorTitle,
          description: _l10n.emptyState_errorDescription,
        ),
        EmptyStateVariant.custom => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: title ?? '',
          description: description ?? '',
        ),
        EmptyStateVariant.noRefundableDrugs => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.refund_noRefundableDrugs,
          description: '',
        ),

        EmptyStateVariant.refund_selectPatient => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.refund_selectPatient,
          description: '',
        ),

        EmptyStateVariant.noWastableDrugs => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.waste_noWastableDrugs,
          description: '',
        ),

        EmptyStateVariant.waste_selectPatient => EmptyStateContent(
          icon: icon ?? PhosphorIcons.info(),
          title: _l10n.waste_selectPatient,
          description: '',
        ),

        EmptyStateVariant.noData => EmptyStateContent(
          icon: PhosphorIcons.tray(),
          title: _l10n.emptyState_noDataTitle,
          description: _l10n.emptyState_noDataDescription,
        ),
        EmptyStateVariant.noPatientSelected => EmptyStateContent(
          icon: PhosphorIcons.userList(),
          title: _l10n.emptyState_noPatientSelectedTitle,
          description: _l10n.emptyState_noPatientSelectedDescription,
        ),
      };
}
