import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// SktRow
// [SWREQ-UI-MOL-002] [HAZ-008]
// Kullanım: SKT listesindeki tek satır — yaklaşan/geçmiş ilaç
// Atomlar : StatusBar + ilaç adı (MedLabel) + detay + gün göstergesi
// Sınıf  : Class B — geçmiş SKT gözden kaçarsa hasta riski oluşur
// ─────────────────────────────────────────────────────────────────

enum SktStatus { expired, critical, warning }

class SktRow extends StatelessWidget {
  const SktRow({
    super.key,
    required this.medicineName,
    required this.detail,
    required this.status,
    this.daysRemaining,
    this.onTap,
  });

  final String medicineName;

  /// Örn: "A-12 · 6 torba · Lot: SF22A"
  final String detail;

  final SktStatus status;

  /// null → geçmiş SKT (expired)
  final int? daysRemaining;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: MedRadius.mdAll,
        ),
        child: Row(
          children: [
            // Sol renkli çubuk
            StatusBar(color: colors.bar, height: 38),
            const SizedBox(width: 10),

            // İlaç bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MedLabel(
                    text: medicineName,
                    variant: MedLabelVariant.monoValue,
                    color: status == SktStatus.expired ? MedColors.red : MedColors.text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  MedLabel(text: detail, variant: MedLabelVariant.monoDetail),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Gün göstergesi
            _DaysIndicator(status: status, daysRemaining: daysRemaining),
          ],
        ),
      ),
    );
  }

  _SktColors _resolveColors(SktStatus status) {
    return switch (status) {
      SktStatus.expired => _SktColors(
        background: const Color(0xFFFFF8F8),
        border: const Color(0xFFFCA5A5),
        bar: MedColors.redDark,
      ),
      SktStatus.critical => _SktColors(background: MedColors.surface2, border: MedColors.border2, bar: MedColors.red),
      SktStatus.warning => _SktColors(background: MedColors.surface2, border: MedColors.border2, bar: MedColors.amber),
    };
  }
}

class _DaysIndicator extends StatelessWidget {
  const _DaysIndicator({required this.status, required this.daysRemaining});

  final SktStatus status;
  final int? daysRemaining;

  @override
  Widget build(BuildContext context) {
    if (status == SktStatus.expired) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'GEÇTİ',
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: MedColors.red,
            ),
          ),
          const SizedBox(height: 1),
          Text('imha et', style: MedTextStyles.monoXs(color: MedColors.red)),
        ],
      );
    }

    final color = switch (status) {
      SktStatus.critical => MedColors.red,
      SktStatus.warning => MedColors.amber,
      SktStatus.expired => MedColors.red,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${daysRemaining ?? 0}', style: MedTextStyles.titleMd(color: color)),
        const SizedBox(height: 1),
        Text('gün kaldı', style: MedTextStyles.monoXs()),
      ],
    );
  }
}

final class _SktColors {
  const _SktColors({required this.background, required this.border, required this.bar});
  final Color background;
  final Color border;
  final Color bar;
}
