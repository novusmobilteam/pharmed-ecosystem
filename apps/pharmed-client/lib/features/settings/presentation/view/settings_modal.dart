// lib/features/settings/presentation/widgets/settings_modal.dart
//
// [SWREQ-UI-SETTINGS-001] [IEC 62304 §5.5]
// Ayarlar modal — sol sidebar + içerik paneli.
// Debug bölümü sadece kDebugMode'da görünür.
// Sınıf: Class A

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_client/features/settings/presentation/state/settings_state.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/settings_notifier.dart';
import 'debug_settings_view.dart';
import 'language_selector_view.dart';

part 'settings_sidebar.dart';

void showSettingsModal(BuildContext context) {
  showDialog<void>(context: context, barrierColor: Colors.black.withAlpha(56), builder: (_) => const _SettingsDialog());
}

class _SettingsDialog extends ConsumerWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 520),
        child: Container(
          decoration: BoxDecoration(
            color: MedColors.surface,
            border: Border.all(color: MedColors.border),
            borderRadius: MedRadius.lgAll,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModalHeader(onClose: () => Navigator.of(context).pop()),
              const Expanded(child: _ModalBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.settings_title,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: MedColors.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                context.l10n.settings_systemConfigTitle,
                style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.8),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: MedColors.border),
                borderRadius: MedRadius.smAll,
              ),
              child: Icon(Icons.close_rounded, size: 14, color: MedColors.text2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalBody extends ConsumerWidget {
  const _ModalBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsSidebar(activeSection: state.activeSection, onSectionTap: notifier.setSection),
        const VerticalDivider(width: 1, thickness: 1, color: MedColors.border2),
        Expanded(child: _buildContent(context, state)),
      ],
    );
  }

  Widget _buildContent(BuildContext context, SettingsState state) {
    return switch (state.activeSection) {
      SettingsSection.debug => const DebugSettingsView(),
      //SettingsSection.general => _PlaceholderView(label: context.l10n.settings_generalLabel),
      SettingsSection.appearance => _PlaceholderView(label: context.l10n.settings_appearanceLabel),
      SettingsSection.general => const LanguageSelectorView(),
    };
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label ayarları yakında',
        style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
      ),
    );
  }
}
