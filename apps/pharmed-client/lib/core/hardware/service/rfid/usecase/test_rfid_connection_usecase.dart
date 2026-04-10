// [SWREQ-RFID-004]
// Sınıf: Class B
import 'package:pharmed_core/pharmed_core.dart';

import '../i_rfid_service.dart';
import '../model/rfid_reader_info.dart';

class TestRfidConnectionUseCase {
  const TestRfidConnectionUseCase(this._rfidService);

  final IRfidService _rfidService;

  Future<Result<RfidReaderInfo>> call({required String ip, required int port}) =>
      _rfidService.testConnection(ip: ip, port: port);
}
