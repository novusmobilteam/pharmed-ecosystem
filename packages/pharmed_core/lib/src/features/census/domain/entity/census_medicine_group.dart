// pharmed_client/lib/src/features/census/domain/census_medicine_group.dart

import 'package:pharmed_core/pharmed_core.dart';

/// Census ekranında aynı ilaca ait reçete kalemlerinin gruplanmış görünümü.
///
/// `items` zamana göre sıralı (en eski → en yeni). Her item bir doz.
class CensusMedicineGroup {
  final Medicine medicine;
  final List<PrescriptionItem> items;

  /// Şu an RFID ile okunan (kabinde mevcut) item ID'leri.
  final Set<int> presentItemIds;

  /// Kullanıcının manuel olarak da işaretleyebileceği (RFID otomatik eklediği)
  /// "kabinde var" işaretli item ID'leri.
  final Set<int> selectedItemIds;

  const CensusMedicineGroup({
    required this.medicine,
    required this.items,
    required this.presentItemIds,
    required this.selectedItemIds,
  });

  int get totalCount => items.length;

  /// Bu grupta seçili (kabinde var olarak işaretli) item sayısı.
  int get countedCount => items.where((i) => i.id != null && selectedItemIds.contains(i.id)).length;

  /// Bu grupta şu an RFID okunan item sayısı (UI rozeti için).
  int get presentCount => items.where((i) => i.id != null && presentItemIds.contains(i.id)).length;

  /// Tüm dozlar sayılmış mı? Grup başlığındaki tik için.
  bool get isFullyCounted => countedCount == totalCount;
}

/// İlaç bazında gruplama yardımcısı.
List<CensusMedicineGroup> groupPrescriptionItemsByMedicine({
  required List<PrescriptionItem> items,
  required Set<String> rfidReadEpcs,
  required Set<int> selectedItemIds,
}) {
  final byMedicineId = <int, List<PrescriptionItem>>{};
  for (final item in items) {
    final medId = item.medicine?.id;
    if (medId == null) continue;
    byMedicineId.putIfAbsent(medId, () => []).add(item);
  }

  return byMedicineId.entries.map((e) {
    final groupItems = [...e.value]
      ..sort((a, b) => (a.lastMovement?.createdAt ?? DateTime(0)).compareTo(b.lastMovement?.createdAt ?? DateTime(0)));

    final presentIds = <int>{
      for (final i in groupItems)
        if (i.id != null && i.rfidTag != null && rfidReadEpcs.contains(i.rfidTag)) i.id!,
    };

    return CensusMedicineGroup(
      medicine: groupItems.first.medicine!,
      items: groupItems,
      presentItemIds: presentIds,
      selectedItemIds: selectedItemIds,
    );
  }).toList()..sort((a, b) => (a.medicine.name ?? '').compareTo(b.medicine.name ?? '')); // alfabetik
}
