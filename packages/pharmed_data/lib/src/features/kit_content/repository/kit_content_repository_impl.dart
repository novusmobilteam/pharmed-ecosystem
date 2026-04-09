import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-KITCONTENT -002]
// IKitContentRepository implementasyonu.
// DTO → entity dönüşümü KitContentMapper üzerinden yapılır.
// Sınıf: Class B

class KitContentRepositoryImpl implements IKitContentRepository {
  KitContentRepositoryImpl({required KitContentRemoteDataSource dataSource, required KitContentMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final KitContentRemoteDataSource _dataSource;
  final KitContentMapper _mapper;

  @override
  Future<Result<List<KitContent>>> getKitContent(int id, {bool forceRefresh = true}) async {
    final result = await _dataSource.getKitContent(id);
    return result.when(ok: (stationDto) => Result.ok(_mapper.toEntityList(stationDto)), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> createKitContent(KitContent entity) async {
    final result = await _dataSource.createKitContent(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> updateKitContent(KitContent entity) async {
    final result = await _dataSource.updateKitContent(_mapper.toDto(entity));
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }

  @override
  Future<Result<void>> deleteKitContent(KitContent entity) async {
    if (entity.id == null) {
      return Result.error(ValidationException(message: "Silinecek kit içeriğinin id'si boş olamaz", field: 'id'));
    }
    final result = await _dataSource.deleteKitContent(entity.id!);
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
