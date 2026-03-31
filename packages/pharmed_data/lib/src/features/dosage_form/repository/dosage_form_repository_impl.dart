import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-DOSAGE-002]
// IDosageFormRepository implementasyonu.
// DTO → entity dönüşümü DosageFormMapper üzerinden yapılır.
// Sınıf: Class B
class DosageFormRepositoryImpl implements IDosageFormRepository {
  const DosageFormRepositoryImpl({required DosageFormRemoteDataSource dataSource, required DosageFormMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final DosageFormRemoteDataSource _dataSource;
  final DosageFormMapper _mapper;

  @override
  Future<Result<ApiResponse<List<DosageForm>>>> getDosageForms({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getDosageForms(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<DosageForm>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createDosageForm(DosageForm entity) async {
    final result = await _dataSource.createDosageForm(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateDosageForm(DosageForm entity) async {
    final result = await _dataSource.updateDosageForm(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteDosageForm(DosageForm entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek sınıfın id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteDosageForm(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
