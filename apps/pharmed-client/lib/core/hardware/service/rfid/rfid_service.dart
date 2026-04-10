// pharmed-client/core/hardware/service/rfid/rfid_service.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../model/rfid_tag.dart';
import 'i_rfid_service.dart';
import 'model/rfid_reader_info.dart';

/// RFID okuyucu ile TCP üzerinden haberleşen gerçek implementasyon.
///
/// Protokol: CRC-16/MCRF4XX (poly=0x1021, init=0xFFFF, reflected, LSB-first)
/// Paket yapısı: [Len][Addr=0x00][CMD][Data...][CRC_LSB][CRC_MSB]
///   Len = data_len + 4
class RfidService implements IRfidService {
  static const _defaultTimeoutSeconds = 5;

  // Inventory komutu sabit parametreleri
  static const _inventoryData = [
    0x04, // QValue
    0x00, // Session
    0x00, // MaskMem
    0x80, // Ant (anten1)
    0x14, // Scantime (20 × 100ms = 2 sn)
  ];

  Socket? _socket;
  String? _host;
  int? _port;

  @override
  bool get isConnected => _socket != null;

  // ---------------------------------------------------------------------------
  // Bağlantı
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> connect(String host, int port) async {
    if (_socket != null) return const Result.ok(null);

    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: _defaultTimeoutSeconds));
      _host = host;
      _port = port;

      MedLogger.info(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-001',
        message: 'RFID okuyucuya bağlanıldı',
        context: {'host': host, 'port': port},
      );

      return const Result.ok(null);
    } on SocketException catch (e) {
      MedLogger.error(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-001',
        message: 'TCP bağlantı hatası',
        context: {'error': e.message},
      );
      return Result.error(ServiceException(message: 'RFID okuyucuya bağlanılamadı: ${e.message}', statusCode: 503));
    }
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    MedLogger.info(unit: 'RfidService', swreq: 'SWREQ-RFID-001', message: 'RFID bağlantısı kapatıldı');
  }

  // ---------------------------------------------------------------------------
  // Scan
  // ---------------------------------------------------------------------------

  @override
  Future<Result<List<RfidTag>>> scan() async {
    final socket = _socket;
    if (socket == null) {
      return Result.error(
        ServiceException(message: 'RFID servisi bağlı değil. Önce connect() çağrılmalı.', statusCode: 503),
      );
    }

    try {
      final packet = _buildPacket(0x01, _inventoryData);
      socket.add(packet);

      // EPC → en yüksek RSSI kaydedilir (duplicate filtreleme)
      final Map<String, RfidTag> tagMap = {};

      await for (final chunk in socket.timeout(const Duration(seconds: _defaultTimeoutSeconds)).cast<List<int>>()) {
        final resp = Uint8List.fromList(chunk);

        // Minimum cevap boyutu kontrolü
        if (resp.length < 18) continue;

        final status = resp[3];

        if (status == 0xFF) {
          // Tag bulunamadı
          break;
        }

        if (status == 0x03 || status == 0x01) {
          final tag = _parseTag(resp);
          if (tag != null) {
            final existing = tagMap[tag.epc];
            if (existing == null || tag.rssi > existing.rssi) {
              tagMap[tag.epc] = tag;
            }
          }
        }

        if (status == 0x01) {
          // Son paket — tarama tamamlandı
          break;
        }
      }

      final tags = tagMap.values.toList();

      MedLogger.info(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-002',
        message: 'Scan tamamlandı',
        context: {'tagCount': tags.length},
      );

      return Result.ok(tags);
    } on TimeoutException {
      MedLogger.error(unit: 'RfidService', swreq: 'SWREQ-RFID-002', message: 'Scan timeout');
      return Result.error(ServiceException(message: 'RFID scan zaman aşımına uğradı.', statusCode: 408));
    } catch (e) {
      MedLogger.error(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-002',
        message: 'Scan hatası',
        context: {'error': e.toString()},
      );
      return Result.error(ServiceException(message: 'RFID scan hatası: $e', statusCode: 500));
    }
  }

  // ---------------------------------------------------------------------------
  // RF Güç
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> setPower(int dbm) async {
    final socket = _socket;
    if (socket == null) {
      return Result.error(ServiceException(message: 'RFID servisi bağlı değil.', statusCode: 503));
    }

    try {
      final packet = _buildPacket(0x2F, [dbm]);
      socket.add(packet);

      MedLogger.info(unit: 'RfidService', swreq: 'SWREQ-RFID-003', message: 'RF güç ayarlandı', context: {'dbm': dbm});

      return const Result.ok(null);
    } catch (e) {
      return Result.error(ServiceException(message: 'RF güç ayar hatası: $e', statusCode: 500));
    }
  }

  // ---------------------------------------------------------------------------
  // Yardımcı metodlar
  // ---------------------------------------------------------------------------

  /// Protokol paketini oluşturur.
  /// TX: [Len][Addr=0x00][CMD][Data...][CRC_LSB][CRC_MSB]
  /// Len = data_len + 4
  Uint8List _buildPacket(int cmd, List<int> data) {
    final len = data.length + 4;
    final payload = [len, 0x00, cmd, ...data];
    final crc = _crc16(payload);
    return Uint8List.fromList([...payload, ...crc]);
  }

  /// CRC-16/MCRF4XX
  /// poly=0x1021, init=0xFFFF, reflected, LSB-first
  List<int> _crc16(List<int> data) {
    var crc = 0xFFFF;
    for (final b in data) {
      crc ^= b;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0x8408 : crc >> 1;
      }
    }
    return [crc & 0xFF, (crc >> 8) & 0xFF];
  }

  /// Cevap paketinden RfidTag parse eder.
  /// RX: 15 00 01 [Status] 01 01 [EPC 12byte] [Ant] [RSSI] [CRC2]
  /// EPC: resp[5:17] (12 byte)
  /// RSSI: resp[17] signed byte
  RfidTag? _parseTag(Uint8List resp) {
    if (resp.length < 19) return null;

    final epcBytes = resp.sublist(5, 17);
    final epc = epcBytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();

    // Signed byte dönüşümü
    final rawRssi = resp[17];
    final rssi = rawRssi >= 128 ? rawRssi - 256 : rawRssi;

    final antenna = resp[16];

    return RfidTag(epc: epc, rssi: rssi, antenna: antenna);
  }

  @override
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port}) async {
    Socket? testSocket;
    try {
      testSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: _defaultTimeoutSeconds));

      final packet = _buildPacket(0x21, []); // GetReaderInformation
      testSocket.add(packet);

      final completer = Completer<Uint8List>();
      late StreamSubscription sub;

      sub = testSocket
          .timeout(const Duration(seconds: _defaultTimeoutSeconds))
          .listen(
            (chunk) {
              if (!completer.isCompleted) {
                completer.complete(Uint8List.fromList(chunk));
              }
              sub.cancel();
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
              sub.cancel();
            },
          );

      final resp = await completer.future;

      if (resp.length < 9) {
        return Result.error(ServiceException(message: 'Geçersiz cevap alındı.', statusCode: 502));
      }

      final info = RfidReaderInfo(
        firmwareVersion: '${resp[4]}.${resp[5]}',
        readerType: resp[6],
        maxPower: resp[7],
        currentPower: resp[8],
      );

      MedLogger.info(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-004',
        message: 'RFID bağlantı testi başarılı',
        context: {'ip': ip, 'port': port, 'fw': info.firmwareVersion, 'power': info.currentPower},
      );

      return Result.ok(info);
    } on SocketException catch (e) {
      MedLogger.error(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-004',
        message: 'RFID bağlantı testi başarısız',
        context: {'error': e.message},
      );
      return Result.error(ServiceException(message: 'RFID okuyucuya ulaşılamadı: ${e.message}', statusCode: 503));
    } on TimeoutException {
      return Result.error(ServiceException(message: 'RFID bağlantı testi zaman aşımına uğradı.', statusCode: 408));
    } finally {
      await testSocket?.close();
    }
  }
}
