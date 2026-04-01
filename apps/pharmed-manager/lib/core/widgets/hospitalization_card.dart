import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';

class HospitalizationCard extends StatelessWidget {
  const HospitalizationCard({super.key, required this.hospitalization, this.isBaby = false, this.isSelected = false});

  final Hospitalization hospitalization;
  final bool isBaby;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    final icon = isBaby ? PhosphorIcons.baby() : patient?.gender?.icon;
    final genderColor = isBaby ? Colors.cyan : patient?.gender?.color;
    final accentColor = isSelected ? context.colorScheme.primary : hospitalization.statusColor;

    return IntrinsicHeight(
      child: Row(
        children: [
          // MARK: Status
          Container(
            width: 12,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
          ),
          // MARK: Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), bottomRight: Radius.circular(16.0)),
                color: context.colorScheme.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: accentColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MARK: Hasta Bilgileri
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient?.fullName ?? '-',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                context,
                                PhosphorIcons.stethoscope(),
                                hospitalization.doctor?.fullName ?? 'Doktor Belirtilmemiş',
                              ),
                            ],
                          ),
                        ),
                        Icon(icon, size: 40, color: genderColor),
                      ],
                    ),
                    const Divider(height: 24, thickness: 0.4),
                    // MARK: Servis, Oda, Yatak
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip(
                          context,
                          PhosphorIcons.hospital(),
                          hospitalization.physicalService?.name ?? '-',
                          Colors.blueGrey,
                        ),
                        _buildStatusChip(
                          context,
                          PhosphorIcons.door(),
                          'Oda: ${hospitalization.roomNo ?? '-'}',
                          Colors.indigo,
                        ),
                        _buildStatusChip(
                          context,
                          PhosphorIcons.bed(),
                          'Yatak: ${hospitalization.bedNo ?? '-'}',
                          Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // MARK: Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFooterInfo(context, 'T.C No', patient?.tcNo ?? '-'),
                        _buildFooterInfo(context, 'Giriş Tarihi', hospitalization.admissionDate?.formattedDate ?? '-'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Küçük Bilgi Satırları (Doktor vs.)
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Text(text, style: context.textTheme.bodyMedium),
      ],
    );
  }

  // Badge/Chip
  Widget _buildStatusChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // En alt kısımdaki gri küçük bilgiler
  Widget _buildFooterInfo(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelSmall),
        Text(value, style: context.textTheme.labelMedium),
      ],
    );
  }
}
