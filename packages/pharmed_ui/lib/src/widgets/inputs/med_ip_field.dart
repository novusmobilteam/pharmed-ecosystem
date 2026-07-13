import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedIpField
// [SWREQ-UI-MOL-IP-001]
// IP adresi girişi — 4 oktet, otomatik odak geçişi, numpad klavye.
// Her oktet 0–255 arası sayısal değer.
// Sınıf : Class A (görsel girdi)
//
// MedInputDecorator + InputFieldTheme üzerine kurulu. Label, border,
// yükseklik ve odak görseli MedTextInputField / MedDropdownInputField
// ile birebir aynı kaynaktan gelir; elle çizim yapılmaz.
// ─────────────────────────────────────────────────────────────────

class MedIpField extends StatefulWidget {
  const MedIpField({super.key, this.initialValue, this.onChanged, this.label, this.helperText, this.enabled = true});

  final String? initialValue; // "192.168.1.100"
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? helperText;
  final bool enabled;

  @override
  State<MedIpField> createState() => _MedIpFieldState();
}

class _MedIpFieldState extends State<MedIpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focuses;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final parts = widget.initialValue?.split('.') ?? [];
    _controllers = List.generate(4, (i) {
      return TextEditingController(text: (i < parts.length) ? parts[i] : '');
    });
    _focuses = List.generate(4, (_) => FocusNode());
    for (final f in _focuses) {
      f.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    final anyFocused = _focuses.any((f) => f.hasFocus);
    if (anyFocused != _focused) setState(() => _focused = anyFocused);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) {
      f.removeListener(_onFocusChange);
      f.dispose();
    }
    super.dispose();
  }

  String get _ipValue => _controllers.map((c) => c.text).join('.');

  void _notifyChange() => widget.onChanged?.call(_ipValue);

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);

    return MedInputDecorator(
      label: widget.label,
      helperText: widget.helperText,
      enabled: widget.enabled,
      isFocused: _focused,
      // Padding'i biz veriyoruz; oktet alanları decorator'ın sabit
      // yüksekliği içinde dikey ortalanır.
      applyPadding: false,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: Padding(
          padding: style.contentPadding,
          child: Row(
            children: [
              _OctetField(
                controller: _controllers[0],
                focusNode: _focuses[0],
                nextFocus: _focuses[1],
                placeholder: '192',
                fontSize: style.inputFontSize,
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(fontSize: style.inputFontSize),
              _OctetField(
                controller: _controllers[1],
                focusNode: _focuses[1],
                nextFocus: _focuses[2],
                prevFocus: _focuses[0],
                placeholder: '168',
                fontSize: style.inputFontSize,
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(fontSize: style.inputFontSize),
              _OctetField(
                controller: _controllers[2],
                focusNode: _focuses[2],
                nextFocus: _focuses[3],
                prevFocus: _focuses[1],
                placeholder: '1',
                fontSize: style.inputFontSize,
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(fontSize: style.inputFontSize),
              _OctetField(
                controller: _controllers[3],
                focusNode: _focuses[3],
                prevFocus: _focuses[2],
                placeholder: '100',
                fontSize: style.inputFontSize,
                onChanged: (_) => _notifyChange(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OctetField extends StatelessWidget {
  const _OctetField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.fontSize,
    this.nextFocus,
    this.prevFocus,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final FocusNode? prevFocus;
  final String placeholder;
  final double fontSize;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _OctetFormatter()],
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: MedColors.text,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(fontFamily: MedFonts.mono, fontSize: fontSize, color: MedColors.text4),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  fillColor: Colors.transparent,
  hoverColor: Colors.transparent,
  filled: false,
        ),
        onChanged: (val) {
          onChanged?.call(val);
          if (val.length >= 3 && nextFocus != null) {
            nextFocus!.requestFocus();
          }
        },
        onEditingComplete: () {
          if (nextFocus != null) {
            nextFocus!.requestFocus();
          }
        },
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '.',
      style: TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: fontSize + 3,
        fontWeight: FontWeight.w700,
        color: MedColors.text3,
      ),
    );
  }
}

class _OctetFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final n = int.tryParse(text);
    if (n == null) return oldValue;
    if (n > 255) {
      return oldValue;
    }
    return newValue;
  }
}
