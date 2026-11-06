import 'package:pharmed_manager/core/core.dart';

extension PrescriptionGrouping on List<PrescriptionItem> {
  /// PrescriptionItem listesini prescriptionId'ye göre gruplar.
  Map<int, List<PrescriptionItem>> get groupedById {
    final Map<int, List<PrescriptionItem>> groups = {};
    for (final item in this) {
      final id = item.prescriptionId;
      if (id != null) {
        groups.putIfAbsent(id, () => []).add(item);
      }
    }
    return groups;
  }

  /// Kalemleri gün bazında gruplar: gün = planlanan uygulama zamanı (yoksa
  /// reçete tarihi). Yeni gün üstte; gün içinde saate göre. Günü belirsiz
  /// kalemler en sonda tek grupta toplanır.
  ///
  /// Reçete işlemleri ve Uygulanmamış Reçeteler detay panelleri ortak kullanır
  /// (`RxGroupCard.day`).
  List<({DateTime? day, List<PrescriptionItem> items})> get groupedByDay {
    DateTime? dayOf(PrescriptionItem i) {
      final d = i.time ?? i.prescription?.prescriptionDate ?? i.prescriptionDate;
      return d == null ? null : DateTime(d.year, d.month, d.day);
    }

    int byTime(PrescriptionItem a, PrescriptionItem b) {
      final ta = a.time, tb = b.time;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return ta.compareTo(tb);
    }

    final map = <DateTime?, List<PrescriptionItem>>{};
    for (final i in this) {
      map.putIfAbsent(dayOf(i), () => []).add(i);
    }
    final groups = [for (final e in map.entries) (day: e.key, items: e.value..sort(byTime))];
    groups.sort((a, b) {
      if (a.day == null && b.day == null) return 0;
      if (a.day == null) return 1;
      if (b.day == null) return -1;
      return b.day!.compareTo(a.day!);
    });
    return groups;
  }

  /// Arama sorgusuna göre gruplanmış reçeteleri filtreler.
  ///
  /// - Reçete ID eşleşiyorsa tüm grup döner.
  /// - Eşleşmiyorsa sadece ilaç adı, barkod veya doktor adıyla eşleşen
  ///   kalemler döner.
  Map<int, List<PrescriptionItem>> filteredGrouped(String query) {
    final grouped = groupedById;
    if (query.isEmpty) return grouped;

    final q = query.toLowerCase();
    final Map<int, List<PrescriptionItem>> result = {};

    grouped.forEach((id, items) {
      if (id.toString().contains(q)) {
        result[id] = items;
        return;
      }

      final matched = items.where((item) {
        final name = item.medicine?.name?.toLowerCase() ?? '';
        final barcode = item.medicine?.barcode?.toLowerCase() ?? '';
        final doctor = item.doctor?.fullName.toLowerCase() ?? '';
        return name.contains(q) || barcode.contains(q) || doctor.contains(q);
      }).toList();

      if (matched.isNotEmpty) result[id] = matched;
    });

    return result;
  }
}
