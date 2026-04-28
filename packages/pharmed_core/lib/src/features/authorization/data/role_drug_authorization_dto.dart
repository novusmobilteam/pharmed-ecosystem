class RoleDrugAuthorizationDto {
  final int? id;
  final int? roleId;
  final int? drugId;
  final bool isDrugPull;
  final bool isFill;
  final bool isReturn;
  final bool isDestruction;

  RoleDrugAuthorizationDto({
    this.id,
    this.roleId,
    this.isDrugPull = false,
    this.isFill = false,
    this.isReturn = false,
    this.isDestruction = false,
    this.drugId,
  });

  RoleDrugAuthorizationDto copyWith({
    int? id,
    int? roleId,
    bool? isDrugPull,
    bool? isFill,
    bool? isReturn,
    bool? isDestruction,
    int? drugId,
  }) {
    return RoleDrugAuthorizationDto(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      isDrugPull: isDrugPull ?? this.isDrugPull,
      isFill: isFill ?? this.isFill,
      isReturn: isReturn ?? this.isReturn,
      isDestruction: isDestruction ?? this.isDestruction,
      drugId: drugId ?? this.drugId,
    );
  }

  factory RoleDrugAuthorizationDto.fromJson(Map<String, dynamic> json) {
    return RoleDrugAuthorizationDto(
      id: json['id'] as int?,
      roleId: json['roleId'] as int?,
      isDrugPull: json['isDrugPull'] as bool? ?? false,
      isFill: json['isFill'] as bool? ?? false,
      isReturn: json['isReturn'] as bool? ?? false,
      isDestruction: json['isDestruction'] as bool? ?? false,
      drugId: json['materialId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'isDrugPull': isDrugPull,
      'isFill': isFill,
      'isReturn': isReturn,
      'isDestruction': isDestruction,
      'materialId': drugId,
    };
  }
}
