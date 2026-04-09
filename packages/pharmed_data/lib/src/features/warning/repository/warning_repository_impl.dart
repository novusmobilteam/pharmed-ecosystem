// [SWREQ-DATA-WARNING-002]
// IWarningRepository implementasyonu.
// DTO → entity dönüşümü WarningMapper üzerinden yapılır.
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class WarningRepositoryImpl implements IWarningRepository {
  WarningRepositoryImpl({required WarningRemoteDataSource dataSource, required WarningMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final WarningRemoteDataSource _dataSource;
  final WarningMapper _mapper;

  @override
  Future<Result<List<Warning>>> getWarnings() async {
    final result = await _dataSource.getWarnings();
    return result.when(ok: (warningDto) => Result.ok(_mapper.toEntityList(warningDto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> createWarning(Warning entity) async {
    final result = await _dataSource.createWarning(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateWarning(Warning entity) async {
    final result = await _dataSource.updateWarning(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteWarning(Warning entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek uyarının id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteWarning(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
