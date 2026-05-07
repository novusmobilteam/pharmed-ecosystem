// apps/pharmed-client/lib/core/hardware/service/mock_cabin_operation_service.dart
//
// [SWREQ-HW-001] [IEC 62304 §5.5]
// Kabin operasyon servisi — mock implementasyon.
//
// KAPSAM:
//   Fiziksel cihaz olmadan çekmece açma/kapama ve tarama akışını simüle eder.
//   Mock flavor'da (main_mock.dart) kullanılır.
//
// SİMÜLASYON DAVRANIŞI:
//   scanManagementCard        : 500ms sonra adres 1'de kart bulur
//   discoverControlCards      : 1s sonra 4 kart döner (kübik, 5'li, 3'lü, serum)
//   getMobileDrawerStatus      : fullyOpen döner, triggerManualClose ile locked
//   openMobileDrawer          : 500ms gecikme, başarılı
//   streamMobileDrawerStatus  : 2s fullyOpen → triggerManualClose ile locked
//   openMasterDrawer          : 1s gecikme, başarılı
//   streamMasterDrawerStatus  : 2s locked → fullyOpen → triggerManualClose ile locked
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

class MockCabinOperationService implements ICabinOperationService {
  bool _shouldFastForward = false;
  int _statusPollCount = 0;

  @override
  void triggerManualClose() {
    _shouldFastForward = true;
    debugPrint('MOCK: Manuel kapatma tetiklendi.');
  }

  // ════════════════════════════════════════════════════════════════
  // YÖNETİM KARTI
  // ════════════════════════════════════════════════════════════════

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    return scanManagementCard();
  }

  @override
  Future<ManagementCard?> scanManagementCard() async {
    debugPrint('MOCK: Yönetim kartı taranıyor...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: ✅ Yönetim kartı bulundu: Adres 1 (a)');
    return const ManagementCard(addressIndex: 1);
  }

  // ════════════════════════════════════════════════════════════════
  // KONTROL KARTLARI (MASTER KABİN)
  // ════════════════════════════════════════════════════════════════

  @override
  Future<List<ControlCard>> discoverControlCards(ManagementCard manager) async {
    debugPrint('MOCK: Kontrol kartları taranıyor...');
    await Future.delayed(const Duration(seconds: 1));

    return [
      ControlCard(rowAddress: 2, rawTypeResponse: '.01,'), // Kübik
      ControlCard(rowAddress: 3, rawTypeResponse: '.33,'), // Standart 5'li
      ControlCard(rowAddress: 4, rawTypeResponse: '.08,'), // Standart 3'lü
      ControlCard(rowAddress: 5, rawTypeResponse: '.250,'), // Serum
    ];
  }

  // ════════════════════════════════════════════════════════════════
  // MOBİL KABİN — ÇEKMECE OPERASYONLARI
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> openMobileDrawer({required ManagementCard manager, required int port}) async {
    debugPrint('MOCK: Mobil çekmece port $port açılıyor...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: ✅ Mobil çekmece port $port AÇILDI 🔓');
  }

  @override
  Future<DrawerPhysicalStatus> getMobileDrawerStatus({required ManagementCard manager, required int port}) async {
    // Mock: her zaman fullyOpen döner (dolum akışında test için)
    await Future.delayed(const Duration(milliseconds: 100));
    return _shouldFastForward ? DrawerPhysicalStatus.locked : DrawerPhysicalStatus.fullyOpen;
  }

  @override
  Stream<DrawerPhysicalStatus> streamMobileDrawerStatus({required ManagementCard manager, required int port}) async* {
    _shouldFastForward = false;

    // Başlangıç: kilit açıldı, kullanıcı henüz kapatmadı
    yield DrawerPhysicalStatus.fullyOpen;
    debugPrint('MOCK SENSOR (Mobil Port $port): Çekmece açık, kapatılması bekleniyor...');

    int elapsed = 0;
    while (elapsed < 60000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR (Mobil Port $port): Çekmece kapandı 🔒');
    yield DrawerPhysicalStatus.locked;
  }

  // ════════════════════════════════════════════════════════════════
  // MASTER KABİN — ÇEKMECE OPERASYONLARI
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> openMasterDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async {
    debugPrint('MOCK: Master çekmece açılıyor (row:$row, port:$port, drawer:$drawer)...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('MOCK: ✅ Master çekmece AÇILDI 🔓');
  }

  @override
  Future<void> openMasterCubicDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  }) async {
    debugPrint('MOCK: Kübik kapak açılıyor (row:$row, port:$port, lid:$lidIndex)...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: ✅ Kübik kapak AÇILDI 🔓');
  }

  @override
  Stream<DrawerPhysicalStatus> streamMasterDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async* {
    _shouldFastForward = false;
    _statusPollCount = 0;

    yield DrawerPhysicalStatus.locked;
    await Future.delayed(const Duration(seconds: 2));
    if (_shouldFastForward) return;

    debugPrint('MOCK SENSOR (Master row:$row): Kullanıcı çekmeceyi çekti!');
    yield DrawerPhysicalStatus.fullyOpen;

    int elapsed = 0;
    while (elapsed < 60000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR (Master row:$row): Çekmece kapandı 🔒');
    yield DrawerPhysicalStatus.locked;
  }

  @override
  Future<void> openMasterSerumDrawer({required ManagementCard manager, required int row}) async {
    debugPrint('MOCK: Master serum çekmecesi açılıyor (row:$row)...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: ✅ Master serum çekmecesi AÇILDI 🔓');
  }

  @override
  Stream<DrawerPhysicalStatus> streamMasterSerumDrawerStatus({
    required ManagementCard manager,
    required int row,
  }) async* {
    _shouldFastForward = false;

    yield DrawerPhysicalStatus.locked;
    await Future.delayed(const Duration(seconds: 2));
    if (_shouldFastForward) return;

    debugPrint('MOCK SENSOR (Master Serum row:$row): Kullanıcı kabini çekti!');
    yield DrawerPhysicalStatus.fullyOpen;

    int elapsed = 0;
    while (elapsed < 60000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR (Master Serum row:$row): Kabin kapandı 🔒');
    yield DrawerPhysicalStatus.locked;
  }

  // ════════════════════════════════════════════════════════════════
  // GENEL KOMUT GÖNDERİMİ
  // ════════════════════════════════════════════════════════════════

  @override
  Future<String?> sendRawCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFastForward) {
      return '.h4,';
    }

    if (commandPayload.contains('O')) return 'ok';
    if (commandPayload.contains('S')) {
      _statusPollCount++;
      if (_statusPollCount < 3) return '.h0,';
      return '.h3,';
    }

    return 'ok';
  }
}
