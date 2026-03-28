import '../../../../core/core.dart';
import '../entity/dosage_form.dart';

abstract class IDosageFormRepository {
  Future<Result<ApiResponse<List<DosageForm>>>> getDosageForms({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<void>> createDosageForm(DosageForm entity);
  Future<Result<void>> updateDosageForm(DosageForm entity);
  Future<Result<void>> deleteDosageForm(int id);
}
