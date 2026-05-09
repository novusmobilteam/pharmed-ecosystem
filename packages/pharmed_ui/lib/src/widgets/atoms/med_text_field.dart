import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_ui/src/widgets/inputs/input_field_style.dart';
import 'package:pharmed_ui/src/widgets/inputs/med_input_decorator.dart';

// ─────────────────────────────────────────────────────────────────
// MedTextField
// [SWREQ-UI-ATOM-TF-001]
// Dokunmatik HMI text input. Min yükseklik InputFieldTheme'den gelir.
// Desteklenen durumlar: normal, focused, error, success, disabled.
// Tüm görsel değerleri InputFieldTheme.of(context) üzerinden alır —
// sıfır hardcoded tasarım değeri.
// Sınıf: Class A (görsel girdi, iş mantığı dışında)
// ─────────────────────────────────────────────────────────────────

/// [MedTextFieldState] artık [MedFieldState] ile eşanlamlıdır.
/// Mevcut kullanım alanları için geriye dönük uyumluluk typedef'i.
typedef MedTextFieldState = MedFieldState;

/// Tek satırlık veya çok satırlı metin girişi.
///
/// Görsel kabuk tamamen [MedInputDecorator] tarafından yönetilir;
/// bu widget yalnızca focus durumunu ve TextField içeriğini yönetir.
///
/// Stil (köşe yarıçapı, padding, label boyutu) otomatik olarak
/// [InputFieldTheme.of(context)] üzerinden alınır:
/// - pharmed-client: [InputFieldStyle.client] — geniş, yuvarlak, dokunmatik
/// - pharmed-manager: [InputFieldStyle.manager] — sıkı, keskin, fare dostu
///
/// Örnek kullanım:
/// ```dart
/// MedTextField(
///   label: 'Hasta Adı',
///   hint: 'Adı giriniz',
///   onChanged: (val) => print(val),
/// )
/// ```
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
    this.fieldState = MedFieldState.normal,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.maxLength,
    this.readOnly = false,
    this.textVariant,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Input alanı üstünde gösterilen etiket.
  final String? label;

  /// Input boşken gösterilen ipucu metni.
  final String? hint;

  /// Hata yokken gösterilen yardımcı metin.
  final String? helperText;

  /// Hata mesajı — varsa [fieldState]'i hata moduna zorlar.
  final String? errorText;

  final Widget? prefixIcon;
  final Widget? suffixWidget;

  /// Input'un görsel durumu. [MedFieldState.error] kırmızı kenarlık,
  /// [MedFieldState.success] yeşil kenarlık gösterir.
  final MedFieldState fieldState;

  final bool enabled;

  /// `true` ise metin gizlenir — şifre alanları için.
  final bool obscureText;

  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final int? maxLength;
  final bool readOnly;

  /// Input metni için [MedLabel] varyantı. Belirtilmezse
  /// [InputFieldStyle.inputFontSize] ve [InputFieldStyle.inputFontWeight]
  /// kullanılır.
  final MedLabelVariant? textVariant;

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

  TextStyle _inputTextStyle(InputFieldStyle style) {
    if (widget.textVariant != null) {
      return MedLabel.resolveStyle(widget.textVariant!, color: MedColors.text);
    }
    return TextStyle(
      fontFamily: MedFonts.sans,
      fontSize: style.inputFontSize,
      fontWeight: style.inputFontWeight,
      color: widget.enabled ? MedColors.text : MedColors.text3,
      height: 1.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = InputFieldTheme.of(context);

    return MedInputDecorator(
      label: widget.label,
      errorText: widget.errorText,
      helperText: widget.helperText,
      enabled: widget.enabled,
      isFocused: _focused,
      fieldState: widget.fieldState,
      child: Row(
        children: [
          if (widget.prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: MedSpacing.sm),
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
              textAlign: style.inputTextAlign,
              style: _inputTextStyle(style),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: style.inputFontSize,
                  color: MedColors.text4,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                counterText: '',
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
              padding: const EdgeInsets.only(left: MedSpacing.sm),
              child: widget.suffixWidget!,
            ),
        ],
      ),
    );
  }
}

class _PasswordToggleButton extends StatelessWidget {
  const _PasswordToggleButton({required this.obscure, required this.onToggle});

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.only(left: MedSpacing.sm),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: MedColors.text3,
        ),
      ),
    );
  }
}
