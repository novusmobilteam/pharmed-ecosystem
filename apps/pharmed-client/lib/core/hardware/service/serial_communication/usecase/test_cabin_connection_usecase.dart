// [SWREQ-SETUP-UI-016]
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import '../i_serial_communication_service.dart';

class TestCabinConnectionUseCase {
  const TestCabinConnectionUseCase(this._serialService);

  final ISerialCommunicationService _serialService;

  Future<Result<void>> call(String portName) async {
    try {
      await _serialService.connectToPort(portName);
      await _serialService.disconnect();
      return const Result.ok(null);
    } on SerialPortException catch (e) {
      return Result.error(ServiceException(message: e.message, statusCode: 503));
    } catch (e) {
      return Result.error(ServiceException(message: 'Bağlantı testi başarısız: $e', statusCode: 500));
    }
  }
}
