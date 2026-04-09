import 'package:pharmed_core/pharmed_core.dart';

abstract class IWarningRepository {
  Future<Result<List<Warning>>> getWarnings();
  Future<Result<void>> createWarning(Warning entity);
  Future<Result<void>> updateWarning(Warning entity);
  Future<Result<void>> deleteWarning(Warning entity);
}
