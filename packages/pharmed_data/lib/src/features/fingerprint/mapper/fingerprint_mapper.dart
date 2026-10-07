import 'dart:convert';

import 'package:pharmed_core/pharmed_core.dart';

/// [SWREQ-FP-100] Parmak izi entity ↔ DTO dönüşümleri. Şablonlar base64'e çevrilir.
class FingerprintMapper {
  const FingerprintMapper();

  FingerprintSourceDTO toSourceDto(FingerprintSource s) => FingerprintSourceDTO(
    templateFormat: s.format.wireName,
    scannerVendor: s.scannerVendor,
    scannerModel: s.scannerModel,
    livenessActive: s.livenessActive,
  );

  FingerprintSampleDTO toSampleDto(FingerprintSample s) =>
      FingerprintSampleDTO(template: base64Encode(s.template), quality: s.quality, lfdScore: s.lfdScore);

  FingerprintEnrollRequestDTO toEnrollDto(FingerprintEnrollmentRequest r) => FingerprintEnrollRequestDTO(
    source: toSourceDto(r.source),
    fingers: [
      for (final f in r.fingers)
        FingerEnrollmentDTO(fingerPosition: f.position.isoCode, samples: f.samples.map(toSampleDto).toList()),
    ],
  );

  FingerprintLoginRequestDTO toLoginDto(FingerprintLoginRequest r) => FingerprintLoginRequestDTO(
    source: toSourceDto(r.source),
    sample: toSampleDto(r.sample),
    macAddress: r.macAddress,
    stationId: r.stationId,
  );

  /// Bilinmeyen pozisyon kodları atlanır (null döner).
  EnrolledFinger? toEnrolledFinger(EnrolledFingerDTO dto) {
    final position = FingerPosition.fromIsoCode(dto.fingerPosition);
    if (position == null) return null;
    return EnrolledFinger(
      position: position,
      enrolledAt: dto.enrolledAt == null ? null : DateTime.tryParse(dto.enrolledAt!)?.toLocal(),
      scannerVendor: dto.scannerVendor,
    );
  }

  List<EnrolledFinger> toEnrolledFingerList(List<EnrolledFingerDTO> dtos) =>
      dtos.map(toEnrolledFinger).whereType<EnrolledFinger>().toList();

  EnrolledFingerDTO toEnrolledFingerDto(EnrolledFinger e) => EnrolledFingerDTO(
    fingerPosition: e.position.isoCode,
    enrolledAt: e.enrolledAt?.toUtc().toIso8601String(),
    scannerVendor: e.scannerVendor,
  );
}
