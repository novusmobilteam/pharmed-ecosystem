part of 'settings_view.dart';

class AppearanceSettingsView extends ConsumerWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return MedLanguageSelector(
      title: context.l10n.settings_languageTitle,
      languages: AppLanguage.values,
      selected: state.language,
      onChanged: notifier.setLanguage,
    );
  }
}
