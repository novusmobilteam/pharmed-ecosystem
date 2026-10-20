import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// MaterialStock ↔ MaterialStockDto dönüşümleri.
class HospitalStockMapper {
  const HospitalStockMapper();

  HospitalStock toEntity(HospitalStockDto dto) {
    return HospitalStock(
      serviceId: dto.serviceId,
      serviceName: dto.serviceName,
      materialId: dto.materialId,
      materialName: dto.materialName,
      code: dto.code,
      quantity: dto.quantity,
      medicine: const MedicineMapper().toEntityOrNull(dto.material),
    );
  }

  HospitalStockDto toDto(HospitalStock entity) {
    return HospitalStockDto(
      serviceId: entity.serviceId,
      serviceName: entity.serviceName,
      materialId: entity.materialId,
      materialName: entity.materialName,
      code: entity.code,
      quantity: entity.quantity,
      material: const MedicineMapper().toDtoOrNull(entity.medicine),
    );
  }

  List<HospitalStock> toEntityList(List<HospitalStockDto> dtos) => dtos.map(toEntity).toList();

  List<HospitalStockDto> toDtoList(List<HospitalStock> entities) => entities.map(toDto).toList();

  HospitalStock? toEntityOrNull(HospitalStockDto? dto) => dto == null ? null : toEntity(dto);

  HospitalStockDto? toDtoOrNull(HospitalStock? entity) => entity == null ? null : toDto(entity);
}
