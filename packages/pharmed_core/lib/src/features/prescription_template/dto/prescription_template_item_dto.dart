import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionTemplateItemDto {
  final int? id;
  final int? templateId;
  final int? medicineId;
  final MedicineDto? medicine;
  final num? dosePiece;
  final List<DateTime>? times;
  final int? requestTypeId;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;
  final String? description;

  PrescriptionTemplateItemDto({
    this.id,
    this.templateId,
    this.medicineId,
    this.medicine,
    this.dosePiece,
    this.times,
    this.requestTypeId,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.description,
  });

  factory PrescriptionTemplateItemDto.fromJson(Map<String, dynamic> json) {
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

    return PrescriptionTemplateItemDto(
      id: json['id'] as int?,
      templateId: json['prescriptionTemplateId'] as int?,
      medicineId: json['materialId'] as int?,
      medicine: json['material'] != null ? MedicineDto.fromJson(json['material']) : null,
      dosePiece: json['dosePiece'] as num?,
      times: parsedTimes,
      requestTypeId: json['requestType'] as int?,
      firstDoseEmergency: json['firstDoseEmergency'] as bool?,
      askDoctor: json['askDoctor'] as bool?,
      inCaseOfNecessity: json['inCaseOfNecessity'] as bool?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'prescriptionTemplateId': templateId,
      'materialId': medicineId,
      //'material': medicine?.toJson(),
      'dosePiece': dosePiece,
      'requestType': requestTypeId,
      'firstDoseEmergency': firstDoseEmergency,
      'askDoctor': askDoctor,
      'inCaseOfNecessity': inCaseOfNecessity,
      'description': description,
      'times': times?.map((t) => t.toIso8601String()).toList(),
    };
  }

  PrescriptionTemplateItemDto copyWith({
    int? id,
    int? templateId,
    int? medicineId,
    MedicineDto? medicine,
    List<DateTime>? times,
    num? dosePiece,
    int? requestTypeId,
    bool? firstDoseEmergency,
    bool? askDoctor,
    bool? inCaseOfNecessity,
    String? description,
  }) {
    return PrescriptionTemplateItemDto(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      medicineId: medicineId ?? this.medicineId,
      medicine: medicine ?? this.medicine,
      dosePiece: dosePiece ?? this.dosePiece,
      requestTypeId: requestTypeId ?? this.requestTypeId,
      firstDoseEmergency: firstDoseEmergency ?? this.firstDoseEmergency,
      askDoctor: askDoctor ?? this.askDoctor,
      inCaseOfNecessity: inCaseOfNecessity ?? this.inCaseOfNecessity,
      description: description ?? this.description,
      times: times ?? this.times,
    );
  }
}
