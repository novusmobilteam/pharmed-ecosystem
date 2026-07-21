// [IEC 62304 Class B]
// BuildContext'e erişimi olmayan sınıflar (ChangeNotifier, servis) için
// yerelleştirme çözümleyici. MaterialApp'in varsayılan locale çözümleme
// davranışını (cihaz dili desteklenmiyorsa ilk desteklenen locale'e düşme)
// taklit eder.

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Uygulama genelinde aktif locale. MaterialApp locale değiştiğinde
/// [setCurrentLocale] ile güncellenir.
Locale _currentLocale = const Locale('tr');

void setCurrentLocale(Locale locale) {
  _currentLocale = locale;
}

/// Resolves [AppLocalizations] without a [BuildContext]. Intended for
/// non-widget classes (ChangeNotifiers, services) that need a localized
/// fallback string and have no access to a [BuildContext].
AppLocalizations contextlessL10n() {
  const supportedCodes = ['tr', 'en', 'fr'];
  final code = _currentLocale.languageCode;
  final resolved = supportedCodes.contains(code) ? code : 'tr';
  return lookupAppLocalizations(Locale(resolved));
}
