// lib/features/setup_wizard/data/dto/cabin_config_dto.dart
//
// [SWREQ-SETUP-DATA-001]
// Sunucuya gönderilecek / sunucudan alınacak ham veri modeli.
// Sınıf: Class B

class CabinConfigDto {
  const CabinConfigDto({
    this.id,
    this.cabinetType,
    this.cabinName,
    this.location,
    this.ipAddress,
    this.port,
    this.timeoutSeconds,

    this.serviceName,
    this.departmentId,
    this.rooms,
    this.sections,
    this.drawerType,
    this.depth,
    this.splitConfig,
    this.mobileDrawers,
  });

  final int? id;
  final String? cabinetType; // "standard" | "mobile"
  final String? cabinName;
  final String? location;
  final String? ipAddress;
  final String? port;
  final int? timeoutSeconds;

  final String? serviceName;
  final String? departmentId;
  final List<String>? rooms;
  final int? sections;
  final String? drawerType; // "cubic4x4" | "cubic4x5" | "unitDose"
  final int? depth;
  final String? splitConfig;
  final List<Map<String, dynamic>>? mobileDrawers;

  factory CabinConfigDto.fromJson(Map<String, dynamic> json) {
    return CabinConfigDto(
      id: json['id'] as int?,
      cabinetType: json['cabinetType'] as String?,
      cabinName: json['cabinName'] as String?,
      location: json['location'] as String?,
      ipAddress: json['ipAddress'] as String?,
      port: json['port'] as String?,
      timeoutSeconds: json['timeoutSeconds'] as int?,

      serviceName: json['serviceName'] as String?,
      departmentId: json['departmentId'] as String?,
      rooms: (json['rooms'] as List?)?.cast<String>(),
      sections: json['sections'] as int?,
      drawerType: json['drawerType'] as String?,
      depth: json['depth'] as int?,
      splitConfig: json['splitConfig'] as String?,
      mobileDrawers: (json['mobileDrawers'] as List?)?.cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (cabinetType != null) 'cabinetType': cabinetType,
      if (cabinName != null) 'cabinName': cabinName,
      if (location != null) 'location': location,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (port != null) 'port': port,
      if (timeoutSeconds != null) 'timeoutSeconds': timeoutSeconds,
      if (serviceName != null) 'serviceName': serviceName,
      if (departmentId != null) 'departmentId': departmentId,
      if (rooms != null) 'rooms': rooms,
      if (sections != null) 'sections': sections,
      if (drawerType != null) 'drawerType': drawerType,
      if (depth != null) 'depth': depth,
      if (splitConfig != null) 'splitConfig': splitConfig,
      if (mobileDrawers != null) 'mobileDrawers': mobileDrawers,
    };
  }
}
