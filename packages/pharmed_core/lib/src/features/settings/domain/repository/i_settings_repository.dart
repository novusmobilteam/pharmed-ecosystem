import 'package:pharmed_core/pharmed_core.dart';

abstract class ISettingsRepository {
  Future<Result<List<SystemParameter>>> getSystemParameters();
  Future<Result<void>> updateSystemParameter(SystemParameter parameter);
}
