import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class Prescription extends TableData {
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

  @override
  List get content => [
    hospitalization?.physicalService?.name,
    hospitalization?.patient?.protocolNo,
    hospitalization?.patient?.fullName,
    hospitalizationId?.toCustomString(),
    hospitalizationDate?.formattedDate,
    remainingCount?.toCustomString(),
  ];

  @override
  List get rawContent => [
    hospitalization?.physicalService,
    hospitalization?.patient?.protocolNo,
    hospitalization?.patient?.fullName,
    hospitalizationId,
    hospitalizationDate,
    remainingCount,
  ];

  @override
  List<String?> get titles => ['Servis', 'Hasta Kodu', 'Hasta', 'Yatış Kodu', 'Yatış Tarihi', 'Bekleyen Adet'];
}
