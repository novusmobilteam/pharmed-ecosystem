import 'package:pharmed_core/pharmed_core.dart';

class Prescription {
  final int? id;
  final int? code;
  final String? name;
  final DateTime? prescriptionDate;
  final DateTime? hospitalizationDate;
  final bool? isPrescribed;
  final int? remainingCount;
  final int? hospitalizationId;
  final Hospitalization? hospitalization;

  Prescription({
    this.id,
    this.code,
    this.name,
    this.hospitalizationId,
    this.hospitalizationDate,
    this.prescriptionDate,
    this.isPrescribed,
    this.remainingCount,
    this.hospitalization,
  });

  Prescription copyWith({int? id, int? code, int? hospitalizationId, String? name, DateTime? prescriptionDate}) {
    return Prescription(
      id: id ?? this.id,
      code: code ?? this.code,
      hospitalizationId: hospitalizationId ?? this.hospitalizationId,
      name: name ?? this.name,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
    );
  }
}
