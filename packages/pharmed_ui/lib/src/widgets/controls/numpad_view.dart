import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Numpad Dialog'unu açan fonksiyon
Future<String?> showNumpadView(
  BuildContext context, {
  String? hintText,
  String title = 'Miktar Giriniz',
  String? initialValue,
}) async {
  final controller = TextEditingController(text: initialValue);

  if (initialValue != null) {
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: initialValue.length),
    );
  }

  final result = await showDialog<String?>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24.0),
        alignment: Alignment.center,
        child: Container(
          width: 380,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.x()),
                      color: colorScheme.onSurfaceVariant,
                      onPressed: () => Navigator.of(context).pop(null),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Content ---
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
  final TextEditingController controller;
  final double buttonHeight;
  final Function() onSubmit;
  final String? hintText;

  const NumpadView({
    super.key,
    required this.controller,
    this.buttonHeight = 72, // Buton yüksekliği
    required this.onSubmit,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      spacing: 12.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Ekran (Display) ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 2,
            ),
            enabled: false, // Klavye açılmasın
            decoration: InputDecoration.collapsed(
              hintText: hintText ?? '0',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // --- Tuşlar ---
        _buildRow(context, ['1', '2', '3']),
        _buildRow(context, ['4', '5', '6']),
        _buildRow(context, ['7', '8', '9']),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> values) {
    return Row(
      spacing: 12.0,
      children: values
          .map((val) => Expanded(
                child: _NumpadButton(
                  text: val,
                  height: buttonHeight,
                  onTap: () => _insertText(val),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 12.0,
      children: [
        // Backspace
        Expanded(
          child: _NumpadActionButton(
            icon: PhosphorIcons.backspace(),
            height: buttonHeight,
            // Hata/Silme rengi tonları
            backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.5),
            iconColor: colorScheme.error,
            onTap: _backspace,
          ),
        ),

        // 0 Tuşu
        Expanded(
          child: _NumpadButton(
            text: '0',
            height: buttonHeight,
            onTap: () => _insertText('0'),
          ),
        ),

        // Submit
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, TextEditingValue value, child) {
              final bool hasText = value.text.isNotEmpty;

              return _NumpadActionButton(
                icon: PhosphorIcons.check(),
                height: buttonHeight,
                // Doluysa Primary, boşsa pasif gri
                backgroundColor: hasText ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                iconColor: hasText ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                onTap: hasText ? onSubmit : () {},
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Logic Kısmı (Aynı kaldı) ---
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
  final String text;
  final VoidCallback onTap;
  final double height;

  const _NumpadButton({
    required this.text,
    required this.onTap,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5), // Hafif gri buton
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumpadActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double height;

  const _NumpadActionButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: iconColor ?? colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
