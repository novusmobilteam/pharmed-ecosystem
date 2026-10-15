// Master kabin donanım kuyruğunun (Census/Refill/Unload/Refund — Intake
// HARİÇ, bkz. IntakeCellGrouper notu) ortak sözleşmesi. Kuyruk birimi HER
// ZAMAN fiziksel çekmecedir, göz değil — bu kural CabinOperationDrawerJob/
// RefillDrawerJob/RefundDrawerJob/IntakeDrawerJob'ın dördünde de ayrı ayrı
// dokümante edilmişti, burada tek yerde ifade ediliyor.
//
// Saf domain — Flutter bağımsız.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class DrawerJobTarget {
  /// Bu hedefin fiziksel adresi (çekmece/göz + stok). Non-null olmalı —
  /// nullable assignment durumu (IntakeTarget gibi) bu arayüze uymaz.
  MedicineAssignment get assignment;

  /// Bu hedef açılırken çekmecenin/gözün ne kadar derine (kaç kademe)
  /// açılacağını sınırlar — null ise tam açılır. Şu an sadece Intake'in
  /// birim-doz akışında (güvenlik: FIFO'nun izin verdiği kadar) kullanılıyor;
  /// diğer tüm job tipleri null döner (davranış değişmez).
  int? get explicitTargetStep;

  /// Elektromanyetik kilitli serum rafındaki avadanlığın kilit adresi —
  /// çekmece (serum kapağı) açıldıktan sonra bu avadanlığın kilidi açılır.
  /// Serum dışı ve kilitsiz raftaki hedeflerde null.
  SerumTrayAddress? get serumTray;
}

abstract interface class DrawerJob<T extends DrawerJobTarget> {
  List<T> get targets;

  /// Kübik çekmece mi — lid-by-lid ilerleme mi, fiziksel aç/kapa mı.
  bool get isKubik;

  /// true → job'un TÜM target'ları aynı açık çekmecede ilerler (kübik lid /
  /// iade çekmecesi gibi), fiziksel aç/kapa döngüsüne hiç girilmez.
  /// false → her target kendi fiziksel aç/kapa döngüsünü yaşar (birim doz).
  bool get staysOpenAcrossTargets;

  /// Serum avadanlık job'u — serum kapağı bir kez açılır ve tüm avadanlıklar
  /// aynı açılışta işlenir. Kilitli raftaki avadanlığın ([DrawerJobTarget.
  /// serumTray]) kilidi açılır ve yerine itilmesi beklenir (kübik kapağın
  /// eşi); kilitsiz raftakinde yalnızca kapak açıktır.
  bool get isSerumTrayJob;

  /// Çekmeceyi açma komutu için kullanılacak temsilci adres.
  MedicineAssignment get representativeAssignment;

  CabinOperationJobStatus get status;

  /// Fiziksel çekmece kimliği — konum rehberinde aktif item'ı bulmak için.
  int get cabinDrawerId;

  /// Çekmecenin bulunduğu kabin — çoklu kabin şeridi ve kabin yerleşimi için.
  int? get cabinId;

  /// copyWith(status: ...)'a yönlendiren adaptör — her concrete job kendi
  /// immutable copyWith'ini kullanır, mixin somut tipi bilmez.
  DrawerJob<T> copyWithStatus(CabinOperationJobStatus status);

  /// Aktif job'ın hedef listesini değiştirir (örn. bir hedefin sayım/doz
  /// girdisi güncellendiğinde). Status/diğer alanlar korunur.
  DrawerJob<T> copyWithTargets(List<T> targets);
}
