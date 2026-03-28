import '../../../../core/core.dart';
import '../model/hospitalization_dto.dart';
import 'hospitalization_datasource.dart';

class _HospitalizationStore extends BaseLocalDataSource<HospitalizationDTO, int> {
  _HospitalizationStore({required super.filePath})
      : super(
          fromJson: (m) => HospitalizationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

/// Hasta Yatış işlemleri için yerel (Mock) veri kaynağı.
class HospitalizationLocalDataSource implements HospitalizationDataSource {
  final _HospitalizationStore _hospitalizationStore;

  HospitalizationLocalDataSource({
    required String hospitalizationPath,
    required String emergencyPath,
  }) : _hospitalizationStore = _HospitalizationStore(filePath: hospitalizationPath);

  @override
  Future<Result<HospitalizationDTO?>> createHospitalization(HospitalizationDTO dto) =>
      _hospitalizationStore.createRequest(dto);

  @override
  Future<Result<void>> deleteHospitalization(int id) => _hospitalizationStore.deleteRequest(id);

  @override
  Future<Result<ApiResponse<List<HospitalizationDTO>>>> getHospitalizations({
    int? skip,
    int? take,
    String? search,
  }) {
    return _hospitalizationStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'patientName',
    );
  }

  @override
  Future<Result<HospitalizationDTO?>> updateHospitalization(HospitalizationDTO dto) async {
    return _hospitalizationStore.createRequest(dto);
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsWithPrescription() async {
    final res = await _hospitalizationStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getPatientsWithActivePrescription() async {
    final res = await _hospitalizationStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getFilteredHospitalizations(PatientFilterType filter) async {
    final res = await _hospitalizationStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<HospitalizationDTO>>> getHospitalizationsByService(int serviceId) async {
    final res = await _hospitalizationStore.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }
}
