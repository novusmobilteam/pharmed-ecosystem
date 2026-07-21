import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class SettingsRemoteDataSource extends BaseRemoteDataSource {
  SettingsRemoteDataSource({required super.apiManager});

  @override
  String get logSwreq => 'SWREQ-DATA-SETTINGS-001';

  @override
  String get logUnit => 'SW-UNIT-SETTINGS';

  Future<Result<List<SystemParameterDTO>>> getSystemParameters() async {
    final res = await fetchRequest<List<SystemParameterDTO>>(
      path: '/SystemParameter',
      parser: BaseRemoteDataSource.listParser(SystemParameterDTO.fromJson),
      successLog: 'System parameters fetched',
      emptyLog: 'No System parameters',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <SystemParameterDTO>[]), error: Result.error);
  }

  Future<Result<void>> updateSystemParameter(SystemParameterDTO parameter) {
    final id = parameter.id ?? 0;
    return putRequest(
      path: '/SystemParameter/$id',
      body: parameter.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Parameter updated successfully',
    );
  }
}
