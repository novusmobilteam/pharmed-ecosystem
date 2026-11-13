// Uygulama genelindeki TEK test durumu modeli. Test adımları, senaryolar ve
// ekrandaki rozetler bu değerleri kullanır; renk ve ikon eşlemesi
// `widgets/status.dart` içindedir (pharmed_ui `MedTone` üzerinden).

enum TestStatus {
  /// Henüz çalıştırılmadı.
  pending('Bekliyor'),

  /// Şu an çalışıyor / teknisyenden gözlem bekleniyor.
  running('Çalışıyor'),

  /// Beklenen sonuç alındı.
  passed('Başarılı'),

  /// Beklenen sonuç alınamadı.
  failed('Başarısız'),

  /// Çalıştı ama dikkat edilmesi gereken bir durum var.
  warning('Uyarı'),

  /// Teknisyen atladı ya da ön koşul sağlanmadığı için çalıştırılmadı.
  skipped('Atlandı'),

  /// Sonuç değil, bilgi kaydı (ör. tarama çıktısı, bağlantı olayı).
  info('Bilgi');

  const TestStatus(this.label);

  final String label;

  /// Sonuçlanmış mı (başarılı, başarısız, uyarı, atlandı).
  bool get isFinished => this == passed || this == failed || this == warning || this == skipped;
}
