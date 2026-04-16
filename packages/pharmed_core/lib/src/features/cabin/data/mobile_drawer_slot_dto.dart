// pharmed_data/src/cabin/dto/mobile_drawer_slot_dto.dart
//
// getMobileCabinSlots response DTO'su.
// API key'leri orijinal haliyle korunur.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

class MobileDrawerSlotDTO extends Equatable {
  const MobileDrawerSlotDTO({
    required this.id,
    required this.orderNumber,
    required this.address,
    required this.cabinId,
    required this.cabinDrawrs,
  });

  final int id;
  final int orderNumber;
  final String address;
  final int cabinId;
  final List<MobileDrawerUnitDTO> cabinDrawrs;

  factory MobileDrawerSlotDTO.fromJson(Map<String, dynamic> json) {
    return MobileDrawerSlotDTO(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as int,
      address: json['address'] as String,
      cabinId: json['cabinId'] as int,
      cabinDrawrs: (json['cabinDrawrs'] as List? ?? [])
          .map((e) => MobileDrawerUnitDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    'address': address,
    'cabinId': cabinId,
    'cabinDrawrs': cabinDrawrs.map((u) => u.toJson()).toList(),
  };

  @override
  List<Object?> get props => [id, orderNumber, address, cabinId, cabinDrawrs];
}

class MobileDrawerUnitDTO extends Equatable {
  const MobileDrawerUnitDTO({
    required this.id,
    required this.cabinDesignId,
    required this.orderNo,
    required this.details,
    this.compartmentNo,
    this.isDeleted,
    this.createdDate,
  });

  final int id;
  final int cabinDesignId; // → slotId
  final int orderNo;
  final List<MobileDrawerCellDto> details;
  final int? compartmentNo;
  final bool? isDeleted;
  final DateTime? createdDate;

  factory MobileDrawerUnitDTO.fromJson(Map<String, dynamic> json) {
    return MobileDrawerUnitDTO(
      id: json['id'] as int,
      cabinDesignId: json['cabinDesignId'] as int,
      orderNo: json['orderNo'] as int,
      compartmentNo: json['compartmentNo'] as int?,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
      details: (json['details'] as List? ?? [])
          .map((e) => MobileDrawerCellDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cabinDesignId': cabinDesignId,
    'orderNo': orderNo,
    'compartmentNo': compartmentNo,
    'isDeleted': isDeleted,
    'createdDate': createdDate?.toIso8601String(),
    'details': details.map((c) => c.toJson()).toList(),
  };

  @override
  List<Object?> get props => [id, cabinDesignId, orderNo, details];
}

class MobileDrawerCellDto extends Equatable {
  const MobileDrawerCellDto({
    required this.id,
    required this.cabinDrawrId,
    required this.stepNo,
    this.isDeleted,
    this.createdDate,
  });

  final int id;
  final int cabinDrawrId; // → unitId
  final int stepNo;
  final bool? isDeleted;
  final DateTime? createdDate;

  factory MobileDrawerCellDto.fromJson(Map<String, dynamic> json) {
    return MobileDrawerCellDto(
      id: json['id'] as int,
      cabinDrawrId: json['cabinDrawrId'] as int,
      stepNo: json['stepNo'] as int,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cabinDrawrId': cabinDrawrId,
    'stepNo': stepNo,
    'isDeleted': isDeleted,
    'createdDate': createdDate?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, cabinDrawrId, stepNo];
}
