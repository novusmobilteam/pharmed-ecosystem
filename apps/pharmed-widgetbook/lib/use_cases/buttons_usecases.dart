import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ─────────────────────────────────────────────────────────────────
// MedButton use-case'leri
// Knob'lar: variant, size, label, loading, disabled, fullWidth, prefix ikon.
// ─────────────────────────────────────────────────────────────────
final buttonsComponent = WidgetbookComponent(
  name: 'MedButton',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _buttonPlayground),
    WidgetbookUseCase(name: 'Tüm varyantlar', builder: _buttonGallery),
  ],
);

Widget _buttonPlayground(BuildContext context) {
  final variant = context.knobs.object.dropdown(
    label: 'variant',
    options: MedButtonVariant.values,
    labelBuilder: (v) => v.name,
  );

  // size null → temadan (density). Diğerleri override.
  final sizeChoice = context.knobs.object.dropdown(
    label: 'size',
    options: const ['temadan', 'sm', 'md', 'lg'],
  );
  final size = switch (sizeChoice) {
    'sm' => MedButtonSize.sm,
    'md' => MedButtonSize.md,
    'lg' => MedButtonSize.lg,
    _ => null,
  };
  final label = context.knobs.string(label: 'label', initialValue: 'Kaydet');
  final loading = context.knobs.boolean(label: 'isLoading', initialValue: false);
  final disabled = context.knobs.boolean(label: 'disabled', initialValue: false);
  final fullWidth = context.knobs.boolean(label: 'fullWidth', initialValue: false);
  final withIcon = context.knobs.boolean(label: 'prefix ikon', initialValue: false);

  return MedButton(
    label: label,
    variant: variant,
    size: size,
    isLoading: loading,
    fullWidth: fullWidth,
    prefixIcon: withIcon ? const Icon(Icons.check) : null,
    onPressed: disabled ? null : () {},
  );
}

Widget _buttonGallery(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final v in MedButtonVariant.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final s in MedButtonSize.values)
                  MedButton(label: '${v.name} · ${s.name}', variant: v, size: s, onPressed: () {}),
              ],
            ),
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// MedRectangleIconButton
// Knob'lar: ikon, size(override), renkli/nötr, disabled, tooltip.
// ─────────────────────────────────────────────────────────────────
final iconButtonComponent = WidgetbookComponent(
  name: 'MedRectangleIconButton',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _iconButtonPlayground),
    WidgetbookUseCase(name: 'Renk örnekleri', builder: _iconButtonGallery),
  ],
);

Widget _iconButtonPlayground(BuildContext context) {
  final disabled = context.knobs.boolean(label: 'disabled', initialValue: false);
  final tinted = context.knobs.boolean(label: 'renkli (mavi)', initialValue: false);
  final withTooltip = context.knobs.boolean(label: 'tooltip', initialValue: true);

  final sizeChoice = context.knobs.object.dropdown(
    label: 'size',
    options: const ['temadan', '32', '40', '48'],
  );
  final size = switch (sizeChoice) {
    '32' => 32.0,
    '40' => 40.0,
    '48' => 48.0,
    _ => null,
  };

  return MedRectangleIconButton(
    iconData: Icons.edit_outlined,
    size: size,
    color: tinted ? MedColors.blueLight : null,
    iconColor: tinted ? MedColors.blue : null,
    tooltip: withTooltip ? 'Düzenle' : null,
    onPressed: disabled ? null : () {},
  );
}

Widget _iconButtonGallery(BuildContext context) {
  Widget item(String label, Widget btn) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [btn, const SizedBox(height: 6), Text(label, style: MedTextStyles.monoSm())],
      );

  return Wrap(
    spacing: 20,
    runSpacing: 20,
    children: [
      item('nötr', MedRectangleIconButton(iconData: Icons.edit_outlined, onPressed: () {})),
      item(
        'mavi',
        MedRectangleIconButton(
          iconData: Icons.visibility_outlined,
          color: MedColors.blueLight,
          iconColor: MedColors.blue,
          onPressed: () {},
        ),
      ),
      item(
        'kırmızı',
        MedRectangleIconButton(
          iconData: Icons.delete_outline,
          color: MedColors.redLight,
          iconColor: MedColors.red,
          onPressed: () {},
        ),
      ),
      item('disabled', MedRectangleIconButton(iconData: Icons.edit_outlined, onPressed: null)),
    ],
  );
}
