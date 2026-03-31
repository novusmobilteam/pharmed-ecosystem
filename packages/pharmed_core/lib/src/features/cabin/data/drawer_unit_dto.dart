// pharmed_data/src/cabin/dto/drawer_unit_dto.dart

import 'drawer_slot_dto.dart';

/// ÇEKMECE BİRİMİ DTO
/// -------------------
/// Bir yuva içindeki bağımsız çekmece ünitesini temsil eder.
///
/// API JSON KEY'LERİ (eski isimler API'den geliyor):
/// - cabinDesignId → drawerSlotId
/// - cabinDesign → drawerSlot (nested)
class DrawerUnitDTO {
  final int? id;
  final int? drawerSlotId;
  final int? compartmentNo;
  final int? orderNo;
  final DrawerSlotDTO? drawerSlot;
  final bool? isDeleted;
  final DateTime? createdDate;

  const DrawerUnitDTO({
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
      drawerSlot: json['cabinDesign'] != null
          ? DrawerSlotDTO.fromJson(json['cabinDesign'] as Map<String, dynamic>)
          : null,
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
