import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionTemplateItem {
  final int? id;
  final int? templateId;
  final int? medicineId;
  final Medicine? medicine;
  final num? dosePiece;
  final List<DateTime>? times;
  final RequestType? requestType;
  final bool? firstDoseEmergency;
  final bool? askDoctor;
  final bool? inCaseOfNecessity;
  final String? description;

  PrescriptionTemplateItem({
    this.id,
    this.templateId,
    this.medicineId,
    this.medicine,
    this.dosePiece,
    this.times,
    this.requestType,
    this.firstDoseEmergency,
    this.askDoctor,
    this.inCaseOfNecessity,
    this.description,
  });

  PrescriptionTemplateItem copyWith({
    int? id,
    int? templateId,
    int? medicineId,
    Medicine? medicine,
    double? dosePiece,
    List<DateTime>? times,
    RequestType? requestType,
    bool? firstDoseEmergency,
    bool? askDoctor,
    bool? inCaseOfNecessity,
    String? description,
  }) {
    return PrescriptionTemplateItem(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      medicineId: medicineId ?? this.medicineId,
      medicine: medicine ?? this.medicine,
      dosePiece: dosePiece ?? this.dosePiece,
      requestType: requestType ?? this.requestType,
      firstDoseEmergency: firstDoseEmergency ?? this.firstDoseEmergency,
      askDoctor: askDoctor ?? this.askDoctor,
      inCaseOfNecessity: inCaseOfNecessity ?? this.inCaseOfNecessity,
      description: description ?? this.description,
      times: times ?? this.times,
    );
  }
}

extension PrescriptionItemTemplateX on PrescriptionItem {
  /// Form'daki bir reçete kalemini, şablon kalemine dönüştürür.
  /// templateId çağıran tarafça (template create sonrası) set edilir.
  PrescriptionTemplateItem toTemplateItem({int? templateId}) {
    return PrescriptionTemplateItem(
      templateId: templateId,
      medicine: medicine,
      medicineId: medicineId,
      dosePiece: dosePiece,
      requestType: requestType,
      times: times,
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      description: description,
    );
  }
}

extension PrescriptionTemplateItemX on PrescriptionTemplateItem {
  PrescriptionItem toPrescriptionItem() {
    final today = DateTime.now();
    final remappedTimes = times?.map((dt) => DateTime(today.year, today.month, today.day, dt.hour, dt.minute)).toList();

    return PrescriptionItem(
      medicine: medicine,
      medicineId: medicineId,
      dosePiece: dosePiece,
      requestType: requestType,
      times: remappedTimes,
      firstDoseEmergency: firstDoseEmergency,
      askDoctor: askDoctor,
      inCaseOfNecessity: inCaseOfNecessity,
      description: description,
    );
  }
}
