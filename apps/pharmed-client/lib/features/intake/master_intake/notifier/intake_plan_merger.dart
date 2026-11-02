// [SWREQ-CLI-MINTAKE-003] [IEC 62304 §5.5]
//
// Aynı ilacın farklı order saatlerine ait kalemleri, aynı gözden alınacaksa
// TEK hedefte birleştirir: kullanıcı ilacı bir kez görür, toplam adedi tek
// seferde alır. Listede kalemler ayrı ayrı kalır; birleştirme yalnızca
// kuyruk (hedef) seviyesindedir.
//
// Kayıt yine kalem bazında yapılır — her reçete detayının kendi alım kaydı
// backend'e ayrı gider (bkz. MasterIntakeExecutionNotifier._saveTarget).
//
// Birleştirilmeyenler (tek başına grup olur):
//   - muadil alım (her kalemin kendi muadil kontrolü/kaydı var),
//   - yönlendirilmiş order alımı,
//   - ilacı ya da ataması çözülemeyen kalem.
//
// Seçim (hedef kurma) ve yürütme (kayıt) aynı fonksiyonu aynı plan listesiyle
// çağırır; gruplama deterministiktir (giriş sırası korunur), temsilci kalem
// her zaman grubun ilk kalemidir — hedefin sourceId'si buna eşittir.
//
// Saf Dart — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

typedef IntakePlanGroup = ({IntakePlan merged, List<IntakePlan> members});

abstract final class IntakePlanMerger {
  static List<IntakePlanGroup> group(List<IntakePlan> plans) {
    final buckets = <Object, List<IntakePlan>>{};
    for (final plan in plans) {
      buckets.putIfAbsent(_keyOf(plan), () => []).add(plan);
    }
    return [
      for (final members in buckets.values) (merged: _merge(members), members: List.unmodifiable(members)),
    ];
  }

  static Object _keyOf(IntakePlan plan) {
    final item = plan.item;
    final medicineId = item.medicine?.id;
    final assignmentId = item.assignment?.id;
    if (item.isEquivalentIntake || item.isRedirectedIntake || medicineId == null || assignmentId == null) {
      return ('single', item.id);
    }
    return ('merge', medicineId, assignmentId);
  }

  /// Temsilci plan: ilk kalem + aynı stoktan alınan dozlar toplanmış detaylar.
  /// Sayım (censusQuantity) burada taşınmaz — hedeften kayıt anında okunur.
  static IntakePlan _merge(List<IntakePlan> members) {
    if (members.length == 1) return members.first;

    final doseByStock = <int, double>{};
    for (final plan in members) {
      for (final d in plan.details) {
        doseByStock.update(d.stockId, (v) => v + d.dosePiece, ifAbsent: () => d.dosePiece);
      }
    }
    final total = doseByStock.values.fold<double>(0, (sum, v) => sum + v);

    return (
      item: members.first.item.copyWith(dosePiece: total),
      details: [
        for (final MapEntry(key: stockId, value: dose) in doseByStock.entries)
          IntakeDetail(stockId: stockId, dosePiece: dose),
      ],
    );
  }
}
