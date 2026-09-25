// [SWREQ-CLI-RFLIST-001]
// Birim doz çekmece için göz bazlı veri giriş tablosu (sayım / ikincil
// miktar / SKT). Notifier'dan bağımsızdır — CabinOperationTarget + callback
// alır. Callback'i verilmeyen sütun çizilmez; böylece dolum, sayım vb.
// ekranlar aynı widget'ı farklı sütun setleriyle kullanır.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'cabin_operation_execution.dart';

/// SKT girişinin tablodaki davranışı.
enum CabinEntryMiadMode {
  /// Her satırda ayrı SKT alanı.
  perCell,

  /// Tablonun üstünde tek SKT alanı; satırlarda SKT sütunu yok.
  shared,

  /// SKT sütunu hiç yok.
  hidden,
}

typedef CabinStepValueChanged = void Function(int stepIndex, double value);
typedef CabinStepDateChanged = void Function(int stepIndex, DateTime? date);

class CabinUnitDoseEntryTable extends StatelessWidget {
  const CabinUnitDoseEntryTable({
    super.key,
    required this.target,
    required this.miadMode,
    this.countLabel,
    this.onCountChanged,
    this.secondaryLabel,
    this.onSecondaryChanged,
    this.onCellMiadChanged,
    this.onSharedMiadChanged,
    this.enabled = true,
    this.datePicker,
  }) : assert((countLabel == null) == (onCountChanged == null), 'countLabel ve onCountChanged birlikte verilmeli'),
       assert(
         (secondaryLabel == null) == (onSecondaryChanged == null),
         'secondaryLabel ve onSecondaryChanged birlikte verilmeli',
       ),
       assert(
         miadMode != CabinEntryMiadMode.perCell || onCellMiadChanged != null,
         'perCell modda onCellMiadChanged zorunlu',
       ),
       assert(
         miadMode != CabinEntryMiadMode.shared || onSharedMiadChanged != null,
         'shared modda onSharedMiadChanged zorunlu',
       );

  final CabinOperationTarget target;
  final CabinEntryMiadMode miadMode;

  /// Sayım sütunu — ikisi birlikte verilmezse sütun çizilmez.
  final String? countLabel;
  final CabinStepValueChanged? onCountChanged;

  /// İşleme özgü ikincil miktar (dolumda "Dolum") — vurgulu çizilir.
  final String? secondaryLabel;
  final CabinStepValueChanged? onSecondaryChanged;

  final CabinStepDateChanged? onCellMiadChanged;
  final ValueChanged<DateTime?>? onSharedMiadChanged;

  /// false → tüm girişler pasif (örn. çekmece henüz açık değil / kayıt sürüyor).
  final bool enabled;

  /// Tarih seçici — verilmezse Flutter'ın standart seçicisi kullanılır.
  final CabinDatePicker? datePicker;

  bool get _hasCount => onCountChanged != null;
  bool get _hasSecondary => onSecondaryChanged != null;
  bool get _hasMiadColumn => miadMode == CabinEntryMiadMode.perCell;

  @override
  Widget build(BuildContext context) {
    final picker = datePicker ?? _defaultDatePicker;
    final sharedMiad = target.singleMiad;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.55,
        child: Column(
          spacing: 8.0,
          children: [
            if (miadMode == CabinEntryMiadMode.shared)
              _SharedMiadBar(
                miad: sharedMiad,
                hasError: (target.hasEntry && sharedMiad == null) || sharedMiad.isExpiredMiad,
                picker: picker,
                onChanged: onSharedMiadChanged!,
              ),
            _Header(countLabel: countLabel, secondaryLabel: secondaryLabel, showMiad: _hasMiadColumn),
            Expanded(
              child: ListView.separated(
                itemCount: target.steps.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final stepIndex = target.steps.length - 1 - index;
                  final step = target.steps[stepIndex];
                  final miad = step.miadDate;

                  // Göz bazlı SKT zorunluluğu hangi miktara bakar: ikincil sütun varsa
                  // (dolum) ona, yoksa (sayım) sayıma.
                  final entry = (_hasSecondary ? step.secondaryQuantity : step.countQuantity) ?? 0;
                  final miadHasError =
                      miadMode == CabinEntryMiadMode.perCell && ((entry > 0 && miad == null) || miad.isExpiredMiad);

                  return _Row(
                    key: ValueKey('cell-$stepIndex'),
                    stepIndex: stepIndex,
                    medicine: target.assignment.medicine,
                    hasError: miadHasError,
                    count: _hasCount
                        ? _QuantityStepper(
                            value: step.countQuantity ?? 0,
                            onChanged: (v) => onCountChanged!(stepIndex, v),
                          )
                        : null,
                    secondary: _hasSecondary
                        ? _QuantityStepper(
                            value: step.secondaryQuantity ?? 0,
                            emphasized: true,
                            onChanged: (v) => onSecondaryChanged!(stepIndex, v),
                          )
                        : null,
                    miad: _hasMiadColumn
                        ? _MiadCell(
                            date: miad,
                            hasError: miadHasError,
                            picker: picker,
                            onChanged: (d) => onCellMiadChanged!(stepIndex, d),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<DateTime?> _defaultDatePicker(BuildContext context, DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    // 2099-12-31 backend'in boş göz işaretidir — kullanıcı seçememeli.
    lastDate: DateTime(2098, 12, 31),
  );
}

abstract final class _Cols {
  static const double cell = 48;
  static const double stepper = 3 * _StepButton.size + 8;
  static const double miad = 150;
  static const double gap = 12;
}

class _Header extends StatelessWidget {
  const _Header({required this.countLabel, required this.secondaryLabel, required this.showMiad});

  final String? countLabel;
  final String? secondaryLabel;
  final bool showMiad;

  @override
  Widget build(BuildContext context) {
    final base = MedTextStyles.bodySm(color: MedColors.text3, weight: FontWeight.w600);
    Widget label(String text, {Color? color, TextAlign align = TextAlign.center}) => Text(
      text.toUpperCase(),
      textAlign: align,
      style: color != null ? base.copyWith(color: color) : base,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: _Cols.gap,
        children: [
          SizedBox(width: _Cols.cell, child: label(context.l10n.inconsistency_compartmentLabel)),
          Expanded(child: label(context.l10n.cabinAssignmentList_medicineColumn, align: TextAlign.start)),
          if (countLabel case final text?) SizedBox(width: _Cols.stepper, child: label(text)),
          if (secondaryLabel case final text?)
            SizedBox(
              width: _Cols.stepper,
              child: label(text, color: MedColors.blue),
            ),
          if (showMiad) SizedBox(width: _Cols.miad, child: label(context.l10n.refill_label_expiryDate)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.stepIndex,
    required this.medicine,
    required this.hasError,
    this.count,
    this.secondary,
    this.miad,
  });

  final int stepIndex;
  final Medicine? medicine;
  final bool hasError;
  final Widget? count;
  final Widget? secondary;
  final Widget? miad;

  @override
  Widget build(BuildContext context) {
    final unit = medicine?.fillingUnitLocalized(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        borderRadius: MedRadius.mdAll,
        border: Border.all(color: hasError ? MedColors.red : MedColors.border),
      ),
      child: Row(
        spacing: _Cols.gap,
        children: [
          SizedBox(
            width: _Cols.cell,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
              child: Text(
                (stepIndex + 1).toString().padLeft(2, '0'),
                style: MedTextStyles.monoMd(color: MedColors.text2),
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: medicine?.name ?? '-', style: MedTextStyles.titleSm()),
                  if (unit != null)
                    TextSpan(
                      text: '  $unit',
                      style: MedTextStyles.bodySm(color: MedColors.text3),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count != null) SizedBox(width: _Cols.stepper, child: count),
          if (secondary != null) SizedBox(width: _Cols.stepper, child: secondary),
          if (miad != null) SizedBox(width: _Cols.miad, child: miad),
        ],
      ),
    );
  }
}

/// − değer + — dokunmatik hedef 44px, 1'er artar, 0'ın altına inmez.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged, this.emphasized = false});

  final double value;
  final ValueChanged<double> onChanged;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final text = value == value.roundToDouble() ? value.toInt().toString() : value.toString();
    final style = emphasized
        ? MedTextStyles.titleMd(color: MedColors.blue).copyWith(fontWeight: FontWeight.w700)
        : MedTextStyles.titleMd(color: MedColors.text2);

    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          onTap: value > 0 ? () => onChanged((value - 1).clamp(0, double.infinity).toDouble()) : null,
        ),
        Expanded(
          child: Text(text, textAlign: TextAlign.center, style: style),
        ),
        _StepButton(icon: Icons.add, onTap: () => onChanged(value + 1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onTap});

  static const double size = 44;

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MedColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: MedRadius.smAll,
        side: const BorderSide(color: MedColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.smAll,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: 18, color: onTap != null ? MedColors.text2 : MedColors.text3.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

class _MiadCell extends StatelessWidget {
  const _MiadCell({required this.date, required this.hasError, required this.picker, required this.onChanged});

  final DateTime? date;
  final bool hasError;
  final CabinDatePicker picker;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: MedRadius.smAll,
      onTap: () async {
        final picked = await picker(context, date);
        if (picked != null) onChanged(picked);
      },
      child: Container(
        height: _StepButton.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.smAll,
          border: Border.all(color: hasError ? MedColors.red : MedColors.border),
        ),
        child: Text(
          date?.formattedDate ?? context.l10n.refill_label_expiryDate,
          style: MedTextStyles.bodyMd(color: date != null ? MedColors.text : MedColors.text3),
        ),
      ),
    );
  }
}

class _SharedMiadBar extends StatelessWidget {
  const _SharedMiadBar({required this.miad, required this.hasError, required this.picker, required this.onChanged});

  final DateTime? miad;
  final bool hasError;
  final CabinDatePicker picker;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasError ? MedColors.redLight : MedColors.blueLight,
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        spacing: _Cols.gap,
        children: [
          Icon(PhosphorIcons.calendar(), size: 18, color: hasError ? MedColors.red : MedColors.blue),
          Expanded(child: Text(context.l10n.refill_label_expiryDate, style: MedTextStyles.titleSm())),
          SizedBox(
            width: _Cols.miad,
            child: _MiadCell(date: miad, hasError: hasError, picker: picker, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
