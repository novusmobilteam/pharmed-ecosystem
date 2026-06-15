import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedToggleButton
// [SWREQ-UI-ATOM-BTN-002]
// Dokunmatik HMI için seçilebilir (toggle) buton / pill bileşeni.
// MedButton ile aynı dili kullanır (variant + size + token renkleri).
// 48px varsayılan yükseklik (input hizası), 38px sm boyut.
//
// Kullanım örnekleri:
//   - "Hastalarım" pill'i:   selected = aktif görünüm
//   - ordered/orderless toggle: selected = true, accent = amber/blue
//   - Filtre menüsü tetikleyici: selected = false, child = PopupMenuButton sarmalar
//
// Sınıf: Class A (görsel eylem; iş kararı notifier'da)
// ─────────────────────────────────────────────────────────────────

/// Seçili durumdaki vurgu rengi. MedButton'daki variant'ın toggle karşılığı.
enum MedToggleAccent { blue, amber, green, red }

enum MedToggleSize { sm, md }

/// Seçilebilir buton/pill — ikon + label, selected durumuna göre renklenir.
///
/// ```dart
/// MedToggleButton(
///   label: 'Hastalarım',
///   icon: PhosphorIcons.user(),
///   selected: viewType == PatientViewType.myPatients,
///   onTap: notifier.togglePatientView,
/// )
/// ```
class MedToggleButton extends StatelessWidget {
  const MedToggleButton({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.accent = MedToggleAccent.blue,
    this.size = MedToggleSize.md,
    this.trailing,
  });

  final String label;
  final IconData? icon;

  /// Seçili mi? Seçiliyse [accent] renginde, değilse nötr (gri) görünür.
  final bool selected;

  final VoidCallback? onTap;

  /// Seçili durumdaki vurgu rengi.
  final MedToggleAccent accent;

  final MedToggleSize size;

  /// Sağda ek bir ikon (örn. filtre için caret). Opsiyonel.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(accent, selected);
    final sizing = _resolveSizing(size);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizing.radius),
      child: Container(
        height: sizing.height,
        padding: sizing.padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(sizing.radius),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: sizing.iconSize, color: colors.foreground),
              SizedBox(width: sizing.gap),
            ],
            Text(
              label,
              style: MedTextStyles.bodySm(color: colors.foreground, weight: FontWeight.w600),
            ),
            if (trailing != null) ...[SizedBox(width: sizing.gap), trailing!],
          ],
        ),
      ),
    );
  }
}

// ── Renk çözümü ──────────────────────────────────────────────────────────────────

final class _ToggleColors {
  const _ToggleColors({required this.background, required this.foreground, required this.borderColor});
  final Color background;
  final Color foreground;
  final Color borderColor;
}

_ToggleColors _accentPair(MedToggleAccent accent) {
  return switch (accent) {
    MedToggleAccent.blue => const _ToggleColors(
      background: MedColors.blueLight,
      foreground: MedColors.blue,
      borderColor: MedColors.blue,
    ),
    MedToggleAccent.amber => const _ToggleColors(
      background: MedColors.amberLight,
      foreground: MedColors.amber,
      borderColor: MedColors.amber,
    ),
    MedToggleAccent.green => const _ToggleColors(
      background: MedColors.greenLight,
      foreground: MedColors.green,
      borderColor: MedColors.green,
    ),
    MedToggleAccent.red => const _ToggleColors(
      background: MedColors.redLight,
      foreground: MedColors.red,
      borderColor: MedColors.red,
    ),
  };
}

_ToggleColors _resolveColors(MedToggleAccent accent, bool selected) {
  if (selected) return _accentPair(accent);
  // Nötr (seçili değil) — gri yüzey.
  return const _ToggleColors(
    background: MedColors.surface2,
    foreground: MedColors.text2,
    borderColor: MedColors.border,
  );
}

// ── Boyut çözümü ─────────────────────────────────────────────────────────────────

final class _ToggleSizing {
  const _ToggleSizing({
    required this.height,
    required this.padding,
    required this.radius,
    required this.iconSize,
    required this.gap,
  });
  final double height;
  final EdgeInsets padding;
  final double radius;
  final double iconSize;
  final double gap;
}

_ToggleSizing _resolveSizing(MedToggleSize s) {
  return switch (s) {
    MedToggleSize.sm => const _ToggleSizing(
      height: 38,
      padding: EdgeInsets.symmetric(horizontal: 14),
      radius: 8,
      iconSize: 15,
      gap: 6,
    ),
    MedToggleSize.md => const _ToggleSizing(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 14),
      radius: 8,
      iconSize: 15,
      gap: 6,
    ),
  };
}
