import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedIpField
// [SWREQ-UI-MOL-IP-001]
// IP adresi girişi — 4 oktet, otomatik odak geçişi, numpad klavye.
// Her oktet 0–255 arası sayısal değer.
// Sınıf : Class A (görsel girdi)
// ─────────────────────────────────────────────────────────────────

class MedIpField extends StatefulWidget {
  const MedIpField({super.key, this.initialValue, this.onChanged, this.label, this.helperText});

  final String? initialValue; // "192.168.1.100"
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? helperText;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MedColors.text2,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: _focused ? MedColors.surface : MedColors.surface2,
            border: Border.all(color: _focused ? MedColors.blue : MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _focused ? const [BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3)] : null,
          ),
          child: Row(
            children: [
              _OctetField(
                controller: _controllers[0],
                focusNode: _focuses[0],
                nextFocus: _focuses[1],
                placeholder: '192',
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(),
              _OctetField(
                controller: _controllers[1],
                focusNode: _focuses[1],
                nextFocus: _focuses[2],
                prevFocus: _focuses[0],
                placeholder: '168',
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(),
              _OctetField(
                controller: _controllers[2],
                focusNode: _focuses[2],
                nextFocus: _focuses[3],
                prevFocus: _focuses[1],
                placeholder: '1',
                onChanged: (_) => _notifyChange(),
              ),
              _Dot(),
              _OctetField(
                controller: _controllers[3],
                focusNode: _focuses[3],
                prevFocus: _focuses[2],
                placeholder: '100',
                onChanged: (_) => _notifyChange(),
              ),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
          ),
        ],
      ],
    );
  }
}

class _OctetField extends StatelessWidget {
  const _OctetField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    this.nextFocus,
    this.prevFocus,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final FocusNode? prevFocus;
  final String placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _OctetFormatter()],
        style: const TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: MedColors.text,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(fontFamily: MedFonts.mono, fontSize: 15, color: MedColors.text4),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          constraints: const BoxConstraints(minHeight: 48),
          isDense: false,
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
  @override
  Widget build(BuildContext context) {
    return Text(
      '.',
      style: const TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 18,
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
