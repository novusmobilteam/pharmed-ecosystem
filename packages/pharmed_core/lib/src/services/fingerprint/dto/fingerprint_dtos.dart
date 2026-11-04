// [SWREQ-FP-100] [SWREQ-FP-103]
// Parmak izi servis sözleşmesinin DTO'ları. Alan adları backend API dokümanıyla
// birebir aynı olmalıdır. Şablonlar base64 (standart alfabe, padding'li) taşınır.

class FingerprintSourceDTO {
  const FingerprintSourceDTO({this.templateFormat, this.scannerVendor, this.scannerModel, this.livenessActive});

  /// 'ISO19794-2' | 'ANSI378' | 'SUPREMA'
  final String? templateFormat;

  /// 'secugen' | 'suprema'
  final String? scannerVendor;
  final String? scannerModel;
  final bool? livenessActive;

  Map<String, dynamic> toJson() => {
    'templateFormat': templateFormat,
    'scannerVendor': scannerVendor,
    // TODO: Sunucuda Hamster U10 tanımlı. Eğer parmak izinde bir hata alınırsa burası kontrol edilsin.
    'scannerModel': 'Hamster U10',
    // 'scannerModel': scannerModel,
    'livenessActive': livenessActive,
  };
}

class FingerprintSampleDTO {
  const FingerprintSampleDTO({this.template, this.quality, this.lfdScore});

  /// base64
  final String? template;
  final int? quality;
  final int? lfdScore;

  Map<String, dynamic> toJson() => {'template': template, 'quality': quality, 'lfdScore': lfdScore};
}

class FingerEnrollmentDTO {
  const FingerEnrollmentDTO({this.fingerPosition, this.samples});

  /// ISO/IEC 19794-2 parmak pozisyonu, 1–10.
  final int? fingerPosition;
  final List<FingerprintSampleDTO>? samples;

  Map<String, dynamic> toJson() => {
    'fingerPosition': fingerPosition,
    'samples': samples?.map((s) => s.toJson()).toList(),
  };
}

/// POST /Fingerprint/enroll
class FingerprintEnrollRequestDTO {
  const FingerprintEnrollRequestDTO({this.source, this.fingers});

  final FingerprintSourceDTO? source;
  final List<FingerEnrollmentDTO>? fingers;

  Map<String, dynamic> toJson() => {...?source?.toJson(), 'fingers': fingers?.map((f) => f.toJson()).toList()};
}

/// GET /Fingerprint/me → liste elemanı
class EnrolledFingerDTO {
  const EnrolledFingerDTO({this.fingerPosition, this.enrolledAt, this.scannerVendor});

  factory EnrolledFingerDTO.fromJson(Map<String, dynamic> json) => EnrolledFingerDTO(
    fingerPosition: json['fingerPosition'] as int?,
    enrolledAt: json['enrolledAt'] as String?,
    scannerVendor: json['scannerVendor'] as String?,
  );

  final int? fingerPosition;

  /// ISO-8601 (UTC)
  final String? enrolledAt;
  final String? scannerVendor;

  Map<String, dynamic> toJson() => {
    'fingerPosition': fingerPosition,
    'enrolledAt': enrolledAt,
    'scannerVendor': scannerVendor,
  };
}

/// POST /Login/loginFingerprint
class FingerprintLoginRequestDTO {
  const FingerprintLoginRequestDTO({this.source, this.sample, this.macAddress, this.stationId});

  final FingerprintSourceDTO? source;
  final FingerprintSampleDTO? sample;
  final String? macAddress;
  final int? stationId;

  Map<String, dynamic> toJson() => {
    ...?source?.toJson(),
    ...?sample?.toJson(),
    if (macAddress != null) 'macAddress': macAddress,
    if (stationId != null) 'stationId': stationId,
  };
}

/// POST /Fingerprint/consent  — GET /Fingerprint/consent/{userId} yanıtı da bu alanları taşıyabilir.
/// KVKK biyometrik veri açık rızası.
class FingerprintConsentDTO {
  const FingerprintConsentDTO({this.userId, this.consentAt});

  factory FingerprintConsentDTO.fromJson(Map<String, dynamic> json) => FingerprintConsentDTO(
    userId: json['userId'] as int?,
    consentAt: json['consentAt'] as String?,
  );

  final int? userId;

  /// ISO-8601 (UTC)
  final String? consentAt;

  Map<String, dynamic> toJson() => {'userId': userId, 'consentAt': consentAt};
}
