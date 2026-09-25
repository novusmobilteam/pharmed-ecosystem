// widgets/cabin_shell_widgets/execution/cabin_cubic_entry_card.dart
//
// [SWREQ-CLI-RFLIST-001]
// Kübik çekmecenin TEK bir gözü için giriş kartı (sayım / ikincil miktar /
// SKT). Notifier'dan bağımsızdır; göz etiketi ve konumu çağırandan gelir
// (sol paneldeki DrawerLayoutOverviewPanel ile aynı sıralamadan türetilmeli).
//
// Sınıf: Class B

// widgets/cabin_shell_widgets/execution/cabin_cubic_entry_card.dart
//
// [SWREQ-CLI-CABINEXEC-001]
// Kübik çekmecenin TEK bir gözü için giriş kartı (sayım / ikincil miktar /
// SKT). Hangi kutuların çizileceği çağıranın verdiği callback'lerden gelir
// (boşaltmada sayım yok, sayımda ikincil miktar yok). Göz etiketi ve konumu
// sol paneldeki DrawerLayoutOverviewPanel ile aynı sıralamadan türetilmeli.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import 'cabin_operation_execution.dart';

class CabinCubicEntryCard extends StatelessWidget {
  const CabinCubicEntryCard({
    super.key,
    required this.target,
    required this.cellLabel,
    required this.cellNumber,
    required this.cellCount,
    required this.onMiadChanged,
    this.countLabel,
    this.onCountChanged,
    this.secondaryLabel,
    this.onSecondaryChanged,
    this.miadRequired = false,
    this.enabled = true,
    this.datePicker,
  }) : assert((countLabel == null) == (onCountChanged == null), 'countLabel ve onCountChanged birlikte verilmeli'),
       assert(
         (secondaryLabel == null) == (onSecondaryChanged == null),
         'secondaryLabel ve onSecondaryChanged birlikte verilmeli',
       );

  final CabinOperationTarget target;

  /// Gözün kısa etiketi (örn. "B2") — bkz. [cubicCellLabel].
  final String cellLabel;

  /// Çekmecedeki sırası (1'den başlar) ve toplam göz sayısı.
  final int cellNumber;
  final int cellCount;

  /// Sayım kutusu — verilmezse çizilmez (boşaltma).
  final String? countLabel;
  final ValueChanged<double>? onCountChanged;

  /// İkincil miktar kutusu — verilmezse çizilmez (sayım).
  final String? secondaryLabel;
  final ValueChanged<double>? onSecondaryChanged;

  final ValueChanged<DateTime?> onMiadChanged;

  /// true → SKT boşsa hata (girdi olan gözde).
  final bool miadRequired;

  final bool enabled;
  final CabinDatePicker? datePicker;

  @override
  Widget build(BuildContext context) {
    final count = target.cubicCount;
    final secondary = target.cubicSecondary;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: SingleChildScrollView(
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CellStrip(label: cellLabel, number: cellNumber, count: cellCount),
              IntrinsicHeight(
                child: Row(
                  spacing: 12.0,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (countLabel case final label?)
                      Expanded(
                        child: _QuantityBox(label: label, value: count?.toDouble() ?? 0, onChanged: onCountChanged!),
                      ),
                    if (secondaryLabel case final label?)
                      Expanded(
                        child: _QuantityBox(
                          label: label,
                          labelColor: MedColors.blue,
                          value: secondary,
                          emphasized: true,
                          onChanged: onSecondaryChanged!,
                        ),
                      ),
                  ],
                ),
              ),
              _MiadSection(
                miad: target.cubicMiad,
                required: miadRequired,
                picker: datePicker ?? defaultCabinDatePicker,
                onChanged: onMiadChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Satır-öncelikli grid konumundan kısa göz etiketi: satır harf, sütun sayı.
/// 4 sütunlu kübikte index 5 → "B2". Sol paneldeki grid ile aynı sıralama.
String cubicCellLabel(int unitIndex, {int columns = 4}) {
  final row = unitIndex ~/ columns;
  final col = unitIndex % columns + 1;
  return '${String.fromCharCode(65 + row)}$col';
}

/// Hangi gözde işlem yapıldığı — ilaç adı başlıkta olduğu için yalnızca göz.
class _CellStrip extends StatelessWidget {
  const _CellStrip({required this.label, required this.number, required this.count});

  final String label;
  final int number;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12.0,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.smAll),
          child: Text(
            context.l10n.cabinEntryCard_cellBadge(label),
            style: MedTextStyles.monoMd(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          context.l10n.cabinEntryCard_cellPosition(number, count),
          style: MedTextStyles.bodySm(color: MedColors.text3, weight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _QuantityBox extends StatelessWidget {
  const _QuantityBox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelColor,
    this.emphasized = false,
  });

  final String label;
  final Color? labelColor;
  final double value;
  final ValueChanged<double> onChanged;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            label.toUpperCase(),
            style: MedTextStyles.bodySm(color: labelColor ?? MedColors.text2, weight: FontWeight.w600),
          ),
          CabinQuantityStepper(value: value, onChanged: onChanged, emphasized: emphasized, large: true),
        ],
      ),
    );
  }
}

class _MiadSection extends StatelessWidget {
  const _MiadSection({required this.miad, required this.required, required this.picker, required this.onChanged});

  final DateTime? miad;
  final bool required;
  final CabinDatePicker picker;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = miad;
    final isMissing = required && current == null;
    final hasError = isMissing || current.isExpiredMiad;

    return Container(
      padding: MedSpacing.insetLg,
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: hasError ? MedColors.red : MedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            context.l10n.cabinEntryCard_miadTitle.toUpperCase(),
            style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600),
          ),
          Material(
            color: MedColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: MedRadius.smAll,
              side: BorderSide(color: hasError ? MedColors.red : MedColors.border),
            ),
            child: InkWell(
              borderRadius: MedRadius.smAll,
              onTap: () async {
                final picked = await picker(context, current);
                if (picked != null) onChanged(picked);
              },
              child: Container(
                height: CabinQuantityStepper.largeButtonSize,
                alignment: Alignment.center,
                child: Text(
                  current?.formattedDate ?? context.l10n.cabinEntryTable_miadPlaceholder,
                  style: MedTextStyles.monoMd(color: current != null ? MedColors.text : MedColors.text3),
                ),
              ),
            ),
          ),
          if (isMissing)
            Text(context.l10n.cabinEntryCard_miadRequired, style: MedTextStyles.bodySm(color: MedColors.red)),
        ],
      ),
    );
  }
}
