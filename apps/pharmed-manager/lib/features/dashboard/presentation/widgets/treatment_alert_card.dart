import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/rectangle_icon.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import 'dashboard_card.dart';

class TreatmentAlertCard extends StatelessWidget {
  const TreatmentAlertCard({super.key, required this.items});

  final List<PrescriptionItem> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Tedavi Uyarıları',
      subtitle: 'Uygulama saati yaklaşan tedaviler',
      icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
      iconColor: Colors.red,
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
                final prescription = items[index];

                // Zaman Kontrolü
                final now = DateTime.now();
                final treatmentTime =
                    prescription.time ?? (prescription.times?.isNotEmpty == true ? prescription.times!.first : now);
                final isOverdue = treatmentTime.isBefore(now); // Saati geçmiş mi?
                final statusColor = isOverdue ? Colors.red : Colors.blue;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        RectangleIcon(
                          icon: isOverdue ? PhosphorIcons.warning() : PhosphorIcons.pill(),
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescription.patientName ?? 'Bilinmeyen Hasta',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prescription.medicine?.name ?? 'İlaç Bilgisi Yok',
                            style: context.textTheme.bodyMedium?.copyWith(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (prescription.description != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                prescription.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall,
                              ),
                            )
                          ]
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Sağ Alan: Saat ve Miktar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            treatmentTime.formattedTime,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${prescription.dosePiece ?? 0} Doz",
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
