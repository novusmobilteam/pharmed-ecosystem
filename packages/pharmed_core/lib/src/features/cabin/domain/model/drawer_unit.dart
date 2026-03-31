// pharmed_core/src/cabin/entity/drawer_unit.dart

import 'package:pharmed_core/pharmed_core.dart';

/// ÇEKMECE BİRİMİ ENTITY'Sİ
/// -------------------------
/// Bir yuva (DrawerSlot) içindeki bağımsız hareket eden tek bir çekmece
/// ünitesini temsil eder.
///
/// - Birim doz yapılarda: yuvadaki dikey bölünmüş parçalar (1-5 arası)
/// - Kübik yapılarda: yuvadaki tek ana çekmece
///
/// İLİŞKİLER:
///   DrawerUnit.drawerSlotId → DrawerSlot.id
///
/// KULLANIM:
///   - Stok yönetimi (ilaç atama, dolum, sayım)
///   - Kapak açma komutları bu birim üzerinden tetiklenir
///   - Taramada: DrawerType.compartmentCount kadar otomatik üretilir
class DrawerUnit {
  const DrawerUnit({
    this.id,
    this.drawerSlotId,
    this.compartmentNo,
    this.orderNo,
    this.drawerSlot,
    this.workingStatus = CabinWorkingStatus.working,
  });

  final int? id;
  final int? drawerSlotId; // Hangi slot'a ait
  final int? compartmentNo; // Göz numarası (1, 2, 3, ...)
  final int? orderNo; // Genel sıralama
  final DrawerSlot? drawerSlot; // İlişkili yuva (nested, opsiyonel)
  final CabinWorkingStatus workingStatus;

  DrawerUnit copyWith({
    int? id,
    int? drawerSlotId,
    int? compartmentNo,
    int? orderNo,
    DrawerSlot? drawerSlot,
    CabinWorkingStatus? workingStatus,
  }) {
    return DrawerUnit(
      id: id ?? this.id,
      drawerSlotId: drawerSlotId ?? this.drawerSlotId,
      compartmentNo: compartmentNo ?? this.compartmentNo,
      orderNo: orderNo ?? this.orderNo,
      drawerSlot: drawerSlot ?? this.drawerSlot,
      workingStatus: workingStatus ?? this.workingStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerUnit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DrawerUnit(id: $id, slotId: $drawerSlotId, compartment: $compartmentNo)';
}
