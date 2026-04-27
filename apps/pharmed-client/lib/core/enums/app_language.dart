import 'dart:ui';

enum AppLanguage {
  turkish('tr'),
  english('en'),
  arabic('ar');

  const AppLanguage(this.code);
  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.turkish);
}
