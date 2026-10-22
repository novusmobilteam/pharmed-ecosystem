part of 'medicine_dto.dart';

// [SWREQ-CORE-MEDICINE-DTO-001]
// Sınıf: Class B
//
// GET /Material/{id} → `materialIndependentService[]` elemanı ve
// PUT /Material/independentServices → `services[]` elemanı.
class IndependentMaterialServiceDto {
  final int? id;
  final int? serviceId;
  final String? serviceName;

  const IndependentMaterialServiceDto({this.id, this.serviceId, this.serviceName});

  factory IndependentMaterialServiceDto.fromJson(Map<String, dynamic> json) {
    final service = json['service'];
    return IndependentMaterialServiceDto(
      id: json['id'] as int?,
      serviceId: json['serviceId'] as int? ?? (service is Map<String, dynamic> ? service['id'] as int? : null),
      serviceName:
          json['serviceName'] as String? ?? (service is Map<String, dynamic> ? service['name'] as String? : null),
    );
  }

  /// PUT gövdesindeki eleman: `{ "id": 1, "serviceId": 1 }` — id yoksa gönderilmez.
  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'serviceId': serviceId};

  static List<IndependentMaterialServiceDto> listFromJson(dynamic data) {
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(IndependentMaterialServiceDto.fromJson).toList();
  }

  /// serviceId'si olmayan bozuk kayıt entity'ye çevrilmez.
  IndependentMaterialService? toEntityOrNull() {
    final sid = serviceId;
    if (sid == null) return null;
    return IndependentMaterialService(id: id, serviceId: sid, serviceName: serviceName);
  }

  factory IndependentMaterialServiceDto.fromEntity(IndependentMaterialService e) =>
      IndependentMaterialServiceDto(id: e.id, serviceId: e.serviceId, serviceName: e.serviceName);
}

// [SWREQ-CORE-MEDICINE-DTO-002]
// Sınıf: Class B
//
// PUT /Material/independentServices gövdesi.
// Boş [services] listesi ilacın tüm serbest ilaç servislerini kaldırır.
class SaveIndependentServicesRequestDto {
  final int materialId;
  final List<IndependentMaterialServiceDto> services;

  const SaveIndependentServicesRequestDto({required this.materialId, required this.services});

  Map<String, dynamic> toJson() => {'materialId': materialId, 'services': services.map((s) => s.toJson()).toList()};
}
