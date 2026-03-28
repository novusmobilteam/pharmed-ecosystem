import '../../../../core/core.dart';
import '../../../service/data/model/service_dto.dart';
import '../../../warehouse/data/model/warehouse_dto.dart';
import '../../domain/entity/station.dart';

class StationDTO {
  final int? id;
  final String? name;
  final bool stationDrug;
  final bool stationMedicalConsumables;
  final String? macAddress;
  final ServiceDTO? service;
  final WarehouseDTO? materialWarehouse;
  final WarehouseDTO? medicalConsumableWarehouse;
  final List<ServiceDTO> stationProvidedServices;

  const StationDTO({
    this.id,
    this.name,
    this.service,
    this.stationDrug = true,
    this.stationMedicalConsumables = true,
    this.materialWarehouse,
    this.medicalConsumableWarehouse,
    this.macAddress,
    this.stationProvidedServices = const [],
  });

  factory StationDTO.fromJson(Map<String, dynamic> json) => StationDTO(
        id: json['id'] as int?,
        name: json['name'] as String?,
        service: json['service'] != null ? ServiceDTO.fromJson(json['service']) : null,
        stationDrug: (json['stationDrug'] as bool?) ?? true,
        stationMedicalConsumables: (json['stationMedicalConsumables'] as bool?) ?? true,
        materialWarehouse: json['materialWarehouse'] != null ? WarehouseDTO.fromJson(json['materialWarehouse']) : null,
        medicalConsumableWarehouse: json['medicalConsumableWarehouse'] != null
            ? WarehouseDTO.fromJson(json['medicalConsumableWarehouse'])
            : null,
        macAddress: json['macAddress'] as String?,
        stationProvidedServices: json['stationProvidedServices'] != null
            ? (json['stationProvidedServices'] as List)
                .map((e) => ServiceDTO.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serviceId': service?.id,
        'stationDrug': stationDrug,
        'stationMedicalConsumables': stationMedicalConsumables,
        'materialWarehouseId': materialWarehouse?.id,
        'medicalConsumableWarehouseId': medicalConsumableWarehouse?.id,
        'stationProvidedServiceIds': stationProvidedServices.map((s) => s.id).toList(),
        //'macAddress': '',
      };

  Station toEntity() {
    return Station(
      id: id,
      name: name,
      drugStatus: orderStatusFromBool(stationDrug),
      medicalConsumableStatus: orderStatusFromBool(stationMedicalConsumables),
      service: service?.toEntity(),
      materialWarehouse: materialWarehouse?.toEntity(),
      medicalConsumableWarehouse: medicalConsumableWarehouse?.toEntity(),
      macAddress: macAddress,
      services: stationProvidedServices.map((s) => s.toEntity()).toList(),
    );
  }

  /// Mock factory for test data generation
  static StationDTO mockFactory(int id, {bool withNested = true}) {
    final serviceNames = [
      'Dahiliye',
      'Cerrahi',
      'Kardiyoloji',
      'Nöroloji',
      'Acil Servis',
      'Yoğun Bakım',
      'Ortopedi',
      'Göz Hastalıkları',
      'KBB',
      'Üroloji',
    ];
    final serviceId = ((id - 1) % 10) + 1;
    return StationDTO(
      id: id,
      name: 'İstasyon ${serviceNames[(id - 1) % serviceNames.length]}',
      stationDrug: true,
      stationMedicalConsumables: true,
      macAddress: 'AA:BB:CC:DD:EE:${id.toString().padLeft(2, '0')}',
      service: withNested ? ServiceDTO.mockFactory(serviceId, withNested: false) : null,
      materialWarehouse: withNested ? WarehouseDTO.mockFactory(id, withNested: false) : null,
      medicalConsumableWarehouse: withNested ? WarehouseDTO.mockFactory(id + 100, withNested: false) : null,
    );
  }
}
