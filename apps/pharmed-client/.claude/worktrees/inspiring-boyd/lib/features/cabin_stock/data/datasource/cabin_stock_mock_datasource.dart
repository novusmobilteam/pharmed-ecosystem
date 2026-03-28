// lib/feature/cabin_stock/data/datasource/mock/cabin_stock_mock_datasource.dart
//
// [SWREQ-CORE-003]
// Mock flavor için tamamen sahte veri kaynağı.
// Servise hiç çıkılmaz. Ağ gecikmesi simüle edilir.
// UI geliştirme ve demo için kullanılır.
//
// Mock veri tasarım kuralları:
// 1. Tüm stok durumlarını kapsa (full, low, critical, empty)
// 2. SKT yaklaşan ve geçmiş ilaçlar içersin
// 3. Hem başarı hem hata senaryoları test edilebilsin
// 4. Gerçekçi hastane verisi (ilaç adları, lot numaraları)

import 'package:result_dart/result_dart.dart';

import '../../../../core/exception/app_exceptions.dart';
import '../../domain/model/cabin_stock.dart';
import '../dto/cabin_stock_dto.dart';
import '../dto/station_stock_dto.dart';
import 'cabin_stock_datasource.dart';

class CabinStockMockDataSource implements CabinStockDataSource {
  // Simüle edilecek gecikme — UI geliştirmede gerçekçi hissi verir
  static const _delay = Duration(milliseconds: 600);

  // ── Mock veri bankası ─────────────────────────────────────────

  static final List<CabinStockDTO> _mockStocks = [
    CabinStockDTO(
      id: 1,
      cabinId: 304,
      drawerId: 1,
      drawerCode: 'A-01',
      medicineName: 'Amoksisilin 500mg',
      medicineId: 101,
      quantity: 24,
      criticalLevel: 5,
      lotNumber: 'AMK2024A',
      expiryDate: DateTime(2026, 8, 15),
      stockStatus: StockStatus.full.toString(),
    ),
    CabinStockDTO(
      id: 2,
      cabinId: 304,
      drawerId: 2,
      drawerCode: 'A-02',
      medicineName: 'Metformin 1000mg',
      medicineId: 102,
      quantity: 18,
      criticalLevel: 5,
      lotNumber: 'MET2024B',
      expiryDate: DateTime(2026, 11, 20),
      stockStatus: StockStatus.full.toString(),
    ),
    CabinStockDTO(
      id: 3,
      cabinId: 304,
      drawerId: 3,
      drawerCode: 'A-03',
      medicineName: 'Omeprazol 20mg',
      medicineId: 103,
      quantity: 12,
      criticalLevel: 5,
      lotNumber: 'OMP2024C',
      expiryDate: DateTime(2026, 5, 10),
      stockStatus: StockStatus.full.toString(),
    ),
    CabinStockDTO(
      id: 4,
      cabinId: 304,
      drawerId: 4,
      drawerCode: 'A-04',
      medicineName: 'Heparin 5000 IU',
      medicineId: 104,
      quantity: 3,
      criticalLevel: 5,
      lotNumber: 'HEP2024D',
      expiryDate: DateTime(2026, 4, 10), // 15 gün kaldı → warning
      stockStatus: StockStatus.low.toString(),
    ),
    CabinStockDTO(
      id: 5,
      cabinId: 304,
      drawerId: 5,
      drawerCode: 'B-02',
      medicineName: 'İnsülin Glarjin 100 IU',
      medicineId: 105,
      quantity: 2,
      criticalLevel: 3,
      lotNumber: 'INS2024E',
      expiryDate: DateTime(2026, 3, 29), // 3 gün kaldı → critical
      stockStatus: StockStatus.critical.toString(),
    ),
    CabinStockDTO(
      id: 6,
      cabinId: 304,
      drawerId: 6,
      drawerCode: 'A-12',
      medicineName: 'Serum Fizyolojik 0.9%',
      medicineId: 106,
      quantity: 6,
      criticalLevel: 4,
      lotNumber: 'SF22A',
      expiryDate: DateTime(2026, 3, 20), // geçmiş SKT → expired
      stockStatus: StockStatus.full.toString(),
    ),
    CabinStockDTO(
      id: 7,
      cabinId: 304,
      drawerId: 7,
      drawerCode: 'C-01',
      medicineName: null, // boş çekmece
      medicineId: null,
      quantity: 0,
      criticalLevel: 0,
      lotNumber: null,
      expiryDate: null,
      stockStatus: StockStatus.empty.toString(),
    ),
    CabinStockDTO(
      id: 8,
      cabinId: 304,
      drawerId: 8,
      drawerCode: 'B-11',
      medicineName: 'Metronidazol 500mg IV',
      medicineId: 108,
      quantity: 12,
      criticalLevel: 5,
      lotNumber: 'MTR2024H',
      expiryDate: DateTime(2026, 4, 2), // 7 gün kaldı → critical
      stockStatus: StockStatus.full.toString(),
    ),
  ];

  static final List<CabinStockDTO> _mockExpiringStocks = _mockStocks
      .where(
        (s) =>
            s.expiryDate != null &&
            s.expiryDate!.isAfter(DateTime.now()) &&
            s.expiryDate!.difference(DateTime.now()).inDays <= 30,
      )
      .toList();

  static final List<CabinStockDTO> _mockExpiredStocks = _mockStocks
      .where((s) => s.expiryDate != null && s.expiryDate!.isBefore(DateTime.now()))
      .toList();

  // ── Interface implementasyonu ────────────────────────────────

  @override
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    await Future.delayed(_delay);
    final filtered = _mockStocks.where((s) => s.cabinId == cabinId).toList();
    return Success(filtered);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async {
    await Future.delayed(_delay);
    return Success(_mockStocks);
  }

  @override
  Future<Result<CabinStockDTO>> getMedicineInfo(int medicineId) async {
    await Future.delayed(_delay);
    final found = _mockStocks.where((s) => s.medicineId == medicineId).firstOrNull;

    if (found == null) {
      return Failure(NotFoundException(message: 'İlaç kabine atanmamış', id: medicineId, resourceType: 'Medicine'));
    }

    return Success(found);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() async {
    await Future.delayed(_delay);
    return Success(_mockExpiringStocks);
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() async {
    await Future.delayed(_delay);
    return Success(_mockExpiredStocks);
  }

  @override
  Future<Result<void>> count(List<dynamic> data) async {
    await Future.delayed(_delay);
    // Mock'ta sayım sessizce başarılı döner
    return const Success(unit);
  }

  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    await Future.delayed(_delay);
    return const Success(unit);
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    await Future.delayed(_delay);
    return const Success(unit);
  }

  @override
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async {
    await Future.delayed(_delay);
    return Success(<StationStockDTO>[]);
  }
}

// ─────────────────────────────────────────────────────────────────
// CabinStockMockErrorDataSource — hata senaryolarını test etmek için
// Mock flavor'da error state'leri görmek gerektiğinde inject edilir.
// ─────────────────────────────────────────────────────────────────

class CabinStockMockErrorDataSource implements CabinStockDataSource {
  @override
  Future<Result<List<CabinStockDTO>>> getStocks(int cabinId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Failure(NetworkUnavailableException(message: 'Mock: Ağ bağlantısı yok'));
  }

  @override
  Future<Result<List<CabinStockDTO>>> getCurrentCabinStock() async =>
      Failure(NetworkUnavailableException(message: 'Mock: Sunucuya ulaşılamıyor'));

  @override
  Future<Result<CabinStockDTO>> getMedicineInfo(int medicineId) async =>
      Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<List<CabinStockDTO>>> getExpiringStocks() async =>
      Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<List<CabinStockDTO>>> getExpiredStocks() async =>
      Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<void>> count(List<dynamic> data) async => Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<void>> fill(List<dynamic> data) async => Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async =>
      Failure(NetworkUnavailableException(message: 'Mock error'));

  @override
  Future<Result<List<StationStockDTO>>> getStationStocks(int stationId) async =>
      Failure(NetworkUnavailableException(message: 'Mock error'));
}
