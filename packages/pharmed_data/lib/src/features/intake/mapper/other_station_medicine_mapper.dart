import 'package:pharmed_core/pharmed_core.dart';

class OtherStationMedicineMapper {
  const OtherStationMedicineMapper();

  OtherStationMedicine toEntity(OtherStationMedicineDTO dto) => OtherStationMedicine(
    stationId: dto.stationId,
    stationName: dto.stationName,
    serviceName: dto.serviceName,
    materialId: dto.materialId,
    materialName: dto.materialName,
    stockQuantity: dto.stockQuantity,
    purchaseQuantity: dto.purchaseQuantity,
    isEquivalent: dto.isEquivalent,
  );

  List<OtherStationMedicine> toEntityList(List<OtherStationMedicineDTO> dtos) => dtos.map(toEntity).toList();
}
