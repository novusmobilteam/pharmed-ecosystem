// [SWREQ-UI-CELLINPUT-002] [IEC 62304 §5.5]
// Sayım ekranında (kübik ve birim doz) tek bir gözün SAYIM + SKT girişini
// toplayan kart. RefillCellCard'ın census karşılığı — farkla: fillingQuantity
// (dolum miktarı) YOK, sadece sayım + miad. SKT her zaman gösterilir (per-cell
// toggle'ı yok — sayımda fiziksel gerçek durum kaydedildiği için tek-SKT
// fallback'inin bir anlamı yok).
//
// Sınıf: Class B

part of 'master_census_view.dart';

class CensusCellCard extends StatelessWidget {
  const CensusCellCard({
    super.key,
    required this.assignment,
    required this.current,
    this.countQuantity,
    required this.miadDate,
    required this.onCountChanged,
    required this.onMiadChanged,
    this.stepLabel,
    this.density = MedValueCardDensity.compact,
  });

  final MedicineAssignment assignment;
  final double current;
  final double? countQuantity;
  final DateTime? miadDate;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<DateTime?> onMiadChanged;
  final String? stepLabel;
  final MedValueCardDensity density;

  static double _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  Future<void> _openNumpad(BuildContext context) async {
    final result = await showNumpadView(context, initialValue: countQuantity.formatFractional);
    if (result != null) onCountChanged(_parseQty(result));
  }

  Future<void> _openMiadPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: miadDate.clampedForPicker(),
      firstDate: todayDateOnly(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) onMiadChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasEntry = (countQuantity ?? 0) > 0;
    final isExpired = miadDate.isExpiredMiad;
    // Ya zorunlu-ama-boş (sayım girilmiş ama SKT yok) ya da mevcut-ama-
    // süresi-geçmiş — RefillCellCard'daki kuralla aynı.
    final miadHasError = (hasEntry && miadDate == null) || isExpired;

    final critQty = assignment.critQuantityFromBackend;
    final minQty = assignment.minQuantityFromBackend;
    final maxQty = assignment.maxQuantityFromBackend;

    final MedCellStockLevel level;
    if (current <= critQty) {
      level = MedCellStockLevel.critical;
    } else if (current <= minQty) {
      level = MedCellStockLevel.low;
    } else {
      level = MedCellStockLevel.ok;
    }

    final medicine = assignment.medicine;
    final miadText = miadDate == null ? context.l10n.dateField_placeholder : miadDate.formattedDate;
    final unitSuffix = medicine?.fillingUnitLocalized(context);

    return Container(
      padding: MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: miadHasError ? MedColors.amber : MedColors.border),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [_header(assignment, current, maxQty, level), _inputs(context, miadText, miadHasError, unitSuffix)],
      ),
    );
  }

  Widget _header(MedicineAssignment assignment, double current, double maxQty, MedCellStockLevel level) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (stepLabel != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
            child: Text(stepLabel!, style: MedTextStyles.monoSm(color: MedColors.blue)),
          ),
          const SizedBox(width: 8),
        ],
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
        Text(
          '${current.formatFractional} / ${maxQty.formatFractional}',
          style: MedTextStyles.monoMd(color: level.color),
        ),
      ],
    );
  }

  Widget _inputs(BuildContext context, String miadText, bool miadHasError, String? unitSuffix) {
    final countCard = MedValueCard(
      density: density,
      label: context.l10n.refill_label_countQty,
      value: countQuantity.formatFractional,
      placeholder: (countQuantity ?? 0) == 0,
      onTap: () => _openNumpad(context),
      suffix: unitSuffix,
    );

    final miadCard = MedValueCard(
      density: density,
      label: context.l10n.refill_label_expiryDate,
      value: miadText,
      placeholder: miadDate == null,
      hasError: miadHasError,
      trailingIcon: PhosphorIcons.calendarBlank(),
      onTap: () => _openMiadPicker(context),
    );

    // Sadece 2 alan (dolum yoktu) — eşit paylaşım, refill'in 3'lü flex'ine
    // (2/2/3) gerek yok.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(child: countCard),
        Expanded(child: miadCard),
      ],
    );
  }
}
