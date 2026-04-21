// pharmed_data/src/cabin/repository/mock/cabin_mock_repository.dart
//
// [SWREQ-DATA-CABIN-003] [IEC 62304 §5.5]
// Mock flavor için kabin repository'si.
// API/Hive'a çıkılmaz, sabit veriler döner.
// Read metodları her zaman RepoSuccess döndürür.
// Sınıf: Class A

import 'package:pharmed_core/pharmed_core.dart';

class CabinMockRepository implements ICabinRepository {
  static const _delay = Duration(milliseconds: 400);

  // ── Mock Veri ─────────────────────────────────────────────────

  final List<Cabin> _mockCabins = [
    Cabin(id: 1, name: 'CB-304', type: CabinType.master, status: Status.active, comPort: ComPort.com3),
    Cabin(id: 2, name: 'MB-101', type: CabinType.mobile, status: Status.active),
  ];

  final List<DrawerType> _mockTypes = [
    const DrawerType(id: 1, name: 'Kübik 4×4', compartmentCount: 16, isKubik: true),
    const DrawerType(id: 2, name: 'Kübik 4×5', compartmentCount: 20, isKubik: true),
    const DrawerType(id: 3, name: 'Birim Doz 3 Göz', compartmentCount: 3, isKubik: false),
    const DrawerType(id: 4, name: 'Birim Doz 5 Göz', compartmentCount: 5, isKubik: false),
    const DrawerType(id: 5, name: 'Serum', compartmentCount: 1, isKubik: false), // ← serum
  ];

  final List<DrawerConfig> _mockConfigs = [
    const DrawerConfig(id: 1, drawerTypeId: 1, numberOfSteps: 16, deviceTypeNo: 1),
    const DrawerConfig(id: 2, drawerTypeId: 2, numberOfSteps: 20, deviceTypeNo: 2),
    const DrawerConfig(id: 3, drawerTypeId: 3, numberOfSteps: 3, deviceTypeNo: 33),
    const DrawerConfig(id: 4, drawerTypeId: 4, numberOfSteps: 5, deviceTypeNo: 8),
    const DrawerConfig(id: 5, drawerTypeId: 5, numberOfSteps: 1, deviceTypeNo: 250), // ← serum
  ];

  final List<DrawerSlot> _mockSlots = [
    DrawerSlot(
      id: 1,
      cabinId: 1,
      orderNumber: 1,
      address: '01',
      drawerConfigId: 1,
      drawerConfig: DrawerConfig(
        id: 1,
        drawerTypeId: 1,
        numberOfSteps: 16,
        deviceTypeNo: 1,
        drawerType: const DrawerType(id: 1, name: 'Kübik 4×4', compartmentCount: 16, isKubik: true),
      ),
    ),
    DrawerSlot(
      id: 3,
      cabinId: 1,
      orderNumber: 3,
      address: '03',
      drawerConfigId: 3,
      drawerConfig: DrawerConfig(
        id: 3,
        drawerTypeId: 3,
        numberOfSteps: 3,
        deviceTypeNo: 33,
        drawerType: const DrawerType(id: 3, name: 'Birim Doz 3 Göz', compartmentCount: 3, isKubik: false),
      ),
    ),
    DrawerSlot(
      id: 4,
      cabinId: 1,
      orderNumber: 4,
      address: '04',
      drawerConfigId: 3,
      drawerConfig: DrawerConfig(
        id: 3,
        drawerTypeId: 3,
        numberOfSteps: 3,
        deviceTypeNo: 33,
        drawerType: const DrawerType(id: 3, name: 'Birim Doz 3 Göz', compartmentCount: 3, isKubik: false),
      ),
    ),

    DrawerSlot(
      id: 6,
      cabinId: 1,
      orderNumber: 6,
      address: '06',
      drawerConfigId: 5,
      drawerConfig: DrawerConfig(
        id: 5,
        drawerTypeId: 5,
        numberOfSteps: 1,
        deviceTypeNo: 250,
        drawerType: const DrawerType(id: 5, name: 'Serum', compartmentCount: 1, isKubik: false),
      ),
    ),
  ];

  // ── Kabin CRUD ─────────────────────────────────────────────────

  @override
  Future<RepoResult<List<Cabin>>> getCabins() async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_mockCabins));
  }

  @override
  Future<RepoResult<List<Cabin>>> getCabinsByStation(int stationId) async {
    await Future.delayed(_delay);
    return RepoSuccess(_mockCabins.where((c) => c.stationId == stationId).toList());
  }

  @override
  Future<Result<Cabin?>> createCabin(Cabin cabin) async {
    await Future.delayed(_delay);
    final newCabin = cabin.copyWith(id: _mockCabins.length + 1);
    _mockCabins.add(newCabin);
    return Result.ok(newCabin);
  }

  @override
  Future<Result<Cabin?>> updateCabin(Cabin cabin) async {
    await Future.delayed(_delay);
    final index = _mockCabins.indexWhere((c) => c.id == cabin.id);
    if (index == -1) {
      return Result.error(const NotFoundException(message: 'Kabin bulunamadı', resourceType: 'Cabin'));
    }
    _mockCabins[index] = cabin;
    return Result.ok(cabin);
  }

  @override
  Future<Result<void>> deleteCabin(Cabin cabin) async {
    await Future.delayed(_delay);
    _mockCabins.removeWhere((c) => c.id == cabin.id);
    return const Result.ok(null);
  }

  // ── Yuva (Slot) & Unit ─────────────────────────────────────────

  @override
  Future<RepoResult<List<DrawerSlot>>> getCabinSlots(int cabinId) async {
    await Future.delayed(_delay);
    return RepoSuccess(_mockSlots);
  }

  @override
  Future<RepoResult<List<MobileDrawerSlot>>> getMobileCabinSlots(int cabinId) async {
    return RepoSuccess(const []);
  }

  @override
  Future<RepoResult<List<DrawerUnit>>> getDrawerUnits(int slotId) async {
    await Future.delayed(_delay);
    final slot = _mockSlots.cast<DrawerSlot?>().firstWhere((s) => s?.id == slotId, orElse: () => null);
    if (slot == null) return RepoSuccess([]);

    final type = slot.drawerConfig?.drawerType;
    final count = type?.compartmentCount ?? 4;

    final units = List.generate(
      count,
      (i) => DrawerUnit(
        id: slotId * 1000 + i, // slot 1 → 1000–1015, slot 3 → 3000–3002
        drawerSlotId: slotId,
        compartmentNo: i + 1,
      ),
    );
    return RepoSuccess(units);
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots) async {
    await Future.delayed(_delay);
    for (var i = 0; i < slots.length; i++) {
      _mockSlots.add(slots[i].copyWith(id: _mockSlots.length + i + 1));
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> createMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> updateMobileDrawerSlots(List<MobileDrawerRequestDTO> drawers) async {
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots) async {
    await Future.delayed(_delay);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<DrawerSlot>>> getSerumSlots() async {
    await Future.delayed(_delay);
    return const Result.ok([]);
  }

  // ── Meta Veri ──────────────────────────────────────────────────

  @override
  Future<RepoResult<List<DrawerConfig>>> getDrawerConfigs({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_mockConfigs));
  }

  @override
  Future<RepoResult<List<DrawerType>>> getDrawerTypes({bool forceRefresh = false}) async {
    await Future.delayed(_delay);
    return RepoSuccess(List.unmodifiable(_mockTypes));
  }

  @override
  Future<RepoResult<Cabin?>> getCabin(int cabinId) async {
    await Future.delayed(_delay);
    return RepoSuccess(null);
  }
}
