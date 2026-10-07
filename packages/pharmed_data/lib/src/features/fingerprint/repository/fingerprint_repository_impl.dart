import 'package:pharmed_core/pharmed_core.dart';

import '../datasource/fingerprint_remote_datasource.dart';
import '../mapper/fingerprint_mapper.dart';

/// [SWREQ-DATA-FP-002] Gerçek servis repository'si (FingerprintApi.isAvailable = true olunca).
class FingerprintRepositoryImpl implements IFingerprintRepository {
  const FingerprintRepositoryImpl({
    required FingerprintRemoteDataSource dataSource,
    FingerprintMapper mapper = const FingerprintMapper(),
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final FingerprintRemoteDataSource _dataSource;
  final FingerprintMapper _mapper;

  @override
  Future<Result<void>> enroll(FingerprintEnrollmentRequest request) =>
      _dataSource.enroll(_mapper.toEnrollDto(request));

  @override
  Future<Result<List<EnrolledFinger>>> getEnrolledFingers() async {
    final r = await _dataSource.getEnrolledFingers();
    return r.when(ok: (dtos) => Result.ok(_mapper.toEnrolledFingerList(dtos)), error: Result.error);
  }

  @override
  Future<Result<void>> deleteFinger(FingerPosition position) => _dataSource.deleteFinger(position.isoCode);
}
