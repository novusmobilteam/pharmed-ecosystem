import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class PrescriptionItem implements Selectable {
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
  final String? rfidTag;
  final PrescriptionItemMovement? lastMovement;
  final Hospitalization? hospitalization;
  final DateTime? applicationDate;
  final User? applicationUser;

  PrescriptionMovementType? get status => lastMovement?.type;
  User? get activityUser => lastMovement?.performedBy;
  DateTime? get activityDate => lastMovement?.createdAt;

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
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.times,
    this.time,
    this.description,
    this.deleteDescription,
    this.removed,
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
    this.rfidTag,
    this.lastMovement,
    this.hospitalization,
    this.applicationDate,
    this.applicationUser,
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
    bool? removed,
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
    String? rfidTag,
    PrescriptionItemMovement? lastMovement,
    bool clearRfidTag = false,
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
      medicine: medicine ?? this.medicine,
      medicineId: medicine?.id ?? this.medicineId,
      dosePiece: dosePiece ?? this.dosePiece,
      requestType: requestType ?? this.requestType,
      description: description ?? this.description,
      deleteDescription: deleteDescription ?? this.deleteDescription,
      times: times ?? this.times,
      time: time ?? this.time,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
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
      rfidTag: clearRfidTag ? null : (rfidTag ?? this.rfidTag),
      prescription: prescription ?? this.prescription,
      lastMovement: lastMovement ?? this.lastMovement,
    );
  }

  @override
  String? get subtitle => medicine?.barcode ?? '-';

  @override
  String get title => medicine?.title ?? '-';

  /// Sunucudan gelen bir kalemi "yeni draft" haline getirir.
  /// Sunucu yönetimindeki tüm alanları (id, prescriptionId, status, approval,
  /// application, RFID, movement) temizler. Manuel düzenleme için temel alanları korur.
  PrescriptionItem asDraft() {
    return PrescriptionItem(
      medicine: medicine,
      medicineId: medicineId,
      doctor: doctor,
      doctorId: doctorId,
      dosePiece: dosePiece,
      requestType: requestType,
      times: times,
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      description: description,
      // id, prescriptionId, prescription, time (singular),
      // approval/application/cancel alanları, detailStatusId,
      // rfidCardTag, lastMovement, createdUserId, createdDate dahil edilmez.
    );
  }
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
    PrescriptionColumn.medicine => contextlessL10n().tableCore_prescriptionMedicineColumn,
    PrescriptionColumn.dose => contextlessL10n().tableCore_prescriptionDoseColumn,
    PrescriptionColumn.applicationUser => contextlessL10n().tableCore_prescriptionApplicationUserColumn,
    PrescriptionColumn.appliedQuantity => contextlessL10n().tableCore_prescriptionAppliedQuantityColumn,
    PrescriptionColumn.applicationDate => contextlessL10n().tableCore_prescriptionApplicationDateColumn,
    PrescriptionColumn.returnUser => contextlessL10n().tableCore_prescriptionReturnUserColumn,
    PrescriptionColumn.returnQuantity => contextlessL10n().tableCore_prescriptionReturnQuantityColumn,
    PrescriptionColumn.returnDate => contextlessL10n().tableCore_prescriptionReturnDateColumn,
    PrescriptionColumn.wastageUser => contextlessL10n().tableCore_prescriptionWastageUserColumn,
    PrescriptionColumn.wastageDate => contextlessL10n().tableCore_prescriptionWastageDateColumn,
    PrescriptionColumn.destructionUser => contextlessL10n().tableCore_prescriptionDestructionUserColumn,
    PrescriptionColumn.destructionDate => contextlessL10n().tableCore_prescriptionDestructionDateColumn,
    PrescriptionColumn.status => contextlessL10n().tableCore_prescriptionStatusColumn,
  };

  int get flex => switch (this) {
    PrescriptionColumn.medicine => 4,
    PrescriptionColumn.status => 2,
    _ => 2,
  };
}
