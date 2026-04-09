part of 'cabin_stock_view.dart';

class StockCell extends StatelessWidget {
  const StockCell({super.key, required this.assignment, required this.unit, this.isSelected = false});

  final CabinAssignment assignment;
  final DrawerUnit unit;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final medicine = assignment.medicine;

    //final double current = (assignment.quantity ?? 0).toDouble();
    final double current = assignment.totalQuantity.toDouble();
    final double max = (assignment.maxQuantity ?? 1).toDouble();
    final double fillRatio = (current / max).clamp(0.0, 1.0);
    final Color dynamicColor = Color.lerp(Colors.red, Colors.green, fillRatio)!;

    // final min = assignment.minQuantity ?? 0;
    // final maxQuantity = assignment.maxQuantity ?? 0;
    // final criticalQuantity = assignment.criticalQuantity ?? 0;

    return BaseUnitCell(
      isSelected: isSelected,
      workingStatus: unit.workingStatus,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillRatio,
                widthFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [dynamicColor.withValues(alpha: 0.15), dynamicColor.withValues(alpha: 0.05)],
                    ),
                  ),
                ),
              ),
            ),

            if (isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Icon(PhosphorIconsFill.checkCircle, color: context.colorScheme.primary),
              ),

            // 2. İçerik Katmanı
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // İlaç İsmi
                Text(
                  medicine?.name ?? 'Dolum Yapılmamış',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),

                if (current != 0)
                  FittedBox(
                    child: Text(
                      '${current.toInt().toString()} ${assignment.operationUnit}',
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900, color: dynamicColor),
                    ),
                  ),

                // if (min != 0 && maxQuantity != 0 && criticalQuantity != 0)
                //   Column(
                //     spacing: 2,
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           QuantityBadge(
                //             label: 'Min',
                //             value: min,
                //             unit: assignment.operationUnit,
                //           ),
                //           const SizedBox(width: 4),
                //           QuantityBadge(
                //             label: 'Max',
                //             value: maxQuantity,
                //             unit: assignment.operationUnit,
                //           ),
                //           const SizedBox(width: 4),
                //         ],
                //       ),
                //       QuantityBadge(
                //         label: 'Krt',
                //         value: criticalQuantity,
                //         isCritical: true,
                //         unit: assignment.operationUnit,
                //       ),
                //     ],
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
