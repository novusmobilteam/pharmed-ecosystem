import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Client ve manager ayarlarında ortak kullanılan dil seçici.
/// Manager'daki `AppearanceSettingsView._LangRow`'dan çıkarıldı — davranış ve
/// görünüm birebir korunuyor, sadece iki app arasında paylaşılabilir hale
/// getirildi.
class MedLanguageSelector extends StatelessWidget {
  const MedLanguageSelector({
    super.key,
    required this.languages,
    required this.selected,
    required this.onChanged,
    this.title,
  });

  final List<AppLanguage> languages;
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;

  /// Örn. "Dil" — verilmezse başlık gösterilmez, çağıran kendi başlığını
  /// dışarıda basabilir.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: MedTextStyles.titleMd(color: MedColors.text3)),
          const SizedBox(height: 16),
        ],
        for (final lang in languages)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _LanguageOptionRow(language: lang, isSelected: lang == selected, onTap: () => onChanged(lang)),
          ),
      ],
    );
  }
}

class _LanguageOptionRow extends StatelessWidget {
  const _LanguageOptionRow({required this.language, required this.isSelected, required this.onTap});

  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.nativeName,
                    style: MedTextStyles.bodyMd(
                      color: isSelected ? MedColors.blue : MedColors.text,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    language.code,
                    style: MedTextStyles.bodySm(
                      color: isSelected ? MedColors.blue : MedColors.text,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: Icon(PhosphorIcons.checkCircle(), size: 20, color: MedColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
