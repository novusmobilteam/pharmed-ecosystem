import 'package:flutter/material.dart';
import '../../../../core/widgets/rectangle_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';
import '../../../prescription/domain/entity/prescription.dart';
import 'dashboard_card.dart';

class UnappliedQrCodeCard extends StatelessWidget {
  const UnappliedQrCodeCard({super.key, required this.items});

  final List<Prescription> items;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Okutulmayan Karekodlar',
      subtitle: 'Alımı tamamlanmamış aktif reçeteler',
      iconColor: Colors.purpleAccent,
      icon: PhosphorIcons.qrCode(PhosphorIconsStyle.fill),
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
                final hosp = item.hospitalization;
                final patient = hosp?.patient;
                final doctor = hosp?.doctor;

                final remainingCount = item.remainingCount ?? 0;

                return Row(
                  spacing: 12,
                  children: [
                    RectangleIcon(
                      icon: PhosphorIcons.barcode(),
                      color: Colors.purpleAccent,
                    ),

                    // Bilgi Alanı
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${patient?.name ?? ""} ${patient?.surname ?? ""}',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Alt bilgi satırı: Doktor ve Oda
                          Row(
                            spacing: 8,
                            children: [
                              _buildInfoChip(
                                context,
                                PhosphorIcons.door(),
                                'Oda: ${hosp?.roomNo ?? "-"}',
                              ),
                              _buildInfoChip(
                                context,
                                PhosphorIcons.bed(),
                                'Yatak: ${hosp?.bedNo ?? "-"}',
                              ),
                              _buildInfoChip(
                                context,
                                PhosphorIcons.stethoscope(),
                                ' ${doctor?.fullName ?? "-"}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bekleyen Karekod Sayısı (Vurgulu)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: remainingCount > 5 ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$remainingCount İlaç',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  // Küçük bilgi etiketleri için yardımcı widget
  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}
