import 'package:pharmed_core/pharmed_core.dart';

/// Census ekranında aynı ilaca ait reçete kalemlerinin gruplanmış görünümü.
///
/// `items` zamana göre sıralı (en eski → en yeni). Her item bir doz.
class CensusMedicineGroup {
  final Medicine medicine;
  final List<PrescriptionItem> items;

  /// RFID ile okunan (kabinde fiziksel mevcut) EPC'ler.
  final Set<String> rfidReadEpcs;

  /// Kullanıcının manuel "eksik" işaretlediği RFID'siz item ID'leri.
  final Set<int> markedMissingItemIds;

  const CensusMedicineGroup({
    required this.medicine,
    required this.items,
    required this.rfidReadEpcs,
    required this.markedMissingItemIds,
  });

  int get totalCount => items.length;

  /// Bir item "sayıldı" mı? (kabinde doğrulandı)
  ///   - RFID'li → EPC okundu
  ///   - RFID'siz → kullanıcı eksik işaretlemedi (varsayılan: var)
  bool _isCounted(PrescriptionItem i) {
    if (i.id == null) return false;
    final epc = i.rfidTag;
    if (epc != null) return rfidReadEpcs.contains(epc);
    return !markedMissingItemIds.contains(i.id); // RFID'siz: işaretlenmemişse sayıldı
  }

  /// Bir item "eksik" mi?
  bool isMissing(PrescriptionItem i) => !_isCounted(i);

  /// Sayılan (doğrulanan) doz sayısı.
  int get countedCount => items.where(_isCounted).length;

  /// RFID ile fiziksel okunan doz sayısı (rozet için).
  int get presentCount => items.where((i) {
    final epc = i.rfidTag;
    return epc != null && rfidReadEpcs.contains(epc);
  }).length;

  /// Tüm dozlar sayılmış mı? Grup başlığındaki tik için.
  bool get isFullyCounted => countedCount == totalCount;
}

/// İlaç bazında gruplama yardımcısı.
List<CensusMedicineGroup> groupPrescriptionItemsByMedicine({
  required List<PrescriptionItem> items,
  required Set<String> rfidReadEpcs,
  required Set<int> markedMissingItemIds,
}) {
  final byMedicineId = <int, List<PrescriptionItem>>{};
  for (final item in items) {
    final medId = item.medicine?.id;
    if (medId == null) continue;
    byMedicineId.putIfAbsent(medId, () => []).add(item);
  }

  return byMedicineId.entries.map((e) {
    final groupItems = [...e.value]..sort((a, b) => (a.time ?? DateTime(0)).compareTo(b.time ?? DateTime(0)));

    return CensusMedicineGroup(
      medicine: groupItems.first.medicine!,
      items: groupItems,
      rfidReadEpcs: rfidReadEpcs,
      markedMissingItemIds: markedMissingItemIds,
    );
  }).toList()..sort((a, b) => (a.medicine.name ?? '').compareTo(b.medicine.name ?? ''));
}
