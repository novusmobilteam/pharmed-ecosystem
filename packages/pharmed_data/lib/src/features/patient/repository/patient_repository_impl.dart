import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PatientRepository implements IPatientRepository {
  PatientRepository({
    required PatientRemoteDataSource dataSource,
    required PatientMapper patientMapper,
    required MyPatientMapper myPatientMapper,
    required UrgentPatientMapper urgentPatientMapper,
    required HospitalizationMapper hospitalizationMapper,
  }) : _dataSource = dataSource,
       _patientMapper = patientMapper,
       _myPatientMapper = myPatientMapper,
       _urgentPatientMapper = urgentPatientMapper,
       _hospitalizationMapper = hospitalizationMapper;

  final PatientRemoteDataSource _dataSource;
  final PatientMapper _patientMapper;
  final MyPatientMapper _myPatientMapper;
  final UrgentPatientMapper _urgentPatientMapper;
  final HospitalizationMapper _hospitalizationMapper;

  @override
  Future<Result<ApiResponse<List<Patient>>>> getPatients({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getPatients(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Patient>>(
          data: apiResponse?.data != null ? _patientMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Patient?>> createPatient(Patient patient) async {
    final result = await _dataSource.createPatient(_patientMapper.toDto(patient));
    return result.when(ok: (dto) => Result.ok(_patientMapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updatePatient(Patient entity) async {
    final result = await _dataSource.updatePatient(_patientMapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deletePatient(Patient entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek hastanın id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deletePatient(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  }) {
    return _dataSource.endEmergencyPatient(
      hospitalizationId: hospitalizationId,
      patientId: patientId,
      prescriptionItemIds: prescriptionItemIds,
    );
  }

  @override
  Future<Result<void>> addPatient(int userId, int hospitalizationId) async {
    final result = await _dataSource.addPatient(userId, hospitalizationId);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<MyPatient>>> getMyPatients() async {
    final result = await _dataSource.getMyPatients();
    return result.when(
      ok: (dtos) => Result.ok(_myPatientMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> removePatient(int id) async {
    final result = await _dataSource.removePatient(id);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> addPatients(List<Map<String, dynamic>> data) async {
    return await _dataSource.addPatiens(data);
  }

  @override
  Future<Result<void>> removePatients(List<int> ids) async {
    return await _dataSource.removePatients(ids);
  }

  @override
  Future<Result<List<Patient>>> getHospitalizedAndRecentExits() async {
    final result = await _dataSource.getHospitalizedAndRecentExits();
    return result.when(ok: (dtos) => Result.ok(_patientMapper.toEntityList(dtos ?? [])), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<UrgentPatient>>> getUrgentPatients() async {
    final result = await _dataSource.getUrgentPatients();
    return result.when(
      ok: (dtos) => Result.ok(_urgentPatientMapper.toEntityList(dtos ?? [])),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Hospitalization?>> createUrgentPatient(int serviceId) async {
    final result = await _dataSource.createUrgentPatient(serviceId);
    return result.when(
      ok: (dto) => Result.ok(_hospitalizationMapper.toEntityOrNull(dto)),
      error: (e) => Result.error(e),
    );
  }
}
