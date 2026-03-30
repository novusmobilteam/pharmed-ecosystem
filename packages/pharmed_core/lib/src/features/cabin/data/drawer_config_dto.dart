// pharmed_data/src/cabin/dto/drawer_config_dto.dart

import 'drawer_type_dto.dart';

/// ÇEKMECE KONFİGÜRASYONU DTO
/// ---------------------------
/// Fiziksel çekmecenin teknik ayarlarını ve cihaz eşleştirme bilgilerini içerir.
///
/// ANAHTAR ALANLAR:
/// - no: Cihazdan gelen tip numarası (v05 → no=5). EŞLEŞTİRME BU ALANLA YAPILIR!
/// - drawerId: Bu konfigürasyonun hangi DrawerTypeDTO'ya ait olduğu
/// - numberOfSteps: Motorun toplam step sayısı
/// - stepMultiplier: Motor hareket çarpanı
///
/// API JSON KEY'LERİ:
/// - drawrId (typo — API'deki alan adı)
/// - drawr (nested DrawerType objesi)
class DrawerConfigDTO {
  final int? id;
  final int? drawerId; // DrawerTypeDTO.id ile eşleşir
  final int? numberOfSteps;
  final int? no; // CİHAZ TİP NUMARASI
  final int? stepMultiplier;
  final DrawerTypeDTO? drawerType; // Nested
  final bool? isDeleted;
  final DateTime? createdDate;

  const DrawerConfigDTO({
    this.id,
    this.drawerId,
    this.numberOfSteps,
    this.no,
    this.stepMultiplier,
    this.drawerType,
    this.isDeleted,
    this.createdDate,
  });

  factory DrawerConfigDTO.fromJson(Map<String, dynamic> json) {
    return DrawerConfigDTO(
      id: json['id'] as int?,
      drawerId: json['drawrId'] as int?, // API typo
      numberOfSteps: json['numberOfSteps'] as int?,
      no: json['no'] as int?,
      stepMultiplier: json['stepMultiplier'] as int?,
      drawerType: json['drawr'] != null ? DrawerTypeDTO.fromJson(json['drawr'] as Map<String, dynamic>) : null,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drawerId': drawerId,
      'numberOfSteps': numberOfSteps,
      'no': no,
      'stepMultiplier': stepMultiplier,
      'drawer': drawerType?.toJson(),
    };
  }

  /// Cihaz komutunu parse ederek hangi no'ya ait olduğunu bulur.
  /// Örnek: "v05" → 5, "v12" → 12
  static int? parseDeviceCommand(String rawCommand) {
    final regex = RegExp(r'v(\d+)');
    final match = regex.firstMatch(rawCommand);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
