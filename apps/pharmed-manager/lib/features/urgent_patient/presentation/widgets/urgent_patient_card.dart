import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/core.dart';

import '../../../patient/domain/entity/urgent_patient.dart';
import '../../../prescription/domain/entity/prescription_item.dart';

class UrgentPatientCard extends StatelessWidget {
  final UrgentPatient patientData;
  final bool isSelected;
  final Set<int> selectedItemIds; // Seçili ilaç id'leri
  final VoidCallback onTap;
  final Function(PrescriptionItem item) onItemToggled;

  const UrgentPatientCard({
    super.key,
    required this.patientData,
    this.isSelected = false,
    required this.selectedItemIds,
    required this.onTap,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    final patient = patientData.patient;
    final admissionDate = patientData.admissionDate?.formattedDateTime ?? '-';
    final items = patientData.prescriptionItems ?? [];
    final selectedCount = items.where((i) => selectedItemIds.contains(i.id)).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? context.colorScheme.primaryContainer.withValues(alpha: 0.3) : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Üst Kısım: Hasta Bilgileri + Seçim
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient?.name ?? ''} ${patient?.surname ?? ''}'.toUpperCase(),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Oluşturulma Tarihi: $admissionDate', style: context.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  // Seçili ilaç sayısı rozeti
                  if (isSelected && items.isNotEmpty)
                    _SelectionBadge(selectedCount: selectedCount, totalCount: items.length),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
                      key: ValueKey(isSelected),
                      color: isSelected ? context.colorScheme.primary : context.colorScheme.outline,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İlaç Listesi
          if (items.isNotEmpty)
            _MedicineSection(items: items, selectedItemIds: selectedItemIds, onItemToggled: onItemToggled),
        ],
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  final int selectedCount;
  final int totalCount;

  const _SelectionBadge({required this.selectedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final isAllSelected = selectedCount == totalCount;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAllSelected
            ? context.colorScheme.primary.withValues(alpha: 0.1)
            : context.colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAllSelected
              ? context.colorScheme.primary.withValues(alpha: 0.3)
              : context.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$selectedCount/$totalCount ilaç',
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isAllSelected ? context.colorScheme.primary : context.colorScheme.secondary,
        ),
      ),
    );
  }
}

class _MedicineSection extends StatelessWidget {
  final List<PrescriptionItem> items;
  final Set<int> selectedItemIds;
  final Function(PrescriptionItem) onItemToggled;

  const _MedicineSection({required this.items, required this.selectedItemIds, required this.onItemToggled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4),
            child: Text(
              'Alınan İlaçlar (${items.length})',
              style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MedicineItemCard(
                item: item,
                isSelected: selectedItemIds.contains(item.id),
                onTap: () => onItemToggled(item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineItemCard extends StatelessWidget {
  final PrescriptionItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MedicineItemCard({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? context.colorScheme.primary.withValues(alpha: 0.08) : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary.withValues(alpha: 0.4)
              : context.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Seçim ikonu
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
                  key: ValueKey(isSelected),
                  color: isSelected ? context.colorScheme.primary : context.colorScheme.outline,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // İlaç adı
              Expanded(
                child: Text(
                  item.medicine?.name ?? 'İsimsiz İlaç',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Doz bilgisi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary.withValues(alpha: 0.1)
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.dosePiece?.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isSelected ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
