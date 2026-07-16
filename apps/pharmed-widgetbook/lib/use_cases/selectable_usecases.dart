import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ─────────────────────────────────────────────────────────────────
// MedSelectable — tekil seçilebilir eleman
// Knob'lar: shape, accent, selected, size(override), icon var/yok, label.
// ─────────────────────────────────────────────────────────────────
final selectableComponent = WidgetbookComponent(
  name: 'MedSelectable',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _selectablePlayground),
    WidgetbookUseCase(name: 'Şekil × durum matrisi', builder: _selectableMatrix),
  ],
);

Widget _selectablePlayground(BuildContext context) {
  final shape = context.knobs.list<MedSelectableShape>(
    label: 'shape',
    options: MedSelectableShape.values,
    labelBuilder: (s) => s.name,
  );
  final accent = context.knobs.list<MedAccent>(
    label: 'accent',
    options: MedAccent.values,
    labelBuilder: (a) => a.name,
  );
  final selected = context.knobs.boolean(label: 'selected', initialValue: true);
  final withIcon = context.knobs.boolean(label: 'ikon', initialValue: true);
  final label = context.knobs.string(label: 'label', initialValue: 'Hastalarım');

  // size knob'u: null = temadan (density). Diğerleri override.
  final sizeChoice = context.knobs.list<String>(
    label: 'size',
    options: const ['temadan', 'sm', 'md'],
  );
  final size = switch (sizeChoice) {
    'sm' => MedSelectableSize.sm,
    'md' => MedSelectableSize.md,
    _ => null,
  };

  return MedSelectable(
    label: label,
    icon: withIcon ? Icons.person_outline : null,
    selected: selected,
    accent: accent,
    shape: shape,
    size: size,
    onTap: () {},
  );
}

/// Üç şekil × (nötr/seçili) — tek bakışta tüm görsel diller.
Widget _selectableMatrix(BuildContext context) {
  Widget row(String title, MedSelectableShape shape) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: MedTextStyles.titleSm()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MedSelectable(label: 'Nötr', shape: shape, selected: false, onTap: () {}),
              for (final a in MedAccent.values)
                MedSelectable(label: a.name, shape: shape, accent: a, selected: true, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row('pill', MedSelectableShape.pill),
        row('chip', MedSelectableShape.chip),
        row('segment (tekil)', MedSelectableShape.segment),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
// MedSelectableGroup — grup (chip scroll + segment track)
// Stateful sarmalayıcı gerekir çünkü seçim state tutar.
// ─────────────────────────────────────────────────────────────────
final selectableGroupComponent = WidgetbookComponent(
  name: 'MedSelectableGroup',
  useCases: [
    WidgetbookUseCase(name: 'Chip grubu', builder: (c) => const _GroupDemo(shape: MedSelectableShape.chip)),
    WidgetbookUseCase(name: 'Pill grubu', builder: (c) => const _GroupDemo(shape: MedSelectableShape.pill)),
    WidgetbookUseCase(name: 'Segment', builder: (c) => const _GroupDemo(shape: MedSelectableShape.segment)),
  ],
);

class _GroupDemo extends StatefulWidget {
  const _GroupDemo({required this.shape});
  final MedSelectableShape shape;

  @override
  State<_GroupDemo> createState() => _GroupDemoState();
}

class _GroupDemoState extends State<_GroupDemo> {
  static const _options = ['Dolum', 'Alım', 'Sayım', 'Boşaltma'];
  String _selected = _options.first;

  @override
  Widget build(BuildContext context) {
    final accent = context.knobs.list<MedAccent>(
      label: 'accent',
      options: MedAccent.values,
      labelBuilder: (a) => a.name,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MedSelectableGroup<String>(
          options: _options,
          selected: _selected,
          onChanged: (v) => setState(() => _selected = v),
          labelBuilder: (v) => v,
          accent: accent,
          shape: widget.shape,
        ),
        const SizedBox(height: 16),
        Text('Seçili: $_selected', style: MedTextStyles.bodyMd(color: MedColors.text2)),
      ],
    );
  }
}
