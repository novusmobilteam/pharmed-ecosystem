import '../../../../core/core.dart';
import '../../domain/entity/cabin_temperature.dart';
import '../../domain/entity/cabin_temperature_detail.dart';
import '../datasource/cabin_temperature_datasource.dart';
import 'cabin_temperature_repository.dart';

class CabinTemperatureRepository implements ICabinTemperatureRepository {
  final CabinTemperatureDataSource _ds;

  CabinTemperatureRepository._(this._ds);

  /// Production: remote data source
  factory CabinTemperatureRepository.prod({required CabinTemperatureDataSource remote}) =>
      CabinTemperatureRepository._(remote);

  /// Development: local data source
  factory CabinTemperatureRepository.dev({required CabinTemperatureDataSource local}) =>
      CabinTemperatureRepository._(local);

  @override
  Future<Result<List<CabinTemperature>>> getCabinTemperatures() async {
    final res = await _ds.getCabinTemperatures();

    return res.when(
      ok: (response) {
        List<CabinTemperature> entities = [];
        if (response.data != null) {
          entities = response.data!.map((d) => d.toEntity()).toList();
        }

        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinTemperatureDetail>>> getCabinTemperatureDetails(int stationId) async {
    final res = await _ds.getCabinTemperatureDetails(stationId);
    return res.when(
      ok: (list) {
        final entities = list.map((d) => d.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }

  @override
  Future<Result<CabinTemperature>> createCabinTemperature(CabinTemperature entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createCabinTemperature(dto);

    return res.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<CabinTemperatureDetail?>> createCabinTemperatureDetail(CabinTemperatureDetail entity) async {
    final dto = entity.toDTO();
    final res = await _ds.createCabinTemperatureDetail(dto);

    return res.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> deleteCabinTemperatureDetail(CabinTemperatureDetail entity) async {
    final id = entity.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deleteCabinTemperature: id is null'));
    }

    final res = await _ds.deleteCabinTemperatureDetail(id);
    return res.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<CabinTemperatureDetail?>> updateCabinTemperatureDetail(CabinTemperatureDetail entity) async {
    final dto = entity.toDTO();
    final res = await _ds.updateCabinTemperatureDetail(dto);

    return res.when(
      ok: (created) {
        final data = (created ?? dto).toEntity();
        return Result.ok(data);
      },
      error: (e) => Result.error(e),
    );
  }
}
