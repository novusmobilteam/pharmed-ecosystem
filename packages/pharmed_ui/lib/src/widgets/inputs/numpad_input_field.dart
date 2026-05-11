import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// Yeniden yazıldı: hardcoded değerler kaldırıldı, MedInputDecorator kullanıldı.
// Material colorScheme referansları MedColors ile değiştirildi.

/// Numpad diyaloğu açan sayısal giriş alanı.
///
/// Dokunulduğunda tam ekran numpad açılır. Değer gösterimi ve birim
/// [MedInputDecorator] kabuğu içinde render edilir.
///
/// ```dart
/// NumpadInputField(
///   label: 'Doz',
///   value: '250',
///   unit: 'mg',
///   onChanged: (v) { ... },
/// )
/// ```
class NumpadInputField extends StatefulWidget {
  const NumpadInputField({
    super.key,
    this.label,
    required this.value,
    this.hint = '0',
    this.title,
    required this.onChanged,
    this.unit,
  });

  final String? label;
  final String value;
  final String hint;
  final String? title;
  final ValueChanged<String> onChanged;
  final String? unit;

  @override
  State<NumpadInputField> createState() => _NumpadInputFieldState();
}

class _NumpadInputFieldState extends State<NumpadInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(NumpadInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);
    final isEmpty = widget.value.isEmpty;

    return MedInputDecorator(
      label: widget.label,
      child: GestureDetector(
        onTap: () async {
          // Numpad entegrasyonu — Step 3.5'te MedNumpadField ile birleştirilecek.
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: MedSpacing.xs,
          children: [
            Text(
              isEmpty ? widget.hint : widget.value,
              style: MedTextStyles.numericLg(color: isEmpty ? MedColors.text4 : MedColors.text),
            ),
            if (widget.unit != null && widget.value.isNotEmpty)
              Text(
                widget.unit!,
                style: TextStyle(fontFamily: MedFonts.sans, fontSize: style.labelFontSize + 2, color: MedColors.text3),
              ),
          ],
        ),
      ),
    );
  }
}
