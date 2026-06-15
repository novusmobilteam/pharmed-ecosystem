// [SWREQ-CLI-MINTAKE-010] [IEC 62304 §5.5]
// Tek bir alım hedefi = bir WithdrawItem + o item için CheckIntakeUseCase'ten
// dönen IntakeDetail planı (hangi stoktan ne kadar alınacağı).
//
// Master dolumdaki RefillFillTarget'ın alım karşılığıdır. Farkları:
//   - Dolum "adet girer, stoğa ekler"; alım "stoktan düşer".
//   - Hangi gözden/stoktan alınacağı kullanıcı seçimi DEĞİL, CheckIntake'in
//     FIFO planıdır (IntakeDetail.stockId). Kullanıcı yalnızca CountType'a göre
//     sayım (censusQuantity) girer.
//   - "Bir item → tek fiziksel çekmece" varsayımı (servis bir ilaç için birden
//     çok göz önermez). Bu yüzden bir IntakeTarget tek bir çekmeceye düşer.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class IntakeTarget {
  const IntakeTarget({required this.item, required this.details});

  /// Alımı yapılacak ilaç kalemi (doz, şahit, assignment, prescriptionItem).
  final IntakeItem item;

  /// CheckIntake planından dönen alım detayları (stockId + dosePiece +
  /// censusQuantity). Sayım değerleri burada güncellenir.
  final List<IntakeDetail> details;

  // ── Türetilen ──────────────────────────────────────────────────────────

  MedicineAssignment? get assignment => item.assignment;

  Medicine? get medicine => item.medicine;

  DrawerUnit? get unit => assignment?.drawerUnit;

  bool get isKubik => assignment?.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  /// Bu hedefin sayım tipi (Drug ise countType, değilse noCount kabul edilir).
  CountType get countType {
    final med = medicine;
    if (med is Drug) return med.countType;
    return CountType.noCount;
  }

  bool get needsCount => countType != CountType.noCount;

  /// Alınacak toplam miktar (plan üzerinden).
  double get totalDose => details.fold<double>(0, (sum, d) => sum + d.dosePiece);

  /// Sayım zorunluysa tüm detaylarda censusQuantity girilmiş mi?
  bool get isCountComplete {
    if (!needsCount) return true;
    return details.every((d) => d.censusQuantity != null);
  }

  /// Tamamlamaya hazır mı? (sayım gerekmiyorsa daima true)
  bool get isValid => isCountComplete;

  IntakeTarget copyWith({List<IntakeDetail>? details}) {
    return IntakeTarget(item: item, details: details ?? this.details);
  }

  /// Belirli bir detayın sayım değerini günceller (immutable kopya döner).
  IntakeTarget withCountAt(int detailIndex, double? value) {
    if (detailIndex < 0 || detailIndex >= details.length) return this;
    final next = List<IntakeDetail>.from(details);
    next[detailIndex] = IntakeDetail(stockId: next[detailIndex].stockId, dosePiece: next[detailIndex].dosePiece)
      ..censusQuantity = value;
    return copyWith(details: next);
  }
}
