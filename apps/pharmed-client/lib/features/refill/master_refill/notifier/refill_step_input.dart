// [SWREQ-CLI-MREFILL-001] [IEC 62304 §5.5]
// Birim doz çekmecede her göz için dolum input verisi.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Birim doz çekmecede tek bir gözün dolum input verisi.
///
/// [unit] → hangi DrawerUnit'e ait
/// [stepNo] → unit içindeki göz numarası (1-tabanlı)
/// [fillingQuantity] → kullanıcının girdiği dolum miktarı
/// [countQuantity] → kullanıcının girdiği sayım miktarı
/// [miadDate] → SKT tarihi
class RefillStepInput {
  const RefillStepInput({
    required this.unit,
    required this.stepNo,
    this.fillingQuantity = 0,
    this.countQuantity = 0,
    this.miadDate,
  });

  final DrawerUnit unit;
  final int stepNo;
  final double fillingQuantity;
  final double countQuantity;

  /// TODO: isPerCellMiadEnabled SettingsNotifier'a eklenince
  /// bu alan göz bazlı doldurulacak.
  final DateTime? miadDate;

  bool get hasInput => fillingQuantity > 0 || countQuantity > 0;

  RefillStepInput copyWith({double? fillingQuantity, double? countQuantity, DateTime? miadDate}) {
    return RefillStepInput(
      unit: unit,
      stepNo: stepNo,
      fillingQuantity: fillingQuantity ?? this.fillingQuantity,
      countQuantity: countQuantity ?? this.countQuantity,
      miadDate: miadDate ?? this.miadDate,
    );
  }
}
