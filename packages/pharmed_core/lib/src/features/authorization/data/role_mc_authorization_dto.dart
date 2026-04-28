class RoleMedicalConsumableAuthorizationDto {
  final int? id;
  final int? roleId;
  final bool isMedicalConsumablesPull;
  final bool isMedicalConsumablesFill;
  final bool isMedicalConsumablesReturn;
  final bool isMedicalConsumablesDestruction;

  RoleMedicalConsumableAuthorizationDto({
    this.id,
    this.roleId,
    this.isMedicalConsumablesPull = false,
    this.isMedicalConsumablesFill = false,
    this.isMedicalConsumablesReturn = false,
    this.isMedicalConsumablesDestruction = false,
  });

  RoleMedicalConsumableAuthorizationDto copyWith({
    int? id,
    int? roleId,
    bool? isMedicalConsumablesPull,
    bool? isMedicalConsumablesFill,
    bool? isMedicalConsumablesReturn,
    bool? isMedicalConsumablesDestruction,
  }) {
    return RoleMedicalConsumableAuthorizationDto(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      isMedicalConsumablesPull: isMedicalConsumablesPull ?? this.isMedicalConsumablesPull,
      isMedicalConsumablesFill: isMedicalConsumablesFill ?? this.isMedicalConsumablesFill,
      isMedicalConsumablesReturn: isMedicalConsumablesReturn ?? this.isMedicalConsumablesReturn,
      isMedicalConsumablesDestruction: isMedicalConsumablesDestruction ?? this.isMedicalConsumablesDestruction,
    );
  }

  factory RoleMedicalConsumableAuthorizationDto.fromJson(Map<String, dynamic> json) {
    return RoleMedicalConsumableAuthorizationDto(
      id: json['id'] as int?,
      roleId: json['roleId'] as int?,
      isMedicalConsumablesPull: json['isMedicalConsumablesPull'] as bool? ?? false,
      isMedicalConsumablesFill: json['isMedicalConsumablesFill'] as bool? ?? false,
      isMedicalConsumablesReturn: json['isMedicalConsumablesReturn'] as bool? ?? false,
      isMedicalConsumablesDestruction: json['isMedicalConsumablesDestruction'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'isMedicalConsumablesPull': isMedicalConsumablesPull,
      'isMedicalConsumablesFill': isMedicalConsumablesFill,
      'isMedicalConsumablesReturn': isMedicalConsumablesReturn,
      'isMedicalConsumablesDestruction': isMedicalConsumablesDestruction,
    };
  }
}
