// pharmed_core/src/cabin/entity/drawer_config.dart

import 'package:pharmed_core/pharmed_core.dart';

/// ÇEKMECE KONFİGÜRASYONU ENTITY'Sİ
/// ----------------------------------
/// Cihaz eşleştirme ve motor kontrol bilgilerini temsil eder.
/// Tarama sırasında cihazdan gelen tip numarası (deviceTypeNo) ile
/// DB'deki konfigürasyon eşleştirilir.
///
/// İLİŞKİLER:
///   DrawerConfig.drawerTypeId → DrawerType.id
///   DrawerSlot.drawerConfigId → DrawerConfig.id
///
/// EŞLEŞTİRME:
///   Cihaz kartı: databaseTypeId == DrawerConfig.deviceTypeNo
///   Örnek: "v05" komutu → deviceTypeNo=5 olan config ile eşleşir
class DrawerConfig {
  const DrawerConfig({
    this.id,
    required this.drawerTypeId,
    required this.numberOfSteps,
    this.deviceTypeNo,
    this.stepMultiplier = 1,
    this.drawerType,
  });

  final int? id;
  final int drawerTypeId; // DrawerType.id ile eşleşir
  final int numberOfSteps; // Motor toplam step sayısı
  final int? deviceTypeNo; // CİHAZ TİP NUMARASI — eşleştirme anahtarı!
  final int stepMultiplier; // Motor step çarpanı
  final DrawerType? drawerType; // İlişkili çekmece tipi (nested)

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

  /// Cihaz komutundaki tip numarasıyla eşleşiyor mu?
  /// Örnek: "v05" → deviceTypeNo=5 olan config ile eşleşir
  bool matchesDeviceTypeNo(int typeNo) => deviceTypeNo == typeNo;

  DrawerConfig copyWith({
    int? id,
    int? drawerTypeId,
    int? numberOfSteps,
    int? deviceTypeNo,
    int? stepMultiplier,
    DrawerType? drawerType,
  }) {
    return DrawerConfig(
      id: id ?? this.id,
      drawerTypeId: drawerTypeId ?? this.drawerTypeId,
      numberOfSteps: numberOfSteps ?? this.numberOfSteps,
      deviceTypeNo: deviceTypeNo ?? this.deviceTypeNo,
      stepMultiplier: stepMultiplier ?? this.stepMultiplier,
      drawerType: drawerType ?? this.drawerType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerConfig && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DrawerConfig(id: $id, drawerTypeId: $drawerTypeId, deviceTypeNo: $deviceTypeNo, steps: $numberOfSteps)';
}
