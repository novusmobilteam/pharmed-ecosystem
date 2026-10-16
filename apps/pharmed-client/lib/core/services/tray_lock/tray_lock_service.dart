// [SWREQ-HW-TRAY-001] [IEC 62304 §5.5]
// Serum kabini avadanlık kilit kartı servisi — gerçek implementasyon.
//
// HAT PAYLAŞIMI:
//   Kart master kabinle aynı RS485 hattındadır. Komutlar aynı
//   ISerialCommunicationService örneğiyle (aynı mutex) gönderilir; bağlantı
//   yoksa CabinOperationService.getOrScanManager() ile açılır (in-flight
//   guard'ı korunur, ikinci bir bağlantı açılmaz).
//   Kart kendi `<iXX:…>` adresini dinler; yönetim kartında satır seçimi
//   GEREKMEZ (saha testinde satır seçmeden yanıt verdiği doğrulandı).
//
// Sınıf: Class B

import 'dart:async';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class TrayLockService implements ITrayLockService {
  TrayLockService({
    required ISerialCommunicationService serialService,
    required ICabinOperationService cabinOperationService,
  }) : _serial = serialService,
       _cabinOps = cabinOperationService;

  final ISerialCommunicationService _serial;
  final ICabinOperationService _cabinOps;

  static const _unit = 'SW-UNIT-TRAY';
  static const _swreq = 'SWREQ-HW-TRAY-001';

  static const _commandTimeout = Duration(milliseconds: 1000);
  static const _defaultPollInterval = Duration(milliseconds: 400);

  @override
  Future<void> lockAll({required int deviceId}) => _expectOk(deviceId, TrayLockAction.lockAll);

  @override
  Future<void> unlockAll({required int deviceId}) => _expectOk(deviceId, TrayLockAction.unlockAll);

  @override
  Future<void> cancelUnlock({required int deviceId, required int port}) =>
      _expectOk(deviceId, TrayLockAction.cancel, port: port);

  @override
  Future<void> unlock({required int deviceId, required int port}) async {
    final response = await _send(deviceId, TrayLockAction.open, port: port);
    if (response is TrayLockOk) return;

    // Onay alınamadı: yanıt kaybolmuş ya da seri katmanın otomatik tekrarı
    // ikinci bir `o` göndermiş olabilir (ikincisi `noo4` döner). Komut kartta
    // uygulandıysa port artık açık/çekilmiş görünür — başarılı say.
    final failure = response is TrayLockErrorResponse ? response.failure : TrayLockFailure.protocolError;
    if (failure == TrayLockFailure.busy || failure == TrayLockFailure.noResponse) {
      final status = await _tryGetStatus(deviceId, port);
      if (status == TrayLockStatus.unlocked || status == TrayLockStatus.pulled) {
        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: 'Açma onayı alınamadı ama port açık — başarılı sayıldı',
          context: {'deviceId': deviceId, 'port': port, 'failure': failure.name, 'status': status!.name},
        );
        return;
      }
    }
    throw TrayLockException(failure, detail: 'open deviceId=$deviceId port=$port');
  }

  @override
  Future<TrayLockStatus> getStatus({required int deviceId, required int port}) async {
    final response = await _send(deviceId, TrayLockAction.status, port: port);
    return switch (response) {
      TrayLockStatusResponse(:final status) => status,
      TrayLockErrorResponse(:final failure) => throw TrayLockException(failure, detail: 'status port=$port'),
      _ => throw TrayLockException(TrayLockFailure.protocolError, detail: 'status port=$port: $response'),
    };
  }

  @override
  Future<int> getKeypadValue({required int deviceId, required int port}) async {
    final response = await _send(deviceId, TrayLockAction.keypadValue, port: port);
    return switch (response) {
      TrayLockKeypadResponse(:final value) => value,
      TrayLockErrorResponse(:final failure) => throw TrayLockException(failure, detail: 'keypad port=$port'),
      _ => throw TrayLockException(TrayLockFailure.protocolError, detail: 'keypad port=$port: $response'),
    };
  }

  @override
  Stream<TrayLockStatus> watchStatus({required int deviceId, required int port, Duration? interval}) async* {
    final period = interval ?? _defaultPollInterval;
    TrayLockStatus? last;

    while (true) {
      try {
        final status = await getStatus(deviceId: deviceId, port: port);
        if (status != last) {
          last = status;
          yield status;
        }
      } catch (e, st) {
        // Hata stream'i kapatmaz; bir sonraki başarılı okuma yeniden yayınlanır.
        last = null;
        yield* Stream<TrayLockStatus>.error(e, st);
      }
      await Future<void>.delayed(period);
    }
  }

  // ── Yardımcılar ─────────────────────────────────────────────────────────

  Future<void> _expectOk(int deviceId, TrayLockAction action, {int? port}) async {
    final response = await _send(deviceId, action, port: port);
    switch (response) {
      case TrayLockOk():
        return;
      case TrayLockErrorResponse(:final failure):
        throw TrayLockException(failure, detail: '${action.name} deviceId=$deviceId port=$port');
      default:
        throw TrayLockException(TrayLockFailure.protocolError, detail: '${action.name}: $response');
    }
  }

  Future<TrayLockStatus?> _tryGetStatus(int deviceId, int port) async {
    try {
      return await getStatus(deviceId: deviceId, port: port);
    } catch (_) {
      return null;
    }
  }

  /// Komutu gönderir ve yanıtı ayrıştırır. Yalnızca bağlantı hatasında
  /// fırlatır; kartın hata yanıtları [TrayLockErrorResponse] olarak döner.
  Future<TrayLockResponse> _send(int deviceId, TrayLockAction action, {int? port}) async {
    final command = TrayLockProtocol.build(deviceId: deviceId, action: action, port: port);
    await _ensureConnected();

    String? raw;
    try {
      raw = await _serial.sendAndReceive(command, timeout: _commandTimeout);
    } on SerialPortException catch (e) {
      throw TrayLockException(TrayLockFailure.noResponse, detail: e.message);
    } catch (e) {
      // Seri katmandan beklenmeyen istisna (ör. zaman aşımı) — üst katmanlar
      // yalnızca TrayLockException bekler.
      throw TrayLockException(TrayLockFailure.noResponse, detail: e.toString());
    }

    final response = TrayLockProtocol.parse(raw);
    if (response is TrayLockErrorResponse) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Kilit kartı hata yanıtı',
        context: {'command': command, 'raw': raw, 'failure': response.failure.name},
      );
    }
    return response;
  }

  Future<void> _ensureConnected() async {
    if (_serial.isConnected) return;
    await _cabinOps.getOrScanManager();
    if (!_serial.isConnected) {
      throw const TrayLockException(TrayLockFailure.noResponse, detail: 'serial port not connected');
    }
  }
}
