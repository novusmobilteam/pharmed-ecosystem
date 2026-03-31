import '../../../../core/core.dart';
import '../model/warning_dto.dart';
import 'warning_datasource.dart';

class WarningRemoteDataSource extends BaseRemoteDataSource implements WarningDataSource {
  WarningRemoteDataSource({required super.apiManager});

  final String _basePath = '/Warning';

  @override
  // TODO: implement logSwreq
  String get logSwreq => throw UnimplementedError();

  @override
  // TODO: implement logUnit
  String get logUnit => throw UnimplementedError();

  @override
  Future<Result<List<WarningDTO>>> getWarnings() async {
    final res = await fetchRequest<List<WarningDTO>>(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(WarningDTO.fromJson),
      successLog: 'Warnings fetched',
      emptyLog: 'No warnings',
    );
    return res.when(ok: (data) => Result.ok(data ?? const <WarningDTO>[]), error: Result.error);
  }

  @override
  Future<Result<void>> createWarning(WarningDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Warning created',
    );
  }

  @override
  Future<Result<void>> updateWarning(WarningDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Warning updated',
    );
  }

  @override
  Future<Result<void>> deleteWarning(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Warning deleted',
    );
  }
}
