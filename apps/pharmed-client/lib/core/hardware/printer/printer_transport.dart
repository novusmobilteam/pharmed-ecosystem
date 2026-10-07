// pharmed-client/lib/core/hardware/printer/printer_transport.dart
//
// [SWREQ-PRN-030] [SWREQ-PRN-031] [IEC 62304 §5.5]
// Hazır ESC/POS baytlarını yazıcıya ileten katman.
//
//   SerialPrinterTransport          → seri port (USB-TTL), sahadaki hedef bağlantı
//   WindowsSpoolerPrinterTransport  → Windows kuyruğuna RAW (USB yazıcı sınıfı)
//
// Her iki gönderim de bloklayan FFI çağrılarıdır (9600 baud'da onlarca saniye
// sürebilir), bu yüzden ayrı bir isolate'te çalışır; UI donmaz.
//
// Yazıcı portu kabinin RS485 hattından (SerialCommunicationService) tamamen
// ayrıdır: ayrı port, ayrı nesne, ortak mutex yok. Port her iş için açılıp
// kapatılır; yazıcı boşta iken portu tutmayız (başka araçla test edilebilsin).
//
// Sınıf: Class B

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:win32/win32.dart';

abstract interface class IPrinterTransport {
  /// Baytların tamamını gönderir. Hata durumunda [PrinterException] fırlatır.
  Future<void> send(Uint8List data, {required String jobName});
}

/// Isolate sınırından güvenle geçen hata özeti.
typedef _SendFailure = ({String reason, String message});

PrinterException _toException(_SendFailure f) => PrinterException(
  message: f.message,
  reason: PrinterFailureReason.values.firstWhere(
    (r) => r.name == f.reason,
    orElse: () => PrinterFailureReason.unexpected,
  ),
);

// ─────────────────────────────────────────────────────────────────
// Seri port
// ─────────────────────────────────────────────────────────────────

class SerialPrinterTransport implements IPrinterTransport {
  const SerialPrinterTransport({required this.portName, required this.baudRate});

  final String portName;
  final int baudRate;

  /// Sistemdeki seri port adları (ayar ekranı için).
  static List<String> availablePorts() {
    try {
      return SerialPort.availablePorts;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> send(Uint8List data, {required String jobName}) async {
    final portName = this.portName;
    final baudRate = this.baudRate;
    final failure = await Isolate.run(() => _serialSend(portName, baudRate, data));
    if (failure != null) throw _toException(failure);
  }
}

/// Isolate içinde çalışır. Başarıda null döner.
_SendFailure? _serialSend(String portName, int baudRate, Uint8List data) {
  // Akış kontrolü yok: veri baud hızından hızlı gidemez, yazıcı ise 115200'de
  // bile gelen veriden hızlı basar. Parçalar tampon taşmasına karşı küçük tutulur.
  const chunkSize = 256;
  final bytesPerSecond = baudRate / 10; // 8N1 → 10 bit/bayt

  SerialPort? port;
  try {
    port = SerialPort(portName);
    if (!port.openWrite()) {
      return (
        reason: PrinterFailureReason.connectionFailed.name,
        message: 'Yazıcı portu açılamadı: $portName (${SerialPort.lastError})',
      );
    }

    final config = SerialPortConfig()
      ..baudRate = baudRate
      ..bits = 8
      ..parity = SerialPortParity.none
      ..stopBits = 1
      ..setFlowControl(SerialPortFlowControl.none);
    port.config = config;
    config.dispose();

    for (var offset = 0; offset < data.length; offset += chunkSize) {
      final end = (offset + chunkSize) < data.length ? offset + chunkSize : data.length;
      final chunk = Uint8List.sublistView(data, offset, end);
      // Beklenen sürenin 3 katı + 1 sn pay.
      final timeoutMs = (chunk.length / bytesPerSecond * 3000).ceil() + 1000;
      final written = port.write(chunk, timeout: timeoutMs);
      if (written < chunk.length) {
        return (
          reason: written < 0 ? PrinterFailureReason.writeFailed.name : PrinterFailureReason.timeout.name,
          message: 'Yazıcıya veri gönderilemedi: $portName ($offset/${data.length} bayt)',
        );
      }
    }
    // İşletim sistemi tamponundaki son baytların hattan çıkmasını bekle.
    port.drain();
    return null;
  } on SerialPortError catch (e) {
    return (reason: PrinterFailureReason.connectionFailed.name, message: 'Seri port hatası: $portName ($e)');
  } catch (e) {
    return (reason: PrinterFailureReason.unexpected.name, message: 'Seri gönderim hatası: $portName ($e)');
  } finally {
    // Temizleme sırası: close → dispose (SerialCommunicationService ile aynı ilke).
    try {
      if (port?.isOpen ?? false) port!.close();
    } catch (_) {}
    port?.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────
// Windows yazıcı kuyruğu (RAW)
// ─────────────────────────────────────────────────────────────────

class WindowsSpoolerPrinterTransport implements IPrinterTransport {
  const WindowsSpoolerPrinterTransport({required this.printerName});

  final String printerName;

  /// Kurulu Windows yazıcılarının adları (ayar ekranı için).
  static List<String> installedPrinters() {
    if (!Platform.isWindows) return const [];
    return using((arena) {
      const flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;
      final needed = arena<Uint32>();
      final returned = arena<Uint32>();
      EnumPrinters(flags, nullptr, 4, nullptr, 0, needed, returned);
      if (needed.value == 0) return const <String>[];

      final buffer = arena<Uint8>(needed.value);
      if (EnumPrinters(flags, nullptr, 4, buffer, needed.value, needed, returned) == 0) {
        return const <String>[];
      }
      final infos = buffer.cast<PRINTER_INFO_4>();
      return [for (var i = 0; i < returned.value; i++) infos[i].pPrinterName.toDartString()];
    });
  }

  @override
  Future<void> send(Uint8List data, {required String jobName}) async {
    if (!Platform.isWindows) {
      throw const PrinterException(
        message: 'Windows yazıcı kuyruğu yalnızca Windows\'ta kullanılabilir',
        reason: PrinterFailureReason.connectionFailed,
      );
    }
    final printerName = this.printerName;
    final failure = await Isolate.run(() => _spoolerSend(printerName, jobName, data));
    if (failure != null) throw _toException(failure);
  }
}

/// Isolate içinde çalışır. Başarıda null döner.
_SendFailure? _spoolerSend(String printerName, String jobName, Uint8List data) {
  return using((arena) {
    final handle = arena<IntPtr>();
    if (OpenPrinter(printerName.toNativeUtf16(allocator: arena), handle, nullptr) == 0) {
      return (
        reason: PrinterFailureReason.connectionFailed.name,
        message: 'Yazıcı kuyruğu açılamadı: $printerName (Win32 hata ${GetLastError()})',
      );
    }
    final h = handle.value;
    var docStarted = false;
    var pageStarted = false;
    try {
      final docInfo = arena<DOC_INFO_1>()
        ..ref.pDocName = jobName.toNativeUtf16(allocator: arena)
        ..ref.pOutputFile = nullptr
        // RAW: sürücü veriyi işlemeden yazıcıya geçirir.
        ..ref.pDatatype = 'RAW'.toNativeUtf16(allocator: arena);

      if (StartDocPrinter(h, 1, docInfo) == 0) {
        return (
          reason: PrinterFailureReason.connectionFailed.name,
          message: 'Yazdırma işi başlatılamadı: $printerName (Win32 hata ${GetLastError()})',
        );
      }
      docStarted = true;
      if (StartPagePrinter(h) == 0) {
        return (reason: PrinterFailureReason.writeFailed.name, message: 'Sayfa başlatılamadı: $printerName');
      }
      pageStarted = true;

      final buffer = arena<Uint8>(data.length);
      buffer.asTypedList(data.length).setAll(0, data);
      final written = arena<Uint32>();
      if (WritePrinter(h, buffer, data.length, written) == 0 || written.value != data.length) {
        return (
          reason: PrinterFailureReason.writeFailed.name,
          message: 'Yazıcıya veri gönderilemedi: $printerName (${written.value}/${data.length} bayt)',
        );
      }
      return null;
    } finally {
      if (pageStarted) EndPagePrinter(h);
      if (docStarted) EndDocPrinter(h);
      ClosePrinter(h);
    }
  });
}
