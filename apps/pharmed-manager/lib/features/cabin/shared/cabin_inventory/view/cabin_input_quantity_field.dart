import 'package:flutter/material.dart';

import '../../../../../core/core.dart';
import '../../../../../core/widgets/form/form_inputs/touch_numpad_field.dart';
import '../../../../cabin_assignment/domain/entity/cabin_assignment.dart';

/// Kabin stok işlemlerinde kullanılan miktar giriş alanı.
///
/// Kübik ve birim doz çekmecelerde hem sayım hem işlem alanı için kullanılır.
///
/// ⚠ Skill §5 — Birim ve değer kuralları:
///
/// Sayım alanı ([isCountField]=true):
///   [useTotalLabel]=true  → data.totalQuantityLabel ile gösterilir (Kübik)
///   [useTotalLabel]=false → currentCount ile gösterilir, refill'de adete çevrilir (Birim Doz)
///   unit=null — birim zaten label içinde
///
/// İşlem alanı ([isCountField]=false):
///   refill → kullanıcı adet giriyor; birim fillingUnit
///   diğer  → kullanıcı ml giriyor; birim operationUnit
class CabinInputQuantityField extends StatelessWidget {
  const CabinInputQuantityField({
    super.key,
    required this.data,
    required this.type,
    required this.isCountField,
    required this.value,
    required this.onChanged,
    this.useTotalLabel = false,
    this.showLabel = true,
  });

  final CabinAssignment data;
  final CabinInventoryType type;

  /// true  → Sayım Miktarı alanı
  /// false → Dolum/Boşaltma/İmha alanı
  final bool isCountField;

  /// Gösterilecek değer.
  /// Sayım: currentCount (birim doz) veya countQuantity (kübik)
  /// İşlem: fillingQuantity
  final double value;

  final void Function(double parsed) onChanged;

  /// true ise sayım alanında data.totalQuantityLabel kullanılır (Kübik).
  /// false ise value direkt gösterilir, refill'de fromFillingBackendValue ile çevrilir (Birim Doz).
  final bool useTotalLabel;

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final String? label = showLabel ? (isCountField ? 'Sayım Miktarı' : type.fieldText) : null;
    final bool isRefill = type == CabinInventoryType.refill;

    final String unit = isRefill ? data.fillingUnit : data.operationUnit;
    double? step = data.medicine?.operationStep;

    return TouchNumpadField(
      label: label,
      value: value,
      unit: unit,
      onChanged: (val) => onChanged(val),
      step: step,
      min: 0,
    );
  }
}
