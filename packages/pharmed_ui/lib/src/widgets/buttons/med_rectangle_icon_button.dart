import 'package:flutter/material.dart';

import '../../theme/theme.dart';

// ─────────────────────────────────────────────────────────────────
// MedRectangleIconButton
// [SWREQ-UI-ATOM-BTN-003]
// Kare/dikdörtgen ikon buton — tablo satır aksiyonları, toolbar,
// panel başlığı gibi yerlerde tek ikonluk dokunma hedefi.
//
// ÖNCE: Theme.of(context).colorScheme'e bağlıydı → client/manager
//   arasında token dışı sapma. ARTIK: tamamen MedColors token'ı.
//
// Boyut: `size` verilmezse MedDensity'den (touch → 44, compact → 36).
//   iconSize verilmezse size'a göre ölçeklenir (size * 0.5).
//
// Sınıf: Class A (görsel eylem; iş kararı notifier'da)
// ─────────────────────────────────────────────────────────────────
class MedRectangleIconButton extends StatelessWidget {
  const MedRectangleIconButton({
    super.key,
    required this.iconData,
    this.color,
    this.iconColor,
    this.onPressed,
    this.tooltip,
    this.size,
    this.iconSize,
    this.dimWhenDisabled = true,
  });

  final IconData iconData;

  /// Arka plan rengi. Verilmezse nötr token yüzeyi (surface3).
  final Color? color;

  /// İkon rengi. Verilmezse nötr token (text2).
  final Color? iconColor;

  final VoidCallback? onPressed;
  final String? tooltip;

  /// Kutu boyutu. null → MedDensity'den (touch: 44, compact: 36).
  final double? size;

  /// İkon boyutu. null → size'ın yarısı.
  final double? iconSize;

  /// onPressed null iken ikon soluklaşsın mı. Statik gösterim (eski
  /// MedRectangleIcon) için false; gerçek disabled buton için true.
  final bool dimWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final density = MedDensity.of(context);
    final effectiveSize = size ?? (density.isCompact ? 36.0 : 44.0);
    final effectiveIconSize = iconSize ?? effectiveSize * 0.5;

    final backgroundColor = color ?? MedColors.surface3;
    final baseIconColor = iconColor ?? MedColors.text2;
    final isEnabled = onPressed != null;

    final effectiveIconColor = (isEnabled || !dimWhenDisabled) ? baseIconColor : baseIconColor.withValues(alpha: 0.5);

    final content = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: iconColor != null ? iconColor!.withValues(alpha: 0.21) : Colors.transparent),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: MedColors.overlayBlue,
          highlightColor: MedColors.blueLight,
          child: Center(
            child: Icon(iconData, color: effectiveIconColor, size: effectiveIconSize),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) return content;
    return Tooltip(message: tooltip!, child: content);
  }
}
