import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Drug ↔ DrugDTO dönüşümleri.
class DrugMapper {
  const DrugMapper();

  Drug toEntity(DrugDTO dto) {
    return Drug(
      id: dto.id,
      definition: dto.definition,
      barcode: dto.barcode,
      name: dto.name,
      code: dto.code,
      prescriptionType: PrescriptionType.fromId(dto.prescriptionTypeId.toInt()),
      dose: dto.dose,
      doseUnit: const UnitMapper().toEntityOrNull(dto.doseUnit),
      isMeasureUnit: dto.isMeasureUnit,
      unitMeasure: const UnitMapper().toEntityOrNull(dto.unitMeasure),
      doseMeasureUnit: dto.doseMeasureUnit,
      volume: dto.volume,
      volumeUnit: const UnitMapper().toEntityOrNull(dto.volumeUnit),
      firm: Firm.fromIdAndName(id: dto.firmId?.toInt(), name: dto.firm),
      dailyMaxUsage: dto.dailyMaxUsage,
      drugType: DrugType.fromIdAndName(id: dto.drugTypeId?.toInt(), name: dto.drugType),
      returnType: ReturnType.fromId(dto.returnFormId?.toInt()),
      isQrCode: dto.isQrCode,
      piece: dto.piece,
      drugClass: DrugClass.fromIdAndName(id: dto.drugClassId?.toInt(), name: dto.drugClass),
      purchaseType: PurchaseType.fromId(dto.purchaseFormId.toInt()),
      isOrderlessStation: dto.isOrderlessStation,
      dosageForm: DosageForm(id: dto.dosageFormUnitId?.toInt(), name: dto.dosageFormUnit),
      countType: CountType.fromId(dto.countTypeId.toInt()),
      atcCode: dto.atcCode?.toInt(),
      isActive: dto.isActive,
      isMultiplePatientAccess: dto.isMultiplePatientAccess,
      isSinglePatientAccess: dto.isSinglePatientAccess,
      isSingleUse: dto.isSingleUse,
      isCameraRecording: dto.isCameraRecording,
      isWastagePharmacyApproval: dto.isWastagePharmacyApproval,
      isWastageOrderRenewed: dto.isWastageOrderRenewed,
      isWitnessedPurchase: dto.isWitnessedPurchase,
      isWastageWitnessedPurchase: dto.isWastageWitnessedPurchase,
      isDestroyable: dto.isDestroyable,
      isIndependentMaterial: dto.isIndependentMaterial,
      isCanLowerDose: dto.isCanLowerDose,
      collectNote: dto.collectNote,
      returnNote: dto.returnNote,
      destructionNote: dto.destructionNote,
      witnessedPurchaseUsers: dto.witnessedPurchaseUsers != null
          ? const UserMapper().toEntityList(dto.witnessedPurchaseUsers!)
          : [],
      destroyableUsers: dto.destroyableUsers != null ? const UserMapper().toEntityList(dto.destroyableUsers!) : [],
      wastageWitnessedPurchaseUsers: dto.wastageWitnessedPurchaseUsers != null
          ? const UserMapper().toEntityList(dto.wastageWitnessedPurchaseUsers!)
          : [],
      materialOrderlessTakingUsers: dto.materialOrderlessTakingUsers != null
          ? const UserMapper().toEntityList(dto.materialOrderlessTakingUsers!)
          : [],
      witnessedPurchaseStations: const StationMapper().toEntityList(dto.witnessedPurchaseStations ?? []),
      wastageWitnessedPurchaseStations: const StationMapper().toEntityList(dto.wastageWitnessedPurchaseStations ?? []),
      activeIngredientIds: dto.activeIngredientIds,
      equivalentCode: dto.equivalentCode,
      isNotSerumCabinetMaxValue: dto.isNotSerumCabinetMaxValue,
      isNotCubicDrawrMaxValue: dto.isNotCubicDrawrMaxValue,
      isRfidEnable: dto.isRfidEnable,
    );
  }

  DrugDTO toDto(Drug entity) {
    return DrugDTO(
      id: entity.id,
      definition: entity.definition,
      barcode: entity.barcode,
      name: entity.name,
      code: entity.code,
      prescriptionTypeId: entity.prescriptionType.id,
      dose: entity.dose,
      doseUnit: UnitMapper().toDtoOrNull(entity.doseUnit),
      unitMeasure: UnitMapper().toDtoOrNull(entity.unitMeasure),
      firmId: entity.firm?.id,
      dailyMaxUsage: entity.dailyMaxUsage,
      drugTypeId: entity.drugType?.id,
      returnFormId: entity.returnType?.id,
      isQrCode: entity.isQrCode,
      piece: entity.piece,
      drugClassId: entity.drugClass?.id,
      purchaseFormId: entity.purchaseType.id,
      isMeasureUnit: entity.isMeasureUnit,
      doseMeasureUnit: entity.doseMeasureUnit,
      volume: entity.volume,
      volumeUnit: UnitMapper().toDtoOrNull(entity.volumeUnit),
      isOrderlessStation: entity.isOrderlessStation,
      dosageFormUnitId: entity.dosageForm?.id,
      countTypeId: entity.countType.id,
      atcCode: entity.atcCode,
      isActive: entity.isActive,
      isMultiplePatientAccess: entity.isMultiplePatientAccess,
      isSinglePatientAccess: entity.isSinglePatientAccess,
      isSingleUse: entity.isSingleUse,
      isCameraRecording: entity.isCameraRecording,
      isWastagePharmacyApproval: entity.isWastagePharmacyApproval,
      isWastageOrderRenewed: entity.isWastageOrderRenewed,
      isWitnessedPurchase: entity.isWitnessedPurchase,
      isWastageWitnessedPurchase: entity.isWastageWitnessedPurchase,
      isDestroyable: entity.isDestroyable,
      collectNote: entity.collectNote,
      returnNote: entity.returnNote,
      destructionNote: entity.destructionNote,
      activeIngredientIds: entity.activeIngredientIds,
      witnessedPurchaseUsers: entity.witnessedPurchaseUsers.map((u) => const UserMapper().toDto(u)).toList(),
      destroyableUsers: entity.destroyableUsers.map((u) => const UserMapper().toDto(u)).toList(),
      wastageWitnessedPurchaseUsers: entity.wastageWitnessedPurchaseUsers
          .map((u) => const UserMapper().toDto(u))
          .toList(),
      materialOrderlessTakingUsers: entity.materialOrderlessTakingUsers
          .map((u) => const UserMapper().toDto(u))
          .toList(),
      witnessedPurchaseStations: const StationMapper().toDtoList(entity.witnessedPurchaseStations),
      wastageWitnessedPurchaseStations: const StationMapper().toDtoList(entity.wastageWitnessedPurchaseStations),
      equivalentCode: entity.equivalentCode,
      isNotSerumCabinetMaxValue: entity.isNotSerumCabinetMaxValue,
      isNotCubicDrawrMaxValue: entity.isNotCubicDrawrMaxValue,
      isCanLowerDose: entity.isCanLowerDose,
      isIndependentMaterial: entity.isIndependentMaterial,
      isRfidEnable: entity.isRfidEnable,
    );
  }

  List<Drug> toEntityList(List<DrugDTO> dtos) => dtos.map(toEntity).toList();

  List<DrugDTO> toDtoList(List<Drug> entities) => entities.map(toDto).toList();

  Drug? toEntityOrNull(DrugDTO? dto) => dto == null ? null : toEntity(dto);

  DrugDTO? toDtoOrNull(Drug? entity) => entity == null ? null : toDto(entity);
}
