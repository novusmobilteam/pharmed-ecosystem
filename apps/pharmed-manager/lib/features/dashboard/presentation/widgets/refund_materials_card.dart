import 'package:flutter/material.dart';
import '../../../../core/widgets/rectangle_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';
import '../../../medicine_refund/domain/entity/refund.dart';
import 'dashboard_card.dart';

class RefundMaterialsCard extends StatelessWidget {
  const RefundMaterialsCard({super.key, required this.items});

  final List<Refund> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'İade Bildirimleri',
      subtitle: 'Eczaneye gönderilen iade talepleri',
      iconColor: Colors.blueAccent,
      icon: PhosphorIcons.arrowUUpLeft(PhosphorIconsStyle.fill),
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
                final item = items[index];
                final material = item.medicine;
                final detail = item.prescriptionDetail;
                final quantity = item.quantity ?? 0.0;
                final reason = item.description ?? 'Sebep belirtilmedi';
                final serviceName = detail?.physicalService?.name ?? 'Genel Servis';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol: İlaç İkonu ve Miktar
                    Column(
                      children: [
                        RectangleIcon(
                          icon: PhosphorIcons.pill(),
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${quantity.toInt()} Adet',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Orta: İlaç ve Servis Bilgileri
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material?.name ?? 'Bilinmeyen İlaç',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(PhosphorIcons.hospital(), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                serviceName,
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Sebep: $reason',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sağ: Tarih ve Durum
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.receiveDate?.formattedDate ?? '-',
                          style: context.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: _getReasonColor(reason),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  // İade sebebine göre renk belirleyen yardımcı fonksiyon
  Color _getReasonColor(String reason) {
    if (reason.toLowerCase().contains('hasar')) return Colors.red;
    if (reason.toLowerCase().contains('fazla')) return Colors.orange;
    return Colors.blue;
  }
}
