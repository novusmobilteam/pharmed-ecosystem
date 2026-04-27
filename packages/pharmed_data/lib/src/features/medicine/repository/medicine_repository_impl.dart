import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-MEDICINE-002]
// IMedicineRepository implementasyonu.
// DTO → entity dönüşümü MedicineMapper üzerinden yapılır.
// Sınıf: Class B
class MedicineRepositoryImpl implements IMedicineRepository {
  MedicineRepositoryImpl({
    required MedicineRemoteDataSource dataSource,
    required MedicineMapper mapper,
    required DrugMapper drugMapper,
    required MedicalConsumableMapper mcMapper,
  }) : _dataSource = dataSource,
       _mapper = mapper,
       _drugMapper = drugMapper,
       _mcMapper = mcMapper;

  final MedicineRemoteDataSource _dataSource;
  final MedicineMapper _mapper;
  final DrugMapper _drugMapper;
  final MedicalConsumableMapper _mcMapper;

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getMedicines({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getMedicines(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Medicine>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Drug>>>> getDrugs({int? skip, int? take, String? search}) async {
    final result = await _dataSource.getDrugs(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Drug>>(
          data: apiResponse?.data != null ? _drugMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<MedicalConsumable>>>> getMedicalConsumables({
    int? skip,
    int? take,
    String? search,
  }) async {
    final result = await _dataSource.getMedicalConsumables(skip: skip, take: take, search: search);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<MedicalConsumable>>(
          data: apiResponse?.data != null ? _mcMapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<ApiResponse<List<Medicine>>>> getEquivalentMedicines(int id) async {
    final result = await _dataSource.getEquivalentMedicines(id);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Medicine>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<Drug?>> getDrug(int id) async {
    final result = await _dataSource.getDrug(id);
    return result.when(
      ok: (dto) {
        print(dto?.toJson().toString());
        return Result.ok(_drugMapper.toEntityOrNull(dto));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createMedicine(Medicine entity) async {
    final result = await _dataSource.createMedicine(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateMedicine(Medicine entity) async {
    final result = await _dataSource.updateMedicine(_mapper.toDto(entity));
    print(_mapper.toDto(entity).toJson());
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteMedicine(Medicine entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek servisin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteMedicine(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
