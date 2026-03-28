import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/dose_stepper.dart';
import '../../../../core/widgets/info_chip.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../medicine_management/domain/entity/cabin_operation_item.dart';
import '../../../medicine_management/presentation/widgets/cabin_operation_card/cabin_operation_witness_section.dart';
import '../../../medicine_management/presentation/widgets/cabin_operation_card/prescription_status_badge.dart';
import '../../../station/domain/entity/station.dart';
import '../../../user/user.dart';
import '../../domain/utils/withdraw_check_status.dart';

/// Alım işleminde kullanılan kart widget'ı.
///
/// İade ve fire/imha için [CabinOperationCard] kullanılır.
/// Ortak alt widget'lar [cabin_operation_shared_widgets.dart]'tan gelir.
class WithdrawOperationCard extends StatelessWidget {
  final CabinOperationItem item;
  final bool isSelected;
  final bool isCompleted;
  final bool isFailed;
  final VoidCallback onTap;
  final ValueChanged<double> onQuantityChanged;
  final Function(User user) onWitnessLoggedIn;
  final VoidCallback onWitnessTap;
  final WithdrawCheckStatus checkStatus;

  /// Kullanıcının bulunduğu istasyon — needsWitness kontrolü için
  final Station? currentStation;

  const WithdrawOperationCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isCompleted,
    required this.isFailed,
    required this.onTap,
    required this.onQuantityChanged,
    required this.onWitnessLoggedIn,
    required this.onWitnessTap,
    this.checkStatus = const CheckIdle(),
    this.currentStation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final bool isCheckSuccess = checkStatus is CheckSuccess;
    final bool isCheckFailed = checkStatus is CheckFailed;

    // Stok yoksa, tamamlandıysa veya hata varsa tıklanamaz
    final bool isTappable = !item.hasNoStock && !isCompleted && !isFailed;

    final Color cardColor = isCompleted
        ? Colors.green.withValues(alpha: 0.1)
        : isFailed
        ? Colors.red.withValues(alpha: 0.05)
        : isSelected
        ? colorScheme.primaryContainer.withValues(alpha: 0.25)
        : colorScheme.surface;

    final Color borderColor = isCompleted
        ? Colors.green.withValues(alpha: 0.4)
        : isFailed
        ? Colors.red.withValues(alpha: 0.3)
        : isCheckFailed
        ? Colors.red.withValues(alpha: 0.3)
        : isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.4);

    return Opacity(
      opacity: item.hasNoStock ? 0.6 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: isTappable ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Üst satır: seçim ikonu + ilaç bilgisi + stepper ──────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _SelectionIcon(
                      isCompleted: isCompleted,
                      isSelected: isSelected,
                      isFailed: isFailed,
                      checkStatus: checkStatus,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WithdrawMedicineHeader(item: item, isSelected: isSelected, isCompleted: isCompleted),
                          if (item.hasWarnings) _WarningChips(item: item),
                        ],
                      ),
                    ),
                    // Doz stepper — tamamlanmadıysa ve stok varsa göster
                    if (!isCompleted && !item.hasNoStock)
                      Opacity(
                        opacity: isCheckSuccess ? 0.4 : 1.0,
                        child: IgnorePointer(
                          ignoring: isCheckSuccess,
                          child: DoseStepper.compact(
                            value: item.dosePiece ?? 0,
                            unit: item.medicine?.operationUnit ?? 'Adet',
                            onChanged: onQuantityChanged,
                            max: 999,
                          ),
                        ),
                      ),
                  ],
                ),

                // ── Tamamlandı bölümü ─────────────────────────────────────
                if (isCompleted) const _WithdrawCompletedSection(),

                // ── Alım hatası bölümü ────────────────────────────────────
                if (isFailed) const _WithdrawFailedSection(),

                // ── Şahit bölümü (ortak widget) ───────────────────────────
                if (item.needsWitness(currentStation: currentStation) && isSelected && !isCompleted && !isFailed)
                  CabinOperationWitnessSection(
                    item: item,
                    onWitnessLoggedIn: onWitnessLoggedIn,
                    onWitnessTap: onWitnessTap,
                    currentStation: currentStation,
                  ),

                // ── Stok yok bölümü ───────────────────────────────────────
                if (item.hasNoStock) const _NoStockSection(),

                // ── Check status bölümü ───────────────────────────────────
                if (isSelected && checkStatus is! CheckIdle) _CheckStatusSection(status: checkStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _SelectionIcon
// =============================================================================

class _SelectionIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isSelected;
  final bool isFailed;
  final WithdrawCheckStatus checkStatus;

  const _SelectionIcon({
    required this.isCompleted,
    required this.isSelected,
    required this.isFailed,
    required this.checkStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: Colors.red, size: 28);
    }
    if (checkStatus is CheckFailed) {
      return Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: Colors.red, size: 28);
    }
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

// =============================================================================
// _WithdrawMedicineHeader
// =============================================================================

class _WithdrawMedicineHeader extends StatelessWidget {
  final CabinOperationItem item;
  final bool isSelected;
  final bool isCompleted;

  const _WithdrawMedicineHeader({required this.item, required this.isSelected, required this.isCompleted});

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
                item.medicine?.name ?? '-',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected && !isCompleted ? context.colorScheme.primary : null,
                ),
              ),
            ),
            if (item.status != null) ...[const SizedBox(width: 8), PrescriptionStatusBadge(status: item.status!)],
          ],
        ),
        Text(
          'Barkod: ${item.medicine?.barcode ?? '-'}',
          style: context.textTheme.bodySmall?.copyWith(color: context.theme.hintColor),
        ),
        // Orderli alımda reçete saatini göster
        if (item.withdrawType == WithdrawType.ordered && !isCompleted)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Icon(PhosphorIcons.clock(), size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  item.prescriptionItem?.time?.formattedDateTime ?? '--:--',
                  style: context.textTheme.bodySmall?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// _WarningChips
// =============================================================================

class _WarningChips extends StatelessWidget {
  final CabinOperationItem item;

  const _WarningChips({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        spacing: 6,
        children: [
          if (item.prescriptionItem?.firstDoseEmergency ?? false)
            InfoChip(info: 'İlk Doz Acil', backgroundColor: Colors.red),
          if (item.prescriptionItem?.askDoctor ?? false)
            InfoChip(info: 'Doktora Sor', backgroundColor: Colors.deepPurple),
          if (item.prescriptionItem?.inCaseOfNecessity ?? false)
            InfoChip(info: 'Lüzum Halinde', backgroundColor: Colors.amber),
        ],
      ),
    );
  }
}

// =============================================================================
// _WithdrawCompletedSection
// =============================================================================

class _WithdrawCompletedSection extends StatelessWidget {
  const _WithdrawCompletedSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Alım Tamamlandı', style: context.textTheme.labelSmall?.copyWith(color: Colors.green[800])),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _WithdrawFailedSection
// =============================================================================

class _WithdrawFailedSection extends StatelessWidget {
  const _WithdrawFailedSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 18, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İlaç Alım İşlemi Tamamlanamadı',
                    style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red[800]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'İlaç alım işlemi sırasında bir hata oluştu. Lütfen ilacı aldığınız yere bırakın ve çekmeceyi kapatın.',
                    style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _NoStockSection
// =============================================================================

class _NoStockSection extends StatelessWidget {
  const _NoStockSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.prohibit(), size: 18, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Kabinde Stok Bulunmamaktadır',
              style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _CheckStatusSection
// =============================================================================

class _CheckStatusSection extends StatelessWidget {
  final WithdrawCheckStatus status;

  const _CheckStatusSection({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 14.0),
      child: switch (status) {
        CheckLoading() => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 4),
            Text('Kontrol ediliyor...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        CheckSuccess() => Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text('Alıma Hazır', style: TextStyle(fontSize: 12, color: Colors.green)),
          ],
        ),
        CheckFailed(:final message) => Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(message ?? 'Kontrol başarısız', style: const TextStyle(fontSize: 12, color: Colors.red)),
            ),
          ],
        ),
        CheckIdle() => const SizedBox.shrink(),
      },
    );
  }
}
