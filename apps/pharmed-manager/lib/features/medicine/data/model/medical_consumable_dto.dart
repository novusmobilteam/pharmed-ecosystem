part of 'medicine_dto.dart';

class MedicalConsumableDTO extends MedicineDTO {
  final int? id;
  final String? barcode;
  final String? name;
  final int? institutionCode;
  final int? sutCode;
  final int? ubbCode;
  final int? materialTypeId;
  final String? materialType;
  final int? firmId;
  final String? firm;
  final int? countTypeId;
  final int? dailyMaxUsage;
  final int? purchaseFormId;
  final int? returnFormId;
  final String? collectNote;
  final String? returnNote;
  final String? destructionNote;
  final bool? isActive;

  const MedicalConsumableDTO({
    this.id,
    this.name,
    this.barcode,
    this.institutionCode,
    this.sutCode,
    this.ubbCode,
    this.materialTypeId,
    this.materialType,
    this.firmId,
    this.firm,
    this.countTypeId,
    this.dailyMaxUsage,
    this.purchaseFormId,
    this.returnFormId,
    this.collectNote,
    this.returnNote,
    this.destructionNote,
    this.isActive,
  });

  factory MedicalConsumableDTO.fromJson(Map<String, dynamic> json) {
    return MedicalConsumableDTO(
      id: json["id"] as int?,
      name: json["name"] as String?,
      barcode: json["barcode"] as String?,
      institutionCode: json["institutionCode"] as int?,
      sutCode: json["sutCode"] as int?,
      ubbCode: json["ubbCode"] as int?,
      materialTypeId: json['materialTypeId'] as int?,
      materialType: json['materialType'] as String?,
      firmId: json["firmId"] as int?,
      firm: json["firm"] as String?,
      countTypeId: json["countTypeId"] as int?,
      dailyMaxUsage: json["dailyMaxUsage"] as int?,
      purchaseFormId: json["purchaseFormId"] as int?,
      returnFormId: json["returnFormId"] as int?,
      collectNote: json["collectNote"] as String?,
      returnNote: json["returnNote"] as String?,
      destructionNote: json["destructionNote"] as String?,
      isActive: json["isActive"] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "barcode": barcode,
        "institutionCode": institutionCode,
        "sutCode": sutCode,
        "ubbCode": ubbCode,
        "materialType": materialType,
        "firmId": firmId,
        "countTypeId": countTypeId,
        "dailyMaxUsage": dailyMaxUsage,
        "purchaseFormId": purchaseFormId,
        "returnFormId": returnFormId,
        "collectNote": collectNote,
        "returnNote": returnNote,
        "destructionNote": destructionNote,
        "isActive": isActive,
      };

  MedicalConsumableDTO copyWith({
    int? id,
    String? name,
    String? barcode,
    int? institutionCode,
    int? sutCode,
    int? ubbCode,
    String? materialType,
    int? firmId,
    int? countTypeId,
    int? dailyMaxUsage,
    int? purchaseFormId,
    int? returnFormId,
    String? collectNote,
    String? returnNote,
    String? destructionNote,
    bool? isActive,
  }) =>
      MedicalConsumableDTO(
        id: id ?? this.id,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        institutionCode: institutionCode ?? this.institutionCode,
        sutCode: sutCode ?? this.sutCode,
        ubbCode: ubbCode ?? this.ubbCode,
        materialType: materialType ?? this.materialType,
        firmId: firmId ?? this.firmId,
        countTypeId: countTypeId ?? this.countTypeId,
        dailyMaxUsage: dailyMaxUsage ?? this.dailyMaxUsage,
        purchaseFormId: purchaseFormId ?? this.purchaseFormId,
        returnFormId: returnFormId ?? this.returnFormId,
        collectNote: collectNote ?? this.collectNote,
        returnNote: returnNote ?? this.returnNote,
        destructionNote: destructionNote ?? this.destructionNote,
        isActive: isActive ?? this.isActive,
      );

  @override
  MedicalConsumable toEntity() {
    return MedicalConsumable(
        id: id,
        name: name,
        barcode: barcode,
        institutionCode: institutionCode,
        sutCode: sutCode,
        ubbCode: ubbCode,
        materialType: MaterialType.fromIdAndName(
          id: materialTypeId,
          name: materialType,
        ),
        firm: Firm.fromIdAndName(
          id: firmId,
          name: firm,
        ),
        countType: CountType.fromId(countTypeId),
        dailyMaxUsage: dailyMaxUsage,
        purchaseType: PurchaseType.fromId(purchaseFormId),
        returnType: ReturnType.fromId(returnFormId),
        collectNote: collectNote,
        returnNote: returnNote,
        destructionNote: destructionNote,
        status: statusFromBool(isActive ?? false));
  }

  /// Mock factory for test data generation
  static MedicalConsumableDTO mockFactory(int id) {
    final consumables = [
      'Flaster',
      'Gazlı Bez',
      'Eldiven (S)',
      'Eldiven (M)',
      'Eldiven (L)',
      'Enjektör 5ml',
      'Enjektör 10ml',
      'İğne',
      'Serum Seti',
      'Sargı Bezi'
    ];
    final firmNames = ['Abdi İbrahim', 'Eczacıbaşı', 'Sanofi', 'Bayer', 'Pfizer', 'Novartis', 'Roche', 'GSK'];

    return MedicalConsumableDTO(
      id: id + 100,
      name: consumables[(id - 1) % consumables.length],
      barcode: (2000000000 + id).toString(),
      institutionCode: 1000 + id,
      sutCode: 2000 + id,
      ubbCode: 3000 + id,
      materialType: null, // Keep it simple
      firmId: ((id - 1) % firmNames.length) + 1,
      firm: firmNames[(id - 1) % firmNames.length],
      countTypeId: 1,
      dailyMaxUsage: 10,
      purchaseFormId: 1,
      returnFormId: 1,
      collectNote: 'Tıbbi atık kutusuna atınız',
      returnNote: 'Açılmış olanlar iade edilemez',
      destructionNote: 'Tıbbi atık prosedürü uygulayınız',
      isActive: true,
    );
  }
}
