// packages/pharmed_ui/lib/src/widgets/med_labeled_dose_stepper.dart

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Görsel ton — normal seviyeler için nötr gri, kritik seviye için
/// dikkat çekici açık kırmızı arkaplan.
enum DoseStepperTone { neutral, critical }

/// Üstte başlık + açıklama, altında geniş tek satır stepper gösteren
/// bileşen. `MedDoseStepper`'dan farkı: unit değeri gösterilmez, sadece
/// büyük bir sayı ortalanır; başlık/açıklama satırı bileşenin bir parçasıdır.
///
/// Kullanım örneği: İlaç atama formunda min/kritik/maks miktar girişleri.
class MedLabeledDoseStepper extends StatelessWidget {
  const MedLabeledDoseStepper({
    super.key,
    this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.step = 1.0,
    this.min = 0.0,
    this.max,

    this.unit,
    this.height = 56.0,
  });

  /// Sol üstte gösterilen kalın başlık, örn. "Minimum Miktar".
  final String? title;

  /// Sağ üstte gösterilen açıklama, örn. "Bu seviyenin altı sipariş önerir".
  final String? description;

  final double value;
  final double step;
  final double min;
  final double? max;
  final ValueChanged<double> onChanged;

  /// Verilirse büyük sayının altında küçük birim etiketi gösterilir.
  /// Görseldeki gibi sade bir sayı için null bırakılabilir.
  final String? unit;

  final double height;

  bool get _canDecrement => value > min;
  bool get _canIncrement => max == null || value < max!;

  Future<void> _handleManualEntry(BuildContext context) async {
    final String? result = await showNumpadView(
      context,
      title: title,
      hintText: '0.0',
      initialValue: value == 0 ? '' : value.formatFractional,
    );

    if (result != null) {
      final double? parsed = double.tryParse(result);
      if (parsed != null) {
        double final_ = (parsed / step).round() * step;
        if (final_ < min) final_ = min;
        if (max != null && final_ > max!) final_ = max!;
        onChanged(final_);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != null) Text(title!, style: MedTextStyles.monoMd(weight: FontWeight.bold)),
            if (description != null)
              Flexible(
                child: Text(
                  description!,
                  textAlign: TextAlign.right,
                  style: MedTextStyles.bodySm(color: MedColors.blue),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(border: Border.all(width: 2)),
          child: Row(
            children: [
              _StepBtn(
                icon: PhosphorIcons.minus(),
                size: height,
                enabled: _canDecrement,
                onTap: _canDecrement ? () => onChanged(value - step) : null,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleManualEntry(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(), right: BorderSide()),
                    ),
                    child: unit == null
                        ? Text(value.formatFractional, style: MedTextStyles.numericXl(color: MedColors.text))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 1,
                            children: [
                              Text(value.formatFractional, style: MedTextStyles.numericLg(color: MedColors.text)),
                              Text(unit!, style: MedTextStyles.monoSm(color: MedColors.text3)),
                            ],
                          ),
                  ),
                ),
              ),
              _StepBtn(
                icon: PhosphorIcons.plus(),
                size: height,
                enabled: _canIncrement,
                onTap: _canIncrement ? () => onChanged(value + step) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.size, required this.enabled, this.onTap});

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: enabled ? MedColors.text2 : MedColors.text4),
      ),
    );
  }
}
