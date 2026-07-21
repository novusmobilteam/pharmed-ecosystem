import 'package:pharmed_core/pharmed_core.dart';

class Refund {
  final int? id;
  final int? type;
  final double? quantity;
  final int? returnFormId;
  final int? prescriptionDetailId;
  final PrescriptionItem? prescriptionDetail;
  final Medicine? medicine;
  final Station? station;

  final int? createdUserId;
  final User? createdUser;
  final DateTime? createdDate;

  final int? receiveUserId;
  final User? receiveUser;
  final DateTime? receiveDate;

  final int? approvedUserId;
  final User? approvedUser;
  final DateTime? approvedDate;

  final bool? isCancel;
  final User? cancelUser;
  final String? description;
  final bool? isDeleted;

  Patient? get patient => prescriptionDetail?.prescription?.hospitalization?.patient;

  Refund({
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
}
