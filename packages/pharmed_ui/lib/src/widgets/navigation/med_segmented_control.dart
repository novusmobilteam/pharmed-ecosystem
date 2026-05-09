import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedSegmentedControl
// [SWREQ-UI-MOL-SEG-001]
// Segmented control — min 42px yükseklik, aktif segment beyaz kart.
// Sınıf : Class A (görsel seçim)
// ─────────────────────────────────────────────────────────────────

class MedSegmentOption<T> {
  const MedSegmentOption({required this.value, required this.label});
  final T value;
  final String label;
}

/// Segmented control — aktif segment beyaz kart + gölge.
///
/// ```dart
/// MedSegmentedControl(options: [...], value: _tab, onChanged: (v) => setState(() => _tab = v))
/// MedSegmentedControl(..., fullWidth: true)  // tam genişlik
/// ```
class MedSegmentedControl<T> extends StatelessWidget {
  const MedSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.fullWidth = false,
  });

  final List<MedSegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// true → kontrol yatayda mevcut alanı doldurur, her segment eşit genişlikte.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final buttons = options.map((opt) {
      final isActive = opt.value == value;
      final button = _SegmentButton(label: opt.label, isActive: isActive, onTap: () => onChanged(opt.value));
      return fullWidth ? Expanded(child: button) : button;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: buttons,
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? MedColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive ? MedShadows.sm : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? MedColors.blue : MedColors.text3,
          ),
        ),
      ),
    );
  }
}
