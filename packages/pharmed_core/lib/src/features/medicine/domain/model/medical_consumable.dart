part of 'medicine.dart';

class MedicalConsumable extends Medicine {
  @override
  final String? name;

  @override
  final String? barcode;
  @override
  final CountType? countType;
  @override
  final PurchaseType? purchaseType;
  @override
  final ReturnType? returnType;

  final MaterialType? materialType;
  final Firm? firm;
  final int? institutionCode;
  final int? sutCode;
  final int? ubbCode;
  final int? dailyMaxUsage;
  final String? collectNote;
  final String? returnNote;
  final String? destructionNote;
  final Status status;

  MedicalConsumable({
    super.id,
    this.name,
    this.countType,
    this.purchaseType,
    this.returnType,
    this.materialType,
    this.firm,
    this.barcode,
    this.institutionCode,
    this.sutCode,
    this.ubbCode,
    this.dailyMaxUsage,
    this.collectNote,
    this.returnNote,
    this.destructionNote,
    this.status = Status.active,
  }) : super(
          title: name?.toString() ?? "-",
          subtitle: barcode,
        );

  MedicalConsumableDTO toDto() {
    return MedicalConsumableDTO(
      id: id,
      name: name,
      barcode: barcode,
      institutionCode: institutionCode,
      sutCode: sutCode,
      ubbCode: ubbCode,
      materialType: materialType?.name,
      materialTypeId: materialType?.id,
      firm: firm?.name,
      countTypeId: countType?.id,
      dailyMaxUsage: dailyMaxUsage,
      purchaseFormId: purchaseType?.id,
      returnFormId: returnType?.id,
      collectNote: collectNote,
      returnNote: returnNote,
      destructionNote: destructionNote,
      isActive: status.isActive,
    );
  }

  MedicalConsumable copyWith({
    int? id,
    String? name,
    String? barcode,
    CountType? countType,
    PurchaseType? purchaseType,
    ReturnType? returnType,
    MaterialType? materialType,
    Firm? firm,
    int? institutionCode,
    int? sutCode,
    int? ubbCode,
    int? dailyMaxUsage,
    String? collectNote,
    String? returnNote,
    String? destructionNote,
    Status? status,
  }) {
    return MedicalConsumable(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      countType: countType ?? this.countType,
      purchaseType: purchaseType ?? this.purchaseType,
      returnType: returnType ?? this.returnType,
      materialType: materialType ?? this.materialType,
      firm: firm ?? this.firm,
      institutionCode: institutionCode ?? this.institutionCode,
      sutCode: sutCode ?? this.sutCode,
      ubbCode: ubbCode ?? this.ubbCode,
      returnNote: returnNote ?? this.returnNote,
      dailyMaxUsage: dailyMaxUsage ?? this.dailyMaxUsage,
      collectNote: collectNote ?? this.collectNote,
      destructionNote: destructionNote ?? this.destructionNote,
      status: status ?? this.status,
    );
  }

  @override
  List get rawContent => [
        barcode,
        '',
        name,
        materialType?.name,
        '',
        countType?.label,
        purchaseType?.label,
        returnType?.label,
      ];
}
