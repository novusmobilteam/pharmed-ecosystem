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
      cabin: const CabinMapper().toEntityOrNull(dto.cabin),
      medicine: _withBarcode(dto.medicine != null ? const MedicineMapper().toEntity(dto.medicine!) : null, dto.barcode),
    );
  }

  /// Barkod yanıtın kökünde de gelebiliyor — malzeme nesnesinde yoksa oradan
  /// tamamlanır (istasyon stok listesi barkodu medicine.barcode'dan okur).
  Medicine? _withBarcode(Medicine? medicine, String? barcode) {
    if (medicine == null || barcode == null || barcode.isEmpty) return medicine;
    if (medicine.barcode?.isNotEmpty ?? false) return medicine;
    return switch (medicine) {
      Drug d => d.copyWith(barcode: barcode),
      MedicalConsumable m => m.copyWith(barcode: barcode),
    };
  }

  StationStockDTO toDto(StationStock entity) {
    return StationStockDTO(
      id: entity.id,
      cabin: const CabinMapper().toDtoOrNull(entity.cabin),
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
