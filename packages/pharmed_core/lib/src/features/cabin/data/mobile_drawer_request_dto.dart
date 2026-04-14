// packages/pharmed_data/lib/src/cabin/dto/mobile_drawer_request_dto.dart
//
// [SWREQ-SETUP-DATA-007] [IEC 62304 §5.5]
// Mobil kabin çekmece kayıt isteği DTO'su.
// WizardDrawerConfig → MobileDrawerRequestDTO dönüşümü
// MobileDrawerRequestMapper üzerinden yapılır.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

class MobileDrawerRequestDTO extends Equatable {
  const MobileDrawerRequestDTO({
    required this.cabinId,
    required this.orderNumber,
    required this.address,
    required this.details,
  });

  final int cabinId;
  final int orderNumber;
  final String address;
  final List<MobileDrawerRowDTO> details;

  factory MobileDrawerRequestDTO.fromJson(Map<String, dynamic> json) {
    return MobileDrawerRequestDTO(
      cabinId: json['cabinId'] as int,
      orderNumber: json['orderNumber'] as int,
      address: json['address'] as String,
      details: (json['details'] as List)
          .map((e) => MobileDrawerRowDTO.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cabinId': cabinId,
    'orderNumber': orderNumber,
    'address': address,
    'details': details.map((d) => d.toJson()).toList(),
  };

  @override
  List<Object?> get props => [cabinId, orderNumber, address, details];
}

class MobileDrawerRowDTO extends Equatable {
  const MobileDrawerRowDTO({required this.orderNumber, required this.columnsCount});

  factory MobileDrawerRowDTO.fromJson(Map<String, dynamic> json) {
    return MobileDrawerRowDTO(orderNumber: json['orderNumber'] as int, columnsCount: json['columnsCount'] as int);
  }

  Map<String, dynamic> toJson() => {'orderNumber': orderNumber, 'columnsCount': columnsCount};

  final int orderNumber;
  final int columnsCount;

  @override
  List<Object?> get props => [orderNumber, columnsCount];
}
