import '../../../../../core/core.dart';
import '../../model/system_parameter_dto.dart';

abstract class SettingsDataSource {
  Future<Result<List<SystemParameterDTO>>> getSystemParameters();
  Future<Result<void>> updateSystemParameter(SystemParameterDTO parameter);
}
