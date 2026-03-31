import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// StationStock ↔ StationStockDTO dönüşümleri.
class StationStockMapper {
  const StationStockMapper();

  StationStock toEntity(StationStockDTO dto) {
    return StationStock(
      id: dto.id,
      code: dto.code,
      maxQuantity: dto.maxQuantity,
      currentQuantity: dto.currentQuantity,
      reservedQuantity: dto.reservedQuantity,
      remainingQuantity: dto.remainingQuantity,
      fillingQuantity: dto.fillingQuantity,
      // Alt modeller için ilgili mapper'lar
      station: const StationMapper().toEntityOrNull(dto.station),
      medicine: dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null,
    );
  }

  StationStockDTO toDto(StationStock entity) {
    return StationStockDTO(
      id: entity.id,
      stationId: entity.station?.id,
      station: const StationMapper().toDtoOrNull(entity.station),
      code: entity.code,
      barcode: entity.medicine?.barcode,
      medicineId: entity.medicine?.id,
      medicine: const MedicineMapper().toDtoOrNull(entity.medicine),
      maxQuantity: entity.maxQuantity,
      currentQuantity: entity.currentQuantity,
      reservedQuantity: entity.reservedQuantity,
      remainingQuantity: entity.remainingQuantity,
      fillingQuantity: entity.fillingQuantity,
    );
  }

  List<StationStock> toEntityList(List<StationStockDTO> dtos) => dtos.map(toEntity).toList();

  List<StationStockDTO> toDtoList(List<StationStock> entities) => entities.map(toDto).toList();

  StationStock? toEntityOrNull(StationStockDTO? dto) => dto == null ? null : toEntity(dto);

  StationStockDTO? toDtoOrNull(StationStock? entity) => entity == null ? null : toDto(entity);
}
