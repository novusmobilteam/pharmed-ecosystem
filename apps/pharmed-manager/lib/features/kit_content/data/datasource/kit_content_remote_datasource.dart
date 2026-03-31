import '../../../../core/core.dart';
import '../model/kit_content_dto.dart';
import 'kit_content_datasource.dart';

class KitContentRemoteDataSource extends BaseRemoteDataSource implements KitContentDataSource {
  final String _basePath = '/Kit/content';

  KitContentRemoteDataSource({required super.apiManager});

  @override
  Future<Result<KitContentDTO?>> createKitContent(KitContentDTO dto) {
    return createRequest<KitContentDTO?>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(KitContentDTO.fromJson),
      successLog: 'Kit content created',
    );
  }

  @override
  Future<Result<void>> deleteKitContent(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit content deleted',
    );
  }

  @override
  Future<Result<List<KitContentDTO>>> getKitContent(int kitId) async {
    final res = await fetchRequest<List<KitContentDTO>>(
      path: '$_basePath/byKit/$kitId',
      parser: BaseRemoteDataSource.listParser(KitContentDTO.fromJson),
      successLog: 'Kit content fetched',
      emptyLog: 'No kits',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <KitContentDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> updateKitContent(KitContentDTO dto) {
    return updateRequest<void>(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit updated',
    );
  }

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();
}
