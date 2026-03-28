import '../../../../core/core.dart';
import '../model/warning_dto.dart';

abstract class WarningDataSource {
  Future<Result<List<WarningDTO>>> getWarnings();
  Future<Result<void>> createWarning(WarningDTO dto);
  Future<Result<void>> updateWarning(WarningDTO dto);
  Future<Result<void>> deleteWarning(int id);
}
