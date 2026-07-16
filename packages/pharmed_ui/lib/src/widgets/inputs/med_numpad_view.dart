import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────────────────────────
// NumpadView / showNumpadView
// [SWREQ-UI-INPUT-NUMPAD-001]
//
// ÖNCE: tamamen Theme.of(context).colorScheme kullanıyordu → client ve
//   manager'da farklı renkler (token dışı sapma). ARTIK: tamamen MedColors
//   token'ı + MedRadius + MedShadows + MedTextStyles.
//
// Dokunmatik sayısal giriş dialog'u. Kabin işlem ekranlarında doz/miktar
// girişi için (MedDoseStepper, MedValueCard tetikler).
//
// Sınıf: Class A (görsel girdi)
// ─────────────────────────────────────────────────────────────────

/// Numpad dialog'unu açar, girilen değeri String olarak döndürür (iptal → null).
Future<String?> showNumpadView(BuildContext context, {String? hintText, String? title, String? initialValue}) async {
  final resolvedTitle = title ?? context.l10n.numpad_defaultTitle;
  final controller = TextEditingController(text: initialValue);

  if (initialValue != null) {
    controller.selection = TextSelection.fromPosition(TextPosition(offset: initialValue.length));
  }

  final result = await showDialog<String?>(
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: MedColors.surface,
            borderRadius: MedRadius.xl3All,
            border: Border.all(color: MedColors.border),
            boxShadow: MedShadows.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(resolvedTitle, style: MedTextStyles.titleMd()),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(null),
                      borderRadius: MedRadius.mdAll,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(PhosphorIcons.x(), size: 20, color: MedColors.text2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── İçerik ──
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: NumpadView(
                  hintText: hintText,
                  controller: controller,
                  onSubmit: () => Navigator.of(context).pop(controller.text),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  controller.dispose();
  return result;
}

class NumpadView extends StatelessWidget {
  const NumpadView({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.buttonHeight = 72,
    this.hintText,
  });

  final TextEditingController controller;
  final double buttonHeight;
  final VoidCallback onSubmit;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Ekran (Display) ──
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: MedColors.surface2,
            borderRadius: MedRadius.xl2All,
            border: Border.all(color: MedColors.border),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MedFonts.title,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: MedColors.blue,
              letterSpacing: 2,
            ),
            enabled: false, // sistem klavyesi açılmasın
            decoration: InputDecoration.collapsed(
              hintText: hintText ?? '0',
              hintStyle: TextStyle(color: MedColors.text4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ── Tuşlar ──
        _buildRow(['1', '2', '3']),
        _buildRow(['4', '5', '6']),
        _buildRow(['7', '8', '9']),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      spacing: 12.0,
      children: values
          .map(
            (val) => Expanded(
              child: _NumpadButton(text: val, height: buttonHeight, onTap: () => _insertText(val)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      spacing: 12.0,
      children: [
        // Backspace
        Expanded(
          child: _NumpadActionButton(
            icon: PhosphorIcons.backspace(),
            height: buttonHeight,
            backgroundColor: MedColors.redLight,
            iconColor: MedColors.red,
            onTap: _backspace,
          ),
        ),
        // 0
        Expanded(
          child: _NumpadButton(text: '0', height: buttonHeight, onTap: () => _insertText('0')),
        ),
        // Submit
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, TextEditingValue value, child) {
              final hasText = value.text.isNotEmpty;
              return _NumpadActionButton(
                icon: PhosphorIcons.check(),
                height: buttonHeight,
                backgroundColor: hasText ? MedColors.blue : MedColors.surface3,
                iconColor: hasText ? MedColors.surface : MedColors.text4,
                onTap: hasText ? onSubmit : () {},
              );
            },
          ),
        ),
      ],
    );
  }

  void _insertText(String myText) {
    final text = controller.text;
    final textSelection = controller.selection;

    if (myText == '.' && text.contains('.')) return;

    String newText;
    int newCursorPosition;

    if (textSelection.start >= 0) {
      final start = text.substring(0, textSelection.start);
      final end = text.substring(textSelection.end, text.length);
      newText = start + myText + end;
      newCursorPosition = textSelection.start + myText.length;
    } else {
      newText = text + myText;
      newCursorPosition = newText.length;
    }

    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newCursorPosition);
  }

  void _backspace() {
    final text = controller.text;
    final textSelection = controller.selection;
    final selectionLength = textSelection.end - textSelection.start;

    if (text.isEmpty) return;

    String newText;
    int newCursorPosition;

    if (selectionLength > 0) {
      final start = text.substring(0, textSelection.start);
      final end = text.substring(textSelection.end, text.length);
      newText = start + end;
      newCursorPosition = textSelection.start;
    } else if (textSelection.start > 0) {
      final start = text.substring(0, textSelection.start - 1);
      final end = text.substring(textSelection.start, text.length);
      newText = start + end;
      newCursorPosition = textSelection.start - 1;
    } else {
      return;
    }

    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newCursorPosition);
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({required this.text, required this.onTap, required this.height});

  final String text;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.xl2All,
        child: Ink(
          height: height,
          decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.xl2All),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: MedColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumpadActionButton extends StatelessWidget {
  const _NumpadActionButton({
    required this.icon,
    required this.onTap,
    required this.height,
    this.backgroundColor,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.xl2All,
        child: Ink(
          height: height,
          decoration: BoxDecoration(color: backgroundColor ?? MedColors.surface3, borderRadius: MedRadius.xl2All),
          child: Center(child: Icon(icon, size: 28, color: iconColor ?? MedColors.text2)),
        ),
      ),
    );
  }
}
