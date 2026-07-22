part of 'settings_view.dart';

/// Şimdilik client'ta genel bir ayar yok — section boş bırakıldı, ileride
/// bir ihtiyaç çıkarsa (ör. otomatik bekleme süresi gibi cihaz-lokal bir
/// ayar) buraya eklenecek.
class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(context.l10n.settingsView_sectionComingSoon, style: MedTextStyles.bodyLg(color: MedColors.text3)),
      ),
    );
  }
}
