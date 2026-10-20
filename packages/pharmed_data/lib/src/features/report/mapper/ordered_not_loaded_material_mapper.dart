import 'package:pharmed_core/pharmed_core.dart';

class OrderedNotLoadedMaterialMapper {
  const OrderedNotLoadedMaterialMapper();

  OrderedNotLoadedMaterial toEntity(OrderedNotLoadedMaterialDto dto) {
    return OrderedNotLoadedMaterial(
      prescriptionItemId: dto.prescriptionDetailId,
      stationId: dto.stationId,
      stationName: dto.stationName,
      serviceName: dto.serviceName,
      materialId: dto.materialId,
      barcode: dto.barcode,
      materialName: dto.materialName,
      orderDate: dto.orderDate,
      protocolNo: dto.protocolNo,
      quantity: dto.quantity,
      patientFullName: dto.patientFullName,
    );
  }

  OrderedNotLoadedMaterial? toEntityOrNull(OrderedNotLoadedMaterialDto? dto) => dto == null ? null : toEntity(dto);

  List<OrderedNotLoadedMaterial> toEntityList(List<OrderedNotLoadedMaterialDto> dtos) => dtos.map(toEntity).toList();

  OrderedNotLoadedMaterialDto toDto(OrderedNotLoadedMaterial entity) {
    return OrderedNotLoadedMaterialDto(
      prescriptionDetailId: entity.prescriptionItemId,
      stationId: entity.stationId,
      stationName: entity.stationName,
      serviceName: entity.serviceName,
      materialId: entity.materialId,
      barcode: entity.barcode,
      materialName: entity.materialName,
      orderDate: entity.orderDate,
      protocolNo: entity.protocolNo,
      quantity: entity.quantity,
      patientFullName: entity.patientFullName,
    );
  }
}
