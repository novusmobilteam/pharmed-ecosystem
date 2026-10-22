part of 'medicine.dart';

// [SWREQ-CORE-MEDICINE-ENT-001]
// Sınıf: Class B
//
// Serbest ilacın (Drug.isIndependentMaterial) alınabileceği bir servis kaydı.
//
// - [id]: ilaç-servis bağının backend kaydı. Yeni eklenen servislerde null'dır;
//   PUT /Material/independentServices isteğinde id varsa kayıt güncellenir,
//   yoksa yeni kayıt eklenir. Listede gönderilmeyen mevcut kayıtlar silinir.
// - [serviceId]: HospitalService.id
// - [serviceName]: yalnızca gösterim amaçlı; backend'den gelmeyebilir.
class IndependentMaterialService {
  final int? id;
  final int serviceId;
  final String? serviceName;

  const IndependentMaterialService({this.id, required this.serviceId, this.serviceName});

  IndependentMaterialService copyWith({int? id, int? serviceId, String? serviceName}) {
    return IndependentMaterialService(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is IndependentMaterialService &&
      other.id == id &&
      other.serviceId == serviceId &&
      other.serviceName == serviceName;

  @override
  int get hashCode => Object.hash(id, serviceId, serviceName);
}
