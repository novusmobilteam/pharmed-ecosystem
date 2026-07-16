import 'package:flutter/material.dart';

import '../theme/med_density.dart';
import '../theme/med_motion.dart';
import '../theme/med_tokens.dart';

// ─────────────────────────────────────────────────────────────────
// MedSelectable — Seçilebilir etiketli eleman (birleşik atom)
// [SWREQ-UI-ATOM-SEL-001]
//
// Önceden ayrı ayrı yazılmış ÜÇ widget'ı tek çatıda toplar:
//   • MedToggleButton    → MedSelectable(shape: pill)
//   • MedFilterChip _Chip → MedSelectable(shape: chip)
//   • MedSegmentedButton  → MedSelectableGroup(shape: segment)
//
// Renk çözümü MedButton ile aynı dili konuşur (accent + selected).
// Boyut: varsayılan MedDensity'den (tema) gelir; `size` param'ı override eder.
//
// Sınıf: Class A (görsel eylem; iş kararı notifier'da)
// ─────────────────────────────────────────────────────────────────

/// Vurgu rengi ailesi — MedButton variant'larının seçim karşılığı.
/// (MedToggleAccent'in genişletilmiş, tek-doğru-kaynak hâli.)
enum MedAccent { blue, amber, green, red }

/// Görsel biçim. Davranış aynı; yalnızca kenar yuvarlaklığı/dolgu dili değişir.
enum MedSelectableShape {
  /// Hap görünümü — eski MedToggleButton. Nötr halde gri yüzey + kenarlık.
  pill,

  /// Filtre chip'i — eski _Chip. Seçiliyken dolu accent, nötrde açık yüzey.
  chip,

  /// Segment üyesi — MedSelectableGroup içinde kullanılır. Kenarlıksız,
  /// seçiliyken dolu accent. Tek başına da kullanılabilir.
  segment,
}

/// Boyut override — verilmezse MedDensity'den türetilir.
enum MedSelectableSize { sm, md }

class MedSelectable extends StatelessWidget {
  const MedSelectable({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.accent = MedAccent.blue,
    this.shape = MedSelectableShape.pill,
    this.size,
    this.trailing,
    this.count,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final MedAccent accent;
  final MedSelectableShape shape;

  /// null → MedDensity'den (compact ise sm, touch ise md). Verilirse override.
  final MedSelectableSize? size;

  /// Sağda ek widget (örn. filtre caret'i).
  final Widget? trailing;

  /// Sağda opsiyonel sayaç (eski MedFilterChip'in count'u). null → gizli.
  final int? count;

  /// Grup içinde eşit genişlik için true (segment kullanır).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final density = MedDensity.of(context);
    final effectiveSize = size ?? (density.isCompact ? MedSelectableSize.sm : MedSelectableSize.md);
    final sizing = _sizing(effectiveSize, density);
    final colors = _colors(shape, accent, selected);
    final radius = _radius(shape);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: sizing.iconSize, color: colors.foreground), SizedBox(width: sizing.gap)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MedTextStyles.bodyMd(color: colors.foreground, weight: selected ? FontWeight.w700 : FontWeight.w600),
          ),
        ),
        if (count != null) ...[
          SizedBox(width: sizing.gap),
          Text(
            '$count',
            style: MedTextStyles.monoSm(color: colors.foreground, weight: selected ? FontWeight.w700 : FontWeight.w400),
          ),
        ],
        if (trailing != null) ...[SizedBox(width: sizing.gap), trailing!],
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(radius),
      child: AnimatedContainer(
        duration: MedMotion.fast,
        curve: MedMotion.standard,
        height: sizing.height,
        padding: EdgeInsets.symmetric(horizontal: sizing.paddingX),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.all(radius),
          border: colors.borderColor != null ? Border.all(color: colors.borderColor!) : null,
        ),
        child: content,
      ),
    );
  }
}

// ── Boyut çözümü (Density-aware) ─────────────────────────────────

final class _Sizing {
  const _Sizing({required this.height, required this.paddingX, required this.iconSize, required this.gap});
  final double height;
  final double paddingX;
  final double iconSize;
  final double gap;
}

_Sizing _sizing(MedSelectableSize s, MedDensity d) {
  return switch (s) {
    MedSelectableSize.sm => _Sizing(
      height: d.isCompact ? 36 : 38,
      paddingX: MedSpacing.lg,
      iconSize: 15,
      gap: MedSpacing.sm,
    ),
    MedSelectableSize.md => _Sizing(
      height: d.controlMinHeight,
      paddingX: MedSpacing.lg,
      iconSize: 16,
      gap: MedSpacing.sm,
    ),
  };
}

// ── Şekil → radius ───────────────────────────────────────────────

Radius _radius(MedSelectableShape shape) {
  return switch (shape) {
    MedSelectableShape.pill => MedRadius.md,
    MedSelectableShape.chip => MedRadius.sm,
    MedSelectableShape.segment => MedRadius.md,
  };
}

// ── Renk çözümü (accent + selected + shape) ──────────────────────

final class _Colors {
  const _Colors({required this.background, required this.foreground, this.borderColor});
  final Color background;
  final Color foreground;
  final Color? borderColor;
}

({Color base, Color light, Color dark}) _accentTones(MedAccent a) {
  return switch (a) {
    MedAccent.blue => (base: MedColors.blue, light: MedColors.blueLight, dark: MedColors.blueDark),
    MedAccent.amber => (base: MedColors.amber, light: MedColors.amberLight, dark: MedColors.amber),
    MedAccent.green => (base: MedColors.green, light: MedColors.greenLight, dark: MedColors.green),
    MedAccent.red => (base: MedColors.red, light: MedColors.redLight, dark: MedColors.redDark),
  };
}

_Colors _colors(MedSelectableShape shape, MedAccent accent, bool selected) {
  final tones = _accentTones(accent);

  if (!selected) {
    // Nötr — üç şekil de gri yüzey. (pill/chip kenarlıklı, segment kenarlıksız)
    return _Colors(
      background: MedColors.surface2,
      foreground: MedColors.text2,
      borderColor: shape == MedSelectableShape.segment ? null : MedColors.border,
    );
  }

  return switch (shape) {
    // pill: açık dolgu + accent metin/kenarlık (eski MedToggleButton dili)
    MedSelectableShape.pill => _Colors(background: tones.light, foreground: tones.base, borderColor: tones.base),
    // chip: dolu accent + beyaz metin (eski _Chip dili)
    MedSelectableShape.chip => _Colors(background: tones.base, foreground: MedColors.surface, borderColor: tones.base),
    // segment: dolu accent + beyaz metin, kenarlıksız (grup track içinde)
    MedSelectableShape.segment => _Colors(background: tones.base, foreground: MedColors.surface, borderColor: null),
  };
}

// ─────────────────────────────────────────────────────────────────
// MedSelectableGroup — birden çok MedSelectable'ı yöneten kaplar
//
// shape'e göre iki mod:
//   • chip/pill → yatay scroll edilebilir grup (eski MedFilterChipGroup)
//   • segment   → eşit bölünmüş track içinde segmented control
//                 (eski MedSegmentedButton; 180ms token'lı geçiş)
//
// Generic: T herhangi bir tip (enum/int/String/model). Eşitlik `==`.
// ─────────────────────────────────────────────────────────────────
class MedSelectableGroup<T> extends StatelessWidget {
  const MedSelectableGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    this.accent = MedAccent.blue,
    this.shape = MedSelectableShape.chip,
    this.size,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelBuilder;
  final IconData? Function(T value)? iconBuilder;
  final MedAccent accent;
  final MedSelectableShape shape;
  final MedSelectableSize? size;

  @override
  Widget build(BuildContext context) {
    if (shape == MedSelectableShape.segment) {
      return _SegmentedTrack<T>(
        options: options,
        selected: selected,
        onChanged: onChanged,
        labelBuilder: labelBuilder,
        iconBuilder: iconBuilder,
        accent: accent,
        size: size,
      );
    }

    // chip / pill → yatay scroll grubu
    final density = MedDensity.of(context);
    final effectiveSize = size ?? (density.isCompact ? MedSelectableSize.sm : MedSelectableSize.md);
    final rowHeight = _sizing(effectiveSize, density).height;

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: MedSpacing.sm),
        itemBuilder: (context, i) {
          final option = options[i];
          return MedSelectable(
            label: labelBuilder(option),
            icon: iconBuilder?.call(option),
            selected: option == selected,
            onTap: () => onChanged(option),
            accent: accent,
            shape: shape,
            size: size,
          );
        },
      ),
    );
  }
}

/// Segmented control track — eşit bölünmüş, tek track içinde.
/// Seçili segment 180ms token'lı geçişle dolgulanır (kayan arkaplan değil,
/// karar gereği her segment kendi rengini animasyonlar).
class _SegmentedTrack<T> extends StatelessWidget {
  const _SegmentedTrack({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    required this.accent,
    this.size,
  });

  final List<T> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T value) labelBuilder;
  final IconData? Function(T value)? iconBuilder;
  final MedAccent accent;
  final MedSelectableSize? size;

  @override
  Widget build(BuildContext context) {
    final density = MedDensity.of(context);
    final effectiveSize = size ?? (density.isCompact ? MedSelectableSize.sm : MedSelectableSize.md);
    final height = _sizing(effectiveSize, density).height + 8; // track padding payı
    const trackPad = MedSpacing.xs;

    return Container(
      height: height,
      padding: const EdgeInsets.all(trackPad),
      decoration: BoxDecoration(
        color: MedColors.surface3,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _SegmentCell(
                label: labelBuilder(option),
                icon: iconBuilder?.call(option),
                selected: option == selected,
                accent: accent,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentCell extends StatelessWidget {
  const _SegmentCell({
    required this.label,
    this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final MedAccent accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(MedSelectableShape.segment, accent, selected);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MedMotion.fast,
        curve: MedMotion.standard,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: selected ? colors.background : Colors.transparent,
          borderRadius: MedRadius.mdAll,
          boxShadow: selected ? MedShadows.sm : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? colors.foreground : MedColors.text2),
              const SizedBox(width: MedSpacing.sm),
            ],
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: MedMotion.fast,
                style: MedTextStyles.bodyMd(
                  color: selected ? colors.foreground : MedColors.text2,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
