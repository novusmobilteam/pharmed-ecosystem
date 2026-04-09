import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class KitContentRemoteDataSource extends BaseRemoteDataSource {
  KitContentRemoteDataSource({required super.apiManager});

  final String _base = '/KitContent';

  @override
  String get logSwreq => 'SWREQ-DATA-KITCONTENT-001';

  @override
  String get logUnit => 'SW-UNIT-KITCONTENT ';

  Future<Result<List<KitContentDto>>> getKitContent(int kitId) async {
    final result = await fetchRequest<List<KitContentDto>>(
      path: '$_base/byKit/$kitId',
      parser: BaseRemoteDataSource.listParser(KitContentDto.fromJson),
      successLog: 'Kit content fetched',
      emptyLog: 'No kits',
    );
    return result.when(ok: (data) => Result.ok(data ?? const <KitContentDto>[]), error: Result.error);
  }

  Future<Result<KitContentDto?>> createKitContent(KitContentDto dto) {
    return createRequest<KitContentDto?>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.singleParser(KitContentDto.fromJson),
      successLog: 'Kit content created',
    );
  }

  Future<Result<void>> deleteKitContent(int id) {
    return deleteRequest<void>(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit content deleted',
    );
  }

  Future<Result<void>> updateKitContent(KitContentDto dto) {
    return updateRequest<void>(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit updated',
    );
  }
}
