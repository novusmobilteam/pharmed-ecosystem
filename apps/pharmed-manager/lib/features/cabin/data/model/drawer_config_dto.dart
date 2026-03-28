import '../../domain/entity/drawer_config.dart';
import 'drawer_type_dto.dart';

/// [ESKİ İSİM: DrawerDetailDTO]
///
/// ÇEKMEECE KONFİGÜRASYONU
/// ----------------------------------------
/// Fiziksel çekmecenin teknik ayarlarını ve cihaz eşleştirme
/// bilgilerini içerir. Bu model, cihaz taraması ile doğrudan ilişkilidir.
///
/// BU MODEL NE İŞE YARAR?
/// 1. Cihazdan gelen "v05" gibi komutları sistemdeki çekmece tipleriyle eşleştirir.
/// 2. Çekmece motorunun step sayısı, çarpanı gibi teknik parametreleri saklar.
/// 3. Hangi fiziksel çekmece numarasının (no) hangi çekmece tipine (drawerId) ait
///    olduğunu belirler.
///
/// ANAHTAR ALANLAR:
/// - no: Cihazdan gelen tip numarası (v05 -> no=5). EŞLEŞTİRME BU ALANLA YAPILIR!
/// - drawerId: Bu konfigürasyonun hangi DrawerTypeDTO'ya ait olduğu
/// - numberOfSteps: Motorun toplam step sayısı
/// - stepMultiplier: Motor hareket çarpanı
///
/// TABLO VERİLERİNE GÖRE ÖRNEKLER:
/// - id: 1, draw_id: 1, no: 2, number_of_steps: 12 → DrawerType 1, cihaz tipi 2, 12 bölmeli
/// - id: 40, draw_id: 40, no: 250, number_of_steps: 14 → Serum kabini (no=250), 14 bölmeli
class DrawerConfigDTO {
  final int? id;
  final int? drawerId; // DrawerTypeDTO.id ile eşleşir
  final int? numberOfSteps; // Çekmece bölüm sayısı
  final int? no; // CİHAZ TİP NUMARASI - EŞLEŞTİRME BU ALANLA!
  final int? stepMultiplier; // Motor step çarpanı
  final DrawerTypeDTO? drawerType; // İlişkili çekmece tipi (nested)
  final bool? isDeleted;
  final DateTime? createdDate;

  DrawerConfigDTO({
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
      drawerId: json['drawrId'] as int?,
      numberOfSteps: json['numberOfSteps'] as int?,
      no: json['no'] as int?,
      stepMultiplier: json['stepMultiplier'] as int?,
      drawerType: json['drawr'] != null ? DrawerTypeDTO.fromJson(json['drawr']) : null,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      isDeleted: json['isDeleted'] as bool?,
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

  DrawerConfigDTO copyWith({
    int? id,
    int? drawerId,
    int? numberOfSteps,
    int? no,
    int? stepMultiplier,
    DrawerTypeDTO? drawerType,
  }) {
    return DrawerConfigDTO(
      id: id ?? this.id,
      drawerId: drawerId ?? this.drawerId,
      numberOfSteps: numberOfSteps ?? this.numberOfSteps,
      no: no ?? this.no,
      stepMultiplier: stepMultiplier ?? this.stepMultiplier,
      drawerType: drawerType ?? this.drawerType,
    );
  }

  /// [ÖNEMLİ]: Cihaz komutunu parse ederek hangi no'ya ait olduğunu bulur
  /// Örnek: "v05" → 5, "v12" → 12
  static int? parseDeviceCommand(String rawCommand) {
    final regex = RegExp(r'v(\d+)');
    final match = regex.firstMatch(rawCommand);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  DrawerConfig toEntity() {
    return DrawerConfig(
      id: id,
      drawerTypeId: drawerId ?? 0,
      numberOfSteps: numberOfSteps ?? 0,
      deviceTypeNo: no ?? 0,
      stepMultiplier: stepMultiplier ?? 1,
      drawerType: drawerType?.toEntity(),
      isDeleted: isDeleted ?? false,
      createdDate: createdDate,
    );
  }

  /// Mock factory for test data generation
  static DrawerConfigDTO mockFactory(int id, {int? drawerId, bool withNested = true}) {
    final effectiveDrawerId = drawerId ?? id;
    return DrawerConfigDTO(
      id: id,
      drawerId: effectiveDrawerId,
      numberOfSteps: 6,
      no: id,
      stepMultiplier: 1,
      drawerType: withNested ? DrawerTypeDTO.mockFactory(effectiveDrawerId) : null,
      isDeleted: false,
      createdDate: DateTime.now().subtract(Duration(days: 20)),
    );
  }
}
