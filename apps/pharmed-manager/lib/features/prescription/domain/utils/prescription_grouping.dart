import '../entity/prescription_item.dart';

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
