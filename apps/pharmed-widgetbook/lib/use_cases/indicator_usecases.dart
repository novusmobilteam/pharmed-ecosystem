import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ═════════════════════════════════════════════════════════════════
// Indicators grubu — küçük tekil göstergeler (ortaklaştırma yok)
// ═════════════════════════════════════════════════════════════════

// ── MedDottedDivider ─────────────────────────────────────────────
final dottedDividerComponent = WidgetbookComponent(
  name: 'MedDottedDivider',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _dottedPlayground),
  ],
);

Widget _dottedPlayground(BuildContext context) {
  final thickness = context.knobs.double.slider(label: 'thickness', initialValue: 1.5, min: 0.5, max: 5);
  final dashWidth = context.knobs.double.slider(label: 'dashWidth', initialValue: 6, min: 2, max: 20);
  final dashSpace = context.knobs.double.slider(label: 'dashSpace', initialValue: 4, min: 1, max: 20);

  return SizedBox(
    width: 320,
    child: MedDottedDivider(thickness: thickness, dashWidth: dashWidth, dashSpace: dashSpace),
  );
}

// ── MedLoadingIndicator ──────────────────────────────────────────
final loadingComponent = WidgetbookComponent(
  name: 'MedLoadingIndicator',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _loadingPlayground),
  ],
);

Widget _loadingPlayground(BuildContext context) {
  final size = context.knobs.double.slider(label: 'size', initialValue: 20, min: 12, max: 64);
  final stroke = context.knobs.double.slider(label: 'strokeWidth', initialValue: 2, min: 1, max: 6);
  return MedLoadingIndicator(size: size, strokeWidth: stroke);
}

// ── MedProgressBar ───────────────────────────────────────────────
final progressBarComponent = WidgetbookComponent(
  name: 'MedProgressBar',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _progressPlayground),
  ],
);

Widget _progressPlayground(BuildContext context) {
  final animated = context.knobs.boolean(label: 'animated (indeterminate)', initialValue: false);
  final value = context.knobs.double.slider(label: 'value', initialValue: 0.65, min: 0, max: 1);
  final height = context.knobs.double.slider(label: 'height', initialValue: 3, min: 2, max: 12);

  return SizedBox(
    width: 280,
    child: MedProgressBar(value: value, color: MedColors.blue, height: height, animated: animated),
  );
}

// ── MedStatusBar ─────────────────────────────────────────────────
final statusBarComponent = WidgetbookComponent(
  name: 'MedStatusBar',
  useCases: [
    WidgetbookUseCase(name: 'Renk örnekleri', builder: _statusBarGallery),
  ],
);

Widget _statusBarGallery(BuildContext context) {
  final colors = <(String, Color)>[
    ('red', MedColors.red),
    ('amber', MedColors.amber),
    ('green', MedColors.green),
    ('blue', MedColors.blue),
  ];
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final (label, color) in colors)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MedStatusBar(color: color, height: 44),
              const SizedBox(height: 6),
              Text(label, style: MedTextStyles.monoSm()),
            ],
          ),
        ),
    ],
  );
}

// ── MedStatusDot ─────────────────────────────────────────────────
final statusDotComponent = WidgetbookComponent(
  name: 'MedStatusDot',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _statusDotPlayground),
  ],
);

Widget _statusDotPlayground(BuildContext context) {
  final pulsing = context.knobs.boolean(label: 'isPulsing', initialValue: true);
  final size = context.knobs.double.slider(label: 'size', initialValue: 8, min: 4, max: 24);
  final colorName = context.knobs.list<String>(
    label: 'color',
    options: const ['green', 'amber', 'red', 'blue'],
  );
  final color = switch (colorName) {
    'amber' => MedColors.amber,
    'red' => MedColors.red,
    'blue' => MedColors.blue,
    _ => MedColors.green,
  };

  return MedStatusDot(color: color, size: size, isPulsing: pulsing);
}
