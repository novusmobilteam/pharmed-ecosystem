/// Ayarlar modal'ındaki section kimlikleri. Hem `SettingsNotifier`
/// (activeSectionId state'i) hem de `SettingsView` (nav item id + content
/// switch) tarafından kullanılır — tek yerden yönetilir ki iki taraf
/// birbirinden bağımsız yanlış string yazmasın.
abstract final class SettingsSectionIds {
  static const general = 'general';
  static const appearance = 'appearance';
  static const cabin = 'cabin';
  static const prescription = 'prescription';
  static const developer = 'developer';
  static const debug = 'debug';
}
