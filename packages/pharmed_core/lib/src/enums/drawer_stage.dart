enum DrawerStage {
  idle, // Boşta, işlem yok
  connecting, // Cihaza bağlanılıyor / Kart aranıyor
  unlockingMaster, // Ana kilit (veya standart kilit) açılıyor
  waitingForPull, // Kilit açıldı, kullanıcının çekmesi bekleniyor (h3 aranıyor)
  openingLid, // Kübik kapak açılıyor
  readyForFilling, // Kapak açıldı, dolum yapılabilir (UI bu aşamada dolum ekranını açar)
  waitingForClose, // Dolum bitti, kullanıcının kapatması bekleniyor (h0 aranıyor)
  completed, // İşlem tamamen bitti
  error // Bir hata oluştu
}

extension DrawerStageExtension on DrawerStage {
  bool get isBusy => this != DrawerStage.idle && this != DrawerStage.completed && this != DrawerStage.error;
}
