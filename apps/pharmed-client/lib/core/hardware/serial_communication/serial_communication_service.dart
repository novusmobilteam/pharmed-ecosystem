import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../providers/datasource_injector.dart';
import 'i_serial_communication_service.dart';

final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return DI.serialCommunicationService();
});

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

  String get connectedPortName => _port?.name ?? "Bağlı Değil";

  @override
  List<String> getAvailablePorts() {
    print('1. Metod başladı');
    final List<String> activePorts = [];

    try {
      print('2. availablePorts çağrılıyor...');
      final allPorts = SerialPort.availablePorts;
      print('3. Sistemdeki ham portlar: $allPorts');

      for (final name in allPorts) {
        try {
          final port = SerialPort(name);

          // Portun gerçekten açılabilir veya sistem tarafından tanınır
          // olduğunu doğrulamak için kısa bir check:
          if (port.description != null || port.vendorId != null) {
            activePorts.add(name);
          }

          port.dispose(); // Bellek sızıntısını önlemek için mutlaka kapatın
        } catch (e) {
          // Port meşgulse veya erişim engellendiyse listeye eklemiyoruz
          debugPrint('Port tarama hatası ($name): $e');
        }
      }

      // Eğer liste hala boşsa, debug konsoluna sistemdeki ham listeyi basalım
      if (activePorts.isEmpty && allPorts.isNotEmpty) {
        debugPrint('Sistem portları görüyor (${allPorts.join(', ')}), ancak erişilemiyor.');
      }
    } catch (e, stack) {
      print('HATA OLUŞTU: $e');
      print('Stacktrace: $stack');
      return [];
    }

    return activePorts;
  }

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) async {
    // 1. Önce istenen portu (COM3) dene
    try {
      if (onStatusChanged != null) onStatusChanged("Porta bağlanılıyor: $portName...");
      await _attemptConnection(portName);
      if (onStatusChanged != null) onStatusChanged("Bağlantı başarılı: $portName");
      return;
    } catch (e) {
      debugPrint("⚠️ $portName başarısız: $e");
    }

    // 2. Başarısız olursa, diğer mevcut portları listele ve dene
    if (onStatusChanged != null) onStatusChanged("$portName başarısız. Diğer portlar taranıyor...");

    final availablePorts = SerialPort.availablePorts;

    // Zaten denediğimiz portu listeden çıkaralım
    final portsToTry = availablePorts.where((p) => p != portName).toList();

    if (portsToTry.isEmpty) {
      throw SerialPortException(message: "Varsayılan port ($portName) başarısız ve başka port bulunamadı.");
    }

    for (final pName in portsToTry) {
      try {
        if (onStatusChanged != null) onStatusChanged("Deneniyor: $pName...");
        await _attemptConnection(pName);

        // Buraya geldiyse bağlantı başarılı demektir
        if (onStatusChanged != null) onStatusChanged("Bağlantı sağlandı: $pName");
        return;
      } catch (e) {
        debugPrint("⚠️ $pName başarısız, sıradakine geçiliyor...");
      }
    }

    // 3. Hiçbiri olmazsa hata fırlat
    throw SerialPortException(message: "Hiçbir porta bağlanılamadı. Kabloları kontrol edin.");
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
      throw SerialPortException(message: 'Port açılamadı ($portName).');
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
      throw SerialPortException(message: 'Bağlantı yok.');
    }

    // 1. MUTEX: EĞER PORT MEŞGULSE BEKLE (Yarış Durumunu Önler)
    int waitCount = 0;
    while (_isBusy) {
      await Future.delayed(const Duration(milliseconds: 50));
      waitCount++;
      if (waitCount > 100) {
        // 5 saniye bekledik hala meşgulse
        _isBusy = false; // Kilidi zorla kır
        throw SerialPortException(message: "Port zaman aşımı (Busy Lock).");
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
        throw SerialPortException(message: "Yazma başarısız.");
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
}
