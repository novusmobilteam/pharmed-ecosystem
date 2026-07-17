import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:widgetbook/widgetbook.dart';

// ═════════════════════════════════════════════════════════════════
// Inputs grubu — l10n bağımsız atomlar
//
// NOT: context.l10n kullanan input'lar (MedTextInputField, MedDoseStepper,
// MedDateInputField, MedTimeInputField, SelectionField, Numpad) katalogda
// gösterilmiyor çünkü Widgetbook'a localization delegate eklenmesi gerek.
// Bu bir kurulum işi — DENSITY/skill notlarına eklendi. Aşağıdakiler
// l10n'suz çalışan seçim atomları.
// ═════════════════════════════════════════════════════════════════

// ── MedCheckbox ──────────────────────────────────────────────────
final checkboxComponent = WidgetbookComponent(
  name: 'MedCheckbox',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: (c) => const _CheckboxDemo()),
    WidgetbookUseCase(name: 'Boyutlar', builder: _checkboxSizes),
  ],
);

class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo();
  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  bool _v = false;
  @override
  Widget build(BuildContext context) {
    final size = context.knobs.object.dropdown(
      label: 'size',
      options: MedCheckboxSize.values,
      labelBuilder: (s) => s.name,
    );
    final partial = context.knobs.boolean(label: 'partial', initialValue: false);
    return MedCheckbox(
      value: _v,
      partial: partial,
      size: size,
      label: 'Onay kutusu',
      onChanged: (v) => setState(() => _v = v),
    );
  }
}

Widget _checkboxSizes(BuildContext context) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final s in MedCheckboxSize.values)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: MedCheckbox(value: true, size: s, label: s.name, onChanged: (_) {}),
        ),
    ],
  );
}

// ── MedRadio ─────────────────────────────────────────────────────
final radioComponent = WidgetbookComponent(
  name: 'MedRadio',
  useCases: [
    WidgetbookUseCase(name: 'Grup', builder: (c) => const _RadioDemo()),
  ],
);

class _RadioDemo extends StatefulWidget {
  const _RadioDemo();
  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String _v = 'a';
  @override
  Widget build(BuildContext context) {
    return MedRadioGroup<String>(
      groupValue: _v,
      onChanged: (v) => setState(() => _v = v),
      options: const [
        MedRadioOption(value: 'a', label: 'Seçenek A'),
        MedRadioOption(value: 'b', label: 'Seçenek B'),
        MedRadioOption(value: 'c', label: 'Seçenek C'),
      ],
    );
  }
}

// ── MedToggle ────────────────────────────────────────────────────
final toggleComponent = WidgetbookComponent(
  name: 'MedToggle',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: (c) => const _ToggleDemo()),
  ],
);

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();
  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  bool _v = true;
  @override
  Widget build(BuildContext context) {
    final withLabel = context.knobs.boolean(label: 'label', initialValue: true);
    return MedToggleField(
      value: _v,
      label: withLabel ? 'Aktif' : '',
      onChanged: (v) => setState(() => _v = v),
    );
  }
}

// ── MedValueCard ─────────────────────────────────────────────────
final valueCardComponent = WidgetbookComponent(
  name: 'MedValueCard',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: _valueCardPlayground),
  ],
);

Widget _valueCardPlayground(BuildContext context) {
  final compact = context.knobs.boolean(label: 'compact', initialValue: false);
  final placeholder = context.knobs.boolean(label: 'placeholder', initialValue: false);
  final hasError = context.knobs.boolean(label: 'hasError', initialValue: false);
  final withIcon = context.knobs.boolean(label: 'trailing ikon', initialValue: false);

  return SizedBox(
    width: 200,
    child: MedValueCard(
      label: 'Sayım',
      value: placeholder ? 'Değer gir' : '24',
      density: compact ? MedValueCardDensity.compact : MedValueCardDensity.comfortable,
      placeholder: placeholder,
      hasError: hasError,
      trailingIcon: withIcon ? Icons.calendar_today_outlined : null,
      onTap: () {},
    ),
  );
}

// ── MedCounter ───────────────────────────────────────────────────
final counterComponent = WidgetbookComponent(
  name: 'MedCounter',
  useCases: [
    WidgetbookUseCase(name: 'Playground', builder: (c) => const _CounterDemo()),
  ],
);

class _CounterDemo extends StatefulWidget {
  const _CounterDemo();
  @override
  State<_CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<_CounterDemo> {
  int _v = 3;
  @override
  Widget build(BuildContext context) {
    return MedCounter(
      value: _v,
      min: 0,
      max: 10,
      onDecrement: () => setState(() => _v--),
      onIncrement: () => setState(() => _v++),
    );
  }
}
