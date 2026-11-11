// Seri hat trafik kaydı: her TX/RX zaman damgası ve süresiyle tutulur.
// Hem ekrandaki trafik panelinde gösterilir hem de test raporuna yazılır.

import 'package:flutter/foundation.dart';
import 'package:pharmed_core/pharmed_core.dart';

class TrafficEntry {
  TrafficEntry({required this.time, required this.command, this.response, this.error, required this.elapsed});

  final DateTime time;
  final String command;
  final String? response;
  final String? error;
  final Duration elapsed;

  String get responseText => error != null ? 'HATA: $error' : (response?.trim() ?? '(cevap yok)');

  String toLine() =>
      '${formatTime(time)}  TX ${command.padRight(12)}  RX ${responseText.padRight(14)}  ${elapsed.inMilliseconds} ms';
}

String formatTime(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  String three(int v) => v.toString().padLeft(3, '0');
  return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.${three(t.millisecond)}';
}

class TrafficLog extends ChangeNotifier {
  static const _max = 2000;
  final List<TrafficEntry> _entries = [];

  List<TrafficEntry> get entries => List.unmodifiable(_entries);

  void add(TrafficEntry entry) {
    _entries.add(entry);
    if (_entries.length > _max) _entries.removeRange(0, _entries.length - _max);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

/// [ISerialCommunicationService] sarmalayıcısı: gerçek servise iletir, her komutu
/// [TrafficLog]'a yazar. Böylece client ile aynı servis kodu (CabinOperationService)
/// kullanılırken hattaki tüm trafik de görünür olur.
class LoggingSerialService implements ISerialCommunicationService {
  LoggingSerialService(this._inner, this._log);

  final ISerialCommunicationService _inner;
  final TrafficLog _log;

  @override
  bool get isConnected => _inner.isConnected;

  @override
  List<String> getAvailablePorts() => _inner.getAvailablePorts();

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) =>
      _inner.connectToPort(portName, onStatusChanged: onStatusChanged);

  @override
  Future<void> disconnect() => _inner.disconnect();

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    final started = DateTime.now();
    final sw = Stopwatch()..start();
    try {
      final response = await _inner.sendAndReceive(command, timeout: timeout);
      _log.add(TrafficEntry(time: started, command: command, response: response, elapsed: sw.elapsed));
      return response;
    } catch (e) {
      _log.add(TrafficEntry(time: started, command: command, error: e.toString(), elapsed: sw.elapsed));
      rethrow;
    }
  }
}
