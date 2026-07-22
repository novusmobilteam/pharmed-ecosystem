import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/settings_notifier.dart';
import '../notifier/settings_state.dart';

part 'general_settings_view.dart';
part 'appearance_settings_view.dart';
part 'debug_settings_view.dart';

/// Client tarafında Ayarlar modal'ını açan giriş noktası.
/// Kabuk manager ile birebir aynı (`MedSettingsModal`, pharmed_ui) — burada
/// tek fark bağlama katmanı: Provider değil, Riverpod.
class SettingsView {
  const SettingsView._();

  static Future<void> show(BuildContext context) {
    return MedSettingsModal.show(context, barrierLabel: 'Ayarlar', builder: (context) => const _SettingsModalBody());
  }
}

class _SettingsModalBody extends ConsumerWidget {
  const _SettingsModalBody();

  static List<MedSettingsNavGroup> _navGroups(BuildContext context) {
    return [
      MedSettingsNavGroup(
        items: [
          MedSettingsNavItem(
            id: SettingsSection.general.name,
            label: context.l10n.settingsView_generalNav,
            icon: PhosphorIcons.house(),
          ),
          MedSettingsNavItem(
            id: SettingsSection.appearance.name,
            label: context.l10n.settingsView_appearanceNav,
            icon: PhosphorIcons.slidersHorizontal(),
          ),
        ],
      ),
      // Debug section sadece debug build'lerde görünür (DebugSettingsView
      // içindeki assert(kDebugMode) ile de tutarlı).
      if (kDebugMode)
        MedSettingsNavGroup(
          items: [
            MedSettingsNavItem(
              id: SettingsSection.debug.name,
              label: context.l10n.settingsView_debugNav,
              icon: PhosphorIcons.bug(),
              badge: MedSettingsNavBadge(text: 'DEV', color: MedColors.amber, background: MedColors.amberLight),
            ),
          ],
        ),
    ];
  }

  static Widget _content(SettingsSection section) {
    return switch (section) {
      SettingsSection.general => const GeneralSettingsView(),
      SettingsSection.appearance => const AppearanceSettingsView(),
      SettingsSection.debug => const DebugSettingsView(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return MedSettingsModal(
      title: context.l10n.settingsView_title,
      subtitle: context.l10n.settingsView_subtitle,
      navGroups: _navGroups(context),
      activeSectionId: state.activeSection.name,
      onSectionSelected: (id) => notifier.setSection(SettingsSection.values.byName(id)),
      content: _content(state.activeSection),
      onClose: () => Navigator.of(context).pop(),
      // Client'ta henüz taslak/kaydet akışı yok — dil değişikliği zaten
      // setLanguage() içinde anında cache'e yazılıyor. Debug'daki kabin
      // seçimi de kendi notifier metoduyla anında uygulanıyor. Bu yüzden
      // isDirty hep false; Kaydet/İptal ikisi de sadece modal'ı kapatır.
      isDirty: false,
      onCancel: () => Navigator.of(context).pop(),
      onSave: () => Navigator.of(context).pop(),
    );
  }
}
