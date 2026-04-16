import 'package:pharmed_core/pharmed_core.dart';

class MockCabinStockRepository implements ICabinStockRepository {
  static const _delay = Duration(milliseconds: 800);

  // JSON'daki gerçek yapıya uygun mock data
  static final _mockStocks = [
    CabinStock(
      id: 256,
      cabinId: 1,
      quantity: 25.0,
      miadDate: DateTime.now().add(const Duration(days: 30)),
      medicine: Drug(id: 27, name: 'PARACEROL 10 MG', barcode: '1234345'),
      assignment: MedicineAssignment(cabinDrawerId: 1, minQuantity: 10, criticalQuantity: 30, maxQuantity: 200),
      cabinDrawerDetail: DrawerCell(
        id: 1731,
        stepNo: 1,
        drawerUnit: DrawerUnit(id: 1000, drawerSlotId: 1, compartmentNo: 1), // slot 1, unit 0
      ),
    ),
    CabinStock(
      id: 246,
      cabinId: 1,
      quantity: 1.0,
      miadDate: DateTime.now().add(const Duration(days: 3)),
      medicine: Drug(id: 30, name: 'Xanax', barcode: '5672824512'),
      assignment: MedicineAssignment(cabinDrawerId: 3, minQuantity: 5, criticalQuantity: 7, maxQuantity: 12),
      cabinDrawerDetail: DrawerCell(
        id: 1747,
        stepNo: 1,
        drawerUnit: DrawerUnit(id: 3000, drawerSlotId: 3, compartmentNo: 1), // slot 3, unit 0
      ),
    ),
    CabinStock(
      id: 264,
      cabinId: 1,
      quantity: 1.0,
      miadDate: DateTime.now().subtract(const Duration(days: 2)),
      medicine: Drug(id: 27, name: 'PARACEROL 10 MG', barcode: '1234345'),
      assignment: MedicineAssignment(cabinDrawerId: 3, minQuantity: 1, criticalQuantity: 6, maxQuantity: 12),
      cabinDrawerDetail: DrawerCell(
        id: 1763,
        stepNo: 2,
        drawerUnit: DrawerUnit(id: 3001, drawerSlotId: 3, compartmentNo: 2), // slot 3, unit 1
      ),
    ),
  ];

  @override
  Future<RepoResult<List<CabinStock>>> getCurrentCabinStock() async {
    await Future.delayed(_delay);
    return RepoSuccess(_mockStocks);
  }

  @override
  Future<Result<List<CabinStock>>> getStocks(int cabinId) async {
    await Future.delayed(_delay);
    return Result.ok(_mockStocks.where((s) => s.cabinId == cabinId).toList());
  }

  @override
  Future<Result<CabinStock?>> getMedicineInfo(int medicineId) async {
    await Future.delayed(_delay);
    final stock = _mockStocks.cast<CabinStock?>().firstWhere((s) => s?.medicine?.id == medicineId, orElse: () => null);
    return Result.ok(stock);
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringStocks() async {
    await Future.delayed(_delay);
    final expiring = _mockStocks.where((s) => (s.daysUntilExpiration) <= 30).toList();
    return Result.ok(expiring);
  }

  @override
  Future<Result<List<CabinStock>>> getExpiredStocks() async {
    await Future.delayed(_delay);
    final expired = _mockStocks.where((s) => s.daysUntilExpiration < 0).toList();
    return Result.ok(expired);
  }

  @override
  Future<Result<void>> count(List<dynamic> data) async {
    await Future.delayed(_delay);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> fill(List<dynamic> data) async {
    await Future.delayed(_delay);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> unload(List<Map<String, dynamic>> data) async {
    await Future.delayed(_delay);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<StationStock>>> getStationStocks(int stationId) async {
    await Future.delayed(_delay);
    return Result.ok([]);
  }
}
