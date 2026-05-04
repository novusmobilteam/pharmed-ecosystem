// apps/pharmed-manager/lib/core/hardware/rfid/rfid_service.dart
//
// [SWREQ-RFID-001] [SWREQ-RFID-002] [SWREQ-RFID-003] [SWREQ-RFID-004]
// [IEC 62304 §5.5]
// RFID okuyucu ile TCP üzerinden haberleşen gerçek implementasyon.
//
// Protokol : CRC-16/MCRF4XX (poly=0x1021, init=0xFFFF, reflected, LSB-first)
// Paket yapısı TX : [Len][Addr=0x00][CMD][Data...][CRC_LSB][CRC_MSB]
//              RX : [Len][Addr=0x00][CMD][Status][Data...][CRC_LSB][CRC_MSB]
//   Len = data_len + 4  (Len byte'ı kendisi hariç)
// Sınıf: Class B

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RfidService implements IRfidService {
  static const _defaultTimeoutSeconds = 5;

  static const _inventoryData = [
    0x04, // QValue
    0x00, // Session
    0x00, // MaskMem
    0x80, // Ant (anten1)
    0x14, // Scantime (20 × 100ms = 2 sn)
  ];

  Socket? _socket;

  @override
  bool get isConnected => _socket != null;

  // ---------------------------------------------------------------------------
  // Bağlantı
  // ---------------------------------------------------------------------------

  @override
  Future<Result<void>> connect(String host, int port) async {
    if (_socket != null) return const Result.ok(null);

    debugPrint('[RFID] connect() → $host:$port');
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: _defaultTimeoutSeconds));

      debugPrint('[RFID] connect() → BAŞARILI');
      MedLogger.info(
        unit: 'RfidService',
        swreq: 'SWREQ-RFID-001',
        message: 'RFID okuyucuya bağlanıldı',
        context: {'host': host, 'port': port},
      );

      return const Result.ok(null);
    } on SocketException catch (e) {
      debugPrint('[RFID] connect() → HATA: ${e.message}');
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
      debugPrint('[RFID] scan() → paket gönderildi: ${_hex(packet)}');
      socket.add(packet);

      final Map<String, RfidTag> tagMap = {};
      final doneCompleter = Completer<void>();
      Timer? idleTimer;
      late StreamSubscription<List<int>> sub;

      // Buffer — TCP chunk'lar protokol paket sınırlarına uymayabilir
      final List<int> buf = [];

      void finish() {
        idleTimer?.cancel();
        if (!doneCompleter.isCompleted) {
          sub.cancel();
          doneCompleter.complete();
        }
      }

      // Buffer'daki tüm tam paketleri parse eder.
      // Python'daki while döngüsüne eşdeğer.
      // Dönüş: true = scan bitti (0x01/0x02/0xFF), false = devam
      bool parseBuffer() {
        while (buf.length >= 4) {
          final pktLen = buf[0]; // Len byte — kendisi hariç toplam uzunluk
          if (pktLen == 0) {
            buf.removeAt(0);
            continue;
          }
          final total = pktLen + 1; // Len byte dahil toplam
          if (buf.length < total) break; // Paket henüz tam gelmedi

          final p = Uint8List.fromList(buf.sublist(0, total));
          buf.removeRange(0, total);

          debugPrint(
            '[RFID] scan() → paket parse: len=$total hex=${_hex(p)} status=0x${p[3].toRadixString(16).padLeft(2, '0')}',
          );

          final status = p[3];

          if (status == 0x03 && p.length >= 22) {
            final tag = _parseTag(p);
            if (tag != null) {
              debugPrint('[RFID] scan() → tag: ${tag.epc} (rssi: ${tag.rssi} dBm)');
              final existing = tagMap[tag.epc];
              if (existing == null || tag.rssi > existing.rssi) {
                tagMap[tag.epc] = tag;
              }
            }
          } else if (status == 0x01 || status == 0x02 || status == 0xFF) {
            debugPrint('[RFID] scan() → bitiş status: 0x${status.toRadixString(16).padLeft(2, '0')}');
            return true; // scan bitti
          }
        }
        return false;
      }

      sub = socket.cast<List<int>>().listen(
        (chunk) {
          idleTimer?.cancel();
          debugPrint('[RFID] scan() → chunk alındı (${chunk.length} byte): ${_hex(Uint8List.fromList(chunk))}');

          buf.addAll(chunk);
          final done = parseBuffer();
          if (done) {
            finish();
            return;
          }

          // Bitiş paketi gelmedi — idle timer başlat
          // Okuyucu son tag'den sonra 0x01 göndermeyebilir
          idleTimer = Timer(const Duration(milliseconds: 800), finish);
        },
        onError: (e) {
          debugPrint('[RFID] scan() → stream hatası: $e');
          if (!doneCompleter.isCompleted) {
            idleTimer?.cancel();
            sub.cancel();
            doneCompleter.completeError(e);
          }
        },
        onDone: () {
          debugPrint('[RFID] scan() → stream kapandı');
          finish();
        },
        cancelOnError: false,
      );

      // Global timeout
      await doneCompleter.future.timeout(
        const Duration(seconds: _defaultTimeoutSeconds),
        onTimeout: () {
          debugPrint('[RFID] scan() → global timeout');
          finish();
        },
      );

      final tags = tagMap.values.toList();
      debugPrint('[RFID] scan() → tamamlandı, ${tags.length} tag: ${tags.map((t) => t.epc).join(', ')}');

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
  // Bağlantı Testi
  // ---------------------------------------------------------------------------

  @override
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port}) async {
    Socket? testSocket;
    try {
      testSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: _defaultTimeoutSeconds));

      final packet = _buildPacket(0x21, []);
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
        context: {'ip': ip, 'port': port, 'fw': info.firmwareVersion},
      );

      return Result.ok(info);
    } on SocketException catch (e) {
      return Result.error(ServiceException(message: 'RFID okuyucuya ulaşılamadı: ${e.message}', statusCode: 503));
    } on TimeoutException {
      return Result.error(ServiceException(message: 'RFID bağlantı testi zaman aşımına uğradı.', statusCode: 408));
    } finally {
      await testSocket?.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Yardımcı metodlar
  // ---------------------------------------------------------------------------

  Uint8List _buildPacket(int cmd, List<int> data) {
    final len = data.length + 4;
    final payload = [len, 0x00, cmd, ...data];
    final crc = _crc16(payload);
    return Uint8List.fromList([...payload, ...crc]);
  }

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

  /// Protokol paketi:
  /// p[0]=len, p[1]=addr, p[2]=cmd, p[3]=status
  /// p[4]=ant, p[5]=flag, p[6]=epc_len, p[7..7+epc_len]=EPC
  /// p[7+epc_len]=rssi_raw, p[...]=CRC
  ///
  /// RSSI: Python'daki gibi rssi_raw - 130
  RfidTag? _parseTag(Uint8List p) {
    if (p.length < 22) return null;

    final epcLen = p[6] > 0 ? p[6] : 12;
    final epcEnd = 7 + epcLen;
    if (p.length < epcEnd + 1) return null;

    final epc = p.sublist(7, epcEnd).map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();

    final rssiRaw = p[epcEnd];
    if (rssiRaw == 0) return null;

    final rssi = rssiRaw - 130; // Python ile aynı formül
    final antenna = p[4];

    return RfidTag(epc: epc, rssi: rssi, antenna: antenna);
  }

  String _hex(Uint8List data) => data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
}
