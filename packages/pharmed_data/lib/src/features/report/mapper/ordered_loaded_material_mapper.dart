import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class OrderedLoadedMaterialMapper {
  const OrderedLoadedMaterialMapper();

  OrderedLoadedMaterial toEntity(OrderedLoadedMaterialDto dto) {
    return OrderedLoadedMaterial(
      serviceName: dto.serviceName,
      stationId: dto.stationId,
      stationName: dto.stationName,
      cabinName: dto.cabinName,
      cabinCode: dto.cabinCode,
      materialName: dto.materialName,
      barcode: dto.barcode,
      medicine: const MedicineMapper().toEntityOrNull(dto.material),
    );
  }

  OrderedLoadedMaterial? toEntityOrNull(OrderedLoadedMaterialDto? dto) => dto == null ? null : toEntity(dto);

  List<OrderedLoadedMaterial> toEntityList(List<OrderedLoadedMaterialDto> dtos) => dtos.map(toEntity).toList();

  OrderedLoadedMaterialDto toDto(OrderedLoadedMaterial entity) {
    return OrderedLoadedMaterialDto(
      serviceName: entity.serviceName,
      stationId: entity.stationId,
      stationName: entity.stationName,
      cabinName: entity.cabinName,
      cabinCode: entity.cabinCode,
      materialName: entity.materialName,
      barcode: entity.barcode,
      material: const MedicineMapper().toDtoOrNull(entity.medicine),
    );
  }
}
