// Master kabin dolum/sayım ekranlarında (kübik ve birim doz) tek bir gözün
// giriş kartı. RefillCellCard + CensusCellCard birleştirildi — fark yalnızca
// dolum alanının olup olmamasıydı (fillingQuantity/onFillingChanged null ise
// dolum alanı hiç gösterilmez, sayım ekranındaki davranış).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// execution/cabin_cell_input_card.dart
// Header (ilaç adı + barkod + stok seviyesi rengi) hâlâ burada çiziliyor —
// bu 3 ekranda da AYNI, domain'e özel değil. Ama alan İÇERİĞİ artık
// `fields` listesiyle dışarıdan geliyor; kart kaç alan geldiğine bakıp
// sadece DİZİLİMİ (Row/Column/flex) kararlaştırır, alanların NE olduğunu
// bilmez. hasError (ör. SKT süresi geçmiş) hesaplaması da çağıranın işi —
// kart bunu bir bool olarak alır, kendi hesaplamaz.

class CabinExecutionGridCard extends StatelessWidget {
  const CabinExecutionGridCard({
    super.key,
    required this.assignment,
    required this.current,
    required this.fields, // sırayla dizilecek MedValueCard'lar (ya da türevleri)
    this.hasError = false, // true → dış çerçeve kenarı amber
    this.stepLabel,
    this.density = MedValueCardDensity.compact,
  });

  final MedicineAssignment assignment;
  final double current;
  final List<Widget> fields;
  final bool hasError;
  final String? stepLabel;
  final MedValueCardDensity density;

  @override
  Widget build(BuildContext context) {
    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;
    final maxQty = assignment.maxQuantityFromBackend;
    final bool isComfortable = density == MedValueCardDensity.comfortable;

    final MedCellStockLevel level;
    if (current <= critQty) {
      level = MedCellStockLevel.critical;
    } else if (current <= minQty) {
      level = MedCellStockLevel.low;
    } else {
      level = MedCellStockLevel.ok;
    }

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: hasError ? MedColors.amber : MedColors.border),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [_header(maxQty, level, isComfortable), _layoutFields()],
      ),
    );
  }

  Widget _header(double maxQty, MedCellStockLevel level, bool isComfortable) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.medicine?.name ?? '—',
                style: MedTextStyles.titleMd(color: MedColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                assignment.medicine?.barcode ?? '—',
                style: MedTextStyles.bodyMd(color: MedColors.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (stepLabel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
            child: Text(stepLabel!, style: MedTextStyles.monoSm(color: MedColors.blue)),
          ),

        // Text(
        //   '${current.formatFractional} / ${maxQty.formatFractional}',
        //   style: MedTextStyles.monoMd(color: level.color),
        // ),
      ],
    );
  }

  /// Eski `_inputs`'teki density-bazlı yerleşim mantığının GENELLEŞTİRİLMİŞİ.
  /// 1-2 alan → eşit Expanded Row. 3 alan → comfortable'da ilk 2'si Row,
  /// 3.'sü altta; compact'te tek Row (flex 2/2/3) — davranış eskiyle birebir
  /// (count+filling+miad = 3 alan durumu). 3'ten fazlası şimdilik wrap'e
  /// düşer, henüz kullanılan bir senaryo yok.
  Widget _layoutFields() {
    if (fields.isEmpty) return const SizedBox.shrink();

    if (fields.length <= 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: fields.map((f) => Expanded(child: f)).toList(),
      );
    }

    if (fields.length == 3) {
      if (density == MedValueCardDensity.comfortable) {
        return Column(
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(flex: 2, child: fields[0]),
                Expanded(flex: 2, child: fields[1]),
              ],
            ),
            fields[2],
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(flex: 2, child: fields[0]),
          Expanded(flex: 2, child: fields[1]),
          Expanded(flex: 3, child: fields[2]),
        ],
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: fields);
  }
}
