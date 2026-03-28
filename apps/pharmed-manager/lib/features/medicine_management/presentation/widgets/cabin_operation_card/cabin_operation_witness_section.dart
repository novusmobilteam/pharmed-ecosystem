import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/core.dart';
import '../../../../station/domain/entity/station.dart';
import '../../../../user/user.dart';
import '../../../domain/entity/cabin_operation_item.dart';

/// Alım ve fire/imha kartlarında ortak kullanılan şahit bölümü.
///
/// [item.needsWitness] false ise bu widget'ı render etmemelisin.
class CabinOperationWitnessSection extends StatelessWidget {
  final CabinOperationItem item;
  final Function(User user) onWitnessLoggedIn;
  final VoidCallback onWitnessTap;
  final Station? currentStation;

  const CabinOperationWitnessSection({
    super.key,
    required this.item,
    required this.onWitnessLoggedIn,
    required this.onWitnessTap,
    this.currentStation,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = item.isWitnessApproved(currentStation: currentStation);

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green.withValues(alpha: 0.08) : Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isApproved ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(
              isApproved
                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                  : PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
              size: 18,
              color: isApproved ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isApproved ? 'Şahit Onaylandı' : 'Şahit Onayı Gerekiyor',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isApproved ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  if (isApproved)
                    Text(
                      item.witness?.fullName ?? '-',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onWitnessTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isApproved ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isApproved ? PhosphorIcons.arrowsClockwise() : PhosphorIcons.userPlus(PhosphorIconsStyle.bold),
                        size: 14,
                        color: isApproved ? Colors.green[800] : Colors.orange[900],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isApproved ? 'Değiştir' : 'Şahit Seç',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isApproved ? Colors.green[800] : Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
