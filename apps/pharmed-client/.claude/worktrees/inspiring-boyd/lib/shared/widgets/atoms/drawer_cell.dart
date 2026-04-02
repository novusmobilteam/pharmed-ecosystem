import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// DrawerCell
// [SWREQ-UI-ATOM-008] [HAZ-003]
// Kullanım: Kabin görselindeki tek çekmece
// Stok durumu renk + alt çizgi ile görsel olarak temsil edilir.
// Sınıf: Class B — Yanlış renk stok bilgisini yanlış gösterebilir.
// ─────────────────────────────────────────────────────────────────

enum DrawerStatus { full, low, critical, empty }

class DrawerCell extends StatelessWidget {
  const DrawerCell({super.key, required this.status, this.tooltip, this.onTap});

  final DrawerStatus status;

  /// Tooltip: "A-01 · Amoksisilin" formatında
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(status);

    final cell = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 20,
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: MedRadius.smAll,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.55,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(color: colors.handle, borderRadius: MedRadius.smAll),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: cell);
    }

    return cell;
  }

  _DrawerColors _resolveColors(DrawerStatus status) {
    return switch (status) {
      DrawerStatus.full => const _DrawerColors(
        background: Color(0xFFEDF6FF),
        border: Color(0xFF90C4F5),
        handle: Color(0xFF5AAAF0),
      ),
      DrawerStatus.low => const _DrawerColors(
        background: Color(0xFFFFFBEB),
        border: Color(0xFFFCD34D),
        handle: Color(0xFFF59E0B),
      ),
      DrawerStatus.critical => const _DrawerColors(
        background: Color(0xFFFFF5F5),
        border: Color(0xFFFCA5A5),
        handle: Color(0xFFEF4444),
      ),
      DrawerStatus.empty => _DrawerColors(
        background: MedColors.surface3,
        border: MedColors.border2,
        handle: MedColors.border,
      ),
    };
  }
}

final class _DrawerColors {
  const _DrawerColors({required this.background, required this.border, required this.handle});
  final Color background;
  final Color border;
  final Color handle;
}
