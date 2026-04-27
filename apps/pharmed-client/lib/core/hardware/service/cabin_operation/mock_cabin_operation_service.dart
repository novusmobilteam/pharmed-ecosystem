// apps/pharmed-client/lib/core/hardware/service/mock_cabin_operation_service.dart

import 'package:flutter/foundation.dart';
import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';
import 'i_cabin_operation_service.dart';

// [SWREQ-HW-001]

/// KABİN OPERASYON SERVİSİ — MOCK İMPLEMENTASYON
/// -----------------------------------------------
/// Fiziksel cihaz olmadan çekmece açma/kapama ve tarama akışını simüle eder.
/// Mock flavor'da (`main_mock.dart`) kullanılır.
///
/// SİMÜLASYON DAVRANIŞI:
/// - findManagementCard: 500ms sonra adres 1'de kart bulur
/// - findControlCards: 1s sonra 4 kart döner (kübik, 5'li, 3'lü, serum)
/// - monitorDrawerStatus: 2s sonra fullyOpen, triggerManualClose ile kapanır
/// - monitorSerumPortStatus: 2s sonra fullyOpen, kullanıcı kapatınca locked
class MockCabinOperationService implements ICabinOperationService {
  int _statusPollCount = 0;
  bool _shouldFastForward = false;

  @override
  void triggerManualClose() {
    _shouldFastForward = true;
    debugPrint('MOCK: Manuel kapatma tetiklendi.');
  }

  // ── Yönetim Kartı ──────────────────────────────────────────────

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    return findManagementCard();
  }

  @override
  Future<ManagementCard?> findManagementCard() async {
    debugPrint('MOCK: Yönetim kartı taranıyor...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: ✅ Yönetim kartı bulundu: Adres 1 (a)');
    return const ManagementCard(addressIndex: 1);
  }

  // ── Kontrol Kartları ───────────────────────────────────────────

  @override
  Future<List<ControlCard>> findControlCards(ManagementCard manager) async {
    debugPrint('MOCK: Kontrol kartları taranıyor...');
    await Future.delayed(const Duration(seconds: 1));

    return [
      ControlCard(rowAddress: 2, rawTypeResponse: '.01,'), // Kübik
      ControlCard(rowAddress: 3, rawTypeResponse: '.33,'), // Standart 5'li
      ControlCard(rowAddress: 4, rawTypeResponse: '.08,'), // Standart 3'lü
      ControlCard(rowAddress: 5, rawTypeResponse: '.250,'), // Serum
    ];
  }

  // ── Komut Gönderme ─────────────────────────────────────────────

  @override
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (_shouldFastForward) {
      debugPrint('MOCK: Zorunlu kapatma algılandı, h4 dönülüyor.');
      return '.h4,';
    }

    if (commandPayload.contains(':T') && commandPayload.contains('O')) {
      debugPrint('MOCK: Kilit açma başarılı.');
      return 'ok';
    }

    if (commandPayload.contains(':Z')) {
      debugPrint('MOCK: Kapak açma başarılı.');
      return '[ac]';
    }

    if (commandPayload.contains(':T') && commandPayload.contains('S')) {
      _statusPollCount++;
      if (_statusPollCount < 3) return '.h0,';
      return '.h3,';
    }

    return 'ok';
  }

  // ── Master Kabin — Standart Çekmece ───────────────────────────

  @override
  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async {
    debugPrint('MOCK: Kilit açılıyor (Row:$row, Port:$port)...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('MOCK: Kilit AÇILDI ✅');
  }

  @override
  Future<void> openCubic({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  }) async {
    debugPrint('MOCK: Kapak açılıyor...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: Kapak AÇILDI 🔓');
  }

  @override
  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
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

    debugPrint('MOCK SENSOR: Kullanıcı çekmeceyi çekti!');
    yield DrawerPhysicalStatus.fullyOpen;

    int elapsed = 0;
    while (elapsed < 50000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR: Çekmece kapandı.');
    yield DrawerPhysicalStatus.locked;
  }

  // ── Master Kabin — Serum (Eski Akış) ──────────────────────────

  @override
  Future<void> unlockSerum({required ManagementCard manager, required int row}) async {
    debugPrint('MOCK: Serum kabini açılıyor (master akış)...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: Serum kabini AÇILDI 🔓');
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row}) async* {
    _shouldFastForward = false;
    _statusPollCount = 0;

    yield DrawerPhysicalStatus.locked;
    await Future.delayed(const Duration(seconds: 2));
    if (_shouldFastForward) return;

    debugPrint('MOCK SENSOR (SERUM): Kullanıcı kabini çekti!');
    yield DrawerPhysicalStatus.fullyOpen;

    int elapsed = 0;
    while (elapsed < 12000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR (SERUM): Kabin kapandı.');
    yield DrawerPhysicalStatus.locked;
  }

  // ── Mobil Kabin — Bağımsız Serum Kartı (Yeni Akış) ────────────

  @override
  Future<void> unlockSerumPort({required ManagementCard manager, required int port}) async {
    debugPrint('MOCK: Serum port $port açılıyor (mobil akış)...');
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('MOCK: Serum port $port AÇILDI 🔓');
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumPortStatus({required ManagementCard manager, required int port}) async* {
    _shouldFastForward = false;
    _statusPollCount = 0;

    // Başlangıç: kilit açıldı, kullanıcı henüz çekmedi
    yield DrawerPhysicalStatus.fullyOpen;

    // 3s sonra kullanıcı çekmeceyi kapattı simülasyonu
    int elapsed = 0;
    while (elapsed < 50000) {
      await Future.delayed(const Duration(milliseconds: 500));
      elapsed += 500;
      if (_shouldFastForward) break;
    }

    debugPrint('MOCK SENSOR (SERUM PORT $port): Çekmece kapandı.');
    yield DrawerPhysicalStatus.locked;
  }
}
