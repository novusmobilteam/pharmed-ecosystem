import '../../../../core/core.dart';
import '../../domain/entity/hospitalization.dart';
import '../../domain/repository/i_hospitalization_repository.dart';
import '../datasource/hospitalization_datasource.dart';

class HospitalizationRepository implements IHospitalizationRepository {
  final HospitalizationDataSource _ds;

  HospitalizationRepository(this._ds);

  @override
  Future<Result<ApiResponse<List<Hospitalization>>>> getHospitalizations({int? skip, int? take, String? search}) async {
    final r = await _ds.getHospitalizations(
      skip: skip,
      take: take,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<Hospitalization> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<Hospitalization>>(
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
  Future<Result<void>> createHospitalization(Hospitalization item) async {
    final dto = item.toDTO();
    final r = await _ds.createHospitalization(dto);
    return r.when(
      ok: Result.ok,
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateHospitalization(Hospitalization item) async {
    final dto = item.toDTO();
    final r = await _ds.updateHospitalization(dto);
    return r.when(
      ok: Result.ok,
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> deleteHospitalization(Hospitalization item) async {
    final id = item.id;
    if (id == null) return Result.error(CustomException(message: 'deletePatientHospitalization: id is null'));

    final r = await _ds.deleteHospitalization(id);
    return r.when(
      ok: (_) => Result.ok(null),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<Hospitalization>>> getHospitalizationsWithPrescription() async {
    final r = await _ds.getHospitalizationsWithPrescription();
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
  Future<Result<List<Hospitalization>>> getPatientsWithActivePrescription() async {
    final r = await _ds.getPatientsWithActivePrescription();
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
  Future<Result<List<Hospitalization>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final r = await _ds.getFilteredHospitalizations(filter);
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
  Future<Result<List<Hospitalization>>> getHospitalizationsByService(int serviceId) async {
    final r = await _ds.getHospitalizationsByService(serviceId);
    return r.when(
      ok: (list) {
        final entities = list.map((e) => e.toEntity()).toList();
        return Result.ok(entities);
      },
      error: Result.error,
    );
  }
}
