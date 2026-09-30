import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/stock_movement_notifier.dart';
import 'stock_movement_palette.dart';

/// Üst bar: tarih aralığı segmentleri + yenile, altında tip ve kabin filtre chip'leri.
class StockMovementToolbar extends StatelessWidget {
  const StockMovementToolbar({super.key, required this.notifier});

  final StockMovementNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasFilter = notifier.selectedTypes.isNotEmpty || notifier.selectedCabinIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _RangeSegments(notifier: notifier),
            const SizedBox(width: MedSpacing.lg),
            Text(
              '${StockMovementDateFormat.full(notifier.rangeStart)} – ${StockMovementDateFormat.full(notifier.rangeEnd)}',
              style: MedTextStyles.monoMd(),
            ),
            const Spacer(),
            _IconTouchButton(
              icon: PhosphorIcons.arrowsClockwise(),
              tooltip: l10n.movement_refreshTooltip,
              onPressed: notifier.isFetching ? null : notifier.refresh,
            ),
          ],
        ),
        const SizedBox(height: MedSpacing.lg),
        SizedBox(
          height: MedSpacing.touchTarget,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final type in StationTransactionType.values)
                _FilterChip(
                  label: type.label(context),
                  color: StockMovementPalette.of(type),
                  selected: notifier.selectedTypes.contains(type),
                  onTap: () => notifier.toggleType(type),
                ),
              if (notifier.availableCabins.length > 1) ...[
                const VerticalDivider(width: MedSpacing.xl3, indent: 8, endIndent: 8, color: MedColors.border),
                for (final cabin in notifier.availableCabins)
                  _FilterChip(
                    label: cabin.cabinName,
                    icon: PhosphorIcons.archive(),
                    selected: notifier.selectedCabinIds.contains(cabin.cabinId),
                    onTap: () => notifier.toggleCabin(cabin.cabinId),
                  ),
              ],
              if (hasFilter)
                Padding(
                  padding: const EdgeInsets.only(left: MedSpacing.md),
                  child: TextButton.icon(
                    onPressed: notifier.clearFilters,
                    icon: Icon(PhosphorIcons.x(), size: 16),
                    label: Text(l10n.movement_filter_clearButton),
                    style: TextButton.styleFrom(minimumSize: const Size(0, MedSpacing.touchTarget)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RangeSegments extends StatelessWidget {
  const _RangeSegments({required this.notifier});

  final StockMovementNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.movement_range_todaySegment,
      l10n.movement_range_last7DaysSegment,
      l10n.movement_range_last30DaysSegment,
      l10n.movement_range_customSegment,
    ];

    return SizedBox(
      width: 480,
      child: MedSegmentedButton(
        labels: labels,
        selectedIndex: notifier.preset.index,
        onChanged: (index) {
          final preset = StockMovementRangePreset.values[index];
          preset == StockMovementRangePreset.custom ? _pickCustomRange(context) : notifier.selectPreset(preset);
        },
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: DateTimeRange(start: notifier.rangeStart, end: notifier.rangeEnd),
      // Klavye yok: metinle tarih girme modunu (kalem ikonu) kapat.
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 640),
          child: ClipRRect(
            borderRadius: MedRadius.xlAll,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: MedColors.blue, onPrimary: Colors.white, surface: MedColors.surface),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: MedColors.surface,
                  headerBackgroundColor: MedColors.blue,
                  headerForegroundColor: Colors.white,
                  rangeSelectionBackgroundColor: MedColors.blue.withValues(alpha: 0.12),
                  dayStyle: MedTextStyles.bodyMd(),
                ),
              ),
              child: child!,
            ),
          ),
        ),
      ),
    );
    if (picked != null) await notifier.setCustomRange(picked.start, picked.end);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap, this.color, this.icon});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? MedColors.blue;
    return Padding(
      padding: const EdgeInsets.only(right: MedSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.12) : MedColors.surface,
            //border: Border.all(color: selected ? accent : MedColors.border, width: 1.5),
            borderRadius: MedRadius.xlAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: selected ? accent : null)
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
              const SizedBox(width: MedSpacing.sm),
              Text(
                label,
                style: MedTextStyles.bodySm().copyWith(fontWeight: FontWeight.w600, color: selected ? accent : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTouchButton extends StatelessWidget {
  const _IconTouchButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      constraints: const BoxConstraints.tightFor(width: MedSpacing.touchTarget, height: MedSpacing.touchTarget),
      style: IconButton.styleFrom(
        backgroundColor: MedColors.surface,
        side: const BorderSide(color: MedColors.border),
        shape: RoundedRectangleBorder(borderRadius: MedRadius.mdAll),
      ),
    );
  }
}
