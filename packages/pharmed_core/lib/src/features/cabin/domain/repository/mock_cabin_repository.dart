// [SWREQ-SETUP-DATA-002] [IEC 62304 §5.5]
// Mock kabin repository — AppFlavor.mock için.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MockCabinRepository implements ICabinRepository {
  // --- MOCK DATA ---

  static final List<DrawerType> _drawerTypes = [
    const DrawerType(id: 1, name: 'Kübik 4x4', compartmentCount: 16, isKubik: true),
    const DrawerType(id: 2, name: 'Birim Doz 3 Göz', compartmentCount: 3, isKubik: false),
    const DrawerType(id: 3, name: 'Serum Çekmecesi', compartmentCount: 1, isKubik: false),
  ];

  static final List<DrawerConfig> _drawerConfigs = [
    const DrawerConfig(id: 1, drawerTypeId: 1, deviceTypeNo: 1, numberOfSteps: 12), // .01 → Kübik
    const DrawerConfig(id: 2, drawerTypeId: 2, deviceTypeNo: 33, numberOfSteps: 6), // .33 → Standart 5'li
    const DrawerConfig(id: 3, drawerTypeId: 2, deviceTypeNo: 8, numberOfSteps: 6), // .08 → Standart 3'lü
    const DrawerConfig(id: 4, drawerTypeId: 3, deviceTypeNo: 250, numberOfSteps: 1), // .250 → Serum
  ];

  static final List<Cabin> _cabins = [
    Cabin(id: 1, stationId: 1, name: 'Kabin A-01', no: 101, status: Status.active),
    Cabin(id: 2, stationId: 1, name: 'Kabin A-02', no: 102, status: Status.active),
    Cabin(id: 3, stationId: 2, name: 'Kabin B-01', no: 201, status: Status.active),
  ];

  static final List<DrawerSlot> _slots = [
    DrawerSlot(id: 1, cabinId: 1, orderNumber: 1, address: "01", drawerConfigId: 1),
    DrawerSlot(id: 2, cabinId: 1, orderNumber: 2, address: "02", drawerConfigId: 2),
    DrawerSlot(id: 3, cabinId: 2, orderNumber: 1, address: "01", drawerConfigId: 1),
  ];

  // ==================== KABİN İŞLEMLERİ ====================

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Result.ok(_cabins);
  }

  @override
  Future<Result<List<Cabin>>> getCabinsByStation(int stationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final result = _cabins.where((c) => c.stationId == stationId).toList();
    return Result.ok(result);
  }

  @override
  Future<Result<Cabin?>> createCabin(Cabin cabin) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Result.ok(cabin.copyWith(id: 99)); // Mock ID
  }

  @override
  Future<Result<Cabin?>> updateCabin(Cabin cabin) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Result.ok(cabin);
  }

  @override
  Future<Result<void>> deleteCabin(Cabin cabin) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Result.ok(null);
  }

  // ==================== YUVA (SLOT) VE DİZİLİM İŞLEMLERİ ====================

  @override
  Future<Result<List<DrawerSlot>>> getCabinSlots(int cabinId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final result = _slots.where((s) => s.cabinId == cabinId).toList();
    return Result.ok(result);
  }

  @override
  Future<Result<List<DrawerUnit>>> getDrawerUnits(int slotId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Mock: Her slot için 3 unit üretelim
    final units = List.generate(
      3,
      (index) => DrawerUnit(
        id: index + (slotId * 10),
        drawerSlotId: slotId,
        compartmentNo: index + 1,
        orderNo: index + 1,
        workingStatus: CabinWorkingStatus.working,
      ),
    );
    return Result.ok(units);
  }

  @override
  Future<Result<void>> createDrawerSlots(List<DrawerSlot> slots) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> updateDrawerSlots(List<DrawerSlot> slots) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Result.ok(null);
  }

  @override
  Future<Result<List<DrawerSlot>>> getSerumSlots() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Sadece configId'si serum olanları (örneğin 3) filtreleyebiliriz
    return Result.ok(_slots.take(1).toList());
  }

  // ==================== KONFİGÜRASYON & TİP (META VERİLER) ====================

  @override
  Future<Result<List<DrawerType>>> getDrawerTypes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.ok(_drawerTypes);
  }

  @override
  Future<Result<List<DrawerConfig>>> getDrawerConfigs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.ok(_drawerConfigs);
  }
}
