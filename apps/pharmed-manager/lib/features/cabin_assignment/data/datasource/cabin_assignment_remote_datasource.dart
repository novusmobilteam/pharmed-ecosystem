import '../../../../core/core.dart';
import '../model/cabin_assignment_dto.dart';
import 'cabin_assignment_datasource.dart';

class CabinAssignmentRemoteDataSource extends BaseRemoteDataSource implements CabinAssignmentDataSource {
  final String _basePath = '/CabinDrawrQuantity';

  CabinAssignmentRemoteDataSource({required super.apiManager});

  /// Belirtilen kabine ait miktar listesini sunucudan çeker.
  @override
  Future<Result<List<CabinAssignmentDTO>>> getAssignments(int cabinId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/cabin/$cabinId',
      parser: listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Cabin Drawer Quantities fetched',
      emptyLog: 'No quantities found',
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }

  /// Yeni bir miktar kaydını sunucuya gönderir.
  @override
  Future<Result<void>> createAssignment(CabinAssignmentDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Cabin drawer quantity created',
    );
  }

  /// Bir miktar kaydını sunucudan siler.
  @override
  Future<Result<void>> deleteAssignment(int id) {
    return deleteRequest<void>(
      path: '$_basePath/cabinDrawr/$id',
      parser: voidParser(),
      successLog: 'Quantity deleted',
    );
  }

  /// Miktar kaydını günceller.
  @override
  Future<Result<void>> updateAssignment(CabinAssignmentDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Quantity updated',
    );
  }

  /// Materyal ID'sine göre açık kabin miktarını getirir.
  @override
  Future<Result<List<CabinAssignmentDTO>>> getMaterialAssignment(int materialId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/openCabinForMaterial/$materialId',
      parser: listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Material Quantity fetched',
      emptyLog: 'No Quantity',
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }

  /// Kabindeki materyalleri getirir
  @override
  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignments() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/cabinInMaterials',
      parser: listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/cabinInMaterials/$cabinId',
      parser: listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getIndependentMaterials() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/cabinInMaterialsIndependent',
      parser: listParser(CabinAssignmentDTO.fromJson),
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<List<CabinAssignmentDTO>>> getOrderlessCabinAssignments() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_basePath/cabinInMaterialsOrderless',
      parser: listParser(CabinAssignmentDTO.fromJson),
    );

    return res.when(
      ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]),
      error: Result.error,
    );
  }
}
