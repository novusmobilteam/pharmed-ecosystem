// [SWREQ-CLI-MINTAKE-013] [IEC 62304 §5.5]
// Bir IntakeDrawerJob içindeki TÜM target'ları FİZİKSEL STOK (IntakeDetail.
// stockId) bazında gruplar. Aynı saatte/farklı prescriptionDetail'den aynı
// fiziksel göze (dolayısıyla aynı stockId'ye) düşen birden fazla IntakeTarget,
// kullanıcıya TEK bir sayım kartı olarak gösterilir — ama tamamlama sırasında
// her target kendi ayrı IntakeParams isteğini atmaya devam eder (bkz.
// MasterIntakeNotifier._saveTarget, per-target çalışıyor).
//
// Bir target İÇİNDEKİ farklı stockId'ler (gerçek FIFO bölünmesi, aynı ilacın
// birden fazla stoktan alınması) burada ayrılmaz — onlar zaten
// IntakeCellCard._censusRow'da doğru şekilde tek kart içinde yan yana
// gösteriliyor. Bu grupla yalnızca TARGET'LAR ARASI çakışmayı çözer.
//
// Bu SADECE bir görünüm/UI yardımcısıdır — IntakeTarget/IntakeDrawerJob'ın
// kendisini değiştirmez, state'te saklanmaz, her build'de türetilir.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Aynı stockId'yi paylaşan bir veya daha fazla (targetIndex, detailIndex)
/// çiftini temsil eder.
class IntakeCellGroup {
  const IntakeCellGroup({required this.stockId, required this.refs});

  final int stockId;

  /// Bu stockId'ye referans veren tüm (targetIndex, detailIndex) çiftleri.
  /// Genelde tek elemanlı; aynı göze düşen çoklu-prescription durumunda
  /// birden fazla eleman taşır.
  final List<(int targetIndex, int detailIndex)> refs;

  bool get isMerged => refs.length > 1;
}

abstract final class IntakeCellGrouper {
  /// [targets] (genelde `job.targets`) içindeki tüm detayları stockId'ye göre
  /// gruplar. Sıralama: ilk görülme sırası korunur.
  static List<IntakeCellGroup> group(List<IntakeTarget> targets) {
    final Map<int, List<(int, int)>> byStock = {};

    for (var ti = 0; ti < targets.length; ti++) {
      final details = targets[ti].details;
      for (var di = 0; di < details.length; di++) {
        byStock.putIfAbsent(details[di].stockId, () => []).add((ti, di));
      }
    }

    return byStock.entries.map((e) => IntakeCellGroup(stockId: e.key, refs: e.value)).toList();
  }
}
