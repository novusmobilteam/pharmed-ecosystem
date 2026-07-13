import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

// TODO : Localization
class Refund implements TableData {
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

  @override
  List<String?> get content => [
    patient?.id?.toCustomString(),
    patient?.fullName,
    createdUser?.fullName,
    medicine?.name,
    quantity?.formatFractional,
    createdDate?.formattedDateTime,
    description,
  ];

  @override
  List<String?> get titles => ['Hasta Kodu', 'Hasta', 'Kullanıcı', 'Malzeme', 'Miktar', 'Tarih', 'Açıklama'];

  @override
  List get rawContent => [
    patient?.id?.toCustomString(),
    patient?.fullName,
    createdUser?.fullName,
    medicine?.name,
    quantity?.formatFractional,
    createdDate?.formattedDate,
    description,
  ];

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
