part of 'cabin_assignment_picker_view.dart';

class RatioProgressIndicator extends StatelessWidget {
  const RatioProgressIndicator({super.key, this.stock, required this.assignment, this.overrideQuantity});

  final CabinStock? stock;
  final CabinAssignment assignment;
  final double? overrideQuantity;

  @override
  Widget build(BuildContext context) {
    final double current = (stock?.quantity ?? 0).toDouble();
    final double quantity = (overrideQuantity ?? current).toDouble();
    final double max = (assignment.maxQuantityFromBackend).toDouble();

    final double ratio = max > 0 ? (quantity / max).clamp(0.0, 1.0) : 0.0;
    final int percentage = (ratio * 100).toInt();

    // Doluluk rengini belirleyelim (Kritikse kırmızı, doluysa yeşil)
    Color progressColor = context.colorScheme.primary;
    if (ratio <= 0.2) {
      progressColor = context.colorScheme.error; // %20 altı kritik
    } else if (ratio >= 0.9) {
      progressColor = Colors.green; // %90 üstü dolu
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Toplam: ${quantity.toInt()}/${max.toInt()}",
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: quantity == 0 ? context.colorScheme.error : null,
              ),
            ),
            Text("%$percentage", style: context.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
