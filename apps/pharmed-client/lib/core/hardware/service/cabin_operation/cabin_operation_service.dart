// apps/pharmed-client/lib/core/hardware/service/cabin_operation_service.dart

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../model/control_card.dart';
import '../../model/drawer_status.dart';
import '../../model/management_card.dart';
import '../serial_communication/i_serial_communication_service.dart';
import 'i_cabin_operation_service.dart';

/// KABİN OPERASYON SERVİSİ — GERÇEK İMPLEMENTASYON
/// -------------------------------------------------
/// Seri port üzerinden fiziksel kabin donanımıyla haberleşir.
/// Yönetim kartı tarama, kontrol kartı bulma, çekmece açma/kapama
/// ve sensör durumu izleme işlemlerini gerçekleştirir.
class CabinOperationService implements ICabinOperationService {
  CabinOperationService({required ISerialCommunicationService serialService}) : _serialService = serialService;

  final ISerialCommunicationService _serialService;
  ManagementCard? _cachedManager;

  // ── Yaşam Döngüsü ──────────────────────────────────────────────

  @override
  void triggerManualClose() {
    // Gerçek implementasyonda sensör polling'ini durduracak bir flag
    // veya stream controller cancel mekanizması eklenebilir.
  }

  // ── Yönetim Kartı ──────────────────────────────────────────────

  @override
  Future<ManagementCard?> getOrScanManager({String? targetPort}) async {
    if (!_serialService.isConnected) {
      final port = targetPort ?? 'COM3';
      debugPrint('🔌 Port bağlı değil. Otomatik bağlanılıyor: $port');
      await _serialService.connectToPort(port);
      // Donanımın kendine gelmesi için safety delay
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
      // Satır seçimi (2 deneme)
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

      // Tip sorgulama — 3 deneme
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
        } catch (_) {
          // Timeout — tekrar dene
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    debugPrint('📊 Toplam ${foundCards.length} kontrol kartı bulundu.');
    return foundCards;
  }

  // ── Çekmece Operasyonları ──────────────────────────────────────

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

  // ── Sensör İzleme ─────────────────────────────────────────────

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
}
