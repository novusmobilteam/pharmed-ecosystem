// apps/pharmed-client/lib/core/hardware/service/cabin_operation_service.dart
//
// [SWREQ-HW-001] [IEC 62304 §5.5]
// Kabin operasyon servisi — gerçek implementasyon.
//
// DESTEKLENEN KABİN TİPLERİ:
//   Master kabin → openMasterDrawer / openMasterCubicDrawer /
//                  openMasterSerumDrawer / streamMasterDrawerStatus /
//                  streamMasterSerumDrawerStatus
//   Mobil kabin  → openMobileDrawer / getMobileDrawerStatus /
//                  streamMobileDrawerStatus
//
// RS485 YARÍ-DUBLEKS NOTLARI:
//   • TX sırasında RX dinlenemez (half-duplex)
//   • Her TX sonrası kısa gecikme bırakılır
//   • Echo filtreleme ISerialCommunicationService katmanında yapılır
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../command/command_builder.dart';
import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';
import '../serial_communication/i_serial_communication_service.dart';
import 'i_cabin_operation_service.dart';

class CabinOperationService implements ICabinOperationService {
  CabinOperationService({required ISerialCommunicationService serialService}) : _serialService = serialService;

  final ISerialCommunicationService _serialService;
  ManagementCard? _cachedManager;

  // ── Sabitler ──────────────────────────────────────────────────────────────

  /// Serum kartını slave moda alan satır adresi.
  /// Bu değerle yönetim kartına komut gönderildiğinde
  /// serum kartı T komutlarını dinlemeye başlar.
  static const int _serumSlaveRow = 26;

  /// Serum kartı komutlarında drawer değeri her zaman 0'dır.
  /// Serum kartında drawer kavramı yoktur; port tek adres boyutudur.
  static const int _serumDrawer = 0;

  @override
  void triggerManualClose() {}

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    if (!_serialService.isConnected) {
      final port = targetPort ?? 'COM3';
      debugPrint('🔌 Port bağlı değil. Otomatik bağlanılıyor: $port');
      // Bağlantı kesilmişse cache geçersiz — temizle
      _cachedManager = null;
      await _serialService.connectToPort(port);
    }

    if (_cachedManager != null) return _cachedManager;

    final found = await scanManagementCard();
    if (found != null) _cachedManager = found;
    return found;
  }

  @override
  Future<ManagementCard?> scanManagementCard() async {
    debugPrint('🔍 Yönetim kartı aranıyor (adres 1-16 taranıyor)...');

    for (int i = 1; i <= 16; i++) {
      final command = CommandBuilder.buildManagementCommand(addressIndex: i, row: 0);

      try {
        final response = await _serialService.sendAndReceive(command, timeout: const Duration(milliseconds: 700));

        if (response != null && (response.contains('ok') || response.contains('+ok-'))) {
          debugPrint('✅ Yönetim kartı bulundu: Adres $i');
          return ManagementCard(addressIndex: i);
        }
      } catch (e) {
        debugPrint('⚠️ Yönetim kartı sorgu hatası (Adres $i): $e');
        continue;
      }
    }

    debugPrint('❌ Yönetim kartı bulunamadı.');
    return null;
  }

  @override
  Future<List<ControlCard>> discoverControlCards(ManagementCard manager) async {
    final List<ControlCard> foundCards = [];
    debugPrint('🔍 Kontrol kartları taranıyor (Yönetici: ${manager.addressChar})...');

    for (int row = 1; row <= 26; row++) {
      // Satır seçimi — 2 deneme (donanım gecikmesi toleransı)
      bool isRowSelected = false;
      for (int attempt = 0; attempt < 2; attempt++) {
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

      // Kart tipi sorgusu — 3 deneme
      final typeCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.type, port: 1, drawer: 1);

      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          final typeResponse = await _serialService.sendAndReceive(
            typeCommand,
            timeout: const Duration(milliseconds: 250),
          );

          if (typeResponse != null && typeResponse.startsWith('.') && typeResponse.endsWith(',')) {
            debugPrint('✅ Satır $row: Kart bulundu → $typeResponse (deneme: ${attempt + 1})');
            foundCards.add(ControlCard(rowAddress: row, rawTypeResponse: typeResponse));
            break;
          }
        } catch (_) {}

        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    debugPrint('📊 Toplam ${foundCards.length} kontrol kartı bulundu.');
    return foundCards;
  }

  @override
  Future<void> openMobileDrawer({required ManagementCard manager, required int port}) async {
    // Adım 1: Serum kartını slave moda al
    final isSelected = await _selectRow(manager.addressIndex, _serumSlaveRow);
    if (!isSelected) {
      throw SerialPortException(
        message:
            'Serum kartı slave moda alınamadı. '
            'Yönetim kartı bağlantısını kontrol edin.',
      );
    }

    // Adım 2: Port kilidini aç
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: port, drawer: _serumDrawer);

    final response = await _serialService.sendAndReceive(command);

    if (response != null && response.contains('.no')) {
      throw SerialPortException(message: 'Mobil kabin port $port solenoid yok (.no). Yanıt: $response');
    }

    final success = response != null && (response.contains('.ok') || response.contains(DeviceConstants.responseOk));

    if (!success) {
      throw SerialPortException(
        message:
            'Mobil kabin port $port açılamadı. '
            'Yanıt: $response. Solenoid bağlı mı?',
      );
    }

    debugPrint('✅ Mobil kabin port $port açıldı.');
  }

  @override
  Future<DrawerPhysicalStatus> getMobileDrawerStatus({required ManagementCard manager, required int port}) async {
    final isSelected = await _selectRow(manager.addressIndex, _serumSlaveRow);
    if (!isSelected) return DrawerPhysicalStatus.unknown;

    final statusCommand = CommandBuilder.buildDrawerCommand(
      action: DeviceAction.status,
      port: port,
      drawer: _serumDrawer,
    );

    try {
      final response = await _serialService.sendAndReceive(statusCommand, timeout: const Duration(milliseconds: 500));
      return _parseMobileDrawerStatus(response);
    } catch (_) {
      return DrawerPhysicalStatus.unknown;
    }
  }

  @override
  Stream<DrawerPhysicalStatus> streamMobileDrawerStatus({required ManagementCard manager, required int port}) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(
      action: DeviceAction.status,
      port: port,
      drawer: _serumDrawer,
    );

    while (true) {
      try {
        // Her döngüde slave mod seçimi (RS485 bus durumu değişmiş olabilir)
        final isSelected = await _selectRow(manager.addressIndex, _serumSlaveRow);

        if (!isSelected) {
          yield DrawerPhysicalStatus.unknown;
          await Future.delayed(DeviceConstants.statusPollingInterval);
          continue;
        }

        final response = await _serialService.sendAndReceive(statusCommand);
        yield _parseMobileDrawerStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  @override
  Future<void> openMasterDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async {
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: port, drawer: drawer);

    final response = await sendRawCommand(manager: manager, targetRow: row, commandPayload: command);

    if (response == null || !response.contains(DeviceConstants.responseOk)) {
      throw SerialPortException(
        message:
            'Master çekmece açılamadı '
            '(row=$row, port=$port, drawer=$drawer). Yanıt: $response',
      );
    }
  }

  @override
  Future<void> openMasterCubicDrawer({
    required ManagementCard manager,
    required int row,
    required int port,
    required int lidIndex,
  }) async {
    final command = CommandBuilder.buildCubicCommand(action: DeviceAction.open, port: port, row: lidIndex);

    await sendRawCommand(manager: manager, targetRow: row, commandPayload: command);

    // Kübik mekanik hareket için bekleme
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Stream<DrawerPhysicalStatus> streamMasterDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: port, drawer: drawer);

    while (true) {
      try {
        final response = await sendRawCommand(manager: manager, targetRow: row, commandPayload: statusCommand);
        yield _parseMasterDrawerStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  @override
  Future<void> openMasterSerumDrawer({required ManagementCard manager, required int row}) async {
    // Master kabin serum çekmecesi: port=1, drawer=0 sabit
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: 1, drawer: 0);

    final response = await sendRawCommand(manager: manager, targetRow: row, commandPayload: command);

    final success =
        response != null &&
        (response.contains(DeviceConstants.responseOk) || response.contains('.ok') || response.contains('h3'));

    if (!success) {
      throw SerialPortException(message: 'Master serum çekmecesi açılamadı (row=$row). Yanıt: $response');
    }
  }

  @override
  Stream<DrawerPhysicalStatus> streamMasterSerumDrawerStatus({
    required ManagementCard manager,
    required int row,
  }) async* {
    // Master serum: port=1, drawer=0 sabit
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: 1, drawer: 0);

    while (true) {
      try {
        final response = await sendRawCommand(manager: manager, targetRow: row, commandPayload: statusCommand);
        yield _parseMasterSerumStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  @override
  Future<String?> sendRawCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    final isSelected = await _selectRow(manager.addressIndex, targetRow);
    if (!isSelected) return null;

    return await _serialService.sendAndReceive(commandPayload);
  }

  // ════════════════════════════════════════════════════════════════
  // PRIVATE — YARDIMCILAR
  // ════════════════════════════════════════════════════════════════

  /// Yönetim kartı üzerinden belirtilen satırı seçer.
  ///
  /// RS485 bus'ta birden fazla kart olabileceğinden her komut öncesinde
  /// hangi kartın dinleyeceği bu komutla belirlenir.
  ///
  /// Returns: true → seçim başarılı, false → yanıt yok veya hata.
  Future<bool> _selectRow(int managerAddress, int rowToSelect) async {
    final command = CommandBuilder.buildManagementCommand(addressIndex: managerAddress, row: rowToSelect);

    try {
      final response = await _serialService.sendAndReceive(command, timeout: const Duration(milliseconds: 500));
      return response != null && response.contains('ok');
    } catch (e) {
      debugPrint('⚠️ Satır seçme hatası (Yönetici $managerAddress, Satır $rowToSelect): $e');
      return false;
    }
  }

  /// Mobil kabin (serum kartı) yanıt parser.
  ///
  /// h3 → açık (fullyOpen)
  /// h4 → kapatıldı (locked)
  /// h0 → kilitlendi (locked)
  DrawerPhysicalStatus _parseMobileDrawerStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;
    if (response.contains('h3')) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains('h4')) return DrawerPhysicalStatus.locked;
    if (response.contains('h0')) return DrawerPhysicalStatus.locked;
    return DrawerPhysicalStatus.unknown;
  }

  /// Master kabin standart çekmece yanıt parser.
  DrawerPhysicalStatus _parseMasterDrawerStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;

    if (response.contains(DeviceConstants.rawFullyOpen) || response.contains(DeviceConstants.rawGeneralOpen)) {
      return DrawerPhysicalStatus.fullyOpen;
    }
    if (response.contains(DeviceConstants.rawLocked) ||
        response.contains(DeviceConstants.rawClosed) ||
        response.contains(DeviceConstants.rawGeneralClosed)) {
      return DrawerPhysicalStatus.locked;
    }
    if (response.contains(DeviceConstants.rawUnlockedWaiting)) {
      return DrawerPhysicalStatus.waitingPull;
    }
    if (response.contains(DeviceConstants.rawHalfOpen)) {
      return DrawerPhysicalStatus.halfOpen;
    }

    return DrawerPhysicalStatus.unknown;
  }

  /// Master kabin serum çekmece yanıt parser.
  ///
  /// h3 → açık (fullyOpen)
  /// h4 → kapatıldı (locked)
  /// h1 → çekilmeyi bekliyor (waitingPull)
  DrawerPhysicalStatus _parseMasterSerumStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;
    if (response.contains('h3')) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains('h4')) return DrawerPhysicalStatus.locked;
    if (response.contains('h1')) return DrawerPhysicalStatus.waitingPull;
    if (response.contains(DeviceConstants.rawFullyOpen)) {
      return DrawerPhysicalStatus.fullyOpen;
    }
    if (response.contains(DeviceConstants.rawLocked)) {
      return DrawerPhysicalStatus.locked;
    }
    return DrawerPhysicalStatus.unknown;
  }
}
