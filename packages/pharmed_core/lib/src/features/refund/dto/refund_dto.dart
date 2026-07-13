import 'package:pharmed_core/pharmed_core.dart';

class RefundDTO {
  final int? id;
  final int? type;
  final double? quantity;
  final int? returnFormId;
  final int? prescriptionDetailId;
  final PrescriptionItemDto? prescriptionDetail;
  final MedicineDto? medicine;
  final StationDTO? station;

  final int? createdUserId;
  final UserDto? createdUser;
  final DateTime? createdDate;

  final int? receiveUserId;
  final UserDto? receiveUser;
  final DateTime? receiveDate;

  final int? approvedUserId;
  final UserDto? approvedUser;
  final DateTime? approvedDate;

  final bool? isCancel;
  final UserDto? cancelUser;
  final String? description;
  final bool? isDeleted;

  RefundDTO({
    this.id,
    this.type,
    this.quantity,
    this.returnFormId,
    this.prescriptionDetailId,
    this.prescriptionDetail,
    this.medicine,
    this.station,

    this.createdUserId,
    this.createdUser,
    this.createdDate,

    this.receiveUserId,
    this.receiveUser,
    this.receiveDate,

    this.approvedUserId,
    this.approvedUser,
    this.approvedDate,

    this.isCancel,
    this.cancelUser,
    this.description,
    this.isDeleted,
  });

  factory RefundDTO.fromJson(Map<String, dynamic> json) {
    return RefundDTO(
      id: json['id'] as int?,
      type: json['type'] as int?,
      quantity: json['quantity'] as double?,
      returnFormId: json['returnFormId'] as int?,
      prescriptionDetailId: json['prescriptionDetailId'] as int?,
      prescriptionDetail: json['prescriptionDetail'] != null
          ? PrescriptionItemDto.fromJson(json['prescriptionDetail'])
          : null,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,

      createdUserId: json['userId'] as int?,
      createdUser: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,

      receiveUserId: json['receiveUserId'] as int?,
      receiveUser: json['receiveUser'] != null ? UserDto.fromJson(json['receiveUser']) : null,
      receiveDate: json['receiveDate'] != null ? DateTime.parse(json['receiveDate'] as String) : null,

      approvedUserId: json['approvedUserId'] as int?,
      approvedUser: json['approvedUser'] != null ? UserDto.fromJson(json['approvedUser']) : null,
      approvedDate: json['approvedDate'] != null ? DateTime.parse(json['approvedDate'] as String) : null,

      isCancel: json['isCancel'] as bool?,
      cancelUser: json['cancelUser'] != null ? UserDto.fromJson(json['cancelUser']) : null,
      description: json['description'] as String?,
      isDeleted: json['isDeleted'] as bool?,
    );
  }
}
