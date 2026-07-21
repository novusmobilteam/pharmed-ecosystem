// pharmed_core/lib/src/services/i_rfid_service.dart
//
// [SWREQ-RFID-IFC-001] [IEC 62304 §5.5]
// RFID okuyucu donanım servisi soyutlaması.
//
// Akış:
//   1. connect(host, port)         → TCP bağlantısı kurulur
//                                    (defensive Answer Mode'a alınır)
//   2. startInventory() → Stream   → Cihaz Real-time mode'a alınır,
//                                    okunan her tag stream'e yayınlanır
//   3. stopInventory()             → Cihaz Answer Mode'a geri alınır,
//                                    stream sonlanır
//   4. disconnect()                → stopInventory + socket close
//
// Notlar:
//   - Aynı anda tek bir inventory aktif olabilir (single-subscription).
//   - Real-time mode flash'a yazılı olduğu için connect() defensive olarak
//     önce Answer Mode'a alır (crash recovery).
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract class IRfidService {
  bool get isConnected;

  /// TCP bağlantısı kur. Bağlantı sonrası cihaz Answer Mode'a alınır.
  Future<Result<void>> connect(String host, int port);

  /// Bağlantıyı kapat. Aktif inventory varsa önce durdurulur.
  Future<void> disconnect();

  /// Sürekli inventory başlat. Cihaz Real-time mode'a geçer ve okunan
  /// her tag stream'e yayınlanır. Stream single-subscription'dur.
  ///
  /// Aynı anda iki kez çağrılırsa [StateError] fırlatır
  /// (önce [stopInventory] çağrılmalı).
  Stream<RfidTag> startInventory();

  /// Aktif inventory'i durdur. Cihaz Answer Mode'a geri alınır.
  Future<Result<void>> stopInventory();

  /// Bağlantı testi (ayrı socket açar, kalıcı bağlantıya etkisi yok).
  Future<Result<RfidReaderInfo>> testConnection({required String ip, required int port});

  /// RF güç ayarı (Answer Mode'da çalışır).
  Future<Result<void>> setPower(int dbm);
}
