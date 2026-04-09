import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-KIT-002]
// IKitRepository implementasyonu.
// DTO → entity dönüşümü KitMapper üzerinden yapılır.
// Sınıf: Class B
class KitRepositoryImpl implements IKitRepository {
  KitRepositoryImpl({required KitRemoteDataSource dataSource, required KitMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final KitRemoteDataSource _dataSource;
  final KitMapper _mapper;

  @override
  Future<Result<List<Kit>>> getKits() async {
    final result = await _dataSource.getKits();
    return result.when(ok: (stationDto) => Result.ok(_mapper.toEntityList(stationDto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> createKit(Kit entity) async {
    final result = await _dataSource.createKit(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateKit(Kit entity) async {
    final result = await _dataSource.updateKit(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteKit(Kit entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek kitin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteKit(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
