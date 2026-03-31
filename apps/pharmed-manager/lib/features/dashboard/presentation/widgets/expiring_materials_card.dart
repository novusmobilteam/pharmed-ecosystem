import 'package:flutter/material.dart';
import '../../../../core/widgets/rectangle_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import 'dashboard_card.dart';

class ExpiringMaterialsCard extends StatelessWidget {
  const ExpiringMaterialsCard({super.key, required this.items});

  final List<CabinStock> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Miad Kontrolü',
      subtitle: 'S.K.T yaklaşan ürünler',
      iconColor: Colors.redAccent,
      icon: PhosphorIcons.calendarX(PhosphorIconsStyle.fill),
      child: items.isEmpty
          ? CommonEmptyStates.noData()
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (c, i) => Divider(height: 24, thickness: 0.5, color: context.theme.dividerColor),
              itemBuilder: (context, index) {
                final stock = items[index];

                return Row(
                  children: [
                    RectangleIcon(icon: PhosphorIcons.pill(), color: stock.statusColor),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.medicine?.name ?? 'Bilinmeyen İlaç',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(PhosphorIcons.clockCounterClockwise(), size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'S.K.T: ${stock.miadDate?.formattedDate ?? '-'}',
                                style: context.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Sağ: Kalan Gün Sayısı (Renkli Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: stock.statusColor.withAlpha(24),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: stock.statusColor.withAlpha(48)),
                      ),
                      child: Text(
                        stock.expirationStatusText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: stock.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
