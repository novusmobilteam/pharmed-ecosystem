import '../../data/model/drawer_config_dto.dart';
import 'drawer_type.dart';

/// [ESKİ İSİM: DrawerDetail]
///
/// ÇEKMEECE KONFİGÜRASYONU ENTITY'Sİ
/// ----------------------------------
/// Domain katmanında çekmece motor konfigürasyonunu temsil eden entity.
/// Bu entity, cihaz eşleştirme ve motor kontrol business logic'inde kullanılır.
///
/// KULLANIM YERLERİ:
/// 1. Cihaz tarama sonuçlarını eşleştirme
/// 2. Motor step hesaplamaları
/// 3. Çekmece tipi ve konfigürasyonu arasındaki ilişki yönetimi
///
/// ÖNEMLİ NOT: [deviceTypeNo] alanı cihazdan gelen "v05" formatındaki
/// komutlarla eşleşir. Bu eşleşme olmadan tarama işlemi tamamlanamaz.
class DrawerConfig {
  final int? id;
  final int drawerTypeId; // DrawerType.id ile eşleşir
  final int numberOfSteps; // Motor toplam step sayısı
  final int? deviceTypeNo; // CİHAZ TİP NUMARASI - eşleştirme anahtarı!
  final int stepMultiplier; // Motor step çarpanı
  final DrawerType? drawerType; // İlişkili çekmece tipi
  final bool isDeleted;
  final DateTime? createdDate;

  /// Serum kabini mi? (deviceTypeNo = 250 ise serum)
  bool get isSerum => deviceTypeNo == 250;

  /// Geçerli bir konfigürasyon mu?
  bool get isValid => (deviceTypeNo ?? 0) > 0 && numberOfSteps > 0;

  /// Motorun toplam step kapasitesi
  int get totalMotorSteps => numberOfSteps * stepMultiplier;

  /// Belirli bir step pozisyonu için göz numarası hesaplama
  int calculateSlotNumber(int stepPosition) {
    if (stepPosition < 0 || stepPosition >= totalMotorSteps) {
      throw ArgumentError('Step position out of range');
    }
    return (stepPosition ~/ stepMultiplier) + 1;
  }

  DrawerConfig({
    this.id,
    required this.drawerTypeId,
    required this.numberOfSteps,
    this.deviceTypeNo,
    this.stepMultiplier = 1,
    this.drawerType,
    this.isDeleted = false,
    this.createdDate,
  });

  DrawerConfig copyWith({
    int? id,
    int? drawerTypeId,
    int? numberOfSteps,
    int? deviceTypeNo,
    int? stepMultiplier,
    DrawerType? drawerType,
    bool? isDeleted,
    DateTime? createdDate,
  }) {
    return DrawerConfig(
      id: id ?? this.id,
      drawerTypeId: drawerTypeId ?? this.drawerTypeId,
      numberOfSteps: numberOfSteps ?? this.numberOfSteps,
      deviceTypeNo: deviceTypeNo ?? this.deviceTypeNo,
      stepMultiplier: stepMultiplier ?? this.stepMultiplier,
      drawerType: drawerType ?? this.drawerType,
      isDeleted: isDeleted ?? this.isDeleted,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  DrawerConfigDTO toDTO() {
    return DrawerConfigDTO(
      id: id,
      drawerId: drawerTypeId,
      numberOfSteps: numberOfSteps,
      no: deviceTypeNo,
      stepMultiplier: stepMultiplier,
      drawerType: drawerType?.toDTO(),
      isDeleted: isDeleted,
      createdDate: createdDate,
    );
  }

  /// Cihaz komutunu parse ederek bu konfigürasyona ait olup olmadığını kontrol etme
  /// Örnek: "v05" -> deviceTypeNo=5 olan config ile eşleşir
  bool matchesDeviceCommand(String rawCommand) {
    final parsedNo = DrawerConfigDTO.parseDeviceCommand(rawCommand);
    return parsedNo != null && parsedNo == deviceTypeNo;
  }
}
