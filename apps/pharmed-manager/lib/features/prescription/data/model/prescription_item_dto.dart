import '../../../../core/core.dart';
import '../../../medicine/data/model/medicine_dto.dart';
import '../../../service/data/model/service_dto.dart';
import '../../domain/entity/prescription_item.dart';
import 'prescription_dto.dart';

class PrescriptionItemDTO {
  final int? id;
  final int? prescriptionId;
  final int? patientRegistrationId;

  final int? physicalServiceId;
  final ServiceDTO? physicalService;

  final int? inpatientServiceId;
  final ServiceDTO? inpatientService;

  final int? doctorId;
  final String? doctor;

  final int? medicineId;
  final MedicineDTO? medicine;

  final num? dosePiece;
  final int? requestType;
  final String? requestTypeName;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;

  final List<DateTime>? times;
  final DateTime? time;
  final String? description;
  final String? deleteDescription;
  final double? returnQuantity;
  final int? barcode;
  final int? sutCode;
  final int? ubbCode;
  final int? atcCode;
  final bool? isQrCode;
  final String? qrCode;
  final DateTime? prescriptionDate;
  final PrescriptionDTO? prescription;
  final bool? removed;
  final String? name;
  final String? surname;
  final String? patientName;
  final String? protocolNo;
  final int? statusId;

  final DateTime? approvalDate;
  final int? approvalUserId;
  final UserDTO? approvalUser;

  final DateTime? cancelDate;
  final int? cancelUserId;
  final UserDTO? cancelUser;

  final DateTime? applicationDate;
  final int? applicationUserId;
  final UserDTO? applicationUser;

  final DateTime? returnDate;
  final int? returnUserId;
  final UserDTO? returnUser;

  final DateTime? createdDate;
  final UserDTO? createdUser;
  final int? createdUserId;

  final DateTime? rejectDate;
  final UserDTO? rejectUser;
  final int? rejectUserId;

  final DateTime? wastageDate;
  final UserDTO? wastageUser;
  final int? wastageUserId;

  final DateTime? destructionDate;
  final UserDTO? destructionUser;
  final int? destructionUserId;

  const PrescriptionItemDTO({
    this.id,
    this.prescriptionId,
    this.patientRegistrationId,
    this.physicalServiceId,
    this.physicalService,
    this.inpatientServiceId,
    this.inpatientService,
    this.doctorId,
    this.doctor,
    this.medicineId,
    this.medicine,
    this.dosePiece,
    this.requestType,
    this.requestTypeName,
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.times,
    this.time,
    this.description,
    this.deleteDescription,
    this.returnQuantity,
    this.barcode,
    this.sutCode,
    this.ubbCode,
    this.atcCode,
    this.isQrCode,
    this.qrCode,
    this.prescriptionDate,
    this.prescription,
    this.removed,
    this.name,
    this.surname,
    this.patientName,
    this.protocolNo,
    this.statusId,
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

  factory PrescriptionItemDTO.fromJson(Map<String, dynamic> json) {
    // Times listesini güvenli parse etme
    List<DateTime>? parsedTimes;
    if (json['times'] != null && json['times'] is List) {
      try {
        parsedTimes = (json['times'] as List).map((x) {
          if (x is String) {
            return DateTime.parse(x);
          } else if (x is DateTime) {
            return x;
          } else {
            return DateTime.now(); // Fallback
          }
        }).toList();
      } catch (e) {
        parsedTimes = null;
      }
    }

    return PrescriptionItemDTO(
      id: json['id'] as int?,
      prescriptionId: json['prescriptionId'] as int?,
      patientRegistrationId: json['patientRegistrationId'] as int?,
      physicalServiceId: json['physicalServiceId'] as int?,
      physicalService: json['physicalService'] != null ? ServiceDTO.fromJson(json['physicalService']) : null,
      inpatientServiceId: json['inpatientServiceId'] as int?,
      inpatientService: json['inpatientService'] != null ? ServiceDTO.fromJson(json['inpatientService']) : null,
      doctorId: json['doctorId'] as int?,
      doctor: json['doctor'] as String?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDTO.fromJson(json['material']) : null,
      dosePiece: json['dosePiece'] as num?,
      requestType: json['requestType'] as int?,
      requestTypeName: json['requestTypeName'] as String?,
      firstDoseEmergency: (json['firstDoseEmergency'] as bool?) ?? false,
      askDoctor: json['askDoctor'] as bool?,
      inCaseOfNecessity: json['inCaseOfNecessity'] as bool?,
      times: parsedTimes,
      time: json['time'] != null ? DateTime.tryParse(json['time']) : null,
      description: json['description'] as String?,
      deleteDescription: json['deleteDescription'] as String?,
      removed: (json['removed'] as bool?) ?? false,

      returnQuantity: json['returnQuantity'] as double?,
      barcode: json['barcode'] as int?,
      sutCode: json['sutCode'] as int?,
      ubbCode: json['ubbCode'] as int?,
      atcCode: json['atcCode'] as int?,
      isQrCode: json['isQrCode'] as bool?,
      qrCode: json['qrCode'] as String?,
      prescription: json['prescription'] != null ? PrescriptionDTO.fromJson(json['prescription']) : null,
      prescriptionDate: json['prescriptionDate'] != null ? DateTime.tryParse(json['prescriptionDate']) : null,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      patientName: json['patientName'] as String?,
      protocolNo: json['protocolNo'] as String?,
      statusId: json['detailStatusId'] as int?,

      //
      approvalDate: json['approvalDate'] != null ? DateTime.tryParse(json['approvalDate']) : null,
      approvalUserId: json['approvalUserId'] as int?,
      approvalUser: json['approvalUser'] != null ? UserDTO.fromJson(json['approvalUser']) : null,
      //
      cancelDate: json['cancelDate'] != null ? DateTime.tryParse(json['cancelDate']) : null,
      cancelUserId: json['cancelUserId'] as int?,
      cancelUser: json['cancelUser'] != null ? UserDTO.fromJson(json['cancelUser']) : null,
      //
      applicationDate: json['applicationDate'] != null ? DateTime.tryParse(json['applicationDate']) : null,
      applicationUserId: json['applicationUserId'] as int?,
      applicationUser: json['applicationUser'] != null ? UserDTO.fromJson(json['applicationUser']) : null,
      //
      returnDate: json['returnDate'] != null ? DateTime.tryParse(json['returnDate']) : null,
      returnUserId: json['returnUserId'] as int?,
      returnUser: json['returnUser'] != null ? UserDTO.fromJson(json['returnUser']) : null,
      //
      createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate']) : null,
      createdUserId: json['createdUserId'] as int?,
      createdUser: json['createdUser'] != null ? UserDTO.fromJson(json['createdUser']) : null,
      //
      rejectDate: json['rejectDate'] != null ? DateTime.tryParse(json['rejectDate']) : null,
      rejectUserId: json['rejectUserId'] as int?,
      rejectUser: json['rejectUser'] != null ? UserDTO.fromJson(json['rejectUser']) : null,
      //
      wastageDate: json['wastageDate'] != null ? DateTime.tryParse(json['wastageDate']) : null,
      wastageUserId: json['wastageUserId'] as int?,
      wastageUser: json['wastageUser'] != null ? UserDTO.fromJson(json['wastageUser']) : null,
      //
      destructionDate: json['destructionDate'] != null ? DateTime.tryParse(json['destructionDate']) : null,
      destructionUserId: json['destructionUserId'] as int?,
      destructionUser: json['destructionUser'] != null ? UserDTO.fromJson(json['destructionUser']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionId': prescriptionId,
      'doctorId': doctorId,
      'materialId': medicineId,
      'dosePiece': dosePiece,
      'requestType': requestType,
      'firstDoseEmergency': firstDoseEmergency ?? false,
      'askDoctor': askDoctor ?? false,
      'inCaseOfNecessity': inCaseOfNecessity ?? false,
      'time': times?.map((x) => x.toIso8601String()).toList(),
      'description': description,
      'qrCode': qrCode,
    };
  }

  PrescriptionItemDTO copyWith({
    int? id,
    int? prescriptionId,
    int? patientRegistrationId,
    int? doctorId,
    int? approvalUserId,
    String? materialName,
    String? qrCode,
    double? dosePiece,
    DateTime? date,
    DateTime? approvalDate,
    bool? isScanned,
    bool? removed,
    String? description,
    double? returnQuantity,
    DateTime? applicationDate,
    int? applicationUserId,
    UserDTO? applicationUser,
  }) {
    return PrescriptionItemDTO(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      patientRegistrationId: patientRegistrationId ?? this.patientRegistrationId,
      doctorId: doctorId ?? this.doctorId,
      approvalUserId: approvalUserId ?? this.approvalUserId,
      qrCode: qrCode ?? this.qrCode,
      dosePiece: dosePiece ?? this.dosePiece,
      approvalDate: approvalDate ?? this.approvalDate,
      removed: removed ?? this.removed,
      description: description ?? this.description,
      returnQuantity: returnQuantity ?? this.returnQuantity,
      applicationDate: applicationDate ?? this.applicationDate,
      applicationUserId: applicationUserId ?? this.applicationUserId,
      applicationUser: applicationUser ?? this.applicationUser,
      physicalServiceId: physicalServiceId,
      physicalService: physicalService,
      inpatientServiceId: inpatientServiceId,
      inpatientService: inpatientService,
      doctor: doctor,
      medicineId: medicineId,
      medicine: medicine,
      requestType: requestType,
      requestTypeName: requestTypeName,
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      times: times,
      time: time,
      deleteDescription: deleteDescription,
      cancelDate: cancelDate,
      cancelUserId: cancelUserId,
      cancelUser: cancelUser,
      returnDate: returnDate,
      returnUserId: returnUserId,
      returnUser: returnUser,
      barcode: barcode,
      sutCode: sutCode,
      ubbCode: ubbCode,
      atcCode: atcCode,
      isQrCode: isQrCode,
      prescriptionDate: prescriptionDate,
      prescription: prescription,
      name: name,
      surname: surname,
      patientName: patientName,
      protocolNo: protocolNo,
    );
  }

  PrescriptionItem toEntity() {
    return PrescriptionItem(
      id: id,
      barcode: barcode,
      prescriptionId: prescriptionId,
      patientRegistrationId: patientRegistrationId,
      doctor: User.fromIdAndFullName(id: doctorId, fullName: doctor),
      approvalUser: const UserMapper().toEntityOrNull(approvalUser),
      cancelUser: const UserMapper().toEntityOrNull(cancelUser),
      applicationUser: const UserMapper().toEntityOrNull(applicationUser),
      returnUser: const UserMapper().toEntityOrNull(returnUser),
      dosePiece: dosePiece,
      requestType: RequestType.fromId(requestType),
      description: description,
      approvalDate: approvalDate,
      cancelDate: cancelDate,
      applicationDate: applicationDate,
      returnDate: returnDate,
      returnQuantity: returnQuantity,
      protocolNo: protocolNo,
      time: time,
      patientName:
          patientName ??
          ([name, surname].whereType<String>().join(' ').trim().isEmpty
              ? null
              : [name, surname].whereType<String>().join(' ')),
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      removed: removed,
      inpatientService: inpatientService?.toEntity(),
      physicalService: physicalService?.toEntity(),
      deleteDescription: deleteDescription,
      prescription: prescription?.toEntity(),
      medicine: medicine?.toEntity(),
      status: PrescriptionStatus.fromId(statusId),
      createdDate: createdDate,
    );
  }
}
