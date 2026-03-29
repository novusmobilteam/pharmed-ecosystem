import 'package:pharmed_manager/core/core.dart';

import '../../../medicine/data/model/medicine_dto.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';
import '../../../station/data/model/station_dto.dart';
import '../../domain/entity/refund.dart';

class RefundDTO {
  final int? id;
  final int? type;
  final double? quantity;
  final int? returnFormId;
  final int? prescriptionDetailId;
  final PrescriptionItemDTO? prescriptionDetail;
  final MedicineDTO? medicine;
  final StationDTO? station;
  final int? userId;
  final String? user;
  final DateTime? receiveDate;
  final UserDTO? receiveUser;
  final bool? isCancel;
  final UserDTO? cancelUser;
  final String? description;
  final bool? isDeleted;
  final DateTime? createdDate;

  RefundDTO({
    this.id,
    this.type,
    this.quantity,
    this.returnFormId,
    this.prescriptionDetailId,
    this.prescriptionDetail,
    this.medicine,
    this.station,
    this.userId,
    this.user,
    this.receiveDate,
    this.receiveUser,
    this.isCancel,
    this.cancelUser,
    this.description,
    this.isDeleted,
    this.createdDate,
  });

  // CopyWith metodu
  RefundDTO copyWith({
    int? id,
    int? type,
    double? quantity,
    int? returnFormId,
    int? prescriptionDetailId,
    PrescriptionItemDTO? prescriptionDetail,
    MedicineDTO? medicine,
    StationDTO? station,
    int? userId,
    String? user,
    DateTime? receiveDate,
    UserDTO? receiveUser,
    bool? isCancel,
    UserDTO? cancelUser,
    String? description,
    bool? isDeleted,
  }) {
    return RefundDTO(
      id: id ?? this.id,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      returnFormId: returnFormId ?? this.returnFormId,
      prescriptionDetailId: prescriptionDetailId ?? this.prescriptionDetailId,
      prescriptionDetail: prescriptionDetail ?? this.prescriptionDetail,
      medicine: medicine ?? this.medicine,
      station: station ?? this.station,
    );
  }

  factory RefundDTO.fromJson(Map<String, dynamic> json) {
    return RefundDTO(
      id: json['id'] as int?,
      type: json['type'] as int?,
      quantity: json['quantity'] as double?,
      returnFormId: json['returnFormId'] as int?,
      prescriptionDetailId: json['prescriptionDetailId'] as int?,
      prescriptionDetail: json['prescriptionDetail'] != null
          ? PrescriptionItemDTO.fromJson(json['prescriptionDetail'])
          : null,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      userId: json['userId'] as int?,
      user: json['user'] as String?,
      receiveDate: json['receiveDate'] != null ? DateTime.parse(json['receiveDate'] as String) : null,
      receiveUser: json['receiveUser'] != null ? UserDTO.fromJson(json['receiveUser']) : null,
      isCancel: json['isCancel'] as bool?,
      cancelUser: json['cancelUser'] != null ? UserDTO.fromJson(json['cancelUser']) : null,
      description: json['description'] as String?,
      isDeleted: json['isDeleted'] as bool?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'returnFormId': returnFormId,
      'prescriptionDetailId': prescriptionDetailId,
      'prescriptionDetail': prescriptionDetail?.toJson(),
      'material': medicine?.toJson(),
      'station': station?.toJson(),
      'userId': userId,
      'user': user,
      'receiveDate': receiveDate?.toIso8601String(),
      'receiveUser': receiveUser?.toJson(),
      'isCancel': isCancel,
      'cancelUser': cancelUser?.toJson(),
      'description': description,
    };
  }

  Refund toEntity() {
    return Refund(
      id: id,
      type: returnFormId,
      quantity: quantity,
      prescriptionDetailId: prescriptionDetailId,
      prescriptionDetail: prescriptionDetail?.toEntity(),
      receiveDate: createdDate,
      receiveUser: const UserMapper().toEntityOrNull(receiveUser),
      isCancel: isCancel,
      cancelUser: const UserMapper().toEntityOrNull(cancelUser),
      medicine: medicine?.toEntity(),
      description: description,
      station: station?.toEntity(),
      user: user,
    );
  }
}
