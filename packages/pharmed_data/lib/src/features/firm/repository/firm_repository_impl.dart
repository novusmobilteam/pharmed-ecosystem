import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// [SWREQ-DATA-FIRM-002]
// IFirmRepository implementasyonu.
// DTO → entity dönüşümü BranchMapper üzerinden yapılır.
// Sınıf: Class B
class FirmRepositoryImpl implements IFirmRepository {
  const FirmRepositoryImpl({required FirmRemoteDataSource dataSource, required FirmMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final FirmRemoteDataSource _dataSource;
  final FirmMapper _mapper;

  @override
  Future<Result<ApiResponse<List<Firm>>>> getFirms({int? skip, int? take, String? searchQuery}) async {
    final result = await _dataSource.getFirms(skip: skip, take: take, searchQuery: searchQuery);
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<Firm>>(
          data: apiResponse?.data != null ? _mapper.toEntityList(apiResponse!.data!) : null,
          isSuccess: apiResponse?.isSuccess ?? true,
          totalCount: apiResponse?.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createFirm(Firm entity) async {
    final result = await _dataSource.createFirm(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateFirm(Firm entity) async {
    final result = await _dataSource.updateFirm(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteFirm(Firm entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: contextlessL10n().dataGuard_deleteFirmIdEmpty, field: 'id'));
    }
    final result = await _dataSource.deleteFirm(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
