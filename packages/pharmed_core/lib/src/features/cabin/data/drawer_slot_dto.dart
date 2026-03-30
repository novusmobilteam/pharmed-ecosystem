// pharmed_data/src/cabin/dto/drawer_slot_dto.dart

import 'drawer_config_dto.dart';

/// ÇEKMECE YUVASI DTO
/// ------------------
/// Kabindeki her bir çekmece pozisyonunu temsil eder.
///
/// API JSON KEY'LERİ (typo'lar API'den geliyor):
/// - drawrDetailId → drawerConfigId
/// - drawrDetail → drawerConfig (nested)
/// - drawrOrderNumber → drawerOrderNumber
class DrawerSlotDTO {
  final int? id;
  final int? drawerConfigId;
  final int? cabinId;
  final int? orderNumber;
  final String? address;
  final int? compartmentNo;
  final int? drawerOrderNumber;
  final DrawerConfigDTO? drawerConfig;
  // final CabinDTO? cabin;
  final bool? isDeleted;
  final DateTime? createdDate;

  const DrawerSlotDTO({
    this.id,
    this.drawerConfigId,
    this.cabinId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.drawerOrderNumber,
    this.drawerConfig,
    // this.cabin,
    this.isDeleted,
    this.createdDate,
  });

  factory DrawerSlotDTO.fromJson(Map<String, dynamic> json) {
    return DrawerSlotDTO(
      id: json['id'] as int?,
      drawerConfigId: json['drawrDetailId'] as int?,
      cabinId: json['cabinId'] as int?,
      orderNumber: json['orderNumber'] as int?,
      address: json['address'] as String?,
      compartmentNo: json['compartmentNo'] as int?,
      drawerOrderNumber: json['drawrOrderNumber'] as int?,
      drawerConfig: json['drawrDetail'] != null
          ? DrawerConfigDTO.fromJson(json['drawrDetail'] as Map<String, dynamic>)
          : null,
      // cabin: json['cabin'] != null ? CabinDTO.fromJson(json['cabin'] as Map<String, dynamic>) : null,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'drawrDetailId': drawerConfigId, 'cabinId': cabinId, 'orderNumber': orderNumber, 'address': address};
  }
}
