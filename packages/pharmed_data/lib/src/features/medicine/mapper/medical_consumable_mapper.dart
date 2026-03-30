import 'package:pharmed_core/pharmed_core.dart';

/// MedicalConsumable ↔ MedicalConsumableDTO dönüşümleri.
class MedicalConsumableMapper {
  const MedicalConsumableMapper();

  MedicalConsumable toEntity(MedicalConsumableDTO dto) {
    return MedicalConsumable(
      id: dto.id,
      name: dto.name,
      barcode: dto.barcode,
      institutionCode: dto.institutionCode,
      sutCode: dto.sutCode,
      ubbCode: dto.ubbCode,
      materialType: MaterialType.fromIdAndName(id: dto.materialTypeId, name: dto.materialType),
      firm: Firm.fromIdAndName(id: dto.firmId, name: dto.firm),
      countType: CountType.fromId(dto.countTypeId),
      dailyMaxUsage: dto.dailyMaxUsage,
      purchaseType: PurchaseType.fromId(dto.purchaseFormId),
      returnType: ReturnType.fromId(dto.returnFormId),
      collectNote: dto.collectNote,
      returnNote: dto.returnNote,
      destructionNote: dto.destructionNote,
      status: statusFromBool(dto.isActive ?? false),
    );
  }

  MedicalConsumableDTO toDto(MedicalConsumable entity) {
    return MedicalConsumableDTO(
      id: entity.id,
      name: entity.name,
      barcode: entity.barcode,
      institutionCode: entity.institutionCode,
      sutCode: entity.sutCode,
      ubbCode: entity.ubbCode,
      materialType: entity.materialType?.name,
      materialTypeId: entity.materialType?.id,
      firm: entity.firm?.name,
      firmId: entity.firm?.id,
      countTypeId: entity.countType?.id,
      dailyMaxUsage: entity.dailyMaxUsage,
      purchaseFormId: entity.purchaseType?.id,
      returnFormId: entity.returnType?.id,
      collectNote: entity.collectNote,
      returnNote: entity.returnNote,
      destructionNote: entity.destructionNote,
      isActive: entity.status.isActive,
    );
  }

  List<MedicalConsumable> toEntityList(List<MedicalConsumableDTO> dtos) => dtos.map(toEntity).toList();

  List<MedicalConsumableDTO> toDtoList(List<MedicalConsumable> entities) => entities.map(toDto).toList();
}
