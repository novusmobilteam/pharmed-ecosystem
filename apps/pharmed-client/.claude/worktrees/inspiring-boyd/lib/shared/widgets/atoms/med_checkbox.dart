import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedCheckbox
// [SWREQ-UI-ATOM-CHK-001]
// Özel checkbox — 22×22px kutu, tüm satır tıklanabilir (min 44px).
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

class MedCheckbox extends StatelessWidget {
  const MedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CheckBox(value: value),
              if (label != null) ...[
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label!,
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 14,
                      color: MedColors.text,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: value ? MedColors.blue : MedColors.surface2,
        border: Border.all(
          color: value ? MedColors.blue : MedColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AnimatedOpacity(
        opacity: value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 100),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      ),
    );
  }
}
