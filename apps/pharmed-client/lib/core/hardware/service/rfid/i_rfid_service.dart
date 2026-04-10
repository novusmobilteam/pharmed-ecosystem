import 'package:pharmed_core/pharmed_core.dart';

import '../../model/rfid_tag.dart';
import 'model/rfid_reader_info.dart';

abstract interface class IRfidService {
  /// TCP bağlantısı kurar. Uygulama başlangıcında veya
  /// operasyon öncesinde bir kez çağrılır.
  Future<Result<void>> connect(String host, int port);

  /// Bağlantıyı kapatır.
  Future<void> disconnect();

  /// Bağlantı durumu.
  bool get isConnected;

  /// Antendeki tüm tag'leri okur (2 saniyelik scan).
  /// Aynı EPC birden fazla gelirse en yüksek RSSI saklanır.
  Future<Result<List<RfidTag>>> scan();

  /// RF güç seviyesini ayarlar (dBm).
  Future<Result<void>> setPower(int dbm);

  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port});
}
