import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class PrescriptionItem implements TableData, Selectable {
  @override
  final int? id;
  final int? prescriptionId;
  final int? physicalServiceId;
  final HospitalService? physicalService;
  final int? inpatientServiceId;
  final HospitalService? inpatientService;
  final int? patientRegistrationId;
  final int? doctorId;
  final User? doctor;
  final int? medicineId;
  final Medicine? medicine;
  final num? dosePiece;
  final RequestType? requestType;
  final String? requestTypeName;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;
  final List<DateTime>? times;
  final DateTime? time;
  final String? description;
  final String? deleteDescription;
  final bool? removed;

  final int? barcode;
  final int? sutCode;
  final int? ubbCode;
  final int? atcCode;
  final bool? isQrCode;
  final String? qrCode;
  final DateTime? prescriptionDate;
  final Prescription? prescription;
  final String? protocolNo;
  final String? patientName;
  final PrescriptionStatus? status;

  final DateTime? approvalDate;
  final int? approvalUserId;
  final User? approvalUser;

  final DateTime? cancelDate;
  final int? cancelUserId;
  final User? cancelUser;

  final DateTime? applicationDate;
  final int? applicationUserId;
  final User? applicationUser;

  final DateTime? returnDate;
  final int? returnUserId;
  final User? returnUser;
  final double? returnQuantity;

  final DateTime? createdDate;
  final User? createdUser;
  final int? createdUserId;

  final DateTime? rejectDate;
  final User? rejectUser;
  final int? rejectUserId;

  final DateTime? wastageDate;
  final User? wastageUser;
  final int? wastageUserId;

  final DateTime? destructionDate;
  final User? destructionUser;
  final int? destructionUserId;

  // Onay Bekliyor -> Created Date - Created User
  // Alım Bekliyor -> Approval Date - Approval User
  // İade Edildi -> Return Date - Return User
  // Fire/İmha -> Cancel Date - Cancel User
  // İptal Edildi -> Cancel Date - Cancle User
  // Uygulandı -> Application Date - Application User

  /// İlaç Aktivitede gösterilen user
  User? get activityUser {
    switch (status ?? PrescriptionStatus.pendingApproval) {
      case PrescriptionStatus.pendingApproval:
        return createdUser;
      case PrescriptionStatus.purchasePending:
        return approvalUser;
      case PrescriptionStatus.applied:
        return applicationUser;
      case PrescriptionStatus.returned:
        return returnUser;
      case PrescriptionStatus.wastaged:
        return wastageUser;
      case PrescriptionStatus.destructed:
        return destructionUser;
      case PrescriptionStatus.cancelled:
        return cancelUser;
      case PrescriptionStatus.rejected:
        return rejectUser;
    }
  }

  DateTime? get activityDate {
    switch (status ?? PrescriptionStatus.pendingApproval) {
      case PrescriptionStatus.pendingApproval:
        return createdDate;
      case PrescriptionStatus.purchasePending:
        return approvalDate;
      case PrescriptionStatus.applied:
        return applicationDate;
      case PrescriptionStatus.returned:
        return returnDate;
      case PrescriptionStatus.wastaged:
        return wastageDate;
      case PrescriptionStatus.destructed:
        return destructionDate;
      case PrescriptionStatus.cancelled:
        return cancelDate;
      case PrescriptionStatus.rejected:
        return cancelDate;
    }
  }

  const PrescriptionItem({
    this.id,
    this.prescriptionId,
    this.physicalServiceId,
    this.physicalService,
    this.inpatientServiceId,
    this.inpatientService,
    this.patientRegistrationId,
    this.doctorId,
    this.doctor,
    this.medicineId,
    this.medicine,
    this.dosePiece,
    this.requestType,
    this.requestTypeName,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.times,
    this.time,
    this.description,
    this.deleteDescription,
    this.removed,
    this.returnQuantity,
    this.barcode,
    this.sutCode,
    this.ubbCode,
    this.atcCode,
    this.isQrCode,
    this.qrCode,
    this.prescriptionDate,
    this.prescription,
    this.protocolNo,
    this.patientName,
    this.status,
    this.approvalDate,
    this.approvalUserId,
    this.approvalUser,
    this.cancelDate,
    this.cancelUserId,
    this.cancelUser,
    this.applicationDate,
    this.applicationUserId,
    this.applicationUser,
    this.returnDate,
    this.returnUserId,
    this.returnUser,
    this.createdDate,
    this.createdUserId,
    this.createdUser,
    this.rejectDate,
    this.rejectUser,
    this.rejectUserId,
    this.wastageDate,
    this.wastageUser,
    this.wastageUserId,
    this.destructionDate,
    this.destructionUser,
    this.destructionUserId,
  });

  PrescriptionItem copyWith({
    int? id,
    int? prescriptionId,
    int? physicalServiceId,
    HospitalService? physicalService,
    int? inpatientServiceId,
    HospitalService? inpatientService,
    int? patientRegistrationId,
    int? doctorId,
    User? doctor,
    int? medicineId,
    Medicine? medicine,
    double? dosePiece,
    RequestType? requestType,
    String? requestTypeName,
    bool? firstDoseEmergency,
    bool? askDoctor,
    bool? inCaseOfNecessity,
    List<DateTime>? times,
    DateTime? time,
    String? description,
    String? deleteDescription,
    DateTime? approvalDate,
    int? approvalUserId,
    User? approvalUser,
    DateTime? cancelDate,
    int? cancelUserId,
    User? cancelUser,
    bool? removed,
    DateTime? applicationDate,
    int? applicationUserId,
    User? applicationUser,
    DateTime? returnDate,
    int? returnUserId,
    User? returnUser,
    double? returnQuantity,
    int? barcode,
    int? sutCode,
    int? ubbCode,
    int? atcCode,
    bool? isQrCode,
    String? qrCode,
    DateTime? prescriptionDate,
    Prescription? prescription,
    String? protocolNo,
    String? patientName,
  }) {
    return PrescriptionItem(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      physicalService: physicalService ?? this.physicalService,
      physicalServiceId: physicalService?.id ?? this.physicalServiceId,
      inpatientService: inpatientService ?? this.inpatientService,
      inpatientServiceId: inpatientService?.id ?? this.inpatientServiceId,
      patientRegistrationId: patientRegistrationId ?? this.patientRegistrationId,
      doctor: doctor ?? this.doctor,
      doctorId: doctor?.id ?? this.doctorId,
      approvalUser: approvalUser ?? this.approvalUser,
      approvalUserId: approvalUser?.id ?? this.approvalUserId,
      cancelUser: cancelUser ?? this.cancelUser,
      cancelUserId: cancelUser?.id ?? this.cancelUserId,
      applicationUser: applicationUser ?? this.applicationUser,
      applicationUserId: applicationUser?.id ?? this.applicationUserId,
      returnUser: returnUser ?? this.returnUser,
      returnUserId: returnUser?.id ?? this.returnUserId,
      medicine: medicine ?? this.medicine,
      medicineId: medicine?.id ?? this.medicineId,
      dosePiece: dosePiece ?? this.dosePiece,
      requestType: requestType ?? this.requestType,
      requestTypeName: requestType?.label ?? this.requestTypeName,
      description: description ?? this.description,
      deleteDescription: deleteDescription ?? this.deleteDescription,
      approvalDate: approvalDate ?? this.approvalDate,
      cancelDate: cancelDate ?? this.cancelDate,
      applicationDate: applicationDate ?? this.applicationDate,
      returnDate: returnDate ?? this.returnDate,
      times: times ?? this.times,
      time: time ?? this.time,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      returnQuantity: returnQuantity ?? this.returnQuantity,
      protocolNo: protocolNo ?? this.protocolNo,
      patientName: patientName ?? this.patientName,
      barcode: barcode ?? this.barcode,
      sutCode: sutCode ?? this.sutCode,
      ubbCode: ubbCode ?? this.ubbCode,
      atcCode: atcCode ?? this.atcCode,
      qrCode: qrCode ?? this.qrCode,
      firstDoseEmergency: firstDoseEmergency ?? this.firstDoseEmergency,
      askDoctor: askDoctor ?? this.askDoctor,
      inCaseOfNecessity: inCaseOfNecessity ?? this.inCaseOfNecessity,
      removed: removed ?? this.removed,
    );
  }

  @override
  List<dynamic> get content => [
    barcode?.toCustomString(),
    medicine?.name,
    (firstDoseEmergency ?? false) ? 'Evet' : 'Hayır',
    (askDoctor ?? false) ? 'Evet' : 'Hayır',
    (inCaseOfNecessity ?? false) ? 'Evet' : 'Hayır',
    prescriptionDate?.formattedDate ?? '',
    time?.formattedTime ?? times?.map((t) => t.formattedTime).join(', ') ?? '',
    dosePiece?.toCustomString() ?? '',
    approvalDate?.formattedDate ?? '',
    approvalUser?.fullName ?? '',
    cancelDate?.formattedDate ?? '',
    cancelUser?.fullName ?? '',
    applicationDate?.formattedDate ?? '',
    applicationUser?.fullName ?? '',
    returnUser?.fullName ?? '',
    returnQuantity?.toCustomString() ?? '',
    returnDate?.formattedDate ?? '',
  ];

  @override
  List get rawContent => [
    medicine?.barcode,
    medicine?.name,
    firstDoseEmergency,
    askDoctor,
    inCaseOfNecessity,
    prescriptionDate,
    time ?? times,
    dosePiece,
    approvalDate,
    approvalUser,
    cancelDate,
    cancelUser,
    applicationDate,
    applicationUser,
    returnUser,
    returnQuantity,
    returnDate,
  ];

  @override
  List<String> get titles => [
    'Barkod/SUT',
    'Malzeme',
    'İlk Doz Acil',
    'Doktora Sor',
    'Lüzumu Halinde',
    'Tarih',
    'Saat',
    'Miktar',
    'Onay Tarihi',
    'Onaylayan',
    'İptal Tarihi',
    'İptal Eden',
    'Uygulama Tarihi',
    'Uygulayan',
    'İade Eden',
    'İade Miktar',
    'İade Tarihi',
  ];

  @override
  String? get subtitle => medicine?.barcode ?? '-';

  @override
  String get title => medicine?.title ?? '-';
}

enum PrescriptionColumn {
  medicine,
  dose,
  applicationUser,
  appliedQuantity,
  applicationDate,
  returnUser,
  returnQuantity,
  returnDate,
  wastageUser,
  wastageDate,
  destructionUser,
  destructionDate,
  status,
}

extension PrescriptionColumnX on PrescriptionColumn {
  String get label => switch (this) {
    PrescriptionColumn.medicine => 'İlaç',
    PrescriptionColumn.dose => 'Doz',
    PrescriptionColumn.applicationUser => 'Uygulayan',
    PrescriptionColumn.appliedQuantity => 'Uygulanan Miktar',
    PrescriptionColumn.applicationDate => 'Uygulama Tarihi',
    PrescriptionColumn.returnUser => 'İade Eden',
    PrescriptionColumn.returnQuantity => 'İade Edilen Miktar',
    PrescriptionColumn.returnDate => 'İade Tarihi',
    PrescriptionColumn.wastageUser => 'Fire Eden',
    PrescriptionColumn.wastageDate => 'Fire Tarihi',
    PrescriptionColumn.destructionUser => 'İmha Eden',
    PrescriptionColumn.destructionDate => 'İmha Tarihi',
    PrescriptionColumn.status => 'Durum',
  };

  int get flex => switch (this) {
    PrescriptionColumn.medicine => 4,
    PrescriptionColumn.status => 2,
    _ => 2,
  };
}
