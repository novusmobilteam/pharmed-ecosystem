import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionItemDto {
  final int? id;
  final int? prescriptionId;
  final int? medicineId;
  final int? hospitalizationId;
  final int? physicalServiceId;
  final int? inpatientServiceId;
  final int? doctorId;
  final int? requestType;

  final int? barcode;
  final int? sutCode;
  final int? ubbCode;
  final int? atcCode;
  final bool? isQrCode;
  final String? qrCode;
  final String? name;
  final String? surname;
  final String? patientName;
  final String? protocolNo;
  final String? rfidTag;
  final String? description;
  final String? deleteDescription;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;
  final DateTime? prescriptionDate;
  final String? doctor;
  final num? dosePiece;
  final bool? removed;
  final DateTime? time;
  final List<DateTime>? times;

  final MedicineDto? medicine;
  final HospitalizationDto? hospitalization;
  final ServiceDto? physicalService;
  final ServiceDto? inpatientService;
  final PrescriptionDto? prescription;
  final PrescriptionItemMovementDto? lastMovement;

  const PrescriptionItemDto({
    this.id,
    this.prescriptionId,
    this.hospitalizationId,
    this.hospitalization,
    this.physicalServiceId,
    this.physicalService,
    this.inpatientServiceId,
    this.inpatientService,
    this.lastMovement,
    this.doctorId,
    this.doctor,
    this.medicineId,
    this.medicine,
    this.dosePiece,
    this.requestType,
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.times,
    this.time,
    this.description,
    this.deleteDescription,
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
    this.rfidTag,
  });

  factory PrescriptionItemDto.fromJson(Map<String, dynamic> json) {
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

    return PrescriptionItemDto(
      id: json['id'] as int?,
      prescriptionId: json['prescriptionId'] as int?,
      hospitalizationId: json['patientHospitalizationId'] as int?,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDto.fromJson(json['patientHospitalization'])
          : null,
      physicalServiceId: json['physicalServiceId'] as int?,
      physicalService: json['physicalService'] != null ? ServiceDto.fromJson(json['physicalService']) : null,
      inpatientServiceId: json['inpatientServiceId'] as int?,
      inpatientService: json['inpatientService'] != null ? ServiceDto.fromJson(json['inpatientService']) : null,
      doctorId: json['doctorId'] as int?,
      doctor: json['doctor'] as String?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      dosePiece: json['dosePiece'] as num?,
      requestType: json['requestType'] as int?,
      firstDoseEmergency: (json['firstDoseEmergency'] as bool?) ?? false,
      askDoctor: json['askDoctor'] as bool?,
      inCaseOfNecessity: json['inCaseOfNecessity'] as bool?,
      times: parsedTimes,
      time: json['time'] != null ? DateTime.tryParse(json['time']) : null,
      description: json['description'] as String?,
      deleteDescription: json['deleteDescription'] as String?,
      removed: (json['removed'] as bool?) ?? false,
      barcode: json['barcode'] as int?,
      sutCode: json['sutCode'] as int?,
      ubbCode: json['ubbCode'] as int?,
      atcCode: json['atcCode'] as int?,
      isQrCode: json['isQrCode'] as bool?,
      qrCode: json['qrCode'] as String?,
      prescription: json['prescription'] != null ? PrescriptionDto.fromJson(json['prescription']) : null,
      prescriptionDate: json['prescriptionDate'] != null ? DateTime.tryParse(json['prescriptionDate']) : null,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      patientName: json['patientName'] as String?,
      protocolNo: json['protocolNo'] as String?,
      rfidTag: json['rfidCardTag'] as String?,
      lastMovement: json['lastMovement'] != null ? PrescriptionItemMovementDto.fromJson(json['lastMovement']) : null,
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
      'rfidCardTag': rfidTag,
    };
  }
}
