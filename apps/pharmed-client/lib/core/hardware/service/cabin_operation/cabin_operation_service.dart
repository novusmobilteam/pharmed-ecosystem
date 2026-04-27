import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../command/command_builder.dart';
import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';
import '../serial_communication/i_serial_communication_service.dart';
import 'i_cabin_operation_service.dart';

// [SWREQ-HW-001]

/// KABİN OPERASYON SERVİSİ — GERÇEK İMPLEMENTASYON
/// -------------------------------------------------
/// Seri port üzerinden fiziksel kabin donanımıyla haberleşir.
///
/// DESTEKLENEN KABİN TİPLERİ:
///   Master kabin  →  unlockDrawer / unlockSerum / monitorSerumStatus
///   Mobil kabin   →  unlockSerumPort / monitorSerumPortStatus
class CabinOperationService implements ICabinOperationService {
  CabinOperationService({required ISerialCommunicationService serialService}) : _serialService = serialService;

  final ISerialCommunicationService _serialService;
  ManagementCard? _cachedManager;

  // ── Sabitler ───────────────────────────────────────────────────

  /// Mobil kabin serum kartı slave mod satır adresi.
  /// Bu değerle yönetim kartına komut gönderildiğinde
  /// kart slave moda geçerek T komutlarını işler.
  static const int _serumSlaveRow = 26;

  /// Serum kartı port komutlarında drawer değeri sabit 0'dır.
  static const int _serumDrawer = 0;

  // ── Yaşam Döngüsü ──────────────────────────────────────────────

  @override
  void triggerManualClose() {}

  // ── Yönetim Kartı ──────────────────────────────────────────────

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    if (!_serialService.isConnected) {
      final port = targetPort ?? 'COM3';
      debugPrint('🔌 Port bağlı değil. Otomatik bağlanılıyor: $port');
      await _serialService.connectToPort(port);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_cachedManager != null) return _cachedManager;

    final found = await findManagementCard();
    if (found != null) _cachedManager = found;
    return found;
  }

  @override
  Future<ManagementCard?> findManagementCard() async {
    debugPrint('Yönetim kartı aranıyor (1-16 arası adresler taranıyor)...');

    for (int i = 1; i <= 16; i++) {
      final command = CommandBuilder.buildManagementCommand(addressIndex: i, row: 0);

      try {
        final response = await _serialService.sendAndReceive(command, timeout: const Duration(milliseconds: 700));

        if (response != null && (response.contains('ok') || response.contains('+ok-'))) {
          debugPrint('✅ Yönetim kartı bulundu: Adres $i');
          return ManagementCard(addressIndex: i);
        }
      } catch (e) {
        debugPrint('Yönetim kartı sorgu hatası (Adres $i): $e');
        continue;
      }
    }

    debugPrint('❌ Yönetim kartı bulunamadı.');
    return null;
  }

  // ── Kontrol Kartları ───────────────────────────────────────────

  @override
  Future<List<ControlCard>> findControlCards(ManagementCard manager) async {
    final List<ControlCard> foundCards = [];
    debugPrint('🔍 Kontrol kartları taranıyor (Yönetici: ${manager.addressChar})...');

    for (int row = 1; row <= 26; row++) {
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

      final typeCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.type, port: 1, drawer: 1);

      String? typeResponse;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          typeResponse = await _serialService.sendAndReceive(typeCommand, timeout: const Duration(milliseconds: 250));

          if (typeResponse != null && typeResponse.startsWith('.') && typeResponse.endsWith(',')) {
            debugPrint('✅ Satır $row: $typeResponse (deneme: ${attempt + 1})');
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

  // ── Komut Gönderme ─────────────────────────────────────────────

  @override
  Future<String?> sendCommand({
    required ManagementCard manager,
    required int targetRow,
    required String commandPayload,
  }) async {
    final isSelected = await _selectRow(manager.addressIndex, targetRow);
    if (!isSelected) return null;

    return await _serialService.sendAndReceive(commandPayload);
  }

  // ── Master Kabin — Standart Çekmece ───────────────────────────

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
      throw SerialPortException(message: 'Kilit açılamadı. Cihaz yanıtı: $response');
    }
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
  Stream<DrawerPhysicalStatus> monitorDrawerStatus({
    required ManagementCard manager,
    required int row,
    required int port,
    required int drawer,
  }) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: port, drawer: drawer);

    while (true) {
      try {
        final response = await sendCommand(manager: manager, targetRow: row, commandPayload: statusCommand);
        yield _parseStandardStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  // ── Master Kabin — Serum (Eski Akış) ──────────────────────────

  @override
  Future<void> unlockSerum({required ManagementCard manager, required int row}) async {
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: 1, drawer: 0);
    final response = await sendCommand(manager: manager, targetRow: row, commandPayload: command);

    final success =
        response != null &&
        (response.contains(DeviceConstants.responseOk) || response.contains('.ok') || response.contains('h3'));

    if (!success) {
      throw SerialPortException(message: 'Serum kabini açılamadı. Cevap: $response');
    }
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumStatus({required ManagementCard manager, required int row}) async* {
    final statusCommand = CommandBuilder.buildDrawerCommand(action: DeviceAction.status, port: 1, drawer: 0);

    while (true) {
      try {
        final response = await sendCommand(manager: manager, targetRow: row, commandPayload: statusCommand);
        yield _parseSerumStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  // ── Mobil Kabin — Bağımsız Serum Kartı (Yeni Akış) ────────────

  @override
  Future<void> unlockSerumPort({required ManagementCard manager, required int port}) async {
    // Serum kartını slave moda al (row=26)
    final isSelected = await _selectRow(manager.addressIndex, _serumSlaveRow);
    if (!isSelected) {
      throw SerialPortException(message: 'Serum kartı slave moda alınamadı.');
    }

    // Port kilidini aç (drawer=0 sabit)
    final command = CommandBuilder.buildDrawerCommand(action: DeviceAction.open, port: port, drawer: _serumDrawer);

    final response = await _serialService.sendAndReceive(command);

    final success = response != null && (response.contains('.ok') || response.contains(DeviceConstants.responseOk));

    if (!success) {
      throw SerialPortException(message: 'Serum port $port açılamadı. Cevap: $response');
    }

    debugPrint('✅ Serum port $port açıldı.');
  }

  @override
  Stream<DrawerPhysicalStatus> monitorSerumPortStatus({required ManagementCard manager, required int port}) async* {
    // drawer=0 ile status komutu
    final statusCommand = CommandBuilder.buildDrawerCommand(
      action: DeviceAction.status,
      port: port,
      drawer: _serumDrawer,
    );

    while (true) {
      try {
        // Her polling döngüsünde slave moda al
        final isSelected = await _selectRow(manager.addressIndex, _serumSlaveRow);
        if (!isSelected) {
          yield DrawerPhysicalStatus.unknown;
          await Future.delayed(DeviceConstants.statusPollingInterval);
          continue;
        }

        final response = await _serialService.sendAndReceive(statusCommand);
        yield _parseSerumPortStatus(response);
      } catch (_) {
        yield DrawerPhysicalStatus.unknown;
      }

      await Future.delayed(DeviceConstants.statusPollingInterval);
    }
  }

  // ── Private Yardımcılar ────────────────────────────────────────

  Future<bool> _selectRow(int managerAddress, int rowToSelect) async {
    final command = CommandBuilder.buildManagementCommand(addressIndex: managerAddress, row: rowToSelect);

    try {
      final response = await _serialService.sendAndReceive(command, timeout: const Duration(milliseconds: 200));
      return response != null && response.contains('ok');
    } catch (e) {
      debugPrint('Satır seçme hatası (Yönetici $managerAddress, Satır $rowToSelect): $e');
      return false;
    }
  }

  DrawerPhysicalStatus _parseStandardStatus(String? response) {
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

  DrawerPhysicalStatus _parseSerumStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;

    if (response.contains('h3')) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains('h4')) return DrawerPhysicalStatus.locked;
    if (response.contains('h1')) return DrawerPhysicalStatus.waitingPull;
    if (response.contains(DeviceConstants.rawFullyOpen)) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains(DeviceConstants.rawLocked)) return DrawerPhysicalStatus.locked;

    return DrawerPhysicalStatus.unknown;
  }

  /// Mobil kabin serum port status parser.
  ///
  /// h0 → kilitlendi   (locked)
  /// h3 → açık         (fullyOpen — kullanıcı henüz kapatmadı)
  /// h4 → kapatıldı    (locked)
  DrawerPhysicalStatus _parseSerumPortStatus(String? response) {
    if (response == null) return DrawerPhysicalStatus.unknown;

    if (response.contains('h3')) return DrawerPhysicalStatus.fullyOpen;
    if (response.contains('h4')) return DrawerPhysicalStatus.locked;
    if (response.contains('h0')) return DrawerPhysicalStatus.locked;

    return DrawerPhysicalStatus.unknown;
  }
}
