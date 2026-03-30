import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/src/network/base_remote_datasource.dart';

// [SWREQ-DATA-ASSIGNMENT-001]
// Sınıf: Class B
class CabinAssignmentRemoteDataSource extends BaseRemoteDataSource {
  CabinAssignmentRemoteDataSource({required super.apiManager});

  static const _base = '/CabinDrawrQuantity';

  String get logSwreq => 'SWREQ-DATA-ASSIGNMENT-001';

  String get logUnit => 'SW-UNIT-ASSIGNMENT';

  /// Belirtilen kabine ait atamaları çeker.
  Future<Result<List<CabinAssignmentDTO>>> getAssignments(int cabinId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/cabin/$cabinId',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Atamalar getirildi',
      emptyLog: 'Atama bulunamadı',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  Future<Result<void>> createAssignment(CabinAssignmentDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Atama oluşturuldu',
    );
  }

  Future<Result<void>> deleteAssignment(int id) {
    return deleteRequest<void>(
      path: '$_base/cabinDrawr/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Quantity deleted',
    );
  }

  Future<Result<void>> updateAssignment(CabinAssignmentDTO dto) {
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Quantity updated',
    );
  }

  Future<Result<List<CabinAssignmentDTO>>> getMaterialAssignment(int materialId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/openCabinForMaterial/$materialId',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Material Quantity fetched',
      emptyLog: 'No Quantity',
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignments() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/cabinInMaterials',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  Future<Result<List<CabinAssignmentDTO>>> getCabinAssignmentsWithCabinId(int cabinId) async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/cabinInMaterials/$cabinId',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
      successLog: 'Cabin Materials fetched',
      emptyLog: 'No material',
      envelope: ResponseEnvelope.auto,
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  Future<Result<List<CabinAssignmentDTO>>> getIndependentMaterials() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/cabinInMaterialsIndependent',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }

  Future<Result<List<CabinAssignmentDTO>>> getOrderlessCabinAssignments() async {
    final res = await fetchRequest<List<CabinAssignmentDTO>>(
      path: '$_base/cabinInMaterialsOrderless',
      parser: BaseRemoteDataSource.listParser(CabinAssignmentDTO.fromJson),
    );

    return res.when(ok: (list) => Result.ok(list ?? const <CabinAssignmentDTO>[]), error: Result.error);
  }
}
