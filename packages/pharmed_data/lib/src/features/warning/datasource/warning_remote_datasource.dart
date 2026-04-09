import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WarningRemoteDataSource extends BaseRemoteDataSource {
  WarningRemoteDataSource({required super.apiManager});

  final String _base = '/Warning';

  @override
  String get logSwreq => 'SWREQ-DATA-WARNING-001';

  @override
  String get logUnit => 'SW-UNIT-WARNING';

  Future<Result<List<WarningDto>>> getWarnings() async {
    final result = await fetchRequest<List<WarningDto>>(
      path: _base,
      parser: BaseRemoteDataSource.listParser(WarningDto.fromJson),
      successLog: 'Warnings fetched',
      emptyLog: 'No warnings',
    );
    return result.when(ok: (data) => Result.ok(data ?? const <WarningDto>[]), error: Result.error);
  }

  Future<Result<void>> createWarning(WarningDto dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Uyarı oluşturuldu',
    );
  }

  Future<Result<void>> updateWarning(WarningDto dto) {
    return updateRequest(
      path: '$_base/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Uyarı güncellendi',
    );
  }

  Future<Result<void>> deleteWarning(int id) {
    return deleteRequest<void>(
      path: '$_base/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Uyarı silindi',
    );
  }
}
