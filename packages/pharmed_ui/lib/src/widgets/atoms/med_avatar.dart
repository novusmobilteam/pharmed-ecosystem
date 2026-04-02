import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedAvatar
// [SWREQ-UI-ATOM-007]
// Kullanım: Hasta baş harfi avatarı — "SE", "FY", "KD"
// Tasarımda 5 farklı renk paleti var, AvatarPalette ile seçilir.
// Sınıf: Class A
// ─────────────────────────────────────────────────────────────────

enum AvatarPalette { blue, green, amber, purple, rose }

class MedAvatar extends StatelessWidget {
  const MedAvatar({super.key, required this.initials, required this.palette, this.size = 24});

  final String initials;
  final AvatarPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(palette);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: MedFonts.title,
          fontSize: size * 0.375, // 9px at 24, orantılı
          fontWeight: FontWeight.w800,
          color: colors.text,
          height: 1,
        ),
      ),
    );
  }

  _AvatarColors _resolveColors(AvatarPalette palette) {
    return switch (palette) {
      AvatarPalette.blue => const _AvatarColors(
        background: Color(0xFFEFF6FF),
        text: Color(0xFF2563EB),
        border: Color(0xFFBFDBFE),
      ),
      AvatarPalette.green => const _AvatarColors(
        background: Color(0xFFF0FDF4),
        text: Color(0xFF16A34A),
        border: Color(0xFFBBF7D0),
      ),
      AvatarPalette.amber => const _AvatarColors(
        background: Color(0xFFFFFBEB),
        text: Color(0xFFD97706),
        border: Color(0xFFFDE68A),
      ),
      AvatarPalette.purple => const _AvatarColors(
        background: Color(0xFFFDF4FF),
        text: Color(0xFF9333EA),
        border: Color(0xFFE9D5FF),
      ),
      AvatarPalette.rose => const _AvatarColors(
        background: Color(0xFFFFF1F2),
        text: Color(0xFFE11D48),
        border: Color(0xFFFECDD3),
      ),
    };
  }
}

final class _AvatarColors {
  const _AvatarColors({required this.background, required this.text, required this.border});
  final Color background;
  final Color text;
  final Color border;
}
