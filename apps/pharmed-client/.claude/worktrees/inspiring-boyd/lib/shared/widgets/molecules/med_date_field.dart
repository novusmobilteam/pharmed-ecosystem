import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../atoms/med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedDateField
// [SWREQ-UI-MOL-DATE-001]
// Tarih girişi — GG/AA/YYYY formatı, otomatik odak geçişi.
// Sınıf : Class A (görsel girdi)
// ─────────────────────────────────────────────────────────────────

class MedDateField extends StatefulWidget {
  const MedDateField({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.helperText,
    this.onCalendarTap,
  });

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final String? helperText;
  final VoidCallback? onCalendarTap;

  @override
  State<MedDateField> createState() => _MedDateFieldState();
}

class _MedDateFieldState extends State<MedDateField> {
  late final TextEditingController _dayCtrl;
  late final TextEditingController _monCtrl;
  late final TextEditingController _yrCtrl;
  late final FocusNode _dayFocus;
  late final FocusNode _monFocus;
  late final FocusNode _yrFocus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final v = widget.value;
    _dayCtrl = TextEditingController(
        text: v != null ? v.day.toString().padLeft(2, '0') : '');
    _monCtrl = TextEditingController(
        text: v != null ? v.month.toString().padLeft(2, '0') : '');
    _yrCtrl =
        TextEditingController(text: v != null ? v.year.toString() : '');
    _dayFocus = FocusNode()..addListener(_onFocusChange);
    _monFocus = FocusNode()..addListener(_onFocusChange);
    _yrFocus = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final anyFocused =
        _dayFocus.hasFocus || _monFocus.hasFocus || _yrFocus.hasFocus;
    if (anyFocused != _focused) setState(() => _focused = anyFocused);
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monCtrl.dispose();
    _yrCtrl.dispose();
    _dayFocus.removeListener(_onFocusChange);
    _monFocus.removeListener(_onFocusChange);
    _yrFocus.removeListener(_onFocusChange);
    _dayFocus.dispose();
    _monFocus.dispose();
    _yrFocus.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final day = int.tryParse(_dayCtrl.text);
    final mon = int.tryParse(_monCtrl.text);
    final yr = int.tryParse(_yrCtrl.text);
    if (day != null &&
        mon != null &&
        yr != null &&
        _yrCtrl.text.length == 4) {
      try {
        final dt = DateTime(yr, mon, day);
        widget.onChanged?.call(dt);
      } catch (_) {
        widget.onChanged?.call(null);
      }
    } else {
      widget.onChanged?.call(null);
    }
  }

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
            border: Border.all(
              color: _focused ? MedColors.blue : MedColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _focused
                ? const [
                    BoxShadow(
                      color: Color(0x1F1A6FD8),
                      blurRadius: 0,
                      spreadRadius: 3,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              _DatePartField(
                controller: _dayCtrl,
                focusNode: _dayFocus,
                nextFocus: _monFocus,
                placeholder: 'GG',
                maxLength: 2,
                maxValue: 31,
                onChanged: (_) => _notifyChange(),
              ),
              _DateSep(),
              _DatePartField(
                controller: _monCtrl,
                focusNode: _monFocus,
                nextFocus: _yrFocus,
                prevFocus: _dayFocus,
                placeholder: 'AA',
                maxLength: 2,
                maxValue: 12,
                onChanged: (_) => _notifyChange(),
              ),
              _DateSep(),
              _DatePartField(
                controller: _yrCtrl,
                focusNode: _yrFocus,
                prevFocus: _monFocus,
                placeholder: 'YYYY',
                maxLength: 4,
                onChanged: (_) => _notifyChange(),
              ),
              if (widget.onCalendarTap != null)
                _CalendarButton(onTap: widget.onCalendarTap!),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 11,
              color: MedColors.text3,
            ),
          ),
        ],
      ],
    );
  }
}

class _DatePartField extends StatelessWidget {
  const _DatePartField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.maxLength,
    this.maxValue,
    this.nextFocus,
    this.prevFocus,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final FocusNode? prevFocus;
  final String placeholder;
  final int maxLength;
  final int? maxValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
          if (maxValue != null) _RangeFormatter(max: maxValue!),
        ],
        style: const TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: MedColors.text,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 15,
            color: MedColors.text4,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          constraints: const BoxConstraints(minHeight: 48),
          isDense: false,
        ),
        onChanged: (val) {
          onChanged?.call(val);
          if (val.length >= maxLength && nextFocus != null) {
            nextFocus!.requestFocus();
          }
        },
      ),
    );
  }
}

class _DateSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      '/',
      style: const TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 16,
        color: MedColors.text3,
      ),
    );
  }
}

class _CalendarButton extends StatefulWidget {
  const _CalendarButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CalendarButton> createState() => _CalendarButtonState();
}

class _CalendarButtonState extends State<_CalendarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _hovered ? MedColors.blueLight : Colors.transparent,
          border: const Border(
            left: BorderSide(color: MedColors.border2),
          ),
        ),
        child: Icon(
          Icons.calendar_month_outlined,
          size: 16,
          color: _hovered ? MedColors.blue : MedColors.text3,
        ),
      ),
    );
  }
}

class _RangeFormatter extends TextInputFormatter {
  const _RangeFormatter({required this.max});
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    if (next.text.isEmpty) return next;
    final n = int.tryParse(next.text);
    if (n == null) return old;
    if (n > max) return old;
    return next;
  }
}
