import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// [SWREQ-DATA-FP-001] Oturum açmış kullanıcının parmak izi kayıtları.
///
/// Yollar ve gövdeler backend için hazırlanan API dokümanıyla aynıdır. Şu an
/// FingerprintApi.isAvailable = false olduğu için client bu sınıf yerine
/// FakeFingerprintRepository'yi kullanır.
class FingerprintRemoteDataSource extends BaseRemoteDataSource {
  FingerprintRemoteDataSource({required super.apiManager});

  @override
  String get logUnit => 'SW-UNIT-FP';

  @override
  String get logSwreq => 'SWREQ-DATA-FP-001';

  static const _base = '/Fingerprint';

  /// POST /Fingerprint/enroll — aynı pozisyon varsa değiştirilir.
  /// 409: parmak başka bir kullanıcıda kayıtlı. 422: örnekler birbiriyle tutarsız / kalite düşük.
  Future<Result<void>> enroll(FingerprintEnrollRequestDTO dto) => postRequest<void>(
    path: '$_base/enroll',
    body: dto.toJson(),
    parser: BaseRemoteDataSource.voidParser(),
    successLog: 'Parmak izi kaydı gönderildi',
  );

  /// GET /Fingerprint/me
  Future<Result<List<EnrolledFingerDTO>>> getEnrolledFingers() async {
    final res = await fetchRequest<List<EnrolledFingerDTO>>(
      path: '$_base/me',
      parser: BaseRemoteDataSource.listParser(EnrolledFingerDTO.fromJson),
      successLog: 'Kayıtlı parmaklar alındı',
      emptyLog: 'Kayıtlı parmak yok',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <EnrolledFingerDTO>[]), error: Result.error);
  }

  /// DELETE /Fingerprint/me/{fingerPosition}
  Future<Result<void>> deleteFinger(int fingerPosition) => deleteRequest<void>(
    path: '$_base/me/$fingerPosition',
    parser: BaseRemoteDataSource.voidParser(),
    successLog: 'Parmak izi kaydı silindi',
  );

  /// [SWREQ-FP-106] GET /Fingerprint/consent/{userId}
  /// `data` boş (null) gelirse rıza yok sayılır.
  Future<Result<bool>> getConsent(int userId) async {
    final res = await fetchRequest<bool>(
      path: '$_base/consent/$userId',
      parser: _consentParser,
      successLog: 'KVKK rıza durumu alındı',
      emptyLog: 'KVKK rızası yok',
    );
    return res.when(ok: (v) => Result.ok(v ?? false), error: Result.error);
  }

  /// [SWREQ-FP-106] POST /Fingerprint/consent
  Future<Result<void>> saveConsent(FingerprintConsentDTO dto) => postRequest<void>(
    path: '$_base/consent',
    body: dto.toJson(),
    parser: BaseRemoteDataSource.voidParser(),
    successLog: 'KVKK rızası kaydedildi',
  );

  /// Zarfın `data` alanı. Swagger'da GET yanıt şeması tanımlı değil; olası şekiller:
  ///   `true` / `false`
  ///   `{ "userId": 1, "consentAt": "..." }` (consentAt doluysa rıza var)
  ///   `{ "isConsented": true }` / `{ "hasConsent": true }`
  // TODO(backend): Yanıt şekli netleşince bu parser sadeleştirilsin.
  static bool? _consentParser(Object? data) => switch (data) {
    null => false,
    bool v => v,
    {'isConsented': bool v} => v,
    {'hasConsent': bool v} => v,
    {'consent': bool v} => v,
    Map<String, dynamic> m => FingerprintConsentDTO.fromJson(m).consentAt != null,
    _ => throw FormatException('Beklenmeyen KVKK rıza yanıtı: ${data.runtimeType}'),
  };
}
