// lib/feature/cabin_stock/data/datasource/remote/cabin_stock_remote_datasource.dart
//
// [SWREQ-DS-REMOTE-001]
// APIManager üzerinden çalışır.
// Sorumluluk: path, parser ve input validasyonu.
// Exception mapping, logging → APIManager'da.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../dto/cabin_stock_dto.dart';
import '../dto/station_stock_dto.dart';
import 'cabin_stock_datasource.dart';

class CabinStockRemoteDataSource implements CabinStockDataSource {
  const CabinStockRemoteDataSource({required this.apiManager});

  final APIManager apiManager;

  static const String _base = '/CabinDrawrStock';

  // ── Yardımcı parser'lar ───────────────────────────────────────

  static List<CabinStockDTO> _parseList(dynamic data) =>
      (data as List).map((e) => CabinStockDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  static List<StationStockDTO> _parseStationList(dynamic data) =>
      (data as List).map((e) => StationStockDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  // ── Okuma işlemleri ───────────────────────────────────────────

  // [SWREQ-DS-001] [HAZ-003] [HAZ-007]
  @override
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    if (cabinId <= 0) {
      MedLogger.warn(
        unit: 'SW-UNIT-DS',
        swreq: 'SWREQ-DS-001',
        message: 'Geçersiz cabinId',
        context: {'cabinId': cabinId},
      );
      return Result.error(
        ValidationException(message: 'cabinId sıfır veya negatif olamaz', field: 'cabinId', value: cabinId),
      );
    }

    return apiManager.get('$_base/allMaterial/$cabinId', parser: _parseList);
  }

  // [SWREQ-DS-002] [HAZ-003]
  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() {
    return apiManager.get('$_base/currentStationStock', parser: _parseList);
  }

  // [SWREQ-DS-003] [HAZ-003]
  @override
  Future<Result<CabinStockDTO>> getMedicineInfo(int medicineId) async {
    if (medicineId <= 0) {
      MedLogger.warn(
        unit: 'SW-UNIT-DS',
        swreq: 'SWREQ-DS-003',
        message: 'Geçersiz medicineId',
        context: {'medicineId': medicineId},
      );
      return Result.error(
        ValidationException(message: 'medicineId sıfır veya negatif olamaz', field: 'medicineId', value: medicineId),
      );
    }

    final result = await apiManager.get<CabinStockDTO>(
      '$_base/materialInfo/$medicineId',
      parser: (data) {
        if (data == null) {
          throw NotFoundException(message: 'İlaç kabine atanmamış', id: medicineId, resourceType: 'Medicine');
        }
        return CabinStockDTO.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );

    // Parser'dan fırlayan NotFoundException → MalformedDataException içinde gelir,
    // wrap'ten çıkarıp doğrudan ilet
    if (result.isError) {
      final error = (result as Error<CabinStockDTO>).error;
      if (error is MalformedDataException && error.cause is NotFoundException) {
        return Result.error(error.cause! as NotFoundException);
      }
    }

    return result;
  }

  // [SWREQ-DS-004] [HAZ-008]
  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() {
    return apiManager.get('$_base/expirationDate/14', parser: _parseList);
  }

  // [SWREQ-DS-008] [HAZ-008]
  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() {
    return apiManager.get('$_base/report/expiredMiadDate', parser: _parseList);
  }

  // [SWREQ-DS-009] [HAZ-003]
  @override
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async {
    if (stationId <= 0) {
      MedLogger.warn(
        unit: 'SW-UNIT-DS',
        swreq: 'SWREQ-DS-009',
        message: 'Geçersiz stationId',
        context: {'stationId': stationId},
      );
      return Result.error(
        ValidationException(message: 'stationId sıfır veya negatif olamaz', field: 'stationId', value: stationId),
      );
    }

    return apiManager.get('$_base/stock/$stationId', parser: _parseStationList);
  }

  // ── Yazma işlemleri ───────────────────────────────────────────

  // [SWREQ-DS-005] [HAZ-005]
  @override
  Future<Result<void>> count(List<dynamic> data) async {
    if (data.isEmpty) {
      return Result.error(ValidationException(message: 'Sayım verisi boş olamaz', field: 'data'));
    }

    return apiManager.patch('$_base/censusQuantity', data: data.map((e) => (e as dynamic).toJson()).toList());
  }

  // [SWREQ-DS-006] [HAZ-004]
  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    if (data.isEmpty) {
      return Result.error(ValidationException(message: 'Dolum verisi boş olamaz', field: 'data'));
    }

    return apiManager.post(_base, data: data.map((e) => (e as dynamic).toJson()).toList());
  }

  // [SWREQ-DS-007] [HAZ-006]
  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      return Result.error(ValidationException(message: 'Boşaltma verisi boş olamaz', field: 'data'));
    }

    return apiManager.post('$_base/emptying', data: data);
  }
}
