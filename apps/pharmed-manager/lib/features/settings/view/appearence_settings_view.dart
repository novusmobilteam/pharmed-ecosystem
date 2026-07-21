part of 'settings_view.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsSectionPlaceholder();
  }
}

/// Henüz içeriği yazılmamış section'lar için ortak yer tutucu.
/// Her section kendi dosyasına geçtikçe burası tek tek kaldırılacak.
class _SettingsSectionPlaceholder extends StatelessWidget {
  const _SettingsSectionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          context.l10n.settingsView_sectionComingSoon,
          style: MedTextStyles.bodyLg().copyWith(color: MedColors.text3),
        ),
      ),
    );
  }
}
