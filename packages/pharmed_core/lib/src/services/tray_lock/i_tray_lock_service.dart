// [SWREQ-HW-TRAY-001] [IEC 62304 §5.5]
// Serum kabini elektromanyetik avadanlık kilit kartı servisi.
//
// KAPSAM: yalnızca donanımla konuşan en alt katman. Hangi rafın hangi kart
// (deviceId), hangi avadanlığın hangi port olduğu bu servisin konusu DEĞİLDİR;
// çağıran taraf (oturum/orchestrator) bunları çözer.
//
// HAT: Kart, master kabinle AYNI RS485 hattındadır. Ayrı port açılmaz;
// komutlar ISerialCommunicationService üzerinden (aynı mutex) gönderilir.
//
// HATALAR: Tüm metotlar başarısızlıkta [TrayLockException] fırlatır.
//
// İKİ İMPLEMENTASYON:
//   - TrayLockService: gerçek kart (pharmed-client)
//   - MockTrayLockService: kart durum makinesi simülasyonu (mock/dev flavor)
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class ITrayLockService {
  /// Kartın tüm kilitlerini enerjiler — raftaki tüm avadanlıklar sabitlenir.
  /// Bir avadanlık çekiliyken [TrayLockFailure.trayOpen].
  Future<void> lockAll({required int deviceId});

  /// Kartın tüm kilitlerini serbest bırakır.
  /// Bir avadanlık çekiliyken [TrayLockFailure.trayOpen].
  Future<void> unlockAll({required int deviceId});

  /// [port]'un kilidini açar; kart diğer tüm portları kendisi kilitler.
  /// Kart meşgulse (başka port açık) [TrayLockFailure.busy].
  ///
  /// Yanıt kaybolup komut kartta uygulanmış olabileceği için, onay
  /// alınamazsa port durumu sorgulanır; port zaten açılmışsa başarılı sayılır.
  Future<void> unlock({required int deviceId, required int port});

  /// Henüz çekilmemiş bir açmayı iptal eder (port tekrar kilitlenir).
  /// Avadanlık çekildiyse [TrayLockFailure.alreadyPulled].
  Future<void> cancelUnlock({required int deviceId, required int port});

  /// [port]'un anlık durumu.
  Future<TrayLockStatus> getStatus({required int deviceId, required int port});

  /// [port] önündeki +/- panelinden girilmiş değer (0-99).
  Future<int> getKeypadValue({required int deviceId, required int port});

  /// [port]'un durumunu [interval] aralıkla yayınlar; yalnızca DEĞİŞİMDE
  /// yayın yapar. Okuma hatası stream'i kapatmaz, hata olarak iletilir —
  /// dinleyen taraf ne kadar ardışık hatayı tolere edeceğine kendisi karar verir.
  Stream<TrayLockStatus> watchStatus({required int deviceId, required int port, Duration? interval});
}
