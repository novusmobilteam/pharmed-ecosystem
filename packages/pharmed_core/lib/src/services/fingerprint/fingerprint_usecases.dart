// [SWREQ-FP-100..105]
// Parmak izi kaydı ve parmak iziyle giriş use case'leri.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Parmak izi API'sinin durumu (kamera kaydındaki RecordingUploadApi ile aynı yaklaşım).
///
/// `false` iken:
///   * kayıt / listeleme / silme: client tarafı sahte bir repository kullanır
///     (bkz. FakeFingerprintRepository) — akış uçtan uca çalışır, veri hiçbir yere gitmez.
///   * parmak iziyle giriş: use case sunucuya GİTMEDEN "servis hazır değil" (501) döner.
///
/// Backend endpoint'leri tamamlanınca `true` yapılır — başka değişiklik gerekmez.
abstract final class FingerprintApi {
  static const bool isAvailable = false;
}

/// Kayıt kuralları. Değerler servis sözleşmesiyle (API dokümanı) aynı olmalı.
abstract final class FingerprintEnrollmentRules {
  /// Parmak başına okuma sayısı.
  static const samplesPerFinger = 3;

  /// Kayıt için minimum kalite (Suprema ve SecuGen kılavuzlarının ortak önerisi).
  static const minEnrollQuality = 50;

  /// Giriş için minimum kalite (SecuGen ≥40, Suprema ≥30 önerir; yüksek olan alınır).
  static const minLoginQuality = 40;

  /// Şablon üst sınırı — bozuk veriyi servise göndermemek için.
  static const maxTemplateBytes = 4096;
}

const _unit = 'SW-UNIT-FP';

// ─────────────────────────────────────────────────────────────────
// Kayıt
// ─────────────────────────────────────────────────────────────────

/// [SWREQ-FP-100] [SWREQ-FP-101] Parmakları kaydeder. Zorunlu parmak yoktur;
/// tek bir parmak bile kaydedilebilir.
class EnrollFingerprintsUseCase {
  const EnrollFingerprintsUseCase(this._repository);
  final IFingerprintRepository _repository;

  Future<Result<void>> call(FingerprintEnrollmentRequest request) {
    final invalid = validate(request);
    if (invalid != null) {
      MedLogger.warn(
        unit: _unit,
        swreq: 'SWREQ-FP-100',
        message: 'Parmak izi kaydı reddedildi',
        context: {'reason': invalid.message, 'request': request.toString()},
      );
      return Future.value(Result.error(invalid));
    }
    return _repository.enroll(request);
  }

  /// UI'ın "Kaydet" butonunu etkinleştirmek için de kullanılır.
  static AppException? validate(FingerprintEnrollmentRequest request) {
    if (request.fingers.isEmpty) {
      return const ValidationException(message: 'Kaydedilecek parmak yok', field: 'fingers');
    }

    final positions = request.fingers.map((f) => f.position).toList();
    if (positions.toSet().length != positions.length) {
      return ValidationException(message: 'Aynı parmak birden fazla kez gönderildi', field: 'fingers', value: positions);
    }

    for (final finger in request.fingers) {
      if (finger.samples.length != FingerprintEnrollmentRules.samplesPerFinger) {
        return ValidationException(
          message: '${finger.position.name}: ${FingerprintEnrollmentRules.samplesPerFinger} okuma gerekli',
          field: 'samples',
          value: finger.samples.length,
        );
      }
      for (final s in finger.samples) {
        if (s.template.isEmpty || s.template.length > FingerprintEnrollmentRules.maxTemplateBytes) {
          return ValidationException(
            message: '${finger.position.name}: geçersiz şablon boyutu',
            field: 'template',
            value: s.template.length,
          );
        }
        if (s.quality < FingerprintEnrollmentRules.minEnrollQuality) {
          return ValidationException(
            message: '${finger.position.name}: kalite ${s.quality} < ${FingerprintEnrollmentRules.minEnrollQuality}',
            field: 'quality',
            value: s.quality,
          );
        }
      }
    }
    return null;
  }
}

/// Kullanıcının kayıtlı parmakları.
class GetEnrolledFingersUseCase {
  const GetEnrolledFingersUseCase(this._repository);
  final IFingerprintRepository _repository;

  Future<Result<List<EnrolledFinger>>> call() => _repository.getEnrolledFingers();
}

/// [SWREQ-FP-101] Bir parmağın kaydını siler. Her parmak silinebilir.
class DeleteEnrolledFingerUseCase {
  const DeleteEnrolledFingerUseCase(this._repository);
  final IFingerprintRepository _repository;

  Future<Result<void>> call(FingerPosition position) => _repository.deleteFinger(position);
}

// ─────────────────────────────────────────────────────────────────
// Giriş
// ─────────────────────────────────────────────────────────────────

/// [SWREQ-FP-103] Parmak iziyle giriş. Eşleştirme sunucuda yapılır.
class LoginWithFingerprintUseCase {
  const LoginWithFingerprintUseCase(this._repository);
  final IAuthRepository _repository;

  Future<Result<AuthToken>> call(FingerprintLoginRequest request) async {
    final s = request.sample;
    if (s.template.isEmpty || s.template.length > FingerprintEnrollmentRules.maxTemplateBytes) {
      return Result.error(
        ValidationException(message: 'Geçersiz şablon boyutu', field: 'template', value: s.template.length),
      );
    }
    if (s.quality < FingerprintEnrollmentRules.minLoginQuality) {
      return Result.error(
        FingerprintException(
          message: 'Parmak izi kalitesi yetersiz',
          reason: FingerprintFailureReason.lowQuality,
        ),
      );
    }

    if (!FingerprintApi.isAvailable) {
      MedLogger.info(
        unit: _unit,
        swreq: 'SWREQ-FP-103',
        message: 'Parmak iziyle giriş simüle edildi (servis yok)',
        context: {'request': request.toString(), 'templateSize': s.template.length},
      );
      return Result.error(
        ServiceException(message: contextlessL10n().fingerprint_login_serviceUnavailable, statusCode: 501),
      );
    }
    return _repository.loginWithFingerprint(request);
  }
}
