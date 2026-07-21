import 'dart:ui';

enum AppLanguage {
  turkish('tr'),
  english('en'),
  french('fr');

  const AppLanguage(this.code);
  final String code;

  Locale get locale => Locale(code);

  /// Dilin kendi dilindeki adı — UI'da her zaman bu gösterilir, l10n'a gerek yok.
  String get nativeName => switch (this) {
    AppLanguage.turkish => 'Türkçe',
    AppLanguage.english => 'English',
    AppLanguage.french => 'Français',
  };

  /// Kısa kod etiketi — mono font ile gösterilir.
  String get displayCode => switch (this) {
    AppLanguage.turkish => 'TR',
    AppLanguage.english => 'EN',
    AppLanguage.french => 'FR',
  };

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.turkish);
}
