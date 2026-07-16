import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/usecases.dart';

void main() => runApp(const PharmedWidgetbook());

// ─────────────────────────────────────────────────────────────────
// PharMed Widgetbook — manuel yaklaşım (annotation/code-gen yok).
//
// İki addon senin iki ana problemini doğrudan gözle test ettirir:
//   • ThemeAddon  → MedTheme.client() ↔ MedTheme.manager() geçişi.
//                   "Aynı widget iki temada aynı mı davranıyor?" sorusu
//                   tek tıkla yan yana.
//   • Bu temalar zaten MedDensity extension'ını taşıdığı için, tema
//     değiştirince yoğunluk (48px ↔ 40px) da otomatik değişir.
//
// Yeni widget grubu eklerken: use_cases/ altında bir dosya oluştur,
// aşağıdaki `directories` listesine WidgetbookComponent olarak ekle.
// ─────────────────────────────────────────────────────────────────
class PharmedWidgetbook extends StatelessWidget {
  const PharmedWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        ThemeAddon<ThemeData>(
          themes: [
            WidgetbookTheme(name: 'Client (touch)', data: MedTheme.client()),
            WidgetbookTheme(name: 'Manager (compact)', data: MedTheme.manager()),
          ],
          themeBuilder: (context, theme, child) {
            return Theme(data: theme, child: child);
          },
        ),
        // Katalog gövdesine biraz nefes payı + arka plan.
        BuilderAddon(
          name: 'Padding',
          builder: (context, child) => ColoredBox(
            color: MedColors.bg,
            child: Center(child: Padding(padding: const EdgeInsets.all(24), child: child)),
          ),
        ),
      ],
      directories: [
        WidgetbookCategory(
          name: 'Atoms',
          children: [
            buttonsComponent,
            iconButtonComponent,
            selectableComponent,
            selectableGroupComponent,
            chipComponent,
          ],
        ),
        WidgetbookCategory(
          name: 'Display',
          children: [
            avatarComponent,
            labelComponent,
            badgeComponent,
            emptyStateComponent,
            sidePanelComponent,
            staleBannerComponent,
          ],
        ),
        WidgetbookCategory(
          name: 'Indicators',
          children: [
            dottedDividerComponent,
            loadingComponent,
            progressBarComponent,
            statusBarComponent,
            statusDotComponent,
          ],
        ),
        WidgetbookCategory(
          name: 'Inputs',
          children: [
            checkboxComponent,
            radioComponent,
            toggleComponent,
            valueCardComponent,
            counterComponent,
          ],
        ),
      ],
    );
  }
}
