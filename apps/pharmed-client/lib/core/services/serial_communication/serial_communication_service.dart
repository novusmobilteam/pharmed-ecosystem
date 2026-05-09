// [SWREQ-HW-SER-001] [IEC 62304 §5.5]
// Seri port haberleşme servisi — gerçek implementasyon.
//
// ÖZELLİKLER:
//   - Mutex ile eşzamanlı komut koruması
//   - Otomatik fallback port taraması
//   - Protokol bitiş karakteri tespiti (-, ,, ;, ])
//   - Buffer biriktirme ile parçalı veri desteği
//
// HATA YÖNETİMİ:
//   - Port handle leak koruması: dispose her zaman çalışır
//   - Doğru temizleme sırası: subscription → reader → port → null
//   - Hatalı işlem sonrası reconnect güvenlidir
//   - OS handle'ı serbest bırakmak için dispose zinciri garantili
//
// Sınıf: Class B

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pharmed_core/pharmed_core.dart';

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

  String get connectedPortName => _port?.name ?? 'Bağlı Değil';

  // ════════════════════════════════════════════════════════════════
  // PORT TARAMA
  // ════════════════════════════════════════════════════════════════

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
        debugPrint(
          'Sistem portları görüyor (${allPorts.join(', ')}), '
          'ancak erişilemiyor.',
        );
      }
    } catch (e) {
      debugPrint('Port listesi alınamadı: $e');
    }

    return activePorts;
  }

  // ════════════════════════════════════════════════════════════════
  // BAĞLANTI
  // ════════════════════════════════════════════════════════════════

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
            '$portName portuna bağlanılamadı ve başka aktif port '
            'bulunamadı. Kablo bağlantısını ve sürücüleri kontrol edin.',
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

    throw SerialPortException(
      message:
          'Hiçbir porta bağlanılamadı. '
          'Kablo bağlantısını kontrol edin ve cihazın açık olduğundan '
          'emin olun.',
    );
  }

  Future<void> _attemptConnection(String portName) async {
    // Mevcut bağlantıyı garantili temizle — handle leak önleme
    await _forceCleanup();

    SerialPort? port;
    try {
      port = SerialPort(portName);

      final config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..dtr = 0
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

    // Input buffer'ı temizle — bağlantı öncesi birikmiş olabilir
    try {
      _port!.flush(SerialPortBuffer.both);
    } catch (_) {
      // Flush hatası kritik değil
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
    await Future.delayed(const Duration(milliseconds: 1000));
    debugPrint('✅ Seri port bağlandı: $portName');
  }

  // ════════════════════════════════════════════════════════════════
  // KOMUT GÖNDERME
  // ════════════════════════════════════════════════════════════════

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    if (!isConnected) {
      throw SerialPortException(message: 'Seri port bağlantısı yok. Önce bağlantı kurulmalı.');
    }

    await _waitForAvailability();

    _isBusy = true;
    _completer = Completer<String?>();
    _buffer.clear();

    try {
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

      // TX → RX geçiş gecikmesi (RS485 half-duplex)
      await Future.delayed(const Duration(milliseconds: 250));

      final effectiveTimeout = timeout ?? const Duration(milliseconds: 500);
      final response = await _completer!.future.timeout(effectiveTimeout);
      return response;
    } on TimeoutException {
      debugPrint('⏱ Timeout: $command');
      return null;
    } on SerialPortException {
      rethrow;
    } catch (e) {
      // Beklenmeyen hata — port state'ini kontrol et
      debugPrint('⚠️ Komut gönderme hatası: $e');
      throw SerialPortException(message: 'Komut gönderme hatası: $e');
    } finally {
      _completer = null;
      _isBusy = false;
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

  // ════════════════════════════════════════════════════════════════
  // VERİ ALIMI
  // ════════════════════════════════════════════════════════════════

  void _onDataReceived(Uint8List data) {
    if (_completer == null || _completer!.isCompleted) return;
    debugPrint('📥 Ham veri geldi: ${data.length} byte — ${data.map((b) => b.toRadixString(16)).join(' ')}');

    try {
      final chunk = String.fromCharCodes(data);
      _buffer.write(chunk);

      final current = _buffer.toString().trim();
      debugPrint('<< Gelen: $current');

      // Protokol bitiş karakteri: -, ,, ;, ]
      if (current.endsWith('-') || current.endsWith(',') || current.endsWith(';') || current.endsWith(']')) {
        _completer?.complete(current);
        _buffer.clear();
      }
    } catch (e) {
      debugPrint('⚠️ Veri parse hatası: $e');
      _completer?.complete(null);
      _buffer.clear();
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BAĞLANTI KAPATMA
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> disconnect() async {
    await _forceCleanup();
    debugPrint('🔌 Seri port bağlantısı kapatıldı.');
  }

  /// Tüm kaynakları garantili serbest bırakan temizleme metodu.
  ///
  /// DOĞRU TEMİZLEME SIRASI:
  ///   1. _isBusy sıfırla — yeni mutex bekleme girişini engelle
  ///   2. Bekleyen completer'ı iptal et — askıdaki Future'ı çöz
  ///   3. Stream subscription'ı iptal et — veri dinlemeyi durdur
  ///   4. Reader'ı kapat — SerialPortReader'ı temizle
  ///   5. Port'u kapat — OS handle'ını serbest bırak
  ///   6. Port'u dispose et — belleği serbest bırak
  ///   7. Tüm referansları null yap — GC'ye bırak
  ///
  /// Bu metod throw etmez — her adımda hata yakalanır.
  /// Reconnect öncesi çağrılması garantili olmalıdır.
  Future<void> _forceCleanup() async {
    _isBusy = false;

    // 1. Bekleyen completer'ı iptal et
    _cancelPendingCompleter('Bağlantı yeniden başlatılıyor.');

    // 2. Stream subscription — önce iptal et
    try {
      await _subscription?.cancel();
    } catch (e) {
      debugPrint('⚠️ Subscription iptal hatası: $e');
    }
    _subscription = null;

    // 3. Reader — subscription iptal edildikten sonra kapat
    try {
      _reader?.close();
    } catch (e) {
      debugPrint('⚠️ Reader kapatma hatası: $e');
    }
    _reader = null;

    // 4. Port — reader kapatıldıktan sonra kapat
    try {
      if (_port?.isOpen ?? false) {
        _port?.close();
      }
    } catch (e) {
      debugPrint('⚠️ Port kapatma hatası: $e');
    }

    // 5. Port dispose — OS handle garantili serbest bırakma
    // close() başarısız olsa bile dispose çalışır
    try {
      _port?.dispose();
    } catch (e) {
      debugPrint('⚠️ Port dispose hatası: $e');
    }
    _port = null;

    _buffer.clear();

    // OS'un handle'ı tamamen serbest bırakması için kısa bekleme
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ════════════════════════════════════════════════════════════════
  // YARDIMCILAR
  // ════════════════════════════════════════════════════════════════

  void _cancelPendingCompleter(String reason) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(SerialPortException(message: reason));
    }
    _completer = null;
  }
}
