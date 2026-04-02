import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedBadge
// [SWREQ-UI-ATOM-001]
// Kullanım: Widget header badge'leri — "Kilitli", "5 Kalem", "7 Bekliyor"
// Sınıf  : Class A (görsel bilgi, iş kararı vermez)
// ─────────────────────────────────────────────────────────────────

enum MedBadgeVariant { green, amber, red, blue, neutral }

class MedBadge extends StatelessWidget {
  const MedBadge({super.key, required this.label, required this.variant});

  final String label;
  final MedBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: colors.background, borderRadius: MedRadius.xlAll),
      child: Text(label, style: MedTextStyles.monoSm(color: colors.foreground)),
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
