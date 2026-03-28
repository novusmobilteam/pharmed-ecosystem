import '../../../../core/core.dart';
import '../model/warning_dto.dart';
import 'warning_datasource.dart';

class WarningRemoteDataSource extends BaseRemoteDataSource implements WarningDataSource {
  final String _basePath = '/Warning';

  WarningRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<WarningDTO>>> getWarnings() async {
    final res = await fetchRequest<List<WarningDTO>>(
      path: _basePath,
      parser: listParser(WarningDTO.fromJson),
      successLog: 'Warnings fetched',
      emptyLog: 'No warnings',
    );
    return res.when(
      ok: (data) => Result.ok(data ?? const <WarningDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> createWarning(WarningDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Warning created',
    );
  }

  @override
  Future<Result<void>> updateWarning(WarningDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'Warning updated',
    );
  }

  @override
  Future<Result<void>> deleteWarning(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'Warning deleted',
    );
  }
}
