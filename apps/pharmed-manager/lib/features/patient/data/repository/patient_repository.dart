import '../../../hospitalization/domain/entity/hospitalization.dart';
import '../../domain/entity/my_patient.dart';

import '../../../../core/core.dart';
import '../../domain/entity/patient.dart';
import '../../domain/entity/urgent_patient.dart';
import '../../domain/repository/i_patient_repository.dart';
import '../datasource/patient_datasource.dart';

class PatientRepository implements IPatientRepository {
  final PatientDataSource _ds;

  PatientRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Patient>>>> getPatients({
    int? skip,
    int? take,
    String? search,
  }) async {
    final r = await _ds.getPatients(
      skip: skip,
      take: take,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<Patient> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Patient>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Patient>> createPatient(Patient patient) async {
    final dto = patient.toDTO(); // entity -> dto
    final r = await _ds.createPatient(dto);
    return r.when(
      ok: (savedDto) {
        // API geri dönüşü varsa onu kullan, yoksa elimizdeki entity'i ekle
        final entity = (savedDto ?? dto).toEntity();
        return Result.ok(entity);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updatePatient(Patient patient) async {
    final dto = patient.toDTO();
    final r = await _ds.updatePatient(dto);
    return r.when(
      ok: Result.ok,
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> deletePatient(Patient patient) async {
    final id = patient.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deletePatient: id is null'));
    }
    final r = await _ds.deletePatient(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  }) {
    return _ds.endEmergencyPatient(
      hospitalizationId: hospitalizationId,
      patientId: patientId,
      prescriptionItemIds: prescriptionItemIds,
    );
  }

  @override
  Future<Result<void>> addPatient(int userId, int hospitalizationId) async {
    final r = await _ds.addPatient(userId, hospitalizationId);
    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MyPatient>>> getMyPatients() async {
    final r = await _ds.getMyPatients();
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<void>> removePatient(int id) async {
    final r = await _ds.removePatient(id);
    return r.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> addPatients(List<Map<String, dynamic>> data) async {
    return await _ds.addPatiens(data);
  }

  @override
  Future<Result<void>> removePatients(List<int> ids) async {
    return await _ds.removePatients(ids);
  }

  @override
  Future<Result<List<Patient>>> getHospitalizedAndRecentExits() async {
    final r = await _ds.getHospitalizedAndRecentExits();
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<List<UrgentPatient>>> getUrgentPatients() async {
    final r = await _ds.getUrgentPatients();
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<Hospitalization?>> createUrgentPatient(int serviceId) async {
    final r = await _ds.createUrgentPatient(serviceId);
    return r.when(
      ok: (data) {
        return Result.ok(data?.toEntity());
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }
}
