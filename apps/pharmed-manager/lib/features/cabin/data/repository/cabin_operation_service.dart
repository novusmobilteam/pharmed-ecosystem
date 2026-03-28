import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/services/serial_communication/i_serial_communication_service.dart';
import '../../domain/entity/management_card.dart';
import '../../domain/repository/i_cabin_operation_service.dart';

class CabinOperationService implements ICabinOperationService {
  final ISerialCommunicationService _serialCommunicationService;

  ManagementCard? _cachedManager;

  CabinOperationService({required ISerialCommunicationService serialCommunicationService})
    : _serialCommunicationService = serialCommunicationService;

  @override
  void triggerManualClose() {
    return;
  }

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    if (!_serialCommunicationService.isConnected) {
      final portToConnect = targetPort ?? "COM3";
      debugPrint('🔌 Port bağlı değil. Otomatik bağlanılıyor: $portToConnect');

      try {
        await _serialCommunicationService.connectToPort(portToConnect);
        // Bağlantı sonrası donanımın kendine gelmesi için kısa bekleme (Safety Delay)
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        throw SerialPortException(message: "Otomatik bağlantı başarısız ($portToConnect): $e");
      }
    }

    // 1. Cache kontrolü
    if (_cachedManager != null) return _cachedManager;

    // Tarama mantığı...
    final found = await findManagementCard();
    if (found != null) {
      _cachedManager = found; // Hafızaya at
    }
    return found;
  }

  @override
  Future<ManagementCard?> findManagementCard() async {
    debugPrint('Yönetim kartı aranıyor (Adresler taranıyor, Satır: 00)...');

    // 1'den 16'ya kadar (a-p) adresleri deniyoruz.
    // Satır olarak '00' (0) sabit gönderiyoruz.
    for (int i = 1; i <= 16; i++) {
      final command = CommandBuilder.buildManagementCommand(
        addressIndex: i,
        row: 0, // Sabit satır 00
      );

      String? response;
      try {
        response = await _serialCommunicationService.sendAndReceive(
          command,
          timeout: const Duration(milliseconds: 700),
        );
      } catch (e) {
        debugPrint('Yönetim kartı sorgu hatası (Adres $i): $e');
        continue;
      }

      // Protokol: +TT- (ok) veya +ok-
      if (response != null && (response.contains('ok') || response.contains('+ok-'))) {
        debugPrint('Yönetim kartı bulundu: Adres $i');
        // Kart bulundu, hemen dönüyoruz. Diğer adresleri taramaya gerek yok.
        return ManagementCard(addressIndex: i);
      }
    }

    debugPrint('Yönetim kartı bulunamadı.');
    return null;
  }

  @override
  Future<List<ControlCard>> findControlCards(ManagementCard manager) async {
    final List<ControlCard> foundCards = [];
    debugPrint('🔍 Kontrol kartları taranıyor (Yönetici: ${manager.addressChar})...');

    // 1'den 26'ya kadar satırları gez
    for (int row = 1; row <= 26; row++) {
      // A) Önce Hattı Seç (Burası genelde hızlı çalışır, retry gerekmeyebilir ama eklenebilir)
      bool isRowSelected = false;
      // Satır seçimini de garantiye alalım (2 deneme)
      for (int i = 0; i < 2; i++) {
        if (await _selectRow(manager.addressIndex, row)) {
          isRowSelected = true;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (!isRowSelected) {
        debugPrint('⚠️ Satır $row seçilemedi, atlanıyor.');
        continue;
      }

      // B) "Tip Sorgula" (V) Komutu - RETRY MANTIKLI
      // Kart bazen uykuda olabilir veya meşgul olabilir. 3 kere şans veriyoruz.
      String? typeResponse;
      int retryCount = 0;
      const int maxRetries = 3;

      final typeCommand = CommandBuilder.buildDrawerCommand(
        action: DeviceAction.type, // 'V'
        port: 1,
        drawer: 1,
      );

      while (retryCount < maxRetries) {
        try {
          typeResponse = await _serialCommunicationService.sendAndReceive(
            typeCommand,
            timeout: const Duration(milliseconds: 250), // Cevap süresi
          );

          // Geçerli bir cevap mı? (.01, .33, .08 gibi)
          if (typeResponse != null && typeResponse.startsWith('.') && typeResponse.endsWith(',')) {
            debugPrint('✅ BULUNDU: Satır $row -> Cevap: $typeResponse (Deneme: ${retryCount + 1})');
            foundCards.add(ControlCard(rowAddress: row, rawTypeResponse: typeResponse));
            break; // Döngüyü kır, diğer satıra geç
          }
        } catch (e) {
          // Hata olursa (Timeout vb.) yut ve tekrar dene
        }

        retryCount++;
        // Bir sonraki deneme öncesi cihaza nefes aldır
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (typeResponse == null) {
        // debugPrint('Satır $row boş.'); // Log kirliliği yapmasın diye kapalı
      }
    }

    return foundCards;
  }

  @override
  Future<void> openCubic({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  }) async {
    final command = CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: port, row: lidIndex);

    await sendCommand(manager: manager, targetRow: row, commandPayload: command);
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    // 1. Önce hattı seç
    final isSelected = await _selectRow(manager.addressIndex, targetRow);
    if (!isSelected) return null;

    // 2. Sonra asıl komutu gönder
    return await _serialCommunicationService.sendAndReceive(commandPayload);
  }

  @override
  Future<void> unlockDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async {
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: port, drawer: drawer);

    final response = await sendCommand(manager: manager, targetRow: row, commandPayload: command);

    if (response == null || !response.contains(DeviceConstants.responseOk)) {
      throw SerialPortException(message: "Kilit açılamadı. Cihaz Yanıtı: $response");
    }
  }

  @override
  Future<void> unlockSerum({required ManagementCard manager, required int row}) async {
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: 1, drawer: 0);

    debugPrint("📤 Serum Aç Komutu (Adres 0): $command (Hedef Row: $row)");

    final response = await sendCommand(manager: manager, targetRow: row, commandPayload: command);

    bool success = false;
    if (response != null) {
      if (response.contains(DeviceConstants.responseOk) || response.contains(".ok") || response.contains("h3")) {
        success = true;
      }
    }

    if (!success) {
      throw SerialPortException(message: "Serum kabini açılamadı. Cevap: $response");
    }
  }

  @override
  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: port, drawer: drawer);

    while (true) {
      try {
        final rawResponse = await sendCommand(manager: manager, targetRow: row, commandPayload: statusCommand);

        yield _parseStandardStatus(rawResponse);
      } catch (e) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row}) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: 1, drawer: 0);

    while (true) {
      try {
        final rawResponse = await sendCommand(manager: manager, targetRow: row, commandPayload: statusCommand);

        yield _parseSerumStatus(rawResponse);
      } catch (e) {
        yield DrawerPhysicalStatus.unknown;
      }
      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  /// Yönetim kartına satır seçme komutu gönderir.
  Future<bool> _selectRow(int managerAddress, int rowToSelect) async {
    final command = CommandBuilder.buildManagementCommand(addressIndex: managerAddress, row: rowToSelect);

    String? response;
    try {
      response = await _serialCommunicationService.sendAndReceive(command, timeout: const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Satır seçme hatası (Yönetici $managerAddress, Satır $rowToSelect): $e');
      return false;
    }

    return response != null && response.contains('ok');
  }

  DrawerPhysicalStatus _parseStandardStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;

    // h3 (Kübik) veya h6 (Standart) durumu: İşlem yapılabilir tam açıklık
    if (response.contains(DeviceConstants.rawFullyOpen) || response.contains(DeviceConstants.rawGeneralOpen)) {
      return DrawerPhysicalStatus.fullyOpen;
    }

    // h0 (Kilitli), h4 (Kapatıldı) veya h5 (Genel Kapalı) durumu
    if (response.contains(DeviceConstants.rawLocked) ||
        response.contains(DeviceConstants.rawClosed) ||
        response.contains(DeviceConstants.rawGeneralClosed)) {
      return DrawerPhysicalStatus.locked;
    }

    // h1: Kilit açıldı ama kullanıcı henüz çekmedi
    if (response.contains(DeviceConstants.rawUnlockedWaiting)) {
      return DrawerPhysicalStatus.waitingPull;
    }

    // h2: Yarım açık durumu
    if (response.contains(DeviceConstants.rawHalfOpen)) {
      return DrawerPhysicalStatus.halfOpen;
    }

    // Eşleşme bulunamazsa
    return DrawerPhysicalStatus.unknown;
  }

  DrawerPhysicalStatus _parseSerumStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;

    // Logda: .h3, -> Açık
    if (response.contains("h3")) return DrawerPhysicalStatus.fullyOpen;
    // Logda: .h4, -> Kapalı (Varsayım)
    if (response.contains("h4")) return DrawerPhysicalStatus.locked;
    // Bekleme
    if (response.contains("h1")) return DrawerPhysicalStatus.waitingPull;

    if (response.contains(DeviceConstants.rawFullyOpen)) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains(DeviceConstants.rawLocked)) return DrawerPhysicalStatus.locked;

    return DrawerPhysicalStatus.unknown;
  }
}
