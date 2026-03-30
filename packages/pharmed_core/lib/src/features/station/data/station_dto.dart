import 'package:pharmed_core/pharmed_core.dart';

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
        ? (json['stationProvidedServices'] as List).map((e) => ServiceDTO.fromJson(e as Map<String, dynamic>)).toList()
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
}
