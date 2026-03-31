// apps/pharmed-client/lib/core/hardware/service/mock_serial_communication_service.dart

import 'package:flutter/foundation.dart';

import 'i_serial_communication_service.dart';

/// SERİ PORT HABERLEŞMESİ — MOCK İMPLEMENTASYON
/// ----------------------------------------------
/// Fiziksel seri port olmadan komut/cevap simülasyonu yapar.
/// Mock flavor'da (`main_mock.dart`) kullanılır.
class MockSerialCommunicationService implements ISerialCommunicationService {
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  List<String> getAvailablePorts() => ['COM2', 'COM3'];

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) async {
    onStatusChanged?.call('$portName portuna bağlanılıyor...');
    await Future.delayed(const Duration(seconds: 1));
    _connected = true;
    onStatusChanged?.call('Bağlantı başarılı: $portName');
    debugPrint('MOCK: $portName portuna bağlanıldı.');
  }

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    if (!_connected) return null;

    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('MOCK IO >> $command');

    // Yönetim kartı satır seçimi: :Ya... → +ok-
    if (command.startsWith(':Ya')) return '+ok-';
    // Kilit açma: :TO... → .ok,
    if (command.startsWith(':TO')) return '.ok,';
    // Kapak açma: :Z... → [ac]
    if (command.startsWith(':Z')) return '[ac]';
    // Durum sorgusu: :TS... → .h3, (açık)
    if (command.startsWith(':TS')) return '.h3,';
    // Tip sorgusu: :TV... → varsayılan tip
    if (command.startsWith(':TV')) return '.01,';

    return 'ok';
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    debugPrint('MOCK: Port bağlantısı kapatıldı.');
  }
}
