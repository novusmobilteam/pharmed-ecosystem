// [SWREQ-CLI-CABIN-OP-011] [IEC 62304 §5.5]
// IntakeItem tabanlı ortak kabin işlem kartı.
//
// Master alım / iade / fire-imha gibi IntakeItem ile çalışan, hasta-merkezli
// master kabin işlemlerinde ortak kullanılır. RxOperationCard'ın (PrescriptionItem
// + RFID) görsel dilini taşır ama içeriği farklıdır:
//   - Seçili kartta editable doz (MedDoseStepper.compact)
//   - needsWitness + seçili ise şahit satırı
//   - Check durumu (idle/loading/success/failed)
//   - RFID gösterimi YOKTUR (master alımda RFID kullanılmaz)
//
// Eski MasterIntakeItemCard'ın yerini alır; iade/imha ekranları da bunu kullanır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../intake.dart';

class IntakeOperationCard extends StatelessWidget {
  const IntakeOperationCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.checkStatus,
    required this.currentStation,
    required this.onTap,
    required this.onDoseChanged,
    required this.onWitnessTap,
    this.doseMax = 999,
  });

  final IntakeItem item;
  final bool isSelected;
  final IntakeCheckStatus checkStatus;

  /// needsWitness kararı için kullanıcı istasyonu.
  final Station? currentStation;

  /// `null` ise kart tıklanamaz (süreç aktif / kilitli).
  final VoidCallback? onTap;
  final ValueChanged<double> onDoseChanged;
  final VoidCallback onWitnessTap;

  final double doseMax;

  bool get _hasNoStock => item.hasNoStock;
  bool get _needsWitness => item.needsWitness(currentStation: currentStation);
  bool get _isTappable => !_hasNoStock && onTap != null;

  Color get _borderColor {
    if (checkStatus is CheckFailed) return MedColors.red;
    return isSelected ? MedColors.blue : MedColors.border;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: _hasNoStock ? 0.6 : 1.0,
        child: InkWell(
          onTap: _isTappable ? onTap : null,
          borderRadius: MedRadius.lgAll,
          child: AnimatedContainer(
            //margin: EdgeInsets.all(4.0),
            duration: const Duration(milliseconds: 150),
            padding: MedSpacing.insetLg,
            decoration: BoxDecoration(
              color: isSelected ? MedColors.blueLight : MedColors.surface,
              borderRadius: MedRadius.lgAll,
              border: Border.all(color: _borderColor, width: isSelected ? 1.5 : 1),
              boxShadow: MedShadows.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            item.medicine?.name ?? '—',
                            style: MedTextStyles.titleSm(color: isSelected ? MedColors.blue : MedColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.medicine?.barcode != null)
                            Text(item.medicine!.barcode!, style: MedTextStyles.monoXs(color: MedColors.text3)),
                        ],
                      ),
                    ),

                    if (isSelected && !_hasNoStock)
                      MedDoseStepper.compact(
                        value: item.dosePiece ?? 0,
                        unit: item.medicine?.operationUnit ?? 'Adet',
                        onChanged: onDoseChanged,
                        max: doseMax,
                      ),
                  ],
                ),

                if (_hasNoStock) const _NoStockChip(),
                if (item.prescriptionItem != null) RxFlagChips(item: item.prescriptionItem!),
                if (_needsWitness && isSelected && !_hasNoStock) _WitnessRow(item: item, onTap: onWitnessTap),
                if (checkStatus is! CheckIdle) _CheckStatusRow(status: checkStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoStockChip extends StatelessWidget {
  const _NoStockChip();

  @override
  Widget build(BuildContext context) {
    return MedInfoChip(
      backgroundColor: MedColors.redLight,
      foregroundColor: MedColors.red,
      info: 'Kabinde stok bulunmamaktadır',
    );
  }
}

class _WitnessRow extends StatelessWidget {
  const _WitnessRow({required this.item, required this.onTap});

  final IntakeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final witness = item.witness;
    final hasWitness = witness != null;

    return InkWell(
      onTap: onTap,
      borderRadius: MedRadius.mdAll,
      child: Container(
        padding: MedSpacing.insetMd,
        decoration: BoxDecoration(
          color: hasWitness ? MedColors.greenLight : MedColors.amberLight,
          borderRadius: MedRadius.mdAll,
          border: Border.all(color: hasWitness ? MedColors.green : MedColors.amber),
        ),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                hasWitness ? 'Şahit: ${witness.fullName}' : 'Şahit girişi gerekli',
                style: MedTextStyles.bodyMd(color: hasWitness ? MedColors.green : MedColors.amber),
              ),
            ),
            if (!hasWitness)
              Icon(PhosphorIcons.caretRight(), size: 14, color: hasWitness ? MedColors.green : MedColors.amber),
          ],
        ),
      ),
    );
  }
}

class _CheckStatusRow extends StatelessWidget {
  const _CheckStatusRow({required this.status});

  final IntakeCheckStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      CheckLoading() => Row(
        spacing: 6,
        children: [
          const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          Text('Kontrol ediliyor...', style: MedTextStyles.monoXs(color: MedColors.text3)),
        ],
      ),
      CheckSuccess() => Row(
        spacing: 6,
        children: [
          Icon(PhosphorIcons.check(), size: 14, color: MedColors.green),
          Text('Alıma hazır', style: MedTextStyles.monoXs(color: MedColors.green)),
        ],
      ),
      CheckFailed(:final message) => Row(
        spacing: 6,
        children: [
          Icon(PhosphorIcons.x(), size: 14, color: MedColors.red),
          Expanded(
            child: Text(
              message ?? 'Kontrol başarısız',
              style: MedTextStyles.monoXs(color: MedColors.red),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      CheckIdle() => const SizedBox.shrink(),
    };
  }
}
