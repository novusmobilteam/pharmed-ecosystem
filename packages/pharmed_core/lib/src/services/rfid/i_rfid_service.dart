// [SWREQ-RFID-001] [IEC 62304 §5.5]
// RFID servis arayüzü — TCP tabanlı UHF okuyucu soyutlaması.
// Sınıf: Class B

import '../../result/result.dart';
import 'rfid_reader_info.dart';
import 'rfid_tag.dart';

abstract interface class IRfidService {
  /// TCP bağlantısı kurar.
  /// Uygulama başlangıcında veya operasyon öncesinde bir kez çağrılır.
  Future<Result<void>> connect(String host, int port);

  /// Bağlantıyı kapatır.
  Future<void> disconnect();

  /// Anlık bağlantı durumu.
  bool get isConnected;

  /// Antendeki tüm tag'leri okur (2 saniyelik scan).
  /// Aynı EPC birden fazla algılanırsa en yüksek RSSI değeri saklanır.
  Future<Result<List<RfidTag>>> scan();

  /// RF güç seviyesini ayarlar (dBm).
  Future<Result<void>> setPower(int dbm);

  /// Bağlantıyı test eder ve okuyucu bilgisini döner.
  /// Setup wizard'da bağlantı doğrulama için kullanılır.
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port});
}
