import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/info_chip.dart';
import '../../../../station/domain/entity/station.dart';
import '../../../domain/entity/cabin_operation_item.dart';
import 'cabin_operation_dose_badge.dart';
import 'cabin_operation_witness_section.dart';
import 'prescription_status_badge.dart';

/// İade ve fire/imha işlemlerinde kullanılan ortak kart widget'ı.
///
/// - [operationType] == refund  → şahit bölümü gösterilmez
/// - [operationType] == disposal → [item.needsWitness] true ise şahit bölümü gösterilir
///
/// Alım işlemi için [WithdrawOperationCard] kullanılmaya devam eder.
class CabinOperationCard extends StatelessWidget {
  final CabinOperationItem item;
  final bool isSelected;
  final bool isCompleted;
  final VoidCallback? onTap;

  /// Şahit seçimi için — disposal'da needsWitness true ise zorunlu
  final Function(User user)? onWitnessLoggedIn;

  /// Şahit dialog'unu açmak için
  final VoidCallback? onWitnessTap;

  /// Kullanıcının bulunduğu istasyon — needsWitness kontrolü için
  final Station? currentStation;

  const CabinOperationCard({
    super.key,
    required this.item,
    required this.isSelected,
    this.isCompleted = false,
    this.onTap,
    this.onWitnessLoggedIn,
    this.onWitnessTap,
    this.currentStation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final Color cardColor = isCompleted
        ? Colors.green.withValues(alpha: 0.07)
        : isSelected
        ? colorScheme.primaryContainer.withValues(alpha: 0.25)
        : colorScheme.surface;

    final Color borderColor = isCompleted
        ? Colors.green.withValues(alpha: 0.35)
        : isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: isCompleted ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Üst satır: seçim ikonu + ilaç bilgisi + doz badge ──────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: _SelectionIcon(isCompleted: isCompleted, isSelected: isSelected),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MedicineHeader(item: item, isSelected: isSelected, isCompleted: isCompleted),
                  ),
                  const SizedBox(width: 8),
                  CabinOperationDoseBadge(item: item),
                ],
              ),

              const SizedBox(height: 10),
              Divider(height: 1, color: context.theme.dividerColor),
              const SizedBox(height: 10),

              // ── Alt satır: meta bilgiler ────────────────────────────────
              _MetaInfoSection(item: item),

              // ── Tamamlandı bölümü ──────────────────────────────────────
              if (isCompleted) _CompletedSection(operationType: item.operationType),

              // ── Şahit bölümü (disposal + needsWitness + seçili) ────────
              if (item.needsWitness(currentStation: currentStation) &&
                  isSelected &&
                  !isCompleted &&
                  onWitnessLoggedIn != null &&
                  onWitnessTap != null)
                CabinOperationWitnessSection(
                  item: item,
                  onWitnessLoggedIn: onWitnessLoggedIn!,
                  onWitnessTap: onWitnessTap!,
                  currentStation: currentStation,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isSelected;

  const _SelectionIcon({required this.isCompleted, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.green, size: 28);
    }
    return Icon(
      isSelected ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill) : PhosphorIcons.circle(),
      color: isSelected ? context.colorScheme.primary : context.colorScheme.outline,
      size: 28,
    );
  }
}

class _MedicineHeader extends StatelessWidget {
  final CabinOperationItem item;
  final bool isSelected;
  final bool isCompleted;

  const _MedicineHeader({required this.item, required this.isSelected, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İlaç adı + status badge yan yana
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                item.medicine?.name ?? 'Bilinmeyen İlaç',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected && !isCompleted ? context.colorScheme.primary : null,
                ),
              ),
            ),
            if (item.status != null) ...[const SizedBox(width: 8), PrescriptionStatusBadge(status: item.status!)],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Barkod: ${item.medicine?.barcode ?? '-'}',
          style: context.textTheme.bodySmall?.copyWith(color: context.theme.hintColor, letterSpacing: 0.5),
        ),
        // Reçete uyarı chip'leri
        if (item.hasWarnings) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (item.prescriptionItem?.firstDoseEmergency ?? false)
                InfoChip(info: 'İlk Doz Acil', backgroundColor: Colors.red),
              if (item.prescriptionItem?.askDoctor ?? false)
                InfoChip(info: 'Doktora Sor', backgroundColor: Colors.deepPurple),
              if (item.prescriptionItem?.inCaseOfNecessity ?? false)
                InfoChip(info: 'Lüzum Halinde', backgroundColor: Colors.amber),
            ],
          ),
        ],
      ],
    );
  }
}

class _MetaInfoSection extends StatelessWidget {
  final CabinOperationItem item;

  const _MetaInfoSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final displayDate = item.applicationDate;
    final appUser = item.applicationUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabinOperationInfoChip(
              title: 'Alım Tarihi',
              value: displayDate != null ? '${displayDate.formattedDate} ${displayDate.formattedTime}' : '--',
            ),
            const SizedBox(height: 2),
            CabinOperationInfoChip(title: 'Alan Kişi', value: appUser?.fullName ?? '-'),
          ],
        ),
        // İade tipini sadece refund'da göster
        if (item.operationType == CabinOperationType.refund && item.medicine?.returnType != null)
          CabinOperationInfoChip(title: 'İade Tipi', value: item.medicine!.returnType!.label),
      ],
    );
  }
}

class _CompletedSection extends StatelessWidget {
  final CabinOperationType operationType;

  const _CompletedSection({required this.operationType});

  String get _label => switch (operationType) {
    CabinOperationType.refund => 'İade Tamamlandı',
    CabinOperationType.disposal => 'Fire/İmha Tamamlandı',
    CabinOperationType.withdraw => 'Alım Tamamlandı',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              _label,
              style: context.textTheme.labelSmall?.copyWith(color: Colors.green[800], fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
