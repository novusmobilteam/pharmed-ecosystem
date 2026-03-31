import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-ASSIGNMENT-002]
// ICabinAssignmentRepository implementasyonu.
// DTO → entity dönüşümü SttionMapper üzerinden yapılır.
// Sınıf: Class B
class CabinAssignmentRepository implements ICabinAssignmentRepository {
  CabinAssignmentRepository({
    required CabinAssignmentRemoteDataSource dataSource,
    required CabinAssignmentMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  final CabinAssignmentRemoteDataSource _dataSource;
  final CabinAssignmentMapper _mapper;

  @override
  Future<Result<List<CabinAssignment>>> getAssignments(int cabinId) async {
    final result = await _dataSource.getAssignments(cabinId);
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> createAssignment(CabinAssignment entity) async {
    final dto = entity.toDTO();
    final result = await _dataSource.createAssignment(dto);

    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteAssignment(int id) async {
    final result = await _dataSource.deleteAssignment(id);
    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateAssignment(CabinAssignment entity) async {
    final dto = entity.toDTO();
    final result = await _dataSource.updateAssignment(dto);

    return result.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getMaterialAssignment(int materialId) async {
    final result = await _dataSource.getMaterialAssignment(materialId);
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getCabinAssignments() async {
    final result = await _dataSource.getCabinAssignments();
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final result = await _dataSource.getCabinAssignmentsWithCabinId(cabinId);
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getIndependentMaterials() async {
    final result = await _dataSource.getIndependentMaterials();
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getOrderlessCabinAssignments() async {
    final result = await _dataSource.getOrderlessCabinAssignments();
    return result.when(ok: (data) => Result.ok(_mapper.toEntityList(data)), error: (e) => Result.error(e));
  }
}
