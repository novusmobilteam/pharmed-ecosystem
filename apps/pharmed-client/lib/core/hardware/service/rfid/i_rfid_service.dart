import 'package:pharmed_core/pharmed_core.dart';

import '../../model/rfid_tag.dart';

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
}
