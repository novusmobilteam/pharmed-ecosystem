import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/rectangle_icon.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import 'dashboard_card.dart';

class CriticalStockCard extends StatelessWidget {
  const CriticalStockCard({super.key, required this.items});

  final List<CabinStock> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Stok Uyarıları',
      subtitle: 'Kritik seviyeye düşen malzemeler',
      icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
      iconColor: Colors.orange,
      child: items.isEmpty
          ? CommonEmptyStates.noData()
          : ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (c, i) => Divider(
                height: 24,
                thickness: 0.5,
                color: context.theme.dividerColor,
              ),
              itemBuilder: (context, index) {
                final stock = items[index];

                final isVeryLow = (stock.stockRatio) < 0.2;
                final statusColor = isVeryLow ? Colors.red : Colors.orange;

                return Row(
                  children: [
                    RectangleIcon(
                      icon: PhosphorIcons.package(),
                      color: statusColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.medicine?.name ?? 'Bilinmeyen İlaç',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Modern İnce Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: stock.stockRatio,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: context.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: '${stock.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                  fontSize: 16,
                                ),
                              ),
                              const TextSpan(text: ' Adet', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          "Kritik: ${stock.assignment?.criticalQuantity ?? 0}",
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
