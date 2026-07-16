import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedRectangleIcon  (EMEKLİ / DEPRECATED)
//
// MedRectangleIconButton'ın tıklanamayan (statik) hâliydi. Artık ona
// delege ediyor: onPressed: null → statik, disabled görünüm YOK çünkü
// renkler zorunlu veriliyor.
//
// YENİ KOD İÇİN:
//   MedRectangleIconButton(
//     iconData: icon, color: bg, iconColor: fg, size: 42, onPressed: null,
//   )
//
// NOT: Eski MedRectangleIcon `Size?` alıyordu (genelde kare). Wrapper
//   width'i kullanır; kare olmayan kullanım varsa doğrudan Container'a geç.
// ─────────────────────────────────────────────────────────────────

@Deprecated('MedRectangleIconButton(onPressed: null) kullanın.')
class MedRectangleIcon extends StatelessWidget {
  const MedRectangleIcon({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    this.size,
    required this.icon,
    this.iconSize,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Size? size;
  final double? iconSize;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MedRectangleIconButton(
      iconData: icon,
      color: backgroundColor,
      iconColor: foregroundColor,
      size: size?.width ?? 42,
      iconSize: iconSize ?? 20,
      dimWhenDisabled: false,
      onPressed: null,
    );
  }
}
