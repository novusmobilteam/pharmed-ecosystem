import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ═════════════════════════════════════════════════════════════════
// Display grubu use-case'leri
// ═════════════════════════════════════════════════════════════════

// ── MedAvatar ────────────────────────────────────────────────────
final avatarComponent = WidgetbookComponent(
  name: 'MedAvatar',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _avatarPlayground),
    WidgetbookUseCase(name: 'Tüm paletler', builder: _avatarGallery),
  ],
);

Widget _avatarPlayground(BuildContext context) {
  final palette = context.knobs.object.dropdown(
    label: 'palette',
    options: AvatarPalette.values,
    labelBuilder: (p) => p.name,
  );
  final initials = context.knobs.string(label: 'initials', initialValue: 'FY');
  final size = context.knobs.double.slider(label: 'size', initialValue: 40, min: 20, max: 80);
  final border = context.knobs.boolean(label: 'showBorder', initialValue: true);

  return MedAvatar(initials: initials, palette: palette, size: size, showBorder: border);
}

Widget _avatarGallery(BuildContext context) {
  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      for (final p in AvatarPalette.values)
        MedAvatar(initials: p.name.substring(0, 2).toUpperCase(), palette: p, size: 48),
    ],
  );
}

// ── MedLabel ─────────────────────────────────────────────────────
final labelComponent = WidgetbookComponent(
  name: 'MedLabel',
  useCases: [
    WidgetbookUseCase(name: 'Tüm varyantlar', builder: _labelGallery),
  ],
);

Widget _labelGallery(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final v in MedLabelVariant.values)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: MedLabel(text: '${v.name} — örnek metin', variant: v),
        ),
    ],
  );
}

// ── MedBadge (pill chip) — emekli ama katalogda göster ───────────
final badgeComponent = WidgetbookComponent(
  name: 'MedBadge (→ MedChip pill)',
  useCases: [
    WidgetbookUseCase(name: 'Varyantlar', builder: _badgeGallery),
  ],
);

Widget _badgeGallery(BuildContext context) {
  final samples = <(String, MedChipStyle)>[
    ('7 Bekliyor', MedChipStyle.warning),
    ('Tamam', MedChipStyle.success),
    ('3 Kritik', MedChipStyle.danger),
    ('5 Kalem', MedChipStyle.info),
    ('Kilitli', MedChipStyle.neutral),
  ];
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final (label, style) in samples)
        MedChip(label: label, style: style, shape: MedChipShape.pill, showBorder: false),
    ],
  );
}

// ── EmptyState ───────────────────────────────────────────────────
final emptyStateComponent = WidgetbookComponent(
  name: 'EmptyStateWidget',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _emptyStatePlayground),
  ],
);

Widget _emptyStatePlayground(BuildContext context) {
  final variant = context.knobs.object.dropdown(
    label: 'variant',
    options: EmptyStateVariant.values,
    labelBuilder: (v) => v.name,
  );
  final compact = context.knobs.boolean(label: 'compact', initialValue: false);
  final withAction = context.knobs.boolean(label: 'action', initialValue: false);

  return EmptyStateWidget(
    variant: variant,
    size: compact ? EmptyStateSize.compact : EmptyStateSize.normal,
    // custom varyant için örnek içerik
    icon: Icons.info_outline,
    title: 'Özel başlık',
    description: 'Özel açıklama metni.',
    action: withAction ? MedButton(label: 'Aksiyon', onPressed: () {}) : null,
  );
}

// ── MedSidePanel ─────────────────────────────────────────────────
final sidePanelComponent = WidgetbookComponent(
  name: 'MedSidePanel',
  useCases: [
    WidgetbookUseCase(name: 'İstasyon listesi', builder: (c) => const _SidePanelDemo()),
  ],
);

class _SidePanelDemo extends StatefulWidget {
  const _SidePanelDemo();
  @override
  State<_SidePanelDemo> createState() => _SidePanelDemoState();
}

class _SidePanelDemoState extends State<_SidePanelDemo> {
  static const _items = ['Kardiyoloji', 'Nöroloji', 'Onkoloji', 'Pediatri', 'Ortopedi'];
  String _selected = _items.first;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: MedColors.border),
          borderRadius: MedRadius.lgAll,
        ),
        child: MedSidePanel<String>(
          title: 'Servisler',
          items: _items,
          selected: _selected,
          labelBuilder: (s) => s,
          countBuilder: (s) => s.length,
          onSelected: (s) => setState(() => _selected = s),
        ),
      ),
    );
  }
}

// ── MedStaleBanner ───────────────────────────────────────────────
final staleBannerComponent = WidgetbookComponent(
  name: 'MedStaleBanner',
  useCases: [
    WidgetbookUseCase(name: 'canProceed', builder: (c) => _staleBanner(c, true)),
    WidgetbookUseCase(name: 'blocked', builder: (c) => _staleBanner(c, false)),
  ],
);

Widget _staleBanner(BuildContext context, bool canProceed) {
  return MedStaleBanner(
    lastUpdated: DateTime.now().subtract(const Duration(minutes: 12)),
    canProceed: canProceed,
  );
}
