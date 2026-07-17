import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ─────────────────────────────────────────────────────────────────
// MedChip — statik bilgi etiketi
// Knob'lar: style, label, ikon, count, mono.
// ─────────────────────────────────────────────────────────────────
final chipComponent = WidgetbookComponent(
  name: 'MedChip',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _chipPlayground),
    WidgetbookUseCase(name: 'Preset galeri', builder: _chipGallery),
    WidgetbookUseCase(name: 'Türetilen chip\'ler', builder: _derivedGallery),
  ],
);

Widget _chipPlayground(BuildContext context) {
  final style = context.knobs.object.dropdown(
    label: 'style',
    options: MedChipStyle.values,
    labelBuilder: (s) => s.name,
  );
  final label = context.knobs.string(label: 'label', initialValue: 'Acil');
  final withIcon = context.knobs.boolean(label: 'ikon', initialValue: false);
  final withCount = context.knobs.boolean(label: 'count', initialValue: false);
  final mono = context.knobs.boolean(label: 'mono', initialValue: true);

  return MedChip(
    label: label,
    style: style,
    icon: withIcon ? Icons.info_outline : null,
    count: withCount ? 5 : null,
    mono: mono,
  );
}

Widget _chipGallery(BuildContext context) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final s in MedChipStyle.values) MedChip(label: s.name, style: s),
    ],
  );
}

/// Domain wrapper'ların (Dose/Rx/Time/RemainingDay) MedChip'e nasıl
/// indiğini gösteren örnekler — gerçek domain objesi olmadan, düz MedChip ile.
Widget _derivedGallery(BuildContext context) {
  Widget labeled(String title, Widget chip) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: MedTextStyles.monoSm()), const SizedBox(height: 4), chip],
      );

  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      labeled('Dose', const MedChip(label: '1 1/2 Tablet', style: MedChipStyle.neutral)),
      labeled('Time', const MedChip(label: 'Bugün 14:30', style: MedChipStyle.warning)),
      labeled('Rx (info)', const MedChip(label: 'Uygulandı', style: MedChipStyle.info)),
      labeled('RemainingDay (normal)',
          MedChip(label: '45 gün', icon: Icons.check_circle_outline, style: MedChipStyle.success, mono: false)),
      labeled('RemainingDay (expired)',
          MedChip(label: '3g geçti', icon: Icons.warning_amber_outlined, style: MedChipStyle.danger, mono: false)),
    ],
  );
}
