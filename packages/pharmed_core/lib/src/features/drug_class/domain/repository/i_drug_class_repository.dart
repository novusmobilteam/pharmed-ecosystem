import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IDrugClassRepository {
  Future<Result<ApiResponse<List<DrugClass>>>> getDrugClasses({int? skip, int? take, String? search});
  Future<Result<void>> createDrugClass(DrugClass entity);
  Future<Result<void>> updateDrugClass(DrugClass entity);
  Future<Result<void>> deleteDrugClass(DrugClass entity);
}
