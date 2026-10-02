import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Sıralı yatay çubuk listesi (en çok hareket gören malzemeler, kabin dağılımı).
///
/// Uzun malzeme adları grafik eksenine sığmadığı için fl_chart yerine
/// satır tabanlı çizilir; her satır dokunmatik hedef boyutundadır.
class StockMovementRankedBars extends StatelessWidget {
  const StockMovementRankedBars({super.key, required this.rows, this.color});

  final List<RankedBarRow> rows;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final max = rows.fold<int>(0, (m, r) => r.value > m ? r.value : m);
    final accent = color ?? MedColors.blue;

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
      itemBuilder: (context, i) {
        final row = rows[i];
        final ratio = max == 0 ? 0.0 : row.value / max;
        final dimmed = row.selected == false;

        return InkWell(
          onTap: row.onTap,
          borderRadius: MedRadius.smAll,
          child: Container(
            constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget),
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.sm),
            decoration: BoxDecoration(
              color: row.selected == true ? accent.withValues(alpha: 0.08) : null,
              borderRadius: MedRadius.smAll,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(row.label, style: MedTextStyles.titleSm(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (row.subLabel != null)
                        Text(
                          row.subLabel!,
                          style: MedTextStyles.monoMd(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: MedSpacing.md),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: MedRadius.smAll,
                    child: Stack(
                      children: [
                        Container(height: 10, color: MedColors.bg),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(height: 10, color: dimmed ? accent.withValues(alpha: 0.35) : accent),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    row.trailing ?? '${row.value}',
                    textAlign: TextAlign.right,
                    style: MedTextStyles.monoSm(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RankedBarRow {
  const RankedBarRow({
    required this.label,
    required this.value,
    this.subLabel,
    this.trailing,
    this.selected,
    this.onTap,
  });

  final String label;
  final String? subLabel;
  final int value;
  final String? trailing;

  /// null: seçim kavramı yok. false: başka satırlar seçili, bu soluk gösterilir.
  final bool? selected;
  final VoidCallback? onTap;
}
