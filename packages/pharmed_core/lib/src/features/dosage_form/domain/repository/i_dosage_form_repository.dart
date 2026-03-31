import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract class IDosageFormRepository {
  Future<Result<ApiResponse<List<DosageForm>>>> getDosageForms({int? skip, int? take, String? search});

  Future<Result<void>> createDosageForm(DosageForm entity);
  Future<Result<void>> updateDosageForm(DosageForm entity);
  Future<Result<void>> deleteDosageForm(DosageForm entity);
}
