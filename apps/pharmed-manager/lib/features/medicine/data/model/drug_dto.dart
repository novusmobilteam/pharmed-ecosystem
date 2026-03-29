// ignore_for_file: unused_local_variable

part of 'medicine_dto.dart';

class DrugDTO extends MedicineDTO {
  final int? id;
  final String? definition;
  final String? barcode;
  final bool isMaterial;

  final String? name;
  final String? code;
  final num prescriptionTypeId;
  // Doz + Birim
  final num? dose;
  final UnitDTO? doseUnit;
  // Ölçü Birimi Kullan
  final bool isMeasureUnit;
  final num? doseMeasureUnit;
  final UnitDTO? unitMeasure;
  // Hacim
  final num? volume;
  final UnitDTO? volumeUnit;
  // Firma
  final num? firmId;
  final String? firm;
  // Günlük Maks.
  final num? dailyMaxUsage;
  // İlaç Tipi
  final num? drugTypeId;
  final String? drugType;
  // İade Tipi
  final num? returnFormId;
  final String? returnForm;
  // Karekodlu
  final bool isQrCode;
  // Karekodlu Adet
  final num? piece;
  // İlaç Sınıfı
  final num? drugClassId;
  final String? drugClass;
  // Alım Şekli
  final num purchaseFormId;
  final String? purchaseForm;

  final bool isOrderlessStation;
  final num? dosageFormUnitId;
  final String? dosageFormUnit;
  final num countTypeId;
  final String? countType;

  final num? atcCode;
  final String? equivalentCode;

  final bool isActive;
  final bool isMultiplePatientAccess;
  final bool isSinglePatientAccess;
  final bool isSingleUse;
  final bool isCameraRecording;
  final bool isWastagePharmacyApproval;
  final bool isWastageOrderRenewed;
  final bool isWitnessedPurchase;
  final bool isWastageWitnessedPurchase;
  final bool isDestroyable;
  final bool isIndependentMaterial;
  final bool isCanLowerDose;
  final bool isNotSerumCabinetMaxValue;
  final bool isNotCubicDrawrMaxValue;

  final String? collectNote;
  final String? returnNote;
  final String? destructionNote;

  final List<int> activeIngredientIds;
  final List<String>? activeIngredients;

  final List<UserDTO>? witnessedPurchaseUsers;
  final List<UserDTO>? destroyableUsers;
  final List<UserDTO>? wastageWitnessedPurchaseUsers;
  final List<UserDTO>? materialOrderlessTakingUsers;

  final List<StationDTO>? wastageWitnessedPurchaseStations;
  final List<StationDTO>? witnessedPurchaseStations;

  const DrugDTO({
    this.id,
    this.definition,
    this.barcode,
    this.name,
    this.code,
    this.isMaterial = true,
    this.prescriptionTypeId = 1,
    this.dose,
    this.doseUnit,
    this.isMeasureUnit = false,
    this.unitMeasure,
    this.doseMeasureUnit,
    this.volume,
    this.volumeUnit,
    this.firmId,
    this.firm,
    this.dailyMaxUsage,
    this.drugTypeId,
    this.drugType,
    this.returnFormId,
    this.returnForm,
    this.isQrCode = false,
    this.piece,
    this.drugClassId,
    this.drugClass,
    this.purchaseFormId = 1,
    this.purchaseForm,
    this.isOrderlessStation = false,
    this.dosageFormUnitId,
    this.dosageFormUnit,
    this.countTypeId = 1,
    this.countType,
    this.atcCode,
    this.isActive = true,
    this.isMultiplePatientAccess = false,
    this.isSinglePatientAccess = true,
    this.isSingleUse = false,
    this.isCameraRecording = true,
    this.isWastagePharmacyApproval = false,
    this.isWastageOrderRenewed = false,
    this.isWitnessedPurchase = false,
    this.witnessedPurchaseUsers,
    this.witnessedPurchaseStations,
    this.isWastageWitnessedPurchase = false,
    this.wastageWitnessedPurchaseUsers,
    this.wastageWitnessedPurchaseStations,
    this.materialOrderlessTakingUsers = const [],
    this.isDestroyable = false,
    this.isIndependentMaterial = false,
    this.isCanLowerDose = false,
    this.isNotSerumCabinetMaxValue = false,
    this.isNotCubicDrawrMaxValue = false,
    this.destroyableUsers,
    this.collectNote,
    this.returnNote,
    this.destructionNote,
    this.activeIngredients,
    this.activeIngredientIds = const [],
    this.equivalentCode,
  });

  factory DrugDTO.fromJson(Map<String, dynamic> json) {
    return DrugDTO(
      id: json['id'] as int?,
      definition: json['definition'] as String?,
      barcode: json['barcode'] as String?,
      name: json['name'] as String?,
      code: json['code'] as String?,
      isMaterial: json['isMaterial'] as bool? ?? true,
      prescriptionTypeId: json['prescriptionTypeId'] as num? ?? 1,
      dose: json['dose'] as num?,
      doseUnit: json['doseUnit'] != null ? UnitDTO.fromJson(json['doseUnit']) : null,
      isMeasureUnit: json['isMeasureUnit'] as bool? ?? false,
      doseMeasureUnit: json['doseMeasureUnit'] as num?,
      unitMeasure: json['unitMeasure'] != null ? UnitDTO.fromJson(json['unitMeasure']) : null,
      volume: json['volume'] as num?,
      volumeUnit: json['unitVolume'] != null ? UnitDTO.fromJson(json['unitVolume']) : null,
      firmId: json['firmId'] as num?,
      firm: json['firm'] as String?,
      dailyMaxUsage: json['dailyMaxUsage'] as num?,
      drugTypeId: json['drugTypeId'] as num?,
      drugType: json['drugType'] as String?,
      returnFormId: json['returnFormId'] as num?,
      returnForm: json['returnForm'] as String?,
      isQrCode: json['isQrCode'] as bool? ?? false,
      piece: json['piece'] as num?,
      drugClassId: json['drugClassId'] as num?,
      drugClass: json['drugClass'] as String?,
      purchaseFormId: json['purchaseFormId'] as num? ?? 1,
      purchaseForm: json['purchaseForm'] as String?,
      isOrderlessStation: json['isOrderlessStation'] as bool? ?? false,
      dosageFormUnitId: json['dosageFormUnitId'] as num?,
      dosageFormUnit: json['dosageFormUnit'] as String?,
      countTypeId: json['countTypeId'] as num? ?? 1,
      countType: json['countType'] as String?,
      atcCode: json['atcCode'] as num?,
      isActive: json['isActive'] as bool? ?? true,
      isMultiplePatientAccess: json['isMultiplePatientAccess'] as bool? ?? false,
      isSinglePatientAccess: json['isSinglePatientAccess'] as bool? ?? true,
      isSingleUse: json['isSingleUse'] as bool? ?? false,
      isCameraRecording: json['isCameraRecording'] as bool? ?? true,
      isNotSerumCabinetMaxValue: json['isNotSerumCabinetMaxValue'] as bool? ?? false,
      isNotCubicDrawrMaxValue: json['isNotCubicDrawrMaxValue'] as bool? ?? false,
      isWastagePharmacyApproval: json['isWastagePharmacyApproval'] as bool? ?? false,
      isWastageOrderRenewed: json['isWastageOrderRenewed'] as bool? ?? false,
      isWitnessedPurchase: json['isWitnessedPurchase'] as bool? ?? false,
      isDestroyable: json['isDestroyable'] as bool? ?? false,
      isIndependentMaterial: json['isIndependentMaterial'] as bool? ?? false,
      isCanLowerDose: json['isCanLowerDose'] as bool? ?? false,
      collectNote: json['collectNote'] as String?,
      returnNote: json['returnNote'] as String?,
      destructionNote: json['destructionNote'] as String?,
      activeIngredients: (json['activeIngredients'] as List<dynamic>?)?.map((e) => e as String).toList(),
      activeIngredientIds: (json['activeIngredientIds'] as List?)?.cast<int>() ?? const [],
      equivalentCode: json['equivalentCode'] as String?,
      isWastageWitnessedPurchase: json['isWastageWitnessedPurchase'] as bool? ?? false,
      witnessedPurchaseUsers: json['witnessedPurchaseUser'] != null
          ? (json['witnessedPurchaseUser'] as List).map((e) => UserDTO.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      witnessedPurchaseStations: json['witnessedPurchaseStation'] != null
          ? (json['witnessedPurchaseStation'] as List)
                .map((e) => StationDTO.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      wastageWitnessedPurchaseUsers: json['wastageWitnessedPurchaseUser'] != null
          ? (json['wastageWitnessedPurchaseUser'] as List)
                .map((e) => UserDTO.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      wastageWitnessedPurchaseStations: json['wastageWitnessedPurchaseStation'] != null
          ? (json['wastageWitnessedPurchaseStation'] as List)
                .map((e) => StationDTO.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      destroyableUsers: json['destroyableUser'] != null
          ? (json['destroyableUser'] as List).map((e) => UserDTO.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      materialOrderlessTakingUsers: json['materialOrderlessTakingUser'] != null
          ? (json['materialOrderlessTakingUser'] as List)
                .map((e) => UserDTO.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'definition': definition,
      'barcode': barcode,
      'name': name,
      'code': code,
      'isMaterial': isMaterial,
      'prescriptionTypeId': prescriptionTypeId,
      // Doz
      'dose': dose,
      'doseUnitId': doseUnit?.id,
      // Ölçü Birimi
      'isMeasureUnit': isMeasureUnit,
      'doseMeasureUnit': doseMeasureUnit,
      'unitMeasure': unitMeasure,
      'unitMeasureId': unitMeasure?.id,
      // Hacim
      'volume': volume,
      'unitVolumeId': volumeUnit?.id,
      'firmId': firmId,
      'dailyMaxUsage': dailyMaxUsage,
      'drugTypeId': drugTypeId,
      'returnFormId': returnFormId,
      'isQrCode': isQrCode,
      'piece': piece,
      'drugClassId': drugClassId,
      'purchaseFormId': purchaseFormId,
      'isOrderlessStation': isOrderlessStation,
      'dosageFormUnitId': dosageFormUnitId,
      'countTypeId': countTypeId,
      'atcCode': atcCode,
      'isActive': isActive,
      'isMultiplePatientAccess': isMultiplePatientAccess,
      'isSinglePatientAccess': isSinglePatientAccess,
      'isSingleUse': isSingleUse,
      'isCameraRecording': isCameraRecording,
      'isWastagePharmacyApproval': isWastagePharmacyApproval,
      'isWastageOrderRenewed': isWastageOrderRenewed,
      'isWitnessedPurchase': isWitnessedPurchase,
      'witnessedPurchaseUserIds': isWitnessedPurchase ? witnessedPurchaseUsers?.map((u) => u.id).toList() : null,
      'witnessedPurchaseStationIds': isWitnessedPurchase ? witnessedPurchaseStations?.map((s) => s.id).toList() : null,
      'isWastageWitnessedPurchase': isWastageWitnessedPurchase,
      'wastageWitnessedPurchaseUserIds': isWastageWitnessedPurchase
          ? wastageWitnessedPurchaseUsers?.map((u) => u.id).toList()
          : null,
      'wastageWitnessedPurchaseStationIds': isWastageWitnessedPurchase
          ? wastageWitnessedPurchaseStations?.map((s) => s.id).toList()
          : null,
      'isDestroyable': isDestroyable,
      'destroyableUserIds': isDestroyable ? destroyableUsers?.map((u) => u.id).toList() : null,
      'materialOrderlessTakingUserIds': materialOrderlessTakingUsers?.map((u) => u.id).toList(),
      'collectNote': collectNote,
      'returnNote': returnNote,
      'destructionNote': destructionNote,
      'activeIngredientIds': activeIngredientIds,
      'equivalentCode': equivalentCode,
      'isNotSerumCabinetMaxValue': isNotSerumCabinetMaxValue,
      'isNotCubicDrawrMaxValue': isNotCubicDrawrMaxValue,

      'isIndependentMaterial': isIndependentMaterial,
      'isCanLowerDose': isCanLowerDose,
    };
  }

  @override
  Drug toEntity() {
    return Drug(
      id: id,
      definition: definition,
      barcode: barcode,
      name: name,
      code: code,
      prescriptionType: PrescriptionType.fromId(prescriptionTypeId.toInt()),
      dose: dose,
      doseUnit: doseUnit?.toEntity(),
      isMeasureUnit: isMeasureUnit,
      unitMeasure: unitMeasure?.toEntity(),
      doseMeasureUnit: doseMeasureUnit,
      volume: volume,
      volumeUnit: volumeUnit?.toEntity(),
      firm: Firm.fromIdAndName(id: firmId?.toInt(), name: firm),
      dailyMaxUsage: dailyMaxUsage,
      drugType: DrugType.fromIdAndName(id: drugTypeId?.toInt(), name: drugType),
      returnType: ReturnType.fromId(returnFormId?.toInt()),
      isQrCode: isQrCode,
      piece: piece,
      drugClass: DrugClass.fromIdAndName(id: drugClassId?.toInt(), name: drugClass),
      purchaseType: PurchaseType.fromId(purchaseFormId.toInt()),
      isOrderlessStation: isOrderlessStation,
      dosageForm: DosageForm(id: dosageFormUnitId?.toInt(), name: dosageFormUnit),
      countType: CountType.fromId(countTypeId.toInt()),
      atcCode: atcCode?.toInt(),
      isActive: isActive,
      isMultiplePatientAccess: isMultiplePatientAccess,
      isSinglePatientAccess: isSinglePatientAccess,
      isSingleUse: isSingleUse,
      isCameraRecording: isCameraRecording,
      isWastagePharmacyApproval: isWastagePharmacyApproval,
      isWastageOrderRenewed: isWastageOrderRenewed,
      isWitnessedPurchase: isWitnessedPurchase,
      isWastageWitnessedPurchase: isWastageWitnessedPurchase,
      isDestroyable: isDestroyable,
      isIndependentMaterial: isIndependentMaterial,
      isCanLowerDose: isCanLowerDose,
      collectNote: collectNote,
      returnNote: returnNote,
      destructionNote: destructionNote,
      witnessedPurchaseUsers: witnessedPurchaseUsers != null
          ? const UserMapper().toEntityList(witnessedPurchaseUsers!)
          : [],
      destroyableUsers: destroyableUsers != null ? const UserMapper().toEntityList(destroyableUsers!) : [],
      wastageWitnessedPurchaseUsers: wastageWitnessedPurchaseUsers != null
          ? const UserMapper().toEntityList(wastageWitnessedPurchaseUsers!)
          : [],
      materialOrderlessTakingUsers: materialOrderlessTakingUsers != null
          ? const UserMapper().toEntityList(materialOrderlessTakingUsers!)
          : [],
      witnessedPurchaseStations: witnessedPurchaseStations?.map((s) => s.toEntity()).toList() ?? [],

      wastageWitnessedPurchaseStations: wastageWitnessedPurchaseStations?.map((s) => s.toEntity()).toList() ?? [],

      activeIngredientIds: activeIngredientIds,
      equivalentCode: equivalentCode,
      isNotSerumCabinetMaxValue: isNotSerumCabinetMaxValue,
      isNotCubicDrawrMaxValue: isNotCubicDrawrMaxValue,
    );
  }
}
