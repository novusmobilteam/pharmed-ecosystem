import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IDrugTypeRepository {
  Future<Result<ApiResponse<List<DrugType>>>> getDrugTypes({int? skip, int? take, String? search});
  Future<Result<void>> createDrugType(DrugType entity);
  Future<Result<void>> updateDrugType(DrugType entity);
  Future<Result<void>> deleteDrugType(DrugType entity);
}
