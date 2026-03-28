import 'drawer_slot_dto.dart';

/// [ESKİ İSİM: CabinDrawerDTO]
///
/// ÇEKMECE BİRİMİ (BAĞIMSIZ HAREKETLİ PARÇA)
/// ----------------------------------------
/// Bir yuvaya (DrawerSlot) fiziksel olarak monte edilmiş, bağımsız olarak
/// dışarı çekilebilen her bir çekmece ünitesini temsil eder.
///
/// BU MODEL NE İŞE YARAR?
/// 1. Birim doz yapılarda yuvadaki dikey bölünmüş (1-5 arası) bağımsız parçaları tanımlar.
/// 2. Kübik (grid) yapılarda yuvadaki tek ve ana çekmeceyi temsil eder.
/// 3. Stok yönetimi ve kapak açma komutları bu "Birim" üzerinden tetiklenir.
///
/// ANAHTAR ALANLAR:
/// - compartmentNo: Ünitenin yuvadaki dikey sıra numarası (Soldan sağa 1, 2, 3...).
/// - drawerSlotId (Eski: cabinDesignId): Bu ünitenin ait olduğu fiziksel yuva.
/// - orderNo: Ünitenin genel sıralamadaki yeri.
class DrawerUnitDTO {
  final int? id;
  final int? drawerSlotId; // Eski: cabinDesignId
  final int? compartmentNo; // Dikey sıradaki yeri
  final int? orderNo;
  final bool? isDeleted;
  final DateTime? createdDate;
  final DrawerSlotDTO? drawerSlot; // İlişkili yuva bilgisi

  DrawerUnitDTO({
    this.id,
    this.drawerSlotId,
    this.compartmentNo,
    this.orderNo,
    this.drawerSlot,
    this.isDeleted,
    this.createdDate,
  });

  factory DrawerUnitDTO.fromJson(Map<String, dynamic> json) {
    return DrawerUnitDTO(
      id: json['id'] as int?,
      drawerSlotId: json['cabinDesignId'] as int?,
      compartmentNo: json['compartmentNo'] as int?,
      orderNo: json['orderNo'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      drawerSlot: json['cabinDesign'] != null ? DrawerSlotDTO.fromJson(json['cabinDesign']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cabinDesignId': drawerSlotId,
      'compartmentNo': compartmentNo,
      'orderNo': orderNo,
      'cabinDesign': drawerSlot?.toJson(),
      'isDeleted': isDeleted,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}
