// [SWREQ-CORE-L10N-001] Localization extension helpers
// Provides ergonomic access to AppLocalizations and localized labels
// for domain enums used in the presentation layer.

import 'package:flutter/widgets.dart';
import 'package:pharmed_client/gen_l10n/app_localizations.dart';
import 'package:pharmed_client/features/setup_wizard/domain/model/cabin_setup_config.dart';

/// Shorthand: `context.l10n.btnContinue`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Localized label for [CabinetType] — use in presentation layer only.
extension CabinetTypeL10n on CabinetType {
  String localizedLabel(BuildContext context) => switch (this) {
        CabinetType.standard => context.l10n.cabinetTypeStandard,
        CabinetType.mobile => context.l10n.cabinetTypeMobile,
      };
}

/// Localized label for [DrawerType] — use in presentation layer only.
extension DrawerTypeL10n on DrawerType {
  String localizedLabel(BuildContext context) => switch (this) {
        DrawerType.cubic4x4 => context.l10n.drawerTypeCubic4x4,
        DrawerType.cubic4x5 => context.l10n.drawerTypeCubic4x5,
        DrawerType.unitDose => context.l10n.drawerTypeUnitDose,
      };
}
