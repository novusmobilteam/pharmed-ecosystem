import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';

class CabinStatCard extends StatelessWidget {
  final String name;
  final double heat;
  final double humidity;
  final bool isOk;
  final bool isClient;

  const CabinStatCard({
    super.key,
    required this.name,
    required this.heat,
    required this.humidity,
    required this.isOk,
    this.isClient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDimensions.cardDecoration(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isClient)
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$heat°",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isOk ? context.colorScheme.onSurface : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Nem %${humidity.toInt()}",
                      style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ],
          ),
          Icon(
            isOk ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.warning(PhosphorIconsStyle.fill),
            color: isOk ? Colors.green : Colors.red,
            size: 32,
          ),
        ],
      ),
    );
  }
}
