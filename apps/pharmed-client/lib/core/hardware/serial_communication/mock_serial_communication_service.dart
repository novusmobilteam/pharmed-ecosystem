import 'package:flutter/material.dart';

import 'i_serial_communication_service.dart';

class MockSerialCommunicationService implements ISerialCommunicationService {
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  List<String> getAvailablePorts() {
    return ["COM2", "COM3"];
  }

  @override
  Future<void> connectToPort(String portName, {Function(String message)? onStatusChanged}) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("MOCK: $portName portuna bağlanıldı.");
    _connected = true;
  }

  @override
  Future<String?> sendAndReceive(String command, {Duration? timeout}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint("MOCK IO -> Giden: $command");

    // Basit cevap mantığı
    if (command.startsWith(":Ya")) return "+ok-"; // Satır seçimi
    if (command.startsWith(":TO")) return ".ok,"; // Kilit açma
    if (command.startsWith(":Z")) return "[ac]"; // Kapak açma
    if (command.startsWith(":TS")) return ".h3,"; // Durum sorgusu (Hemen açık dön)

    return "unknown";
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }
}
