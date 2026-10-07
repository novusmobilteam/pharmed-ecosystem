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
}
