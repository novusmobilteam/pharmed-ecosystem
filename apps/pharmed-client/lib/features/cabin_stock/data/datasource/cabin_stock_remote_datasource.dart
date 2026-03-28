// lib/feature/cabin_stock/data/datasource/remote/cabin_stock_remote_datasource.dart
//
// [SWREQ-DS-REMOTE-001]
// NetworkManager üzerinden çalışır.
// Sorumluluk: path, parser ve input validasyonu.
// Exception mapping, logging → NetworkManager'da.
// Sınıf: Class B

import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:result_dart/result_dart.dart';

import '../../../../../core/network/network_manager.dart';
import '../../../../../core/exception/app_exceptions.dart';
import '../dto/cabin_stock_dto.dart';
import '../dto/station_stock_dto.dart';
import 'cabin_stock_datasource.dart';

class CabinStockRemoteDataSource implements CabinStockDataSource {
  const CabinStockRemoteDataSource({required this.networkManager});

  final NetworkManager networkManager;

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
      return Failure(
        ValidationException(message: 'cabinId sıfır veya negatif olamaz', field: 'cabinId', value: cabinId),
      );
    }

    return networkManager.get(NetworkRequest(path: '$_base/allMaterial/$cabinId', swreq: 'SWREQ-DS-001'), _parseList);
  }

  // [SWREQ-DS-002] [HAZ-003]
  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() {
    return networkManager.get(
      const NetworkRequest(path: '$_base/currentStationStock', swreq: 'SWREQ-DS-002'),
      _parseList,
    );
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
      return Failure(
        ValidationException(message: 'medicineId sıfır veya negatif olamaz', field: 'medicineId', value: medicineId),
      );
    }

    // Servis null döndürebilir → NotFoundException'a çevir
    final result = await networkManager.get<CabinStockDTO>(
      NetworkRequest(path: '$_base/materialInfo/$medicineId', swreq: 'SWREQ-DS-003'),
      (data) {
        if (data == null) {
          throw NotFoundException(message: 'İlaç kabine atanmamış', id: medicineId, resourceType: 'Medicine');
        }
        return CabinStockDTO.fromJson(Map<String, dynamic>.from(data as Map));
      },
    );

    // Parser'dan fırlayan NotFoundException → MalformedData değil,
    // doğrudan Failure olarak iletilmeli
    return result.fold(Success.new, (error) {
      if (error is MalformedDataException && error.cause is NotFoundException) {
        return Failure(error.cause! as NotFoundException);
      }
      return Failure(error);
    });
  }

  // [SWREQ-DS-004] [HAZ-008]
  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() {
    return networkManager.get(
      const NetworkRequest(path: '$_base/expirationDate/14', swreq: 'SWREQ-DS-004'),
      _parseList,
    );
  }

  // [SWREQ-DS-008] [HAZ-008]
  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() {
    return networkManager.get(
      const NetworkRequest(path: '$_base/report/expiredMiadDate', swreq: 'SWREQ-DS-008'),
      _parseList,
    );
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
      return Failure(
        ValidationException(message: 'stationId sıfır veya negatif olamaz', field: 'stationId', value: stationId),
      );
    }

    return networkManager.get(
      NetworkRequest(path: '$_base/stock/$stationId', swreq: 'SWREQ-DS-009'),
      _parseStationList,
    );
  }

  // ── Yazma işlemleri ───────────────────────────────────────────

  // [SWREQ-DS-005] [HAZ-005]
  @override
  Future<Result<void>> count(List<dynamic> data) async {
    if (data.isEmpty) {
      return Failure(ValidationException(message: 'Sayım verisi boş olamaz', field: 'data'));
    }

    return networkManager.patch(
      NetworkRequest(
        path: '$_base/censusQuantity',
        swreq: 'SWREQ-DS-005',
        body: data.map((e) => (e as dynamic).toJson()).toList(),
      ),
    );
  }

  // [SWREQ-DS-006] [HAZ-004]
  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    if (data.isEmpty) {
      return Failure(ValidationException(message: 'Dolum verisi boş olamaz', field: 'data'));
    }

    return networkManager.post(
      NetworkRequest(path: _base, swreq: 'SWREQ-DS-006', body: data.map((e) => (e as dynamic).toJson()).toList()),
    );
  }

  // [SWREQ-DS-007] [HAZ-006]
  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      return Failure(ValidationException(message: 'Boşaltma verisi boş olamaz', field: 'data'));
    }

    return networkManager.post(NetworkRequest(path: '$_base/emptying', swreq: 'SWREQ-DS-007', body: data));
  }
}
