import '../../model/system_parameter_dto.dart';

import '../../../../../core/core.dart';
import 'settings_data_source.dart';

class SettingsRemoteDataSource extends BaseRemoteDataSource implements SettingsDataSource {
  SettingsRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<SystemParameterDTO>>> getSystemParameters() async {
    final res = await fetchRequest<List<SystemParameterDTO>>(
      path: '/SystemParameter',
      parser: listParser(SystemParameterDTO.fromJson),
      successLog: 'System parameters fetched',
      emptyLog: 'No System parameters',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <SystemParameterDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateSystemParameter(SystemParameterDTO parameter) {
    final id = parameter.id ?? 0;
    return updateRequest(
      path: '/SystemParameter/$id',
      body: parameter.toJson(),
      parser: voidParser(),
      successLog: 'Parameter updated successfully',
    );
  }
}
