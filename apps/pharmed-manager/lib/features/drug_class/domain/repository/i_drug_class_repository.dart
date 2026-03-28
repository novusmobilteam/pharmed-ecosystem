import '../../../../core/core.dart';
import '../entity/drug_class.dart';

abstract class IDrugClassRepository {
  Future<Result<ApiResponse<List<DrugClass>>>> getDrugClasses({int? skip, int? take, String? search});
  Future<Result<void>> createDrugClass(DrugClass entity);
  Future<Result<void>> updateDrugClass(DrugClass entity);
  Future<Result<void>> deleteDrugClass(DrugClass entity);
}
