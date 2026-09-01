import 'package:pharmed_core/pharmed_core.dart';

class Station extends Selectable {
  final String? name;
  final OrderStatus drugStatus;
  final OrderStatus medicalConsumableStatus;
  final HospitalService? service;
  final Warehouse? materialWarehouse;
  final Warehouse? medicalConsumableWarehouse;
  final String? macAddress;
  final List<HospitalService> services;
  final StationType? type;
  final List<Cabin> cabins;
  final bool canCreateEmergencyPatient;

  Cabin? get activeCabin => cabins.isNotEmpty ? cabins.first : null;

  Station({
    super.id,
    this.name,
    this.service,
    this.drugStatus = OrderStatus.ordered,
    this.medicalConsumableStatus = OrderStatus.ordered,
    this.materialWarehouse,
    this.medicalConsumableWarehouse,
    this.macAddress,
    this.services = const [],
    this.type,
    this.cabins = const [],
    this.canCreateEmergencyPatient = false,
  }) : super(title: name.toString());

  static Station? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Station(id: id, name: name);
  }

  Station copyWith({
    int? id,
    String? name,
    OrderStatus? drugStatus,
    OrderStatus? medicalConsumableStatus,
    HospitalService? service,
    Warehouse? materialWarehouse,
    Warehouse? medicalConsumableWarehouse,
    List<HospitalService>? services,
    StationType? type,
    bool? canCreateEmergencyPatient,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      drugStatus: drugStatus ?? this.drugStatus,
      medicalConsumableStatus: medicalConsumableStatus ?? this.medicalConsumableStatus,
      service: service ?? this.service,
      materialWarehouse: materialWarehouse ?? this.materialWarehouse,
      medicalConsumableWarehouse: medicalConsumableWarehouse ?? this.medicalConsumableWarehouse,
      services: services ?? this.services,
      type: type ?? this.type,
      canCreateEmergencyPatient: canCreateEmergencyPatient ?? this.canCreateEmergencyPatient,
    );
  }
}
