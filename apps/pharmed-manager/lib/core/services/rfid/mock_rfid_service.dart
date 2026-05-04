// [SWREQ-RFID-001] [IEC 62304 §5.5]
// Mock RFID servisi — dev/mock flavor için sabit tag listesi döner.
// Gerçek TCP bağlantısı kurmaz.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class MockRfidService implements IRfidService {
  static const _mockTags = [
    RfidTag(epc: '010CE280689400005017CFB6', rssi: -45, antenna: 1),
    RfidTag(epc: '010CE280689400004017CFB5', rssi: -52, antenna: 1),
    RfidTag(epc: '010CE280689400003017CFB4', rssi: -48, antenna: 1),
    RfidTag(epc: '010CE280689400002017CFB3', rssi: -61, antenna: 1),
    RfidTag(epc: '010CE280689400001017CFB2', rssi: -55, antenna: 1),
  ];

  bool _connected = false;

  /// Test senaryolarında dışarıdan override edilebilir.
  List<RfidTag> mockTags = List.of(_mockTags);

  @override
  bool get isConnected => _connected;

  @override
  Future<Result<void>> connect(String host, int port) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _connected = true;
    return const Result.ok(null);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Future<Result<List<RfidTag>>> scan() async {
    if (!_connected) {
      return Result.error(ServiceException(message: 'Mock RFID servisi bağlı değil.', statusCode: 503));
    }
    await Future.delayed(const Duration(seconds: 2)); // Gerçek scan süresini simüle et
    return Result.ok(List.of(mockTags));
  }

  @override
  Future<Result<void>> setPower(int dbm) async => const Result.ok(null);

  @override
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Result.ok(RfidReaderInfo(firmwareVersion: '3.2', readerType: 1, maxPower: 30, currentPower: 22));
  }
}
