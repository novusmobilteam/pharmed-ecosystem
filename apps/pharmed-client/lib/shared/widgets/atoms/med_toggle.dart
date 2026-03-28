import 'package:flutter/material.dart';
import 'med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedToggle
// [SWREQ-UI-ATOM-TGL-001]
// Toggle switch — 50×28px, mavi aktif, min 44px touch hedefi.
// Sınıf : Class A (görsel kontrol)
// ─────────────────────────────────────────────────────────────────

class MedToggle extends StatelessWidget {
  const MedToggle({
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
      onTap: enabled && onChanged != null
          ? () => onChanged!(!value)
          : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TrackWidget(value: value),
              if (label != null) ...[
                const SizedBox(width: 12),
                Text(
                  label!,
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 14,
                    color: MedColors.text,
                    fontWeight: FontWeight.w400,
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

class _TrackWidget extends StatelessWidget {
  const _TrackWidget({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 28,
      decoration: BoxDecoration(
        color: value ? MedColors.blue : MedColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.elasticOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x331A2332),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
