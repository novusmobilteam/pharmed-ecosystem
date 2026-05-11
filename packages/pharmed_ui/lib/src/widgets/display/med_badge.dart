import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedBadge
// [SWREQ-UI-ATOM-001]
// Kullanım: Widget header badge'leri — "Kilitli", "5 Kalem", "7 Bekliyor"
// Sınıf  : Class A (görsel bilgi, iş kararı vermez)
// ─────────────────────────────────────────────────────────────────

enum MedBadgeVariant { green, amber, red, blue, neutral }

enum MedBadgeSize { sm, md }

/// Yuvarlak köşeli badge — 5 renk varyantı, 2 boyut.
///
/// ```dart
/// MedBadge(label: '7 Bekliyor', variant: MedBadgeVariant.amber)
/// MedBadge(label: '3', variant: MedBadgeVariant.red, size: MedBadgeSize.sm)
/// ```
class MedBadge extends StatelessWidget {
  const MedBadge({super.key, required this.label, required this.variant, this.size = MedBadgeSize.md});

  final String label;
  final MedBadgeVariant variant;
  final MedBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);
    final (hPad, vPad, style) = switch (size) {
      MedBadgeSize.sm => (7.0, 1.0, MedTextStyles.monoXs(color: colors.foreground)),
      MedBadgeSize.md => (10.0, 2.0, MedTextStyles.monoSm(color: colors.foreground)),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(color: colors.background, borderRadius: MedRadius.xlAll),
      child: Text(label, style: style),
    );
  }

  _BadgeColors _resolveColors(MedBadgeVariant variant) {
    return switch (variant) {
      MedBadgeVariant.green => _BadgeColors(MedColors.greenLight, MedColors.green),
      MedBadgeVariant.amber => _BadgeColors(MedColors.amberLight, MedColors.amber),
      MedBadgeVariant.red => _BadgeColors(MedColors.redLight, MedColors.red),
      MedBadgeVariant.blue => _BadgeColors(MedColors.blueLight, MedColors.blue),
      MedBadgeVariant.neutral => _BadgeColors(MedColors.surface3, MedColors.text3),
    };
  }
}

final class _BadgeColors {
  const _BadgeColors(this.background, this.foreground);
  final Color background;
  final Color foreground;
}
