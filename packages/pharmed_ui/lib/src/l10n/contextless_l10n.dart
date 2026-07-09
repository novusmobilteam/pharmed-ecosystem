// [IEC 62304 Class B]
// BuildContext'e erişimi olmayan sınıflar (ChangeNotifier, servis) için
// yerelleştirme çözümleyici. MaterialApp'in varsayılan locale çözümleme
// davranışını (cihaz dili desteklenmiyorsa ilk desteklenen locale'e düşme)
// taklit eder.

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Resolves [AppLocalizations] without a [BuildContext]. Intended for
/// non-widget classes (ChangeNotifiers, services) that need a localized
/// fallback string and have no access to a [BuildContext].
AppLocalizations contextlessL10n() {
  const supportedLanguageCodes = ['tr', 'en', 'fr', 'ar'];
  final deviceLanguageCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final languageCode = supportedLanguageCodes.contains(deviceLanguageCode) ? deviceLanguageCode : 'tr';
  return lookupAppLocalizations(Locale(languageCode));
}
