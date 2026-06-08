// pharmed_data/src/cabin/dto/drawer_cell_dto.dart

import 'drawer_unit_dto.dart';

/// ÇEKMECE GÖZÜ DTO
/// -----------------
/// Çekmece ünitesi içindeki en küçük depolama birimini temsil eder.
///
/// API JSON KEY'LERİ (eski isim API'den geliyor):
/// - cabinDrawr → drawerUnit (nested)
class DrawerCellDTO {
  final int? id;
  final int? stepNo;
  final DrawerUnitDTO? drawerUnit;
  final bool? isDeleted;
  final DateTime? createdDate;

  const DrawerCellDTO({this.id, this.stepNo, this.drawerUnit, this.isDeleted, this.createdDate});

  factory DrawerCellDTO.fromJson(Map<String, dynamic> json) {
    return DrawerCellDTO(
      id: json['id'] as int?,
      stepNo: json['stepNo'] as int?,
      drawerUnit: json['cabinDrawr'] != null
          ? DrawerUnitDTO.fromJson(json['cabinDrawr'] as Map<String, dynamic>)
          : null,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepNo': stepNo,
      'cabinDrawr': drawerUnit?.toJson(),
      'isDeleted': isDeleted,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}
