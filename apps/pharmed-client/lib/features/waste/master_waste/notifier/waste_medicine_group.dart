// [SWREQ-CLI-MWASTE-003] [IEC 62304 §5.5]
// Fire/İmha ekranında ilaç-adı bazlı gruplama — GÖRÜNÜM amaçlı yardımcı.
//
// Bu sınıf state'te SAKLANMAZ, her build'de
// MasterWasteMedicineSelection.visibleItems'tan türetilir (bkz.
// pharmed-ecosystem IntakeCellGrouper deseni). Seçim/miktar (selectedItemIds/
// amounts) mantığını hiç bilmez, sadece görüntüleme sırasını belirler.
//
// Sınıf: Class B (salt görünüm, klinik karar/veri üretmiyor)

import 'package:pharmed_core/pharmed_core.dart';

class WasteMedicineGroup {
  const WasteMedicineGroup({required this.name, required this.items});

  /// Grup anahtarı olarak da kullanılır — issue'nun tanımladığı gibi
  /// "isim bazlı" gruplama; ilaç adı boşsa '—' fallback'i grup adı olur.
  final String name;
  final List<DisposableItem> items;

  int get count => items.length;

  bool hasSelection(Set<int> selectedItemIds) => items.any((i) => selectedItemIds.contains(i.id));

  static List<WasteMedicineGroup> groupByMedicineName(List<DisposableItem> items) {
    final Map<String, List<DisposableItem>> buckets = {};
    for (final item in items) {
      final name = item.medicine?.name ?? '—';
      buckets.putIfAbsent(name, () => []).add(item);
    }

    final groups = buckets.entries.map((entry) {
      // Grup içi: gün/saat bilgisine göre sırala (issue'nun beklediği davranış).
      final sorted = [...entry.value]
        ..sort((a, b) {
          final at = a.time;
          final bt = b.time;
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return at.compareTo(bt);
        });
      return WasteMedicineGroup(name: entry.key, items: sorted);
    }).toList();

    groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return groups;
  }
}
