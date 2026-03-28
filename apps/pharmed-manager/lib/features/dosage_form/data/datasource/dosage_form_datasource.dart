import '../../../../core/core.dart';
import '../model/dosage_form_dto.dart';

abstract class DosageFormDataSource {
  Future<Result<ApiResponse<List<DosageFormDTO>>>> getDosageForms({
    int? skip,
    int? take,
    String? search,
  });

  Future<Result<DosageFormDTO?>> createDosageForm(DosageFormDTO dto);
  Future<Result<DosageFormDTO?>> updateDosageForm(DosageFormDTO dto);
  Future<Result<void>> deleteDosageForm(int id);
}
