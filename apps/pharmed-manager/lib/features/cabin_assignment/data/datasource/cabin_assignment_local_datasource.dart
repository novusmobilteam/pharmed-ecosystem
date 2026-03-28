import '../../../../core/core.dart';
import '../model/cabin_assignment_dto.dart';
import 'cabin_assignment_datasource.dart';

class _CabinAssignmentStor extends BaseLocalDataSource<CabinAssignmentDTO, int> {
  _CabinAssignmentStor({required super.filePath})
      : super(
          fromJson: (m) => CabinAssignmentDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => d.copyWith(id: id),
        );
}

class CabinAssignmentLocalDataSource implements CabinAssignmentDataSource {
  final _CabinAssignmentStor _store;

  CabinAssignmentLocalDataSource({required String assetPath}) : _store = _CabinAssignmentStor(filePath: assetPath);

  @override
  Future<Result<List<CabinAssignmentDTO>>> getAssignments(int cabinId) async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createAssignment(CabinAssignmentDTO dto) async {
    final res = await _store.createRequest(dto);
    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteAssignment(int id) async {
    final res = await _store.deleteRequest(id);
    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateAssignment(CabinAssignmentDTO dto) async {
    final res = await _store.updateRequest(dto);
    return res.when(
      ok: (_) => Result.ok(null),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getMaterialAssignment(int materialId) async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignments() async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getIndependentMaterials() async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getOrderlessCabinAssignments() async {
    final res = await _store.fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }
}
