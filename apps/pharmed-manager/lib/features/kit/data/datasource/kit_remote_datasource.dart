import '../../../../core/core.dart';
import '../model/kit_dto.dart';
import 'kit_datasource.dart';

class KitRemoteDataSource extends BaseRemoteDataSource implements KitDataSource {
  final String _basePath = '/Kit';

  KitRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<KitDTO>>> getKits() async {
    final res = await fetchRequest<List<KitDTO>>(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(KitDTO.fromJson),
      successLog: 'Kits fetched',
      emptyLog: 'No kits',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <KitDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> createKit(KitDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit created',
    );
  }

  @override
  Future<Result<void>> updateKit(KitDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit updated',
    );
  }

  @override
  Future<Result<void>> deleteKit(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit deleted',
    );
  }

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();
}
