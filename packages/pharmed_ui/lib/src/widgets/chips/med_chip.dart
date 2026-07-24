import 'package:flutter/material.dart';

import '../../theme/theme.dart';

// ─────────────────────────────────────────────────────────────────
// MedChip — Statik bilgi etiketi (birleşik primitive)
// [SWREQ-UI-CHIP-001]
//
// Şu ayrı chip'lerin ORTAK görsel iskeleti:
//   MedInfoChip · MedDoseChip · MedRxMovementChip · MedTimeChip ·
//   MedRemainingDayChip
//
// Bunların hepsi "container + border + (ikon) + metin + (sayaç)" idi;
// tek farkları renk/ikon/metnin nereden geldiğiydi. O veri-türetme işi
// domain wrapper'larda kalır; MedChip yalnızca String/Color/IconData alır.
// SAF UI — pharmed_core bağımlılığı YOK.
//
// Renk için iki yol:
//   • style: MedChipStyle preset'i (neutral/info/success/warning/danger)
//   • ya da background/foreground/border ile tam manuel override
//
// Sınıf: Class A (görsel; iş kararı çağırana ait)
// ─────────────────────────────────────────────────────────────────

/// Hazır renk preset'leri. Token semantik renklerine bağlı.
enum MedChipStyle { neutral, info, success, warning, danger }

/// Köşe biçimi. rounded = küçük köşe (chip), pill = tam oval (badge).
enum MedChipShape { rounded, pill }

/// Yoğunluk. md = standart, sm = sıkı (eski MedBadge.sm).
enum MedChipSize { sm, md, lg }

class MedChip extends StatelessWidget {
  const MedChip({
    super.key,
    required this.label,
    this.icon,
    this.count,
    this.style = MedChipStyle.neutral,
    this.shape = MedChipShape.rounded,
    this.size = MedChipSize.md,
    this.background,
    this.foreground,
    this.border,
    this.mono = true,
    this.showBorder = true,
    this.fullWidth = false,
    this.onTap,
    this.onDeleted,
  });

  final String label;

  /// Soldaki opsiyonel ikon (RemainingDayChip gibi).
  final IconData? icon;

  /// Sağdaki opsiyonel sayaç (FilterChip gibi). null → gizli.
  final int? count;

  /// Hazır renk preset'i. [background]/[foreground] verilirse yok sayılır.
  final MedChipStyle style;

  /// Köşe biçimi. pill → eski MedBadge oval görünümü.
  final MedChipShape shape;

  /// Yoğunluk. sm → eski MedBadge.sm.
  final MedChipSize size;

  /// Manuel renk override — preset'i ezer.
  final Color? background;
  final Color? foreground;
  final Color? border;

  /// Metin mono mu (teknik değer: doz, lot, tarih) yoksa sans mı.
  final bool mono;

  /// Kenarlık çizilsin mi. Eski MedBadge kenarlıksızdı → pill'de genelde false.
  final bool showBorder;

  /// Tam genişlik kaplasın mı (EPC satırı gibi). true → label Expanded + ellipsis.
  final bool fullWidth;

  /// Tıklanabilir yapmak için. null → statik etiket.
  final VoidCallback? onTap;

  /// Verilirse chip'in sağında bir "x" butonu render edilir (aktif filtre
  /// gösterimi gibi kaldırılabilir etiketler için). [onTap]'ten bağımsız
  /// çalışır — silme ikonuna tıklamak [onTap]'i tetiklemez.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final preset = _presetColors(style);
    final bg = background ?? preset.background;
    final fg = foreground ?? preset.foreground;
    final borderColor = border ?? preset.border ?? fg.withValues(alpha: 0.22);

    final radius = shape == MedChipShape.pill ? MedRadius.xlAll : MedRadius.smAll;
    final (padX, padY, textStyle, deleteIconSize) = switch (size) {
      MedChipSize.sm => (
        MedSpacing.sm + 1,
        1.0,
        mono ? MedTextStyles.monoXs(color: fg) : MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
        12.0,
      ),
      MedChipSize.md => (
        MedSpacing.md.toDouble(),
        MedSpacing.xs + 1,
        mono
            ? MedTextStyles.monoSm(color: fg, weight: FontWeight.w600)
            : MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
        14.0,
      ),

      MedChipSize.lg => (
        MedSpacing.md.toDouble(),
        MedSpacing.md + 1,
        mono
            ? MedTextStyles.monoSm(color: fg, weight: FontWeight.w600)
            : MedTextStyles.bodySm(color: fg, weight: FontWeight.w600),
        16.0,
      ),
    };

    final chip = AnimatedContainer(
      duration: MedMotion.fast,
      curve: MedMotion.standard,
      padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: showBorder ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: MedSpacing.xs)],
          fullWidth
              ? Expanded(
                  child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
                )
              : Text(label, style: textStyle),
          if (count != null) ...[
            const SizedBox(width: MedSpacing.xs),
            Text(
              '$count',
              style: MedTextStyles.monoSm(color: fg, weight: FontWeight.w700),
            ),
          ],

          if (onDeleted != null) ...[
            const SizedBox(width: MedSpacing.xs),
            GestureDetector(
              onTap: onDeleted,
              behavior: HitTestBehavior.opaque,
              // Dokunmatik hedefi ikonun görsel boyutundan büyük tutuyoruz
              // (44px kuralı chip boyutuna sığmaz, bu yüzden sadece padding ile yaklaşıyoruz).
              child: Padding(
                padding: const EdgeInsets.all(MedSpacing.xs),
                child: Icon(Icons.close, size: deleteIconSize, color: fg),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}

// ── Preset renk çözümü ───────────────────────────────────────────

final class _ChipColors {
  const _ChipColors({required this.background, required this.foreground, this.border});
  final Color background;
  final Color foreground;
  final Color? border;
}

_ChipColors _presetColors(MedChipStyle s) {
  return switch (s) {
    MedChipStyle.neutral => const _ChipColors(
      background: MedColors.surface3,
      foreground: MedColors.text2,
      border: MedColors.border,
    ),
    MedChipStyle.info => const _ChipColors(background: MedColors.blueLight, foreground: MedColors.blue),
    MedChipStyle.success => const _ChipColors(background: MedColors.greenLight, foreground: MedColors.green),
    MedChipStyle.warning => const _ChipColors(background: MedColors.amberLight, foreground: MedColors.amber),
    MedChipStyle.danger => const _ChipColors(background: MedColors.redLight, foreground: MedColors.red),
  };
}
