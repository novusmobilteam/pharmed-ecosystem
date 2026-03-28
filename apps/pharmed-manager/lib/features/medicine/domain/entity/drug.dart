part of 'medicine.dart';

class Drug extends Medicine {
  @override
  final String? name;
  final String? code;
  @override
  final String? barcode;
  final DrugType? drugType;
  final DrugClass? drugClass;
  @override
  final PrescriptionType prescriptionType;
  @override
  final ReturnType? returnType;
  @override
  final PurchaseType purchaseType;
  @override
  final CountType countType;

  final String? definition;

  final num? dose;
  final Unit? doseUnit;

  final bool isMeasureUnit;
  final num? doseMeasureUnit;
  final Unit? unitMeasure;

  final num? volume;
  final Unit? volumeUnit;

  final Firm? firm;

  final DosageForm? dosageForm;

  final num? dailyMaxUsage;
  final bool isQrCode;
  final num? piece;

  final bool isOrderlessStation;

  final int? atcCode;
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

  final List<User> witnessedPurchaseUsers;
  final List<User> materialOrderlessTakingUsers;
  final List<User> wastageWitnessedPurchaseUsers;
  final List<User> destroyableUsers;

  final List<Station> witnessedPurchaseStations;
  final List<Station> wastageWitnessedPurchaseStations;

  Status get status => isActive ? Status.active : Status.passive;

  static Drug? fromIdAndName({int? id, String? name, String? barcode}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Drug(
      id: id,
      name: name,
      barcode: barcode,
    );
  }

  Drug({
    super.id,
    this.definition,
    this.barcode,
    this.name,
    this.code,
    this.prescriptionType = PrescriptionType.white,
    this.dose,
    this.doseUnit,
    this.isMeasureUnit = false,
    this.unitMeasure,
    this.doseMeasureUnit,
    this.volume,
    this.volumeUnit,
    this.firm,
    this.drugType,
    this.returnType,
    this.drugClass,
    this.purchaseType = PurchaseType.ordered,
    this.dailyMaxUsage,
    this.isQrCode = false,
    this.piece,
    this.isOrderlessStation = false,
    this.dosageForm,
    this.countType = CountType.normalCount,
    this.atcCode,
    this.isActive = true,
    this.isMultiplePatientAccess = false,
    this.isSinglePatientAccess = true,
    this.isSingleUse = false,
    this.isCameraRecording = true,
    this.isWastagePharmacyApproval = false,
    this.isWastageOrderRenewed = false,
    this.isWitnessedPurchase = false,
    this.isWastageWitnessedPurchase = false,
    this.isDestroyable = false,
    this.isIndependentMaterial = false,
    this.isCanLowerDose = false,
    this.isNotSerumCabinetMaxValue = false,
    this.isNotCubicDrawrMaxValue = false,
    this.collectNote,
    this.returnNote,
    this.destructionNote,
    this.activeIngredientIds = const [],
    this.witnessedPurchaseUsers = const [],
    this.witnessedPurchaseStations = const [],
    this.wastageWitnessedPurchaseUsers = const [],
    this.wastageWitnessedPurchaseStations = const [],
    this.destroyableUsers = const [],
    this.materialOrderlessTakingUsers = const [],
    this.equivalentCode,
  }) : super(
          title: name?.toString() ?? "-",
          subtitle: barcode,
        );

  Drug copyWith({
    int? id,
    String? definition,
    String? barcode,
    String? name,
    String? code,
    PrescriptionType? prescriptionType,
    int? dose,
    Unit? doseUnit,
    bool? isMeasureUnit,
    int? doseMeasureUnit,
    Unit? unitMeasure,
    int? volume,
    Unit? volumeUnit,
    Firm? firm,
    int? dailyMaxUsage,
    DrugType? drugType,
    ReturnType? returnType,
    DrugClass? drugClass,
    PurchaseType? purchaseType,
    bool? isQrCode,
    int? piece,
    bool? isOrderlessStation,
    DosageForm? dosageForm,
    CountType? countType,
    int? atcCode,
    bool? isActive,
    bool? isMultiplePatientAccess,
    bool? isSinglePatientAccess,
    bool? isSingleUse,
    bool? isCameraRecording,
    bool? isWastagePharmacyApproval,
    bool? isWastageOrderRenewed,
    bool? isWitnessedPurchase,
    bool? isWastageWitnessedPurchase,
    bool? isDestroyable,
    bool? isIndependentMaterial,
    bool? isCanLowerDose,
    bool? isNotSerumCabinetMaxValue,
    bool? isNotCubicDrawrMaxValue,
    String? collectNote,
    String? returnNote,
    String? destructionNote,
    String? equivalentCode,
    List<int>? activeIngredientIds,
    List<User>? witnessedPurchaseUsers,
    List<Station>? witnessedPurchaseStations,
    List<User>? wastageWitnessedPurchaseUsers,
    List<Station>? wastageWitnessedPurchaseStations,
    List<User>? destroyableUsers,
    List<User>? materialOrderlessTakingUsers,
  }) {
    return Drug(
      id: id ?? this.id,
      definition: definition ?? this.definition,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      code: code ?? this.code,
      prescriptionType: prescriptionType ?? this.prescriptionType,
      dose: dose ?? this.dose,
      doseUnit: doseUnit ?? this.doseUnit,
      isMeasureUnit: isMeasureUnit ?? this.isMeasureUnit,
      doseMeasureUnit: doseMeasureUnit ?? this.doseMeasureUnit,
      unitMeasure: unitMeasure ?? this.unitMeasure,
      volume: volume ?? this.volume,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      firm: firm ?? this.firm,
      returnType: returnType ?? this.returnType,
      drugType: drugType ?? this.drugType,
      drugClass: drugClass ?? this.drugClass,
      purchaseType: purchaseType ?? this.purchaseType,
      dailyMaxUsage: dailyMaxUsage,
      isQrCode: isQrCode ?? this.isQrCode,
      piece: piece ?? this.piece,
      isOrderlessStation: isOrderlessStation ?? this.isOrderlessStation,
      dosageForm: dosageForm ?? this.dosageForm,
      countType: countType ?? this.countType,
      atcCode: atcCode ?? this.atcCode,
      isActive: isActive ?? this.isActive,
      isMultiplePatientAccess: isMultiplePatientAccess ?? this.isMultiplePatientAccess,
      isSinglePatientAccess: isSinglePatientAccess ?? this.isSinglePatientAccess,
      isSingleUse: isSingleUse ?? this.isSingleUse,
      isCameraRecording: isCameraRecording ?? this.isCameraRecording,
      isWastagePharmacyApproval: isWastagePharmacyApproval ?? this.isWastagePharmacyApproval,
      isWastageOrderRenewed: isWastageOrderRenewed ?? this.isWastageOrderRenewed,
      isWitnessedPurchase: isWitnessedPurchase ?? this.isWitnessedPurchase,
      witnessedPurchaseUsers: witnessedPurchaseUsers ?? this.witnessedPurchaseUsers,
      witnessedPurchaseStations: witnessedPurchaseStations ?? this.witnessedPurchaseStations,
      isWastageWitnessedPurchase: isWastageWitnessedPurchase ?? this.isWastageWitnessedPurchase,
      wastageWitnessedPurchaseUsers: wastageWitnessedPurchaseUsers ?? this.wastageWitnessedPurchaseUsers,
      wastageWitnessedPurchaseStations: wastageWitnessedPurchaseStations ?? this.wastageWitnessedPurchaseStations,
      isDestroyable: isDestroyable ?? this.isDestroyable,
      isIndependentMaterial: isIndependentMaterial ?? this.isIndependentMaterial,
      isCanLowerDose: isCanLowerDose ?? this.isCanLowerDose,
      destroyableUsers: destroyableUsers ?? this.destroyableUsers,
      collectNote: collectNote ?? this.collectNote,
      returnNote: returnNote ?? this.returnNote,
      destructionNote: destructionNote ?? this.destructionNote,
      activeIngredientIds: activeIngredientIds ?? this.activeIngredientIds,
      isNotSerumCabinetMaxValue: isNotSerumCabinetMaxValue ?? this.isNotSerumCabinetMaxValue,
      isNotCubicDrawrMaxValue: isNotCubicDrawrMaxValue ?? this.isNotCubicDrawrMaxValue,
      materialOrderlessTakingUsers: materialOrderlessTakingUsers ?? this.materialOrderlessTakingUsers,
      equivalentCode: equivalentCode ?? this.equivalentCode,
    );
  }

  DrugDTO toDto() {
    return DrugDTO(
      id: id,
      definition: definition,
      barcode: barcode,
      name: name,
      code: code,
      prescriptionTypeId: prescriptionType.id,
      dose: dose,
      doseUnit: doseUnit?.toDTO(),
      unitMeasure: unitMeasure?.toDTO(),
      firmId: firm?.id,
      dailyMaxUsage: dailyMaxUsage,
      drugTypeId: drugType?.id,
      returnFormId: returnType?.id,
      isQrCode: isQrCode,
      piece: piece,
      drugClassId: drugClass?.id,
      purchaseFormId: purchaseType.id,
      isMeasureUnit: isMeasureUnit,
      doseMeasureUnit: doseMeasureUnit,
      volume: volume,
      volumeUnit: volumeUnit?.toDTO(),
      isOrderlessStation: isOrderlessStation,
      dosageFormUnitId: dosageForm?.id,
      countTypeId: countType.id,
      atcCode: atcCode,
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
      collectNote: collectNote,
      returnNote: returnNote,
      destructionNote: destructionNote,
      activeIngredientIds: activeIngredientIds,
      witnessedPurchaseUsers: witnessedPurchaseUsers.map((user) => user.toDTO()).toList(),
      witnessedPurchaseStations: witnessedPurchaseStations.map((station) => station.toDTO()).toList(),
      wastageWitnessedPurchaseUsers: wastageWitnessedPurchaseUsers.map((user) => user.toDTO()).toList(),
      wastageWitnessedPurchaseStations: wastageWitnessedPurchaseStations.map((station) => station.toDTO()).toList(),
      destroyableUsers: destroyableUsers.map((user) => user.toDTO()).toList(),
      equivalentCode: equivalentCode,
      isNotSerumCabinetMaxValue: isNotSerumCabinetMaxValue,
      isNotCubicDrawrMaxValue: isNotCubicDrawrMaxValue,
      materialOrderlessTakingUsers: materialOrderlessTakingUsers.map((user) => user.toDTO()).toList(),
      isCanLowerDose: isCanLowerDose,
      isIndependentMaterial: isIndependentMaterial,
    );
  }

  @override
  List get rawContent => [
        barcode,
        atcCode?.toCustomString(),
        name,
        drugType?.name,
        prescriptionType.label,
        countType.label,
        purchaseType.label,
        returnType?.label,
      ];
}
