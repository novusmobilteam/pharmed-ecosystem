import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../notifier/section_ids.dart';
import '../notifier/settings_notifier.dart';

part 'general_settings_view.dart';
part 'prescription_settings_view.dart';
part 'appearence_settings_view.dart';

/// Manager tarafında Ayarlar modal'ını açan giriş noktası.
///
/// Kabuk (`MedSettingsModal`) pharmed_ui'da yaşıyor ve state-management
/// bilmiyor; burada yaptığımız tek şey onu `SettingsNotifier` (Provider) ile
/// bağlamak. Client tarafı aynı kabuğu kendi Riverpod notifier'ıyla,
/// muhtemelen aynı şablonla ama ayrı bir dosyada bağlayacak.
class SettingsView {
  const SettingsView._();

  static Future<void> show(BuildContext context) {
    return MedSettingsModal.show(context, builder: (context) => const _SettingsModalBody());
  }
}

class _SettingsModalBody extends StatefulWidget {
  const _SettingsModalBody();

  static List<MedSettingsNavGroup> _navGroups(BuildContext context) {
    return [
      MedSettingsNavGroup(
        items: [
          MedSettingsNavItem(
            id: SettingsSectionIds.general,
            label: context.l10n.settingsView_generalNav,
            icon: PhosphorIcons.house(),
          ),
          MedSettingsNavItem(
            id: SettingsSectionIds.appearance,
            label: context.l10n.settingsView_appearanceNav,
            icon: PhosphorIcons.slidersHorizontal(),
          ),
        ],
      ),
      MedSettingsNavGroup(
        items: [
          MedSettingsNavItem(
            id: SettingsSectionIds.cabin,
            label: context.l10n.settingsView_cabinNav,
            icon: PhosphorIcons.dresser(),
          ),
          MedSettingsNavItem(
            id: SettingsSectionIds.prescription,
            label: context.l10n.settingsView_prescriptionNav,
            icon: PhosphorIcons.prescription(),
          ),
        ],
      ),

      // Debug section sadece debug build'lerde görünür.
      if (kDebugMode)
        MedSettingsNavGroup(
          items: [
            MedSettingsNavItem(
              id: SettingsSectionIds.debug,
              label: context.l10n.settingsView_debugNav,
              icon: Icons.bug_report_outlined,
              badge: const MedSettingsNavBadge(text: 'DEV', color: MedColors.amber, background: MedColors.amberLight),
            ),
          ],
        ),
    ];
  }

  static Widget _content(String sectionId) {
    return switch (sectionId) {
      SettingsSectionIds.general => const GeneralSettingsView(),
      SettingsSectionIds.cabin => const AppearanceSettingsView(),
      SettingsSectionIds.appearance => const AppearanceSettingsView(),
      SettingsSectionIds.prescription => const PrescriptionSettingsView(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  State<_SettingsModalBody> createState() => _SettingsModalBodyState();
}

class _SettingsModalBodyState extends State<_SettingsModalBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final settings = context.read<SettingsNotifier>();
      settings.discardChanges();
      settings.getSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsNotifier>();

    return MedSettingsModal(
      title: context.l10n.settingsView_title,
      subtitle: context.l10n.settingsView_subtitle,
      navGroups: _SettingsModalBody._navGroups(context),
      activeSectionId: settings.activeSectionId,
      onSectionSelected: settings.goToSection,
      content: _SettingsModalBody._content(settings.activeSectionId),
      onClose: () => Navigator.of(context).pop(),
      isDirty: settings.isDirty,
      onCancel: () {
        settings.discardChanges();
        Navigator.of(context).pop();
      },
      onSave: () {
        settings.saveAllChanges(
          onSuccess: (_) {
            MessageUtils.showSuccessSnackbar(context, context.l10n.common_defaultSuccessMessage);
          },
          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
        );
      },
    );
  }
}
