import '../../../hospitalization/data/model/hospitalization_dto.dart';
import '../model/my_patient_dto.dart';

import '../../../../core/core.dart';
import '../model/patient_dto.dart';
import '../model/urgent_patient_dto.dart';
import 'patient_datasource.dart';

class _PatientStore extends BaseLocalDataSource<PatientDTO, int> {
  _PatientStore({required super.filePath})
      : super(
          fromJson: (m) => PatientDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

/// Hasta işlemleri için yerel (Mock) veri kaynağı.
class PatientLocalDataSource implements PatientDataSource {
  final _PatientStore _patientStore;

  PatientLocalDataSource({
    required String assetPath,
  }) : _patientStore = _PatientStore(filePath: assetPath);

  @override
  Future<Result<ApiResponse<List<PatientDTO>>>> getPatients({
    int? skip,
    int? take,
    String? search,
  }) {
    return _patientStore.fetchRequest(
      skip: skip,
      take: take,
      searchText: search,
      searchField: 'name',
    );
  }

  @override
  Future<Result<PatientDTO?>> createPatient(PatientDTO dto) => _patientStore.createRequest(dto);

  @override
  Future<Result<void>> updatePatient(PatientDTO dto) => _patientStore.updateRequest(dto);

  @override
  Future<Result<void>> deletePatient(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> endEmergencyPatient({
    required int hospitalizationId,
    required int patientId,
    required List<int> prescriptionItemIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> addPatient(int userId, int hospitalizationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<List<MyPatientDTO>>> getMyPatients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok([]);
  }

  @override
  Future<Result<void>> removePatient(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> addPatiens(List<Map<String, dynamic>> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<void>> removePatients(List<int> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(null);
  }

  @override
  Future<Result<List<PatientDTO>>> getHospitalizedAndRecentExits() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok([]);
  }

  @override
  Future<Result<List<UrgentPatientDTO>>> getUrgentPatients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok([]);
  }

  @override
  Future<Result<HospitalizationDTO>> createUrgentPatient(int serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(HospitalizationDTO());
  }
}
