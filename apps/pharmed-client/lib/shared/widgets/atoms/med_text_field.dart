import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedTextField
// [SWREQ-UI-ATOM-TF-001]
// Dokunmatik HMI text input. Min 48px yükseklik.
// Desteklenen durumlar: normal, focused, error, success, disabled.
// data-keyboard özelliği yerine keyboardType kullanılır.
// Sınıf : Class A (görsel girdi, iş mantığı dışında)
// ─────────────────────────────────────────────────────────────────

enum MedTextFieldState { normal, error, success }

class MedTextField extends StatefulWidget {
  const MedTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixWidget,
    this.fieldState = MedTextFieldState.normal,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.maxLength,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixWidget;
  final MedTextFieldState fieldState;
  final bool enabled;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final int? maxLength;
  final bool readOnly;

  @override
  State<MedTextField> createState() => _MedTextFieldState();
}

class _MedTextFieldState extends State<MedTextField> {
  late final FocusNode _focus;
  bool _focused = false;
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _focus = widget.focusNode ?? FocusNode();
    _obscure = widget.obscureText;
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    _focus.removeListener(_onFocusChange);
    super.dispose();
  }

  Color get _borderColor {
    if (!widget.enabled) return MedColors.border;
    if (widget.fieldState == MedTextFieldState.error) return MedColors.red;
    if (widget.fieldState == MedTextFieldState.success) return MedColors.green;
    if (_focused) return MedColors.blue;
    return MedColors.border;
  }

  Color get _bgColor {
    if (!widget.enabled) return MedColors.surface3;
    if (widget.fieldState == MedTextFieldState.error) return MedColors.redLight;
    if (_focused) return MedColors.surface;
    return MedColors.surface2;
  }

  List<BoxShadow>? get _shadow {
    if (!_focused || !widget.enabled) return null;
    final shadowColor = widget.fieldState == MedTextFieldState.error
        ? const Color(0x1FDC2626)
        : const Color(0x1F1A6FD8);
    return [BoxShadow(color: shadowColor, blurRadius: 0, spreadRadius: 3)];
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
            style: TextStyle(
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
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border.all(color: _borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _shadow,
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: IconTheme(
                    data: const IconThemeData(color: MedColors.text3, size: 16),
                    child: widget.prefixIcon!,
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  obscureText: _obscure,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  textInputAction: widget.textInputAction,
                  maxLength: widget.maxLength,
                  readOnly: widget.readOnly,
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 14,
                    color: MedColors.text,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 14,
                      color: MedColors.text4,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.prefixIcon != null ? 10 : 14,
                      vertical: 12,
                    ),
                    isDense: false,
                    counterText: '',
                    constraints: const BoxConstraints(minHeight: 48),
                  ),
                ),
              ),
              if (widget.obscureText)
                _PasswordToggleButton(
                  obscure: _obscure,
                  onToggle: () => setState(() => _obscure = !_obscure),
                )
              else if (widget.suffixWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffixWidget!,
                ),
            ],
          ),
        ),
        if (widget.fieldState == MedTextFieldState.error &&
            widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 11,
              color: MedColors.red,
            ),
          ),
        ] else if (widget.helperText != null) ...[
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

// ── Şifre göster/gizle butonu ────────────────────────────────────
class _PasswordToggleButton extends StatelessWidget {
  const _PasswordToggleButton({
    required this.obscure,
    required this.onToggle,
  });

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: MedColors.text3,
        ),
      ),
    );
  }
}
