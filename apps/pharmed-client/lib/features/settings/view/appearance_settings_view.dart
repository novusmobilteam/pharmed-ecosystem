part of 'settings_view.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<SettingsNotifier>();

    return MedLanguageSelector(
      title: context.l10n.settings_languageTitle,
      languages: AppLanguage.values,
      selected: notifier.language,
      onChanged: notifier.setLanguage,
    );
  }
}
