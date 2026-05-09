// [SWREQ-CLI-CABIN-OP-010] [IEC 62304 §5.5]
// Master kabin çekmece oturumunun anlık fiziksel aşamaları.
//
// DrawerStage enum'unun sealed class karşılığı.
// Mobil kabindeki MobileDrawerStage ile paralel tasarım —
// kübik çekmece için WaitingForPull + OpeningLid + Opened aşamaları eklenmiştir.
//
// Sınıf: Class B

// ignore_for_file: public_member_api_docs

/// Master kabin çekmece oturum aşamaları.
sealed class MasterDrawerStage {
  const MasterDrawerStage();

  /// Oturum aktif mi? (Idle ve terminal state'ler dışındakiler)
  bool get isActive => switch (this) {
    MasterDrawerIdle() => false,
    MasterDrawerClosed() => false,
    MasterDrawerFailed() => false,
    _ => true,
  };
}

/// Boşta — aktif oturum yok.
final class MasterDrawerIdle extends MasterDrawerStage {
  const MasterDrawerIdle();
}

/// Bağlanıyor / kilit açılıyor.
/// DrawerStage.connecting + unlockingMaster aşamalarını kapsar.
final class MasterDrawerOpening extends MasterDrawerStage {
  const MasterDrawerOpening({required this.message});

  /// Kullanıcıya gösterilecek durum metni.
  final String message;
}

/// Kilit açıldı, kullanıcının çekmesi bekleniyor.
/// DrawerStage.waitingForPull karşılığı.
final class MasterDrawerWaitingForPull extends MasterDrawerStage {
  const MasterDrawerWaitingForPull();
}

/// Kübik çekmece: iç kapaklar açılıyor.
/// DrawerStage.openingLid karşılığı — sadece kübik çekmecelerde geçilir.
final class MasterDrawerOpeningLid extends MasterDrawerStage {
  const MasterDrawerOpeningLid();
}

/// Çekmece (veya kübik kapak) açık — kullanıcı dolum/sayım yapabilir.
/// DrawerStage.readyForFilling karşılığı.
final class MasterDrawerOpened extends MasterDrawerStage {
  const MasterDrawerOpened();
}

/// Dolum tamamlandı, kullanıcının çekmeceyi kapatması bekleniyor.
/// DrawerStage.waitingForClose karşılığı.
final class MasterDrawerWaitingForClose extends MasterDrawerStage {
  const MasterDrawerWaitingForClose();
}

/// Çekmece kapatıldı — işlem onayı bekliyor.
/// DrawerStage.completed karşılığı.
final class MasterDrawerClosed extends MasterDrawerStage {
  const MasterDrawerClosed();
}

/// Hata oluştu — oturum sonlandırıldı.
final class MasterDrawerFailed extends MasterDrawerStage {
  const MasterDrawerFailed({required this.message});

  final String message;
}
