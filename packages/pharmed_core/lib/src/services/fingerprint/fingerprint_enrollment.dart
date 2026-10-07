// [SWREQ-FP-100] [SWREQ-FP-103]
// Parmak izi kaydı ve parmak iziyle giriş için domain modelleri.
//
// KVKK: Şablonlar yalnızca bellekte tutulur ve servise gönderilir; loglanmaz,
// diske yazılmaz. toString'ler şablon içeriğini bilerek göstermez.
//
// Sınıf: Class B

import 'dart:typed_data';

import 'fingerprint_capture.dart';
import 'finger_position.dart';

/// Bir parmağın tek bir okuması.
class FingerprintSample {
  const FingerprintSample({required this.template, required this.quality, this.lfdScore});

  factory FingerprintSample.fromCapture(FingerprintCapture c) =>
      FingerprintSample(template: c.template, quality: c.quality, lfdScore: c.lfdScore);

  final Uint8List template;
  final int quality;
  final int? lfdScore;

  @override
  String toString() => 'FingerprintSample(quality: $quality, lfdScore: $lfdScore, size: ${template.length})';
}

/// Kayda gönderilecek bir parmak ve okumaları.
class FingerEnrollment {
  const FingerEnrollment({required this.position, required this.samples});

  final FingerPosition position;
  final List<FingerprintSample> samples;

  @override
  String toString() => 'FingerEnrollment(${position.name}, samples: ${samples.length})';
}

/// Okuyucu bilgisi — sunucu şablonun kaynağını bilsin (kalite ölçekleri üreticiye göre farklı).
class FingerprintSource {
  const FingerprintSource({
    required this.format,
    required this.scannerVendor,
    required this.scannerModel,
    required this.livenessActive,
  });

  factory FingerprintSource.fromScanner(FingerprintScannerInfo info, FingerprintTemplateFormat format) =>
      FingerprintSource(
        format: format,
        scannerVendor: info.vendor,
        scannerModel: info.model,
        livenessActive: info.livenessActive,
      );

  final FingerprintTemplateFormat format;
  final String scannerVendor;
  final String scannerModel;
  final bool livenessActive;
}

/// Tek istekte gönderilen kayıt. Kullanıcı kimliği gövdede yok; oturum token'ından alınır.
/// Aynı pozisyon daha önce kayıtlıysa sunucu onu bu kayıtla DEĞİŞTİRİR.
class FingerprintEnrollmentRequest {
  const FingerprintEnrollmentRequest({required this.fingers, required this.source});

  final List<FingerEnrollment> fingers;
  final FingerprintSource source;

  @override
  String toString() =>
      'FingerprintEnrollmentRequest(${fingers.map((f) => f.position.name).join(', ')}, '
      '${source.scannerVendor}/${source.format.wireName})';
}

/// Sunucuda kayıtlı bir parmak (şablon istemciye dönmez).
class EnrolledFinger {
  const EnrolledFinger({required this.position, this.enrolledAt, this.scannerVendor});

  final FingerPosition position;
  final DateTime? enrolledAt;
  final String? scannerVendor;

  @override
  String toString() => 'EnrolledFinger(${position.name}, $enrolledAt)';
}

/// Parmak iziyle giriş isteği.
class FingerprintLoginRequest {
  const FingerprintLoginRequest({required this.sample, required this.source, this.macAddress, this.stationId});

  final FingerprintSample sample;
  final FingerprintSource source;
  final String? macAddress;
  final int? stationId;

  @override
  String toString() => 'FingerprintLoginRequest(quality: ${sample.quality}, ${source.scannerVendor})';
}
