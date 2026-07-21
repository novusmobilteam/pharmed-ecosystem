import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import '../../core.dart';

class SerialCommunicationService implements ISerialCommunicationService {
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription? _subscription;

  // -- KİLİT MEKANİZMASI (MUTEX) --
  // Aynı anda sadece bir komutun işlenmesini sağlar.
  bool _isBusy = false;

  // Cevabı bekleyen completer
  Completer<String?>? _completer;

  // Gelen verileri biriktiren tampon
  final StringBuffer _buffer = StringBuffer();

  @override
  bool get isConnected => _port?.isOpen ?? false;

  String get connectedPortName => _port?.name ?? contextlessL10n().core_serialPortDisconnectedLabel;

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) async {
    final l10n = contextlessL10n();

    // 1. Önce istenen portu (COM3) dene
    try {
      if (onStatusChanged != null) onStatusChanged(l10n.core_serialConnectingStatus(portName));
      await _attemptConnection(portName);
      if (onStatusChanged != null) onStatusChanged(l10n.core_serialConnectSuccessStatus(portName));
      return;
    } catch (e) {
      debugPrint("⚠️ $portName başarısız: $e");
    }

    // 2. Başarısız olursa, diğer mevcut portları listele ve dene
    if (onStatusChanged != null) onStatusChanged(l10n.core_serialPortFailedScanningOthersStatus(portName));

    final availablePorts = SerialPort.availablePorts;

    // Zaten denediğimiz portu listeden çıkaralım
    final portsToTry = availablePorts.where((p) => p != portName).toList();

    if (portsToTry.isEmpty) {
      throw SerialPortException(message: l10n.core_serialNoOtherPortsError(portName));
    }

    for (final pName in portsToTry) {
      try {
        if (onStatusChanged != null) onStatusChanged(l10n.core_serialTryingPortStatus(pName));
        await _attemptConnection(pName);

        // Buraya geldiyse bağlantı başarılı demektir
        if (onStatusChanged != null) onStatusChanged(l10n.core_serialConnectionEstablishedStatus(pName));
        return;
      } catch (e) {
        debugPrint("⚠️ $pName başarısız, sıradakine geçiliyor...");
      }
    }

    // 3. Hiçbiri olmazsa hata fırlat
    throw SerialPortException(message: l10n.core_serialNoPortConnectedError);
  }

  Future<void> _attemptConnection(String portName) async {
    if (_port != null) {
      await disconnect();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final port = SerialPort(portName);
    port.flush();
    final config = SerialPortConfig()
      ..baudRate = 9600
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..dtr = 1
      ..rts = 1
      ..xonXoff = 0;

    port.config = config;

    if (!port.openReadWrite()) {
      throw SerialPortException(message: contextlessL10n().core_serialPortOpenFailedError(portName));
    }

    _port = port;
    _port!.flush(SerialPortBuffer.both);

    _reader = SerialPortReader(_port!);
    _subscription = _reader?.stream.listen(
      _onDataReceived,
      onError: (e) {
        debugPrint("⚠️ Port okuma hatası: $e");
        disconnect();
      },
    );

    // Cihazın kendine gelmesi için bekleme
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    if (!isConnected) {
      throw SerialPortException(message: contextlessL10n().core_serialNoConnectionError);
    }

    // 1. MUTEX: EĞER PORT MEŞGULSE BEKLE (Yarış Durumunu Önler)
    int waitCount = 0;
    while (_isBusy) {
      await Future.delayed(const Duration(milliseconds: 50));
      waitCount++;
      if (waitCount > 100) {
        // 5 saniye bekledik hala meşgulse
        _isBusy = false; // Kilidi zorla kır
        throw SerialPortException(message: contextlessL10n().core_serialPortBusyTimeoutError);
      }
    }

    _isBusy = true; // Kilidi al
    _completer = Completer<String?>();
    _buffer.clear();

    try {
      try {
        _port!.flush(SerialPortBuffer.input);
      } catch (_) {}

      final bytes = utf8.encode(command);
      debugPrint('>> Giden: $command'); // Log kirliliği olmaması için kapatılabilir

      final written = _port?.write(Uint8List.fromList(bytes));
      if (written == null || written <= 0) {
        throw SerialPortException(message: contextlessL10n().core_serialWriteFailedError);
      }

      // Cevabı bekle
      final effectiveTimeout = timeout ?? const Duration(milliseconds: 500);
      final response = await _completer!.future.timeout(effectiveTimeout);

      return response;
    } on TimeoutException {
      debugPrint('Timeout: $command');
      return null;
    } catch (e) {
      rethrow;
    } finally {
      // İşlem bitti (başarılı veya hatalı), kilidi serbest bırak
      _completer = null;
      _isBusy = false;

      // Artık burada uzun 'delay' yok! Akışı yavaşlatmamalıyız.
      // Sadece cihazın art arda komutları sindirmesi için minik bir nefes payı.
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _onDataReceived(Uint8List data) {
    if (_completer == null || _completer!.isCompleted) return;

    final chunk = String.fromCharCodes(data);
    _buffer.write(chunk);

    final currentString = _buffer.toString();

    // Gelen veriyi temizle (boşluklar, \r, \n vs.)
    final cleanString = currentString.trim();
    debugPrint('Gelen Veri: $cleanString');

    // Protokol Bitiş Kontrolü
    if (cleanString.endsWith('-') ||
        cleanString.endsWith(',') ||
        cleanString.endsWith(';') ||
        cleanString.endsWith(']')) {
      // debugPrint('<< Gelen: $cleanString');
      _completer?.complete(cleanString);
      _buffer.clear();
    }
  }

  @override
  Future<void> disconnect() async {
    _isBusy = false;
    await _subscription?.cancel();
    _subscription = null;
    _reader?.close();
    _port?.close();
    _port = null;

    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError("Disconnected");
    }
  }

  @override
  List<String> getAvailablePorts() {
    return [];
  }
}
