import 'package:pharmed_core/pharmed_core.dart';

/// Uygulanmamış Reçeteler ekranının bir satırı: tek bir yatış ve o yatışın
/// uygulanmayı bekleyen reçeteleri / reçete kalemleri.
class UnappliedHospitalization {
  final int? id;
  final int? hospitalizationId;
  final Hospitalization? hospitalization;
  final DateTime? hospitalizationDate;

  /// Yatıştaki toplam bekleyen (uygulanmamış) kalem adedi.
  final int? remainingCount;

  /// Bekleyen kalemlerin ilaç adları — sunucuda virgülle birleştirilmiş gelir.
  final String? materialNames;

  /// Yatışın bekleyen kalemi olan reçeteleri.
  final List<Prescription> prescriptions;

  /// Uygulanmayı bekleyen reçete kalemleri (detay panelinde reçete bazlı gruplanır).
  final List<PrescriptionItem> items;

  const UnappliedHospitalization({
    this.id,
    this.hospitalizationId,
    this.hospitalization,
    this.hospitalizationDate,
    this.remainingCount,
    this.materialNames,
    this.prescriptions = const [],
    this.items = const [],
  });

  /// En son yazılan reçetenin tarihi (tabloda "Reçete Tarihi" kolonu).
  DateTime? get lastPrescriptionDate {
    DateTime? latest;
    for (final p in prescriptions) {
      final date = p.prescriptionDate;
      if (date != null && (latest == null || date.isAfter(latest))) latest = date;
    }
    return latest;
  }
}
