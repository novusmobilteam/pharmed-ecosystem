import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-ASSIGNMENT-002]
// ICabinAssignmentRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B
class AssignmentRepository implements IAssignmentRepository {
  AssignmentRepository({
    required AssignmentRemoteDataSource dataSource,
    required MedicineAssignmentMapper medicineAssignmentMapper,
    required PatientAssignmentMapper patientAssignmentMapper,
  }) : _dataSource = dataSource,
       _medicineAssignmentMapper = medicineAssignmentMapper,
       _patientAssignmentMapper = patientAssignmentMapper;

  final AssignmentRemoteDataSource _dataSource;
  final MedicineAssignmentMapper _medicineAssignmentMapper;
  final PatientAssignmentMapper _patientAssignmentMapper;

  @override
  Future<Result<List<MedicineAssignment>>> getMedicineAssignments(int cabinId) async {
    final result = await _dataSource.getMedicineAssignments(cabinId);
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createMedicineAssignment(MedicineAssignment entity) async {
    final dto = entity.toDTO();
    final result = await _dataSource.createMedicineAssignment(dto);

    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteMedicineAssignment(int id) async {
    final result = await _dataSource.deleteMedicineAssignment(id);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateMedicineAssignment(MedicineAssignment entity) async {
    final dto = entity.toDTO();
    final result = await _dataSource.updateMedicineAssignment(dto);

    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<MedicineAssignment>>> getMaterialAssignment(int materialId) async {
    final result = await _dataSource.getMaterialAssignment(materialId);
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MedicineAssignment>>> getCabinAssignments() async {
    final result = await _dataSource.getCabinAssignments();
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MedicineAssignment>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final result = await _dataSource.getCabinAssignmentsWithCabinId(cabinId);
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MedicineAssignment>>> getIndependentMaterials() async {
    final result = await _dataSource.getIndependentMaterials();
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<MedicineAssignment>>> getOrderlessCabinAssignments() async {
    final result = await _dataSource.getOrderlessCabinAssignments();
    return result.when(
      ok: (data) => Result.ok(_medicineAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createPatientAssignment({required int cellId, required int bedId}) async {
    final result = await _dataSource.createPatientAssignment(cellId: cellId, bedId: bedId);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PatientAssignment>>> getPatientAssignments(int cabinId) async {
    final result = await _dataSource.getPatientAssignments(cabinId);
    return result.when(
      ok: (data) => Result.ok(_patientAssignmentMapper.toEntityList(data)),
      error: (e) => Result.error(e),
    );
  }
}
