// lib/features/settings/presentation/widgets/language_selector_view.dart
//
// [SWREQ-UI-SETTINGS-002] [IEC 62304 §5.5]
// Genel ayarlar paneli — dil seçimi.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/enums/app_language.dart';
import '../notifier/settings_notifier.dart';

class LanguageSelectorView extends ConsumerWidget {
  const LanguageSelectorView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(settingsNotifierProvider.select((s) => s.language));
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.settings_languageTitle, style: MedTextStyles.monoXs(color: MedColors.text3)),
          const SizedBox(height: 4),
          Text(context.l10n.settings_languageSubtitle, style: MedTextStyles.bodySm(color: MedColors.text3)),
          const SizedBox(height: 16),
          ...AppLanguage.values.map(
            (lang) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _LangRow(lang: lang, isSelected: lang == current, onTap: () => notifier.setLanguage(lang)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  const _LangRow({required this.lang, required this.isSelected, required this.onTap});

  final AppLanguage lang;
  final bool isSelected;
  final VoidCallback onTap;

  String get _nativeName => switch (lang) {
    AppLanguage.turkish => 'Türkçe',
    AppLanguage.english => 'English',
    AppLanguage.arabic => 'العربية',
  };

  String get _code => switch (lang) {
    AppLanguage.turkish => 'TR',
    AppLanguage.english => 'EN',
    AppLanguage.arabic => 'AR',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface2,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border),
          borderRadius: MedRadius.smAll,
        ),
        child: Row(
          children: [
            // Dil adı + kod
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _nativeName,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? MedColors.blue : MedColors.text,
                    ),
                  ),
                  Text(
                    _code,
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: isSelected ? MedColors.blue.withAlpha(178) : MedColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            // Check
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
