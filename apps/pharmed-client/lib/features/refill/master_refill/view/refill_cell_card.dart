part of 'master_refill_view.dart';

// [SWREQ-UI-CELLINPUT-001] [IEC 62304 §5.5]
// Dolum ekranında (kübik ve birim doz) tek bir gözün sayım/işlem/miad
// girişini toplayan kart. Önceden pharmed_ui'daki generic MedCellInputCard'a
// delege ediyordu; artık kendi layout'unu doğrudan MedValueCard üzerine
// kuruyor — MedCellInputCard'ın comfortable/compact ayrımı bu ekran için
// hiç gerekmiyordu (burada hep compact kullanılıyordu), o yüzden gereksiz
// genellik kaldırıldı. Sayım/İade gibi diğer master işlemler kendi
// kartlarını aynı desende (MedValueCard + bu dosyadaki header/stock bar
// kalıbı) ayrı ayrı yazacak.
//
// Sınıf: Class B

class RefillCellCard extends StatelessWidget {
  const RefillCellCard({
    super.key,
    required this.assignment,
    required this.current,
    this.countQuantity,
    this.fillingQuantity,
    required this.miadDate,
    required this.onCountChanged,
    required this.onFillingChanged,
    this.onMiadChanged,
    this.stepLabel,
    this.density = MedValueCardDensity.compact,
  });

  final MedicineAssignment assignment;
  final double current;
  final double? countQuantity;
  final double? fillingQuantity;
  final DateTime? miadDate;
  final ValueChanged<double> onCountChanged;
  final ValueChanged<double> onFillingChanged;

  /// null → hücre bazlı SKT kapalı (MiadDate=0). Bu göz için miad girişi
  /// hiç gösterilmez; SKT üst seviyede (job/target bazında) tek yerden
  /// yönetilir (bkz. _SingleMiadHeader).
  final ValueChanged<DateTime?>? onMiadChanged;

  final String? stepLabel;
  final MedValueCardDensity density;

  static double _parseQty(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    return double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
  }

  Future<void> _openNumpad({
    required BuildContext context,
    required double? currentValue,
    required ValueChanged<double> onChanged,
  }) async {
    final result = await showNumpadView(context, initialValue: currentValue.formatFractional);
    if (result != null) onChanged(_parseQty(result));
  }

  Future<void> _openMiadPicker(BuildContext context) async {
    final onChanged = onMiadChanged;
    if (onChanged == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: miadDate.clampedForPicker(),
      firstDate: todayDateOnly(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final showMiad = onMiadChanged != null;
    final hasFilling = (fillingQuantity ?? 0) > 0;
    final isExpired = miadDate.isExpiredMiad;
    final miadHasError = showMiad && ((hasFilling && miadDate == null) || isExpired);

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
    final fillRatio = maxQty > 0 ? (current / maxQty).clamp(0.0, 1.0) : 0.0;

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
        children: [
          _header(assignment, current, maxQty, level),
          _inputs(context, showMiad, miadText, miadHasError, unitSuffix, density),
        ],
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

  Widget _inputs(
    BuildContext context,
    bool showMiad,
    String miadText,
    bool miadHasError,
    String? unitSuffix,
    MedValueCardDensity density,
  ) {
    final countCard = MedValueCard(
      density: density,
      label: context.l10n.refill_label_countQty,
      value: countQuantity.formatFractional,
      placeholder: (countQuantity ?? 0) == 0,
      onTap: () => _openNumpad(context: context, currentValue: countQuantity, onChanged: onCountChanged),
      suffix: unitSuffix,
    );
    final fillingCard = MedValueCard(
      density: density,
      label: context.l10n.refill_label_fillQty,
      value: fillingQuantity.formatFractional,
      placeholder: (fillingQuantity ?? 0) == 0,
      onTap: () => _openNumpad(context: context, currentValue: fillingQuantity, onChanged: onFillingChanged),
      suffix: unitSuffix,
    );

    if (!showMiad) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(child: countCard),
          Expanded(child: fillingCard),
        ],
      );
    }

    final miadCard = MedValueCard(
      density: density,
      label: context.l10n.refill_label_expiryDate,
      value: miadText,
      placeholder: miadDate == null,
      hasError: miadHasError,
      trailingIcon: PhosphorIcons.calendarBlank(),
      onTap: () => _openMiadPicker(context),
    );

    if (density == MedValueCardDensity.comfortable) {
      return Column(
        spacing: 8.0,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Expanded(flex: 2, child: countCard),
              Expanded(flex: 2, child: fillingCard),
            ],
          ),
          miadCard,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(flex: 2, child: countCard),
          Expanded(flex: 2, child: fillingCard),
          Expanded(flex: 3, child: miadCard),
        ],
      );
    }
  }
}
