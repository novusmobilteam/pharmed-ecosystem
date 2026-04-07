// pharmed-client/core/hardware/service/rfid/mock_rfid_service.dart

import 'package:pharmed_core/pharmed_core.dart';

import '../../model/rfid_tag.dart';
import 'i_rfid_service.dart';

/// Dev/test flavor için sabit tag listesi döner.
/// Gerçek TCP bağlantısı kurmaz.
class MockRfidService implements IRfidService {
  static const _mockTags = [
    RfidTag(epc: '010CE280689400005017CFB6', rssi: -45, antenna: 1),
    RfidTag(epc: '010CE280689400004017CFB5', rssi: -52, antenna: 1),
    RfidTag(epc: '010CE280689400003017CFB4', rssi: -48, antenna: 1),
    RfidTag(epc: '010CE280689400002017CFB3', rssi: -61, antenna: 1),
    RfidTag(epc: '010CE280689400001017CFB2', rssi: -55, antenna: 1),
    RfidTag(epc: '010CE280689400000017CFB1', rssi: -43, antenna: 1),
    RfidTag(epc: '010CE280689400009017CFB0', rssi: -58, antenna: 1),
    RfidTag(epc: '010CE280689400008017CFAF', rssi: -50, antenna: 1),
    RfidTag(epc: '010CE280689400007017CFAE', rssi: -47, antenna: 1),
    RfidTag(epc: '010CE280689400006017CFAD', rssi: -54, antenna: 1),
  ];

  bool _connected = false;

  /// Mock: scan çağrıldığında bu index'ten sonraki tag'leri döner.
  /// Test senaryolarında dışarıdan set edilebilir.
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
    // Gerçek scan süresini simüle et
    await Future.delayed(const Duration(seconds: 2));
    return Result.ok(List.of(mockTags));
  }

  @override
  Future<Result<void>> setPower(int dbm) async {
    return const Result.ok(null);
  }
}
