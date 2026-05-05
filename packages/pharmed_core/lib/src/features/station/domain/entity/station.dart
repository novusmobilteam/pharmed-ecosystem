import 'package:pharmed_core/pharmed_core.dart';

class Station extends Selectable implements TableData {
  final String? name;
  final OrderStatus drugStatus;
  final OrderStatus medicalConsumableStatus;
  final HospitalService? service;
  final Warehouse? materialWarehouse;
  final Warehouse? medicalConsumableWarehouse;
  final String? macAddress;
  final List<HospitalService> services;
  final StationType? type;

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
  }) : super(title: name.toString());

  static Station? fromIdAndName({int? id, String? name}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Station(id: id, name: name);
  }

  @override
  List<String?> get content => [
    id?.toString(),
    title,
    service?.name?.toString() ?? "-",
    materialWarehouse?.name,
    drugStatus.label,
    medicalConsumableWarehouse?.name,
    medicalConsumableStatus.label,
    type?.label,
  ];

  @override
  List get rawContent => content;

  @override
  List<String> get titles => [
    "İstasyon Kodu",
    "İstasyon Adı",
    "Servis",
    "İlaç Depo",
    "İlaç",
    "Tıbbi Sarf Depo",
    "Tıbbi Sarf",
    "Çalışma Tipi",
  ];

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
    );
  }
}
