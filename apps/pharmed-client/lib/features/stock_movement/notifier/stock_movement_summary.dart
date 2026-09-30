import 'package:pharmed_core/pharmed_core.dart';

/// Zaman ekseninin gruplama birimi.
/// Tek günlük aralıkta saatlik, daha uzun aralıklarda günlük gruplanır.
enum StockMovementBucket { hour, day }

class StockMovementTypeTotal {
  const StockMovementTypeTotal({required this.type, required this.count, required this.quantity});

  final StationTransactionType type;
  final int count;
  final double quantity;
}

class StockMovementTimePoint {
  const StockMovementTimePoint({required this.bucketStart, required this.countsByType});

  final DateTime bucketStart;
  final Map<StationTransactionType, int> countsByType;

  int get total => countsByType.values.fold(0, (a, b) => a + b);
}

class StockMovementMaterialTotal {
  const StockMovementMaterialTotal({
    required this.material,
    required this.code,
    required this.count,
    required this.quantity,
  });

  final String material;
  final String? code;
  final int count;
  final double quantity;
}

class StockMovementCabinTotal {
  const StockMovementCabinTotal({required this.cabinId, required this.cabinName, required this.count});

  final int? cabinId;
  final String cabinName;
  final int count;
}

class StockMovementSummary {
  const StockMovementSummary({
    required this.totalCount,
    required this.bucket,
    required this.byType,
    required this.timeline,
    required this.topMaterials,
    required this.byCabin,
  });

  static const empty = StockMovementSummary(
    totalCount: 0,
    bucket: StockMovementBucket.day,
    byType: [],
    timeline: [],
    topMaterials: [],
    byCabin: [],
  );

  final int totalCount;
  final StockMovementBucket bucket;

  /// Hareket tipine göre toplamlar, adede göre azalan.
  final List<StockMovementTypeTotal> byType;

  /// Aralığın tamamını kapsayan, boş bucket'lar dahil sürekli zaman serisi.
  final List<StockMovementTimePoint> timeline;

  /// En çok hareket gören malzemeler (hareket sayısına göre).
  final List<StockMovementMaterialTotal> topMaterials;

  final List<StockMovementCabinTotal> byCabin;

  bool get isEmpty => totalCount == 0;
}

/// Ham [StationTransaction] listesini grafik verisine dönüştürür.
/// Saf Dart; Flutter'a bağımlı değildir, birim testi doğrudan yazılabilir.
class StockMovementAggregator {
  const StockMovementAggregator({this.topMaterialCount = 10});

  final int topMaterialCount;

  StockMovementSummary aggregate(
    List<StationTransaction> items, {
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final bucket = rangeEnd.difference(rangeStart).inHours <= 24 ? StockMovementBucket.hour : StockMovementBucket.day;

    final typeCounts = <StationTransactionType, int>{};
    final typeQuantities = <StationTransactionType, double>{};
    final timeline = <DateTime, Map<StationTransactionType, int>>{};
    final materials = <String, _MaterialAcc>{};
    final cabins = <int?, _CabinAcc>{};

    for (final item in items) {
      final type = item.transactionType;
      final date = item.transactionDate;
      if (type == null || date == null) continue;

      typeCounts.update(type, (v) => v + 1, ifAbsent: () => 1);
      typeQuantities.update(type, (v) => v + (item.quantity ?? 0), ifAbsent: () => item.quantity ?? 0);

      final slot = timeline.putIfAbsent(_bucketStart(date, bucket), () => {});
      slot.update(type, (v) => v + 1, ifAbsent: () => 1);

      final materialKey = item.code ?? item.material ?? '-';
      materials.putIfAbsent(materialKey, () => _MaterialAcc(item.material ?? '-', item.code)).add(item.quantity ?? 0);

      cabins.putIfAbsent(item.cabinId, () => _CabinAcc(item.cabinName ?? '-')).count++;
    }

    final byType = [
      for (final e in typeCounts.entries)
        StockMovementTypeTotal(type: e.key, count: e.value, quantity: typeQuantities[e.key] ?? 0),
    ]..sort((a, b) => b.count.compareTo(a.count));

    final topMaterials = [
      for (final m in materials.values)
        StockMovementMaterialTotal(material: m.name, code: m.code, count: m.count, quantity: m.quantity),
    ]..sort((a, b) => b.count.compareTo(a.count));

    final byCabin = [
      for (final e in cabins.entries)
        StockMovementCabinTotal(cabinId: e.key, cabinName: e.value.name, count: e.value.count),
    ]..sort((a, b) => b.count.compareTo(a.count));

    return StockMovementSummary(
      totalCount: byType.fold(0, (a, b) => a + b.count),
      bucket: bucket,
      byType: byType,
      timeline: _fillTimeline(timeline, rangeStart, rangeEnd, bucket),
      topMaterials: topMaterials.take(topMaterialCount).toList(),
      byCabin: byCabin,
    );
  }

  /// Grafik çizgisi kopmasın diye veri olmayan bucket'ları da 0 ile ekler.
  List<StockMovementTimePoint> _fillTimeline(
    Map<DateTime, Map<StationTransactionType, int>> data,
    DateTime start,
    DateTime end,
    StockMovementBucket bucket,
  ) {
    final points = <StockMovementTimePoint>[];
    var cursor = _bucketStart(start, bucket);
    final last = _bucketStart(end, bucket);
    while (!cursor.isAfter(last)) {
      points.add(StockMovementTimePoint(bucketStart: cursor, countsByType: Map.unmodifiable(data[cursor] ?? {})));
      cursor = bucket == StockMovementBucket.hour
          ? DateTime(cursor.year, cursor.month, cursor.day, cursor.hour + 1)
          : DateTime(cursor.year, cursor.month, cursor.day + 1); // DST güvenli
    }
    return points;
  }

  DateTime _bucketStart(DateTime d, StockMovementBucket bucket) {
    final local = d.toLocal();
    return bucket == StockMovementBucket.hour
        ? DateTime(local.year, local.month, local.day, local.hour)
        : DateTime(local.year, local.month, local.day);
  }
}

class _MaterialAcc {
  _MaterialAcc(this.name, this.code);

  final String name;
  final String? code;
  int count = 0;
  double quantity = 0;

  void add(double q) {
    count++;
    quantity += q;
  }
}

class _CabinAcc {
  _CabinAcc(this.name);

  final String name;
  int count = 0;
}
