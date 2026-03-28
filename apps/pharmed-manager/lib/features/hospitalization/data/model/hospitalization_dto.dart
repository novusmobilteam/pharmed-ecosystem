import '../../../service/data/model/service_dto.dart';
import '../../../patient/data/model/patient_dto.dart';
import '../../../user/user.dart';
import '../../domain/entity/hospitalization.dart';

class HospitalizationDTO {
  final int? id;
  final int? code;
  final int? patientId;
  final PatientDTO? patient;
  final int? physicalServiceId;
  final ServiceDTO? physicalService;
  final int? inpatientServiceId;
  final ServiceDTO? inpatientService;
  final int? doctorId;
  final UserDTO? doctor;
  final String? roomNo;
  final String? bedNo;
  final String? description;
  final DateTime? admissionDate;
  final DateTime? exitDate;
  final int? waitingQuantity;
  final DateTime? lastApproveDate;
  final bool? isBaby;
  final int? colorId;
  final bool? isUrgent;

  HospitalizationDTO({
    this.id,
    this.code,
    this.patientId,
    this.patient,
    this.physicalServiceId,
    this.physicalService,
    this.inpatientServiceId,
    this.inpatientService,
    this.doctorId,
    this.doctor,
    this.roomNo,
    this.bedNo,
    this.description,
    this.admissionDate,
    this.exitDate,
    this.waitingQuantity,
    this.lastApproveDate,
    this.isBaby,
    this.colorId,
    this.isUrgent,
  });

  factory HospitalizationDTO.fromJson(Map<String, dynamic> json) {
    return HospitalizationDTO(
      id: json['id'] as int?,
      code: json['code'] as int?,
      patientId: json['patientId'] as int?,
      patient: json['patient'] != null ? PatientDTO.fromJson(json['patient']) : null,
      physicalServiceId: json['physicalServiceId'] as int?,
      physicalService: json['physicalService'] != null ? ServiceDTO.fromJson(json['physicalService']) : null,
      inpatientServiceId: json['inpatientServiceId'] as int?,
      inpatientService: json['inpatientService'] != null ? ServiceDTO.fromJson(json['inpatientService']) : null,
      doctorId: json['doctorId'] as int?,
      doctor: json['doctor'] != null ? UserDTO.fromJson(json['doctor']) : null,
      roomNo: json['roomNo'] as String?,
      bedNo: json['bedNo'] as String?,
      description: json['description'] as String?,
      admissionDate: json['admissionDate'] != null ? DateTime.tryParse(json['admissionDate']) : null,
      exitDate: json['exitDate'] != null ? DateTime.tryParse(json['exitDate']) : null,
      waitingQuantity: json['waitingQuantity'] as int?,
      lastApproveDate: json['lastApproveDate'] != null ? DateTime.tryParse(json['lastApproveDate']) : null,
      isBaby: json['isBaby'] as bool?,
      colorId: json['colorId'] as int?,
      isUrgent: json['isUrgent'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'patientId': patientId,
      'physicalServiceId': physicalServiceId,
      'inpatientServiceId': inpatientServiceId,
      'doctorId': doctorId,
      // 'doctor': doctor?.toJson(),
      'roomNo': roomNo,
      'bedNo': bedNo,
      'description': description,
      'admissionDate': admissionDate?.toIso8601String(),
      'exitDate': exitDate?.toIso8601String(),
      'isBaby': isBaby ?? false,
      'isUrgent': false,
    };
  }

  Hospitalization toEntity() {
    return Hospitalization(
      id: id,
      code: code,
      roomNo: roomNo,
      bedNo: bedNo,
      description: description,
      admissionDate: admissionDate,
      exitDate: exitDate,
      physicalService: physicalService?.toEntity(),
      inpatientService: inpatientService?.toEntity(),
      doctor: doctor?.toEntity(),
      patient: patient?.toEntity(),
      waitingQuantity: waitingQuantity,
      lastApproveDate: lastApproveDate,
      isBaby: isBaby,
      colorId: colorId,
      isUrgent: isUrgent ?? false,
    );
  }

  HospitalizationDTO copyWith({
    int? id,
    int? code,
    int? patientId,
    PatientDTO? patient,
    int? physicalServiceId,
    ServiceDTO? physicalService,
    int? inpatientServiceId,
    ServiceDTO? inpatientService,
    int? doctorId,
    UserDTO? doctor,
    String? roomNo,
    String? bedNo,
    String? description,
    DateTime? admissionDate,
    DateTime? exitDate,
  }) {
    return HospitalizationDTO(
      id: id ?? this.id,
      code: code ?? this.code,
      patientId: patientId ?? this.patientId,
      physicalServiceId: physicalServiceId ?? this.physicalServiceId,
      physicalService: physicalService ?? this.physicalService,
      inpatientServiceId: inpatientServiceId ?? this.inpatientServiceId,
      inpatientService: inpatientService ?? this.inpatientService,
      doctorId: doctorId ?? this.doctorId,
      doctor: doctor ?? this.doctor,
      roomNo: roomNo ?? this.roomNo,
      bedNo: bedNo ?? this.bedNo,
      description: description ?? this.description,
      admissionDate: admissionDate ?? this.admissionDate,
      exitDate: exitDate ?? this.exitDate,
    );
  }

  /// Mock factory for test data generation
  static HospitalizationDTO mockFactory(int id, {bool withNested = true}) {
    final patientId = ((id - 1) % 100) + 1;
    final serviceId = ((id - 1) % 20) + 1;
    final doctorId = ((id - 1) % 20) + 1;

    final admissionDate = DateTime.now().subtract(Duration(days: 60 - (id % 60)));

    return HospitalizationDTO(
      id: id,
      code: 100000 + id,
      patientId: patientId,
      patient: withNested ? PatientDTO.mockFactory(patientId) : null,
      physicalServiceId: serviceId,
      physicalService: withNested ? ServiceDTO.mockFactory(serviceId, withNested: false) : null,
      inpatientServiceId: serviceId,
      inpatientService: withNested ? ServiceDTO.mockFactory(serviceId, withNested: false) : null,
      doctorId: doctorId,
      doctor: withNested ? UserDTO.mockFactory(doctorId) : null,
      roomNo: '${((id - 1) % 10) + 1}',
      bedNo: '${((id - 1) % 4) + 1}',
      description: 'Yatış açıklaması $id',
      admissionDate: admissionDate,
      exitDate: (id % 3 == 0) ? admissionDate.add(Duration(days: 10)) : null,
      waitingQuantity: (id * 3) % 10,
      lastApproveDate: admissionDate.add(Duration(days: 1)),
      isBaby: (id % 10 == 0),
    );
  }
}
