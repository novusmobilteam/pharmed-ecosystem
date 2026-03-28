import '../../../../core/core.dart';
import '../../domain/entity/cabin_assignment.dart';
import '../../domain/repository/i_cabin_assignment_repository.dart';
import '../datasource/cabin_assignment_datasource.dart';

class CabinAssignmentRepository implements ICabinAssignmentRepository {
  final CabinAssignmentDataSource _ds;

  CabinAssignmentRepository(this._ds);

  @override
  Future<Result<List<CabinAssignment>>> getAssignments(int cabinId) async {
    final r = await _ds.getAssignments(cabinId);
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createAssignment(CabinAssignment entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createAssignment(dto);

    return res.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteAssignment(int id) async {
    final res = await _ds.deleteAssignment(id);
    return res.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateAssignment(CabinAssignment entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateAssignment(dto);

    return res.when(ok: (_) => Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinAssignment>>> getMaterialAssignment(int materialId) async {
    final r = await _ds.getMaterialAssignment(materialId);
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignment>>> getCabinAssignments() async {
    final r = await _ds.getCabinAssignments();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignment>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final r = await _ds.getCabinAssignmentsWithCabinId(cabinId);
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignment>>> getIndependentMaterials() async {
    final r = await _ds.getIndependentMaterials();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignment>>> getOrderlessCabinAssignments() async {
    final r = await _ds.getOrderlessCabinAssignments();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }
}
