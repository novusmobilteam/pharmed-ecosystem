import 'package:pharmed_core/pharmed_core.dart';

/// `Prescription/uncollectedPrescriptionMaster` satırı.
///
/// Servis yatış bazlı gruplanmış kayıt döner: yatış bilgisi, o yatışa ait
/// bekleyen reçeteler (`prescriptions`) ve uygulanmayı bekleyen reçete
/// kalemleri (`details`) tek yanıtta gelir; ayrı detay servisi çağrılmaz.
class UnappliedHospitalizationDto {
  final int? id;
  final int? hospitalizationId;
  final HospitalizationDto? hospitalization;
  final DateTime? hospitalizationDate;
  final int? remainingCount;
  final String? materialNames;
  final List<PrescriptionDto> prescriptions;
  final List<PrescriptionItemDto> details;

  const UnappliedHospitalizationDto({
    this.id,
    this.hospitalizationId,
    this.hospitalization,
    this.hospitalizationDate,
    this.remainingCount,
    this.materialNames,
    this.prescriptions = const [],
    this.details = const [],
  });

  factory UnappliedHospitalizationDto.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(Object? raw, T Function(Map<String, dynamic>) parser) => raw is List
        ? raw.whereType<Map<String, dynamic>>().map(parser).toList()
        : <T>[];

    return UnappliedHospitalizationDto(
      id: json['id'] as int?,
      hospitalizationId: json['patientHospitalizationId'] as int?,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDto.fromJson(json['patientHospitalization'] as Map<String, dynamic>)
          : null,
      hospitalizationDate: json['hospitalizationDate'] != null
          ? DateTime.tryParse(json['hospitalizationDate'] as String)
          : null,
      remainingCount: (json['remainingCount'] as num?)?.toInt(),
      materialNames: json['materialNames'] as String?,
      prescriptions: parseList(json['prescriptions'], PrescriptionDto.fromJson),
      details: parseList(json['details'], PrescriptionItemDto.fromJson),
    );
  }
}
