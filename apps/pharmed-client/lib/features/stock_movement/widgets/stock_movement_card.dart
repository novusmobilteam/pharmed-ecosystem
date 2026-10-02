import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Tasarım sistemindeki kart kalıbı: renkli nokta + büyük harf başlık,
/// ince bölücü, gövde.
class StockMovementCard extends StatelessWidget {
  const StockMovementCard({super.key, required this.title, required this.child, this.dotColor, this.trailing});

  final String title;
  final Widget child;
  final Color? dotColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.midAll,
        boxShadow: MedShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor ?? MedColors.blue, shape: BoxShape.circle),
                ),
                const SizedBox(width: MedSpacing.md),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: MedTextStyles.titleSm(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: MedColors.border),
          Expanded(
            child: Padding(padding: MedSpacing.insetLg, child: child),
          ),
        ],
      ),
    );
  }
}

/// Kart içinde veri yokken gösterilen sade boş durum.
class StockMovementCardEmpty extends StatelessWidget {
  const StockMovementCardEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.movement_emptyDescription, textAlign: TextAlign.center, style: MedTextStyles.bodySm()),
    );
  }
}
