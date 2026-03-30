// apps/pharmed-client/lib/core/hardware/service/serial_communication_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pharmed_core/pharmed_core.dart';

import 'i_serial_communication_service.dart';

/// SERİ PORT HABERLEŞMESİ — GERÇEK İMPLEMENTASYON
/// ------------------------------------------------
/// flutter_libserialport paketini kullanarak fiziksel seri port
/// üzerinden cihazlarla haberleşir.
///
/// ÖZELLİKLER:
/// - Mutex ile eşzamanlı komut koruması
/// - Otomatik fallback port taraması
/// - Protokol bitiş karakteri tespiti (-, ,, ;, ])
/// - Buffer biriktirme ile parçalı veri desteği
class SerialCommunicationService implements ISerialCommunicationService {
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _subscription;

  /// Aynı anda sadece bir komutun işlenmesini sağlayan kilit.
  bool _isBusy = false;

  /// Aktif komutun cevabını bekleyen completer.
  Completer<String?>? _completer;

  /// Gelen verileri biriktiren tampon.
  final StringBuffer _buffer = StringBuffer();

  @override
  bool get isConnected => _port?.isOpen ?? false;

  /// Bağlı portun adı (debug/log amaçlı).
  String get connectedPortName => _port?.name ?? 'Bağlı Değil';

  // ── Port Tarama ────────────────────────────────────────────────

  @override
  List<String> getAvailablePorts() {
    final List<String> activePorts = [];

    try {
      final allPorts = SerialPort.availablePorts;

      for (final name in allPorts) {
        SerialPort? port;
        try {
          port = SerialPort(name);
          if (port.description != null || port.vendorId != null) {
            activePorts.add(name);
          }
        } catch (e) {
          debugPrint('Port tarama hatası ($name): $e');
        } finally {
          port?.dispose();
        }
      }

      if (activePorts.isEmpty && allPorts.isNotEmpty) {
        debugPrint('Sistem portları görüyor (${allPorts.join(', ')}), ancak erişilemiyor.');
      }
    } catch (e) {
      debugPrint('Port listesi alınamadı: $e');
    }

    return activePorts;
  }

  // ── Bağlantı ──────────────────────────────────────────────────

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) async {
    // 1. İstenen portu dene
    try {
      onStatusChanged?.call('$portName portuna bağlanılıyor...');
      await _attemptConnection(portName);
      onStatusChanged?.call('Bağlantı başarılı: $portName');
      return;
    } catch (e) {
      debugPrint('⚠️ $portName başarısız: $e');
    }

    // 2. Başarısız → diğer portları tara
    onStatusChanged?.call('$portName başarısız. Diğer portlar taranıyor...');

    List<String> availablePorts;
    try {
      availablePorts = SerialPort.availablePorts.where((p) => p != portName).toList();
    } catch (e) {
      throw SerialPortException(message: 'Port listesi alınamadı. Sürücülerin yüklü olduğundan emin olun.');
    }

    if (availablePorts.isEmpty) {
      throw SerialPortException(
        message:
            '$portName portuna bağlanılamadı ve başka aktif port bulunamadı. '
            'Kablo bağlantısını ve sürücüleri kontrol edin.',
      );
    }

    for (final candidatePort in availablePorts) {
      try {
        onStatusChanged?.call('Deneniyor: $candidatePort...');
        await _attemptConnection(candidatePort);
        onStatusChanged?.call('Bağlantı sağlandı: $candidatePort');
        return;
      } catch (e) {
        debugPrint('⚠️ $candidatePort başarısız: $e');
      }
    }

    // 3. Hiçbiri olmazsa
    throw SerialPortException(
      message:
          'Hiçbir porta bağlanılamadı. '
          'Kablo bağlantısını kontrol edin ve cihazın açık olduğundan emin olun.',
    );
  }

  Future<void> _attemptConnection(String portName) async {
    // Mevcut bağlantıyı temizle
    if (_port != null) {
      await disconnect();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    SerialPort? port;
    try {
      port = SerialPort(portName);
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
    } catch (e) {
      port?.dispose();
      throw SerialPortException(message: 'Port konfigürasyonu başarısız ($portName): $e');
    }

    if (!port.openReadWrite()) {
      final lastError = SerialPort.lastError;
      port.dispose();
      throw SerialPortException(
        message:
            'Port açılamadı ($portName). '
            '${lastError != null ? 'Sistem hatası: $lastError' : 'Port başka bir uygulama tarafından kullanılıyor olabilir.'}',
      );
    }

    _port = port;

    try {
      _port!.flush(SerialPortBuffer.both);
    } catch (_) {
      // Flush hatası kritik değil, devam et
    }

    _reader = SerialPortReader(_port!);
    _subscription = _reader?.stream.listen(
      _onDataReceived,
      onError: (Object e) {
        debugPrint('⚠️ Port okuma hatası: $e');
        _cancelPendingCompleter('Port okuma hatası: $e');
      },
    );

    // Donanımın kendine gelmesi için safety delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ── Komut Gönderme ─────────────────────────────────────────────

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    if (!isConnected) {
      throw SerialPortException(message: 'Seri port bağlantısı yok. Önce bağlantı kurulmalı.');
    }

    // Mutex: port meşgulse bekle
    await _waitForAvailability();

    _isBusy = true;
    _completer = Completer<String?>();
    _buffer.clear();

    try {
      // Input buffer'ı temizle (önceki artık veriler)
      try {
        _port!.flush(SerialPortBuffer.input);
      } catch (_) {
        // Flush hatası kritik değil
      }

      final bytes = utf8.encode(command);
      debugPrint('>> Giden: $command');

      final written = _port?.write(Uint8List.fromList(bytes));
      if (written == null || written <= 0) {
        throw SerialPortException(message: 'Komut gönderilemedi. Port yazma hatası.');
      }

      // Cevabı bekle
      final effectiveTimeout = timeout ?? const Duration(milliseconds: 500);
      final response = await _completer!.future.timeout(effectiveTimeout);
      return response;
    } on TimeoutException {
      debugPrint('⏱ Timeout: $command');
      return null;
    } on SerialPortException {
      rethrow;
    } catch (e) {
      throw SerialPortException(message: 'Komut gönderme hatası: $e');
    } finally {
      _completer = null;
      _isBusy = false;
      // Cihaza nefes payı — akışı yavaşlatmayacak kadar kısa
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Mutex bekleme — port meşgulse serbest kalmasını bekler.
  /// Maksimum 5 saniye sonra kilidi zorla kırar.
  Future<void> _waitForAvailability() async {
    int waitCount = 0;
    const maxWait = 100; // 100 × 50ms = 5 saniye

    while (_isBusy) {
      await Future.delayed(const Duration(milliseconds: 50));
      waitCount++;

      if (waitCount > maxWait) {
        debugPrint('⚠️ Mutex timeout — kilit zorla kırılıyor.');
        _cancelPendingCompleter('Port meşgul kalma süresi aşıldı.');
        _isBusy = false;
        break;
      }
    }
  }

  // ── Veri Alımı ─────────────────────────────────────────────────

  void _onDataReceived(Uint8List data) {
    if (_completer == null || _completer!.isCompleted) return;

    try {
      final chunk = String.fromCharCodes(data);
      _buffer.write(chunk);

      final current = _buffer.toString().trim();
      debugPrint('<< Gelen: $current');

      // Protokol bitiş karakteri kontrolü: -, ,, ;, ]
      if (current.endsWith('-') || current.endsWith(',') || current.endsWith(';') || current.endsWith(']')) {
        _completer?.complete(current);
        _buffer.clear();
      }
    } catch (e) {
      debugPrint('⚠️ Veri parse hatası: $e');
      // Parse hatası olsa bile completer'ı tamamla ki akış takılmasın
      _completer?.complete(null);
      _buffer.clear();
    }
  }

  // ── Bağlantı Kapatma ──────────────────────────────────────────

  @override
  Future<void> disconnect() async {
    _isBusy = false;

    _cancelPendingCompleter('Bağlantı kapatıldı.');

    await _subscription?.cancel();
    _subscription = null;

    _reader?.close();
    _reader = null;

    try {
      _port?.close();
    } catch (e) {
      debugPrint('Port kapatma hatası: $e');
    }
    _port = null;

    _buffer.clear();
  }

  // ── Yardımcı ──────────────────────────────────────────────────

  /// Bekleyen completer varsa hata ile tamamlar.
  void _cancelPendingCompleter(String reason) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(SerialPortException(message: reason));
    }
    _completer = null;
  }
}
