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

  bool _isBusy = false;
  Completer<String?>? _completer;
  final StringBuffer _buffer = StringBuffer();

  /// Son gönderilen komutun byte'ları — echo filtresi için.
  Uint8List? _lastSentBytes;

  // RS485 timing sabitleri — Python scriptiyle eşleşir
  static const _rs485DelayBeforeTxMs = 1;
  static const _rs485DelayAfterTxMs = 5;
  static const _connectSettleMs = 500; // Python: CONNECT_DELAY_S = 0.5

  @override
  bool get isConnected => _port?.isOpen ?? false;

  String get connectedPortName => _port?.name ?? 'Bağlı Değil';

  // ════════════════════════════════════════════════════════════════
  // PORT TARAMA
  // ════════════════════════════════════════════════════════════════

  @override
  List<String> getAvailablePorts() {
    final activePorts = <String>[];
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
    try {
      onStatusChanged?.call('$portName portuna bağlanılıyor...');
      await _attemptConnection(portName);
      onStatusChanged?.call('Bağlantı başarılı: $portName');
      return;
    } catch (e) {
      debugPrint('⚠️ $portName başarısız: $e');
    }

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

    throw SerialPortException(
      message:
          'Hiçbir porta bağlanılamadı. '
          'Kablo bağlantısını kontrol edin ve cihazın açık olduğundan emin olun.',
    );
  }

  Future<void> _attemptConnection(String portName) async {
    await _forceCleanup();

    SerialPort? port;
    try {
      port = SerialPort(portName);

      // Python: rtscts=False, dsrdtr=False
      // Önceki implementasyonda dtr=0, rts=1 vardı — bu RS485 yönü
      // manuel tutuyordu. Python bunu converter'a bırakıyor (rts=False).
      // RS485 USB converter'lar genellikle TX aktifken RTS'i otomatik
      // yönetiyor, manuel set gereksiz ve zaman zaman çakışıyor.
      final config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1
        ..dtr =
            0 // dsrdtr=False
        ..rts =
            1 // rtscts=False — converter kendi yönetir
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

    // Python: reset_input_buffer() + reset_output_buffer()
    // flush(both) yeterli değil — Windows'ta bazen buffer'da eski
    // veri kalıyor. İkisini ayrı ayrı sıfırla.
    try {
      _port!.flush(SerialPortBuffer.input);
      _port!.flush(SerialPortBuffer.output);
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

    // Python: time.sleep(CONNECT_DELAY_S)  →  0.5s
    await Future.delayed(const Duration(milliseconds: _connectSettleMs));
    // İlk açılışta converter'ı "uyandır"
    // Bazı RS485 USB converter'larda ilk TX kaybolabiliyor.
    try {
      _port!.flush(SerialPortBuffer.input);
      _port!.flush(SerialPortBuffer.output);

      // Dummy wakeup byte
      _port!.write(Uint8List.fromList([0x00]));

      // KRİTİK: gerçekten hatta çıksın
      _port!.flush(SerialPortBuffer.output);

      await Future.delayed(const Duration(milliseconds: 100));

      // Gelen garbage temizle
      _port!.flush(SerialPortBuffer.input);
    } catch (e) {
      debugPrint('⚠️ RS485 wakeup hatası: $e');
    }

    debugPrint('✅ Seri port bağlandı: $portName');
  }

  // ════════════════════════════════════════════════════════════════
  // KOMUT GÖNDERME
  // ════════════════════════════════════════════════════════════════

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout, int retryCount = 1}) async {
    if (!isConnected) {
      throw SerialPortException(message: 'Seri port bağlantısı yok. Önce bağlantı kurulmalı.');
    }

    await _waitForAvailability();

    _isBusy = true;
    _completer = Completer<String?>();
    _buffer.clear();

    final bytes = Uint8List.fromList(utf8.encode(command));
    _lastSentBytes = bytes;

    try {
      for (int attempt = 0; attempt <= retryCount; attempt++) {
        try {
          debugPrint('>> Giden: $command');

          await Future.delayed(const Duration(milliseconds: _rs485DelayBeforeTxMs));

          _setTransmitMode();

          final written = _port?.write(bytes);

          if (written == null || written <= 0) {
            throw SerialPortException(message: 'Komut gönderilemedi. Port yazma hatası.');
          }

          try {
            _port!.flush(SerialPortBuffer.output);
          } catch (e) {
            debugPrint('⚠️ Output flush hatası: $e');
          }

          await Future.delayed(const Duration(milliseconds: 5));

          _setReceiveMode();

          await Future.delayed(const Duration(milliseconds: _rs485DelayAfterTxMs));

          final effectiveTimeout = timeout ?? const Duration(milliseconds: 1000);
          final response = await _completer!.future.timeout(effectiveTimeout);

          return response;
        } on TimeoutException {
          debugPrint('⏱ Timeout: $command (attempt=${attempt + 1})');

          if (attempt < retryCount) {
            _buffer.clear();

            // retry öncesi yeni completer oluştur
            _completer = Completer<String?>();

            await Future.delayed(const Duration(milliseconds: 150));

            continue;
          }

          return null;
        }
      }

      return null;
    } finally {
      _lastSentBytes = null;
      _completer = null;
      _isBusy = false;

      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  Future<void> _waitForAvailability() async {
    int waitCount = 0;
    const maxWait = 100;

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

  void _setTransmitMode() {
    try {
      final config = _port!.config;
      config.rts = 1;
      _port!.config = config;
    } catch (e) {
      debugPrint('⚠️ TX mode hatası: $e');
    }
  }

  void _setReceiveMode() {
    try {
      final config = _port!.config;
      config.rts = 0;
      _port!.config = config;
    } catch (e) {
      debugPrint('⚠️ RX mode hatası: $e');
    }
  }

  void _onDataReceived(Uint8List data) {
    if (_completer == null || _completer!.isCompleted) return;

    try {
      // ── Echo filtresi ─────────────────────────────────────────
      // RS485 half-duplex'te gönderilen veri geri okunur.
      // Python: if raw == self._last_sent → yoksay
      //         if raw in self._last_sent → kısmi echo, yoksay
      if (_lastSentBytes != null) {
        if (_isSameBytes(data, _lastSentBytes!)) {
          debugPrint('<< (echo, yoksayıldı) ${utf8.decode(data, allowMalformed: true)}');
          return;
        }
        if (_isSubBytes(data, _lastSentBytes!)) {
          debugPrint('<< (kısmi echo, yoksayıldı) ${utf8.decode(data, allowMalformed: true)}');
          return;
        }
      }
      // ─────────────────────────────────────────────────────────

      final chunk = utf8.decode(data, allowMalformed: true);
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

  /// İki byte dizisinin aynı olup olmadığını kontrol eder.
  bool _isSameBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// [sub]'ın [full] içinde olup olmadığını kontrol eder (kısmi echo).
  bool _isSubBytes(Uint8List sub, Uint8List full) {
    if (sub.length > full.length) return false;
    outer:
    for (var i = 0; i <= full.length - sub.length; i++) {
      for (var j = 0; j < sub.length; j++) {
        if (full[i + j] != sub[j]) continue outer;
      }
      return true;
    }
    return false;
  }

  // ════════════════════════════════════════════════════════════════
  // BAĞLANTI KAPATMA
  // ════════════════════════════════════════════════════════════════

  @override
  Future<void> disconnect() async {
    await _forceCleanup();
    debugPrint('🔌 Seri port bağlantısı kapatıldı.');
  }

  Future<void> _forceCleanup() async {
    _isBusy = false;
    _lastSentBytes = null;

    _cancelPendingCompleter('Bağlantı yeniden başlatılıyor.');

    try {
      await _subscription?.cancel();
    } catch (e) {
      debugPrint('⚠️ Subscription iptal hatası: $e');
    }
    _subscription = null;

    try {
      _reader?.close();
    } catch (e) {
      debugPrint('⚠️ Reader kapatma hatası: $e');
    }
    _reader = null;

    try {
      if (_port?.isOpen ?? false) _port?.close();
    } catch (e) {
      debugPrint('⚠️ Port kapatma hatası: $e');
    }

    try {
      _port?.dispose();
    } catch (e) {
      debugPrint('⚠️ Port dispose hatası: $e');
    }
    _port = null;

    _buffer.clear();

    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _cancelPendingCompleter(String reason) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(SerialPortException(message: reason));
    }
    _completer = null;
  }
}
