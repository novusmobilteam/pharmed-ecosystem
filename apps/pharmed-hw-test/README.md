# pharmed-hw-test — Donanım test uygulaması

Saha teknisyenlerinin kabin donanımını client/manager kullanmadan test etmesi için ayrı Windows uygulaması. Kabin kartlarıyla client'ın kullandığı **aynı servis koduyla** (`packages/pharmed_hardware`) konuşur; sahada görülen davranış client'taki davranışın aynısıdır.

Protokol: [`docs/hardware/rs485-protokol.md`](../../docs/hardware/rs485-protokol.md)

## Kullanım

1. **Giriş:** Kullanıcı kendi hesabıyla giriş yapar (ek şifre yok). Çekmece tanımları ve istasyon/kabin bilgisi servisten çekildiği için giriş gerekir.
2. **Bağlantı:** Test edilecek istasyon seçilir (kabinler ve yönetim kartı adresleri listelenir), COM porta bağlanılır.
3. **Hat taraması:** a–p adreslerine `:Y?00c;` gönderilir. Cevap veren yönetim kartları istasyondaki kabin tanımlarıyla karşılaştırılır (cevap vermeyen kabin / tanımsız kart), ısı/nem ve akü okunur. Satır 00 seçimi de bıraktığı için tarama hatta açık seçim bırakmaz.
4. **Kart taraması:** Seçilen yönetim kartında satır 01–26 taranır (client'taki `discoverControlCards`). Her kart için ham tip cevabı, tip numarasıyla eşleşen **tüm** servis tanımları ve göz sayısı gösterilir; birden fazla tanım eşleşirse uyarı verilir. "Kübik gözleri yokla" ile `Z M` komutu sıra 00–04 × port 1–4 için gönderilir ve cevap veren gözler tabloda görünür (16/20 gözlü kübik ayrımı).
5. **Çekmece testi:** Standart çekmece aç / durum (h0–h9), kübik kapak aç / durum (ac/kp), serum kapağı aç / durum. Çoklu kabinde açma sonrası "Yalnız hedef açıldı" / "Başka kabin de açıldı" gözlemi rapora işlenir; "Tüm kabinlerde seçimi bırak" ile hattaki seçimler sıfırlanır.
6. **Konsol:** `Y` / `T` / `Z` komutları alanlardan checksum'ıyla üretilir ya da elle yazılır.
7. **Rapor:** Tüm test adımları ve seri hat trafiği `Belgeler\PharMed-HwTest\rapor-<tarih>.txt` dosyasına kaydedilir.

Ekranın altındaki panel hattaki tüm komutları (TX) ve cevapları (RX) süreleriyle gösterir.

## Çalıştırma ve derleme

```bash
cd apps/pharmed-hw-test
flutter run -d windows -t lib/main_dev.dart
flutter build windows --release -t lib/main_dev.dart --dart-define=APP_VERSION=v0.1.0
```

CI: Actions → "Windows Build" → uygulama `hw-test` (ya da `all`). Release'te otomatik derlenir. Paket VC++ runtime DLL'lerini içerir; zip'i açıp `pharmed_hw_test.exe` çalıştırmak yeterlidir.

## Notlar

- Mock donanım yoktur; uygulama her zaman gerçek seri port kullanır.
- Arayüz yalnız Türkçedir (saha aracı).
