import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class KitRemoteDataSource extends BaseRemoteDataSource {
  KitRemoteDataSource({required super.apiManager});

  final String _base = '/Kit';

  @override
  String get logSwreq => 'SWREQ-DATA-KIT-001';

  @override
  String get logUnit => 'SW-UNIT-KIT';

  Future<Result<List<KitDto>>> getKits() async {
    final res = await fetchRequest<List<KitDto>>(
      path: _base,
      parser: BaseRemoteDataSource.listParser(KitDto.fromJson),
      successLog: 'Kits fetched',
      emptyLog: 'No kits',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <KitDto>[]), error: Result.error);
  }

  Future<Result<void>> createKit(KitDto dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit oluşturuldu',
    );
  }

  Future<Result<void>> updateKit(KitDto dto) {
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kit güncellendi',
    );
  }

  Future<Result<void>> deleteKit(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Kit silindi');
  }
}
