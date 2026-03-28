import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedRadio & MedRadioGroup
// [SWREQ-UI-ATOM-RDO-001]
// Radio buton — 22×22px daire, tüm satır tıklanabilir (min 44px).
// MedRadioGroup: grup yönetimi için yardımcı widget.
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

class MedRadio<T> extends StatelessWidget {
  const MedRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;
  final bool enabled;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(value) : null,
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
              _RadioDot(selected: _selected),
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

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? MedColors.blue : MedColors.surface2,
        border: Border.all(
          color: selected ? MedColors.blue : MedColors.border,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: selected ? 8 : 0,
          height: selected ? 8 : 0,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Grup yardımcısı ───────────────────────────────────────────────

/// Radyo seçeneklerini dikey olarak listeleyen yardımcı widget.
class MedRadioGroup<T> extends StatelessWidget {
  const MedRadioGroup({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
  });

  final List<MedRadioOption<T>> options;
  final T? groupValue;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options
          .map(
            (opt) => MedRadio<T>(
              value: opt.value,
              groupValue: groupValue,
              onChanged: onChanged,
              label: opt.label,
              enabled: enabled && opt.enabled,
            ),
          )
          .toList(),
    );
  }
}

class MedRadioOption<T> {
  const MedRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });
  final T value;
  final String label;
  final bool enabled;
}
