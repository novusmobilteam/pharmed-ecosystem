import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
    this.isSelected = false,
    this.onTap, // Listede tıklama için eklendi
  });

  final Patient patient;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = patient.gender?.icon ?? PhosphorIcons.user();
    final genderColor = patient.gender?.color ?? Colors.grey;
    // Seçili olduğunda tema rengini, değilse cinsiyet rengini alır
    final accentColor = isSelected ? context.colorScheme.primary : genderColor;

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0), // Liste elemanları arası boşluk
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // MARK: Status Bar
              Container(
                width: 10, // Biraz daha daraltıldı, liste için daha zarif
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
              ),
              // MARK: Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.05) // Seçiliyken hafif arka plan
                        : context.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                    border: Border.all(
                      color: isSelected ? accentColor : accentColor.withValues(alpha: 0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${patient.name ?? ''} ${patient.surname ?? ''}'.trim().isNotEmpty
                                    ? '${patient.name} ${patient.surname}'
                                    : 'İsimsiz Hasta',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? accentColor : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                context,
                                PhosphorIcons.identificationCard(),
                                patient.tcNo ?? 'T.C. No Belirtilmemiş',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(icon, size: 32, color: accentColor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(text, style: context.textTheme.bodySmall?.copyWith(letterSpacing: 0.5)),
      ],
    );
  }
}
