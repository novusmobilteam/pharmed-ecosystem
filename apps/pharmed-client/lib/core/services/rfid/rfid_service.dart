// pharmed-client/lib/core/services/rfid/rfid_service.dart
//
// [SWREQ-CLI-RFID-001] [IEC 62304 §5.5]
// UHF RFID okuyucu (UHFEx10) için TCP üzerinden stream-based implementasyon.
//
// Protokol:
//   CRC-16/MCRF4XX (poly=0x1021, init=0xFFFF, reflected, LSB-first)
//   Paket: [Len][Addr=0x00][CMD][Data...][CRC_LSB][CRC_MSB]
//   Len = data_len + 4
//
// Çalışma modları:
//   - Answer Mode (default)  → host komutla okutur, cevap döner
//   - Real-time Mode (0x76)  → cihaz otomatik tag yayınlar (reCmd 0xEE)
//
// Akış:
//   connect → Answer Mode (defensive)
//   startInventory → Real-time Mode + stream
//   stopInventory  → Answer Mode + stream sonlandır
//   disconnect     → stopInventory + close
//
// Sınıf: Class B

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class RfidService implements IRfidService {
  static const _connectTimeoutSeconds = 5;
  static const _commandResponseTimeoutSeconds = 3;

  // ── Komut kodları (UHFEx10 protokolü) ──────────────────────────────────
  static const int _cmdGetReaderInformation = 0x21;
  static const int _cmdSetPower = 0x2F;
  static const int _cmdSetWorkingMode = 0x76;
  static const int _reCmdRealtimeTag = 0xEE;
  static const int _statusRealtimeTagOk = 0x00;
  static const int _statusRealtimeHeartbeat = 0x28;

  // ── Working mode değerleri ─────────────────────────────────────────────
  static const int _modeAnswer = 0x00;
  static const int _modeRealtime = 0x01;

  Socket? _socket;
  StreamSubscription<List<int>>? _socketSub;

  /// Socket'ten gelen ham byte'ları biriktiren buffer.
  final BytesBuilder _rxBuffer = BytesBuilder(copy: false);

  /// Aktif inventory için stream controller (single-subscription).
  StreamController<RfidTag>? _inventoryController;

  /// Bekleyen senkron komut tamamlayıcısı (Answer Mode'da cevap bekleyen).
  Completer<Uint8List>? _pendingCommandCompleter;

  @override
  bool get isConnected => _socket != null;

  bool get _inventoryActive => _inventoryController != null;

  // ── Bağlantı ────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> connect(String host, int port) async {
    if (_socket != null) return const Result.ok(null);

    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: _connectTimeoutSeconds));

      // Tek socket listener — tüm okuma buradan akar
      _socketSub = _socket!.listen(_handleIncomingData, onError: _handleSocketError, onDone: _handleSocketDone);

      MedLogger.info(
        unit: 'RfidService',
        swreq: 'SWREQ-CLI-RFID-001',
        message: 'RFID okuyucuya bağlanıldı',
        context: {'host': host, 'port': port},
      );

      // Defensive: önceki uygulama crash'inden Real-time mode'da kalmış olabilir.
      // Answer Mode'a al — başarısız olursa bağlantıyı bozmuyoruz, log'la geç.
      final modeResult = await _setWorkingMode(_modeAnswer);
      modeResult.when(
        ok: (_) {},
        error: (e) {
          MedLogger.warn(
            unit: 'RfidService',
            swreq: 'SWREQ-CLI-RFID-001',
            message: 'Defensive Answer Mode set başarısız (devam ediliyor)',
            context: {'error': e.toString()},
          );
        },
      );

      return const Result.ok(null);
    } on SocketException catch (e) {
      MedLogger.error(
        unit: 'RfidService',
        swreq: 'SWREQ-CLI-RFID-001',
        message: 'TCP bağlantı hatası',
        context: {'error': e.message},
      );
      return Result.error(ServiceException(message: 'RFID okuyucuya bağlanılamadı: ${e.message}', statusCode: 503));
    }
  }

  @override
  Future<void> disconnect() async {
    if (_inventoryActive) {
      await stopInventory();
    }
    await _socketSub?.cancel();
    await _socket?.close();
    _socketSub = null;
    _socket = null;
    _rxBuffer.clear();
    _pendingCommandCompleter = null;
    MedLogger.info(unit: 'RfidService', swreq: 'SWREQ-CLI-RFID-001', message: 'RFID bağlantısı kapatıldı');
  }

  // ── Inventory akışı ─────────────────────────────────────────────────────

  @override
  Stream<RfidTag> startInventory() {
    if (_socket == null) {
      throw StateError('startInventory: bağlı değil. Önce connect() çağırın.');
    }
    if (_inventoryActive) {
      throw StateError('startInventory: zaten aktif. Önce stopInventory() çağırın.');
    }

    final controller = StreamController<RfidTag>(
      onListen: () async {
        // Listener bağlandı — şimdi cihaza Real-time mode komutu gönder
        final result = await _setWorkingMode(_modeRealtime);
        result.when(
          ok: (_) {
            MedLogger.info(
              unit: 'RfidService',
              swreq: 'SWREQ-CLI-RFID-002',
              message: 'Inventory başladı (Real-time mode)',
            );
          },
          error: (e) {
            // Mode değişimi başarısızsa stream'i hata ile sonlandır
            _inventoryController?.addError(e);
            _inventoryController?.close();
            _inventoryController = null;
          },
        );
      },
      onCancel: () async {
        // Listener iptal etti — Answer Mode'a geri al
        await _setWorkingMode(_modeAnswer);
        _inventoryController = null;
        MedLogger.info(unit: 'RfidService', swreq: 'SWREQ-CLI-RFID-002', message: 'Inventory durdu (Answer mode)');
      },
    );

    _inventoryController = controller;
    return controller.stream;
  }

  @override
  Future<Result<void>> stopInventory() async {
    if (!_inventoryActive) return const Result.ok(null);

    final controller = _inventoryController!;
    _inventoryController = null;

    // Mode'u Answer'a al
    final result = await _setWorkingMode(_modeAnswer);

    // Stream'i kapat (listener'a done event gider)
    await controller.close();

    return result;
  }

  // ── Test bağlantı ───────────────────────────────────────────────────────
  // Kalıcı bağlantıdan ayrı bir socket kullanır; ana bağlantıyı bozmaz.

  @override
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port}) async {
    Socket? testSocket;
    try {
      testSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: _connectTimeoutSeconds));

      final packet = _buildPacket(_cmdGetReaderInformation, []);
      testSocket.add(packet);

      final completer = Completer<Uint8List>();
      late StreamSubscription sub;

      sub = testSocket
          .timeout(const Duration(seconds: _commandResponseTimeoutSeconds))
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
        swreq: 'SWREQ-CLI-RFID-003',
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

  // ── RF Güç ──────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> setPower(int dbm) async {
    if (_inventoryActive) {
      return Result.error(
        ServiceException(
          message: 'Inventory aktifken güç ayarı değiştirilemez. Önce stopInventory() çağırın.',
          statusCode: 409,
        ),
      );
    }
    final result = await _sendCommandAndWait(_cmdSetPower, [dbm]);
    return result.when(
      ok: (_) {
        MedLogger.info(
          unit: 'RfidService',
          swreq: 'SWREQ-CLI-RFID-004',
          message: 'RF güç ayarlandı',
          context: {'dbm': dbm},
        );
        return const Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  // ── Internal: SetWorkingMode komutu ─────────────────────────────────────

  Future<Result<void>> _setWorkingMode(int mode) async {
    final result = await _sendCommandAndWait(_cmdSetWorkingMode, [mode]);
    return result.when(
      ok: (resp) {
        // Cevap status byte'ı kontrol et (response: [Len][Adr][0x76][Status]...)
        if (resp.length >= 4 && resp[3] != 0x00) {
          return Result.error(
            ServiceException(
              message: 'SetWorkingMode reddedildi (status=0x${resp[3].toRadixString(16)})',
              statusCode: 502,
            ),
          );
        }
        return const Result.ok(null);
      },
      error: (e) => Result.error(e),
    );
  }

  // ── Internal: Senkron komut + cevap ─────────────────────────────────────

  Future<Result<Uint8List>> _sendCommandAndWait(int cmd, List<int> data) async {
    final socket = _socket;
    if (socket == null) {
      return Result.error(ServiceException(message: 'RFID servisi bağlı değil.', statusCode: 503));
    }
    if (_pendingCommandCompleter != null) {
      return Result.error(ServiceException(message: 'Önceki komut hâlâ cevap bekliyor.', statusCode: 409));
    }

    final completer = Completer<Uint8List>();
    _pendingCommandCompleter = completer;

    try {
      final packet = _buildPacket(cmd, data);
      socket.add(packet);

      final resp = await completer.future.timeout(const Duration(seconds: _commandResponseTimeoutSeconds));

      return Result.ok(resp);
    } on TimeoutException {
      return Result.error(
        ServiceException(
          message: 'Komut cevabı zaman aşımına uğradı (cmd=0x${cmd.toRadixString(16)}).',
          statusCode: 408,
        ),
      );
    } catch (e) {
      return Result.error(ServiceException(message: 'Komut hatası: $e', statusCode: 500));
    } finally {
      _pendingCommandCompleter = null;
    }
  }

  // ── Internal: Socket olayları ───────────────────────────────────────────

  void _handleIncomingData(List<int> chunk) {
    _rxBuffer.add(chunk);
    _processBuffer();
  }

  void _handleSocketError(Object e, StackTrace st) {
    MedLogger.error(
      unit: 'RfidService',
      swreq: 'SWREQ-CLI-RFID-001',
      message: 'Socket hatası',
      context: {'error': e.toString()},
    );
    _pendingCommandCompleter?.completeError(e);
    _inventoryController?.addError(e);
  }

  void _handleSocketDone() {
    MedLogger.warn(
      unit: 'RfidService',
      swreq: 'SWREQ-CLI-RFID-001',
      message: 'Socket karşı taraf tarafından kapatıldı',
    );
    _socket = null;
    _socketSub = null;
    _pendingCommandCompleter?.completeError(StateError('Socket kapandı'));
    _inventoryController?.close();
    _inventoryController = null;
  }

  /// Buffer'daki bytelardan tam frame'leri ayrıştır.
  /// Frame: [Len][Adr][Cmd][Data...][CRC_LSB][CRC_MSB]
  /// Toplam frame uzunluğu = Len + 1 (Len byte'ı kendisi sayılmaz; Len = data_len + 4)
  void _processBuffer() {
    final bytes = _rxBuffer.toBytes();
    var consumed = 0;

    while (consumed < bytes.length) {
      final remaining = bytes.length - consumed;
      if (remaining < 5) break; // En küçük frame: [Len][Adr][Cmd][CRC_LSB][CRC_MSB]

      final len = bytes[consumed];
      final frameSize = len + 1;

      if (remaining < frameSize) break; // Tam frame henüz gelmedi

      final frame = Uint8List.sublistView(bytes, consumed, consumed + frameSize);
      _dispatchFrame(frame);
      consumed += frameSize;
    }

    // Tüketilenleri buffer'dan at, kalanları yeniden yükle
    _rxBuffer.clear();
    if (consumed < bytes.length) {
      _rxBuffer.add(bytes.sublist(consumed));
    }
  }

  /// Tam bir frame geldiğinde çağrılır. Frame'in türüne göre yönlendirir:
  ///   - reCmd 0xEE → Real-time mode tag/heartbeat paketi → inventory stream
  ///   - Diğer reCmd'ler → bekleyen senkron komut cevabı
  void _dispatchFrame(Uint8List frame) {
    if (frame.length < 5) return;

    final reCmd = frame[2];

    if (reCmd == _reCmdRealtimeTag) {
      _dispatchRealtimeFrame(frame);
      return;
    }

    // Senkron cevap — bekleyen completer'a ver
    final completer = _pendingCommandCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(frame);
    }
  }

  void _dispatchRealtimeFrame(Uint8List frame) {
    // Format: [Len][Adr][0xEE][Status][Data...][CRC_LSB][CRC_MSB]
    if (frame.length < 5) return;
    final status = frame[3];

    switch (status) {
      case _statusRealtimeTagOk:
        final tag = _parseRealtimeTag(frame);
        if (tag != null) {
          _inventoryController?.add(tag);
        }
        break;

      case _statusRealtimeHeartbeat:
        // Heartbeat — şimdilik sadece log'la
        MedLogger.info(unit: 'RfidService', swreq: 'SWREQ-CLI-RFID-002', message: 'RFID heartbeat alındı (tag yok)');
        break;

      default:
        MedLogger.warn(
          unit: 'RfidService',
          swreq: 'SWREQ-CLI-RFID-002',
          message: 'Real-time frame tanımsız status',
          context: {'status': '0x${status.toRadixString(16)}'},
        );
    }
  }

  /// Real-time tag paketini parse eder.
  /// Format: [Len][Adr][0xEE][0x00][Ant][LenEpc][EPC...][RSSI][CRC_LSB][CRC_MSB]
  RfidTag? _parseRealtimeTag(Uint8List frame) {
    // Minimum: 4 başlık + 1 ant + 1 lenEpc + 1+ EPC + 1 rssi + 2 CRC
    if (frame.length < 10) return null;

    final ant = frame[4];
    final lenEpc = frame[5];

    final epcStart = 6;
    final epcEnd = epcStart + lenEpc;

    // EPC + RSSI + CRC sığıyor mu?
    if (frame.length < epcEnd + 1 + 2) return null;

    final epcBytes = frame.sublist(epcStart, epcEnd);
    final epc = epcBytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join();

    final rawRssi = frame[epcEnd];
    final rssi = rawRssi >= 128 ? rawRssi - 256 : rawRssi;

    return RfidTag(epc: epc, rssi: rssi, antenna: ant);
  }

  // ── Yardımcı: Paket / CRC ───────────────────────────────────────────────

  Uint8List _buildPacket(int cmd, List<int> data) {
    final len = data.length + 4;
    final payload = [len, 0x00, cmd, ...data];
    final crc = _crc16(payload);
    return Uint8List.fromList([...payload, ...crc]);
  }

  /// CRC-16/MCRF4XX
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
}
