import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entity/management_card.dart';

import '../../domain/repository/i_cabin_operation_service.dart';

class MockCabinOperationService implements ICabinOperationService {
  int _statusPollCount = 0;
  // Akışı dışarıdan kesmek için bir bayrak
  bool _shouldFastForward = false;

  /// Kullanıcı işlemi bitirdiğinde veya vazgeçtiğinde bu metodu çağıracağız.
  @override
  void triggerManualClose() {
    _shouldFastForward = true;
    debugPrint("MOCK: Manuel kapatma tetiklendi, polling ve stream sonlandırılıyor...");
  }

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    return await findManagementCard();
  }

  @override
  Future<ManagementCard?> findManagementCard() async {
    debugPrint('MOCK: Yönetim kartı taranıyor...');
    await Future.delayed(const Duration(milliseconds: 500));

    // Her zaman 1. adresi bulsun
    debugPrint('MOCK: ✅ Yönetim kartı bulundu: Adres 1 (a)');
    return ManagementCard(addressIndex: 1);
  }

  @override
  Future<List<ControlCard>> findControlCards(ManagementCard manager) async {
    debugPrint('MOCK: Kontrol kartları taranıyor...');
    await Future.delayed(const Duration(seconds: 1));

    // 1. Kübik (Tip 01)
    // 2. Standart 5'li (Tip 33)
    // 3. Standart 3'lü (Tip 08)
    // 4. Serum Kabini

    final mockCards = [
      ControlCard(rowAddress: 2, rawTypeResponse: '.01,'),
      ControlCard(rowAddress: 3, rawTypeResponse: '.33,'),
      ControlCard(rowAddress: 4, rawTypeResponse: '.08,'),
      ControlCard(rowAddress: 4, rawTypeResponse: '.250,'),
    ];

    return mockCards;
  }

  @override
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    debugPrint('_shouldFastForward:$_shouldFastForward');

    // EĞER MANUEL KAPATMA GELDİYSE: Hemen h4 (Kilitli/Kapalı) dön ki polling dursun.
    if (_shouldFastForward) {
      debugPrint('MOCK SENSOR: Zorunlu kapatma algılandı, h4 dönülüyor.');
      return ".h4,";
    }

    // 1. KİLİT AÇMA (TO...)
    if (commandPayload.contains(":T") && commandPayload.contains("O")) {
      debugPrint('MOCK: Kilit Açma başarılı.');
      return "ok"; // veya .ok,
    }

    // 2. KAPAK AÇMA (Z...)
    if (commandPayload.contains(":Z")) {
      debugPrint('MOCK: Kapak Açma başarılı.');
      return "[ac]";
    }

    // 3. DURUM SORGULAMA (TS...) - AKILLI SİMÜLASYON
    if (commandPayload.contains(":T") && commandPayload.contains("S")) {
      _statusPollCount++;

      // İlk 3 sorguda "Kapalı/Kilitli" (h0) dön
      if (_statusPollCount < 3) {
        debugPrint('MOCK SENSOR: Henüz çekilmedi (h0)');
        return ".h0,";
      }

      // Sonra "Açık/Çekildi" (h3) dön
      debugPrint('MOCK SENSOR: Kullanıcı çekti! (h3)');
      return ".h3,";
    }

    // Varsayılan Başarılı
    return "ok";
  }

  @override
  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async {
    debugPrint("MOCK: Kilit açılıyor (Row:$row, Port:$port)...");
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("MOCK: Kilit AÇILDI ✅");
  }

  @override
  Future<void> openCubic({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  }) async {
    debugPrint("MOCK: Kapak açılıyor...");
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("MOCK: Kapak AÇILDI 🔓");
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

    debugPrint("MOCK SENSOR: Kullanıcı çekmeceyi çekti!");
    yield DrawerPhysicalStatus.fullyOpen; // .h3

    // 12 saniyelik bekleme, 500ms'lik parçalarla kontrol ediliyor
    int totalWait = 0;
    while (totalWait < 50000) {
      await Future.delayed(const Duration(milliseconds: 500));
      totalWait += 500;
      if (_shouldFastForward) break;
    }

    debugPrint("MOCK SENSOR: Kullanıcı çekmeceyi kapattı! (h4)");
    yield DrawerPhysicalStatus.locked; // .h4
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row}) async* {
    // Her izleme başladığında bayrağı ve sayacı sıfırla
    _shouldFastForward = false;
    _statusPollCount = 0;

    // 1. Durum: Kilitli
    yield DrawerPhysicalStatus.locked;

    // Simüle edilmiş bir gecikme (Kullanıcının kilidi duyup çekmesi için geçen süre)
    await Future.delayed(const Duration(seconds: 2));
    if (_shouldFastForward) return; // Eğer o sırada işlem iptal edildiyse çık

    // 2. Durum: Çekmece Çekildi / Kapak Açıldı
    debugPrint("MOCK SENSOR (SERUM): Kullanıcı kabini çekti! (h3)");
    yield DrawerPhysicalStatus.fullyOpen; // .h3

    // 3. Bekleme Süreci: Periyodik kontrol
    // 12 saniye boyunca her 500ms'de bir "Zorunlu kapatma geldi mi?" diye bakıyoruz
    int totalWait = 0;
    while (totalWait < 12000) {
      await Future.delayed(const Duration(milliseconds: 500));
      totalWait += 500;

      // Eğer kullanıcı UI üzerinden "Kaydet" veya "Kapat" dediyse bekleme süresini kır
      if (_shouldFastForward) {
        debugPrint("MOCK SENSOR (SERUM): Bekleme yarıda kesildi, h4'e geçiliyor...");
        break;
      }
    }

    // 4. Durum: Kapandı / Kilitlendi
    debugPrint("MOCK SENSOR (SERUM): Kabin kapandı! (h4)");
    yield DrawerPhysicalStatus.locked; // .h4
  }

  @override
  Future<void> unlockSerum({required ManagementCard manager, required int row}) async {
    debugPrint("MOCK: Kapak açılıyor...");
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("MOCK: Kapak AÇILDI 🔓");
  }
}
