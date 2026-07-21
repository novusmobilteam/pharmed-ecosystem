import 'package:pharmed_core/pharmed_core.dart';

import '../settings.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  SettingsRepositoryImpl({required SettingsRemoteDataSource dataSource, required SystemParameterMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final SettingsRemoteDataSource _dataSource;
  final SystemParameterMapper _mapper;

  @override
  Future<Result<List<SystemParameter>>> getSystemParameters() async {
    final res = await _dataSource.getSystemParameters();

    return res.when(ok: (list) => Result.ok(_mapper.toEntityList(list)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateSystemParameter(SystemParameter parameter) async {
    return _dataSource.updateSystemParameter(_mapper.toDto(parameter));
  }
}
