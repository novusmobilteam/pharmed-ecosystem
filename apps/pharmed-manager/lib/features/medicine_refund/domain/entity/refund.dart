import '../../../../core/core.dart';
import '../../../medicine/domain/entity/medicine.dart';
import '../../../patient/domain/entity/patient.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../../station/domain/entity/station.dart';

class Refund implements TableData {
  final int? id;
  final int? type;
  final double? quantity;
  final int? returnFormId;
  final int? prescriptionDetailId;
  final PrescriptionItem? prescriptionDetail;
  final Medicine? medicine;
  final Station? station;
  final int? userId;
  final String? user;
  final DateTime? receiveDate;
  final User? receiveUser;
  final bool? isCancel;
  final User? cancelUser;
  final String? description;
  final bool? isDeleted;

  Patient? get patient => prescriptionDetail?.prescription?.hospitalization?.patient;

  @override
  List<String?> get content => [
    patient?.id?.toCustomString(),
    patient?.fullName,
    user,
    medicine?.name,
    quantity?.formatFractional,
    receiveDate?.formattedDate,
    description,
  ];

  @override
  List<String?> get titles => ['Hasta Kodu', 'Hasta', 'Kullanıcı', 'Malzeme', 'Miktar', 'Tarih', 'Açıklama'];

  @override
  List get rawContent => [
    patient?.id?.toCustomString(),
    patient?.fullName,
    user,
    medicine?.name,
    quantity?.formatFractional,
    receiveDate?.formattedDate,
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
    this.userId,
    this.user,
    this.receiveDate,
    this.receiveUser,
    this.isCancel,
    this.cancelUser,
    this.description,
    this.isDeleted,
  });
}
