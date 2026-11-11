# pharmed-hw-test — Donanım test uygulaması

Saha teknisyenlerinin kabin donanımını client/manager kullanmadan test etmesi için ayrı Windows uygulaması. Kabin kartları ve RFID okuyucuyla client'ın kullandığı **aynı servis koduyla** (`packages/pharmed_hardware`) konuşur; sahada görülen davranış client'taki davranışın aynısıdır.

Protokol: [`docs/hardware/rs485-protokol.md`](../../docs/hardware/rs485-protokol.md)

## Kullanım

1. **Giriş:** Kullanıcı kendi hesabıyla giriş yapar (ek şifre yok). Çekmece tanımları servisten çekildiği için giriş gerekir.
2. **Bağlantı:** COM porta bağlanılır. Uygulama istasyondan bağımsızdır.
3. **Hat taraması:** a–p adreslerine `:Y?00c;` gönderilir. Cevap veren yönetim kartları (kabinler) listelenir, ısı/nem ve akü okunur. Satır 00 seçimi de bıraktığı için tarama hatta açık seçim bırakmaz.
4. **Kart taraması:** Seçilen yönetim kartında satır 01–26 taranır (client'taki `discoverControlCards`). Her kart için ham tip cevabı, tip numarasıyla eşleşen **tüm** servis tanımları ve göz sayısı gösterilir; birden fazla tanım eşleşirse uyarı verilir. "Kübik gözleri yokla" ile `Z M` komutu sıra 00–04 × port 1–4 için gönderilir ve cevap veren gözler tabloda görünür (16/20 gözlü kübik ayrımı).
5. **Master çekmece:** Standart çekmece aç / durum (h0–h9), kübik kapak aç / durum (ac/kp), serum kapağı aç / durum. Çoklu kabinde açma sonrası "Yalnız hedef açıldı" / "Başka kabin de açıldı" gözlemi rapora işlenir; "Tüm kabinlerde seçimi bırak" ile hattaki seçimler sıfırlanır.
6. **Mobil kabin:** Yönetim kartında satır 26 (serum kartı slave modu) seçilip port 1–8 çekmeceleri açılır / durumu okunur (`h3` açık, `h0`/`h4` kilitli). Port başına canlı durum izleme (1 sn) ve "tüm portları sırayla test et" vardır; çoklu açılma gözlemi rapora işlenir.
7. **RFID:** UHFEx10 okuyucuya TCP ile bağlanılır (varsayılan `192.168.1.190:6000`): bağlantı testi (firmware, güç), güç ayarı, envanter başlat/durdur ve canlı etiket listesi (EPC, okuma sayısı, RSSI, anten). Envanter durdurulunca okunan etiketler rapora eklenir.
8. **Konsol:** `Y` / `T` / `Z` komutları alanlardan checksum'ıyla üretilir ya da elle yazılır.
9. **Rapor:** Tüm test adımları ve seri hat trafiği `Belgeler\PharMed-HwTest\rapor-<tarih>.txt` dosyasına kaydedilir.

Ekranın altındaki panel hattaki tüm komutları (TX) ve cevapları (RX) süreleriyle gösterir.

## Çalıştırma ve derleme

```bash
cd apps/pharmed-hw-test
flutter run -d windows -t lib/main_dev.dart
flutter build windows --release -t lib/main_dev.dart --dart-define=APP_VERSION=v0.1.0
```

macOS'ta yalnız arayüz kontrol edilebilir (kabin/seri port testi yapılamaz; giriş çalışır):

```bash
cd apps/pharmed-hw-test
flutter run -d macos -t lib/main_dev.dart   # ya da: dart run melos run run:hw-test:mac
```

CI: Actions → "Windows Build" → uygulama `hw-test` (ya da `all`). Release'te otomatik derlenir. Paket VC++ runtime DLL'lerini içerir; zip'i açıp `pharmed_hw_test.exe` çalıştırmak yeterlidir.

## Notlar

- Mock donanım yoktur; uygulama her zaman gerçek seri port kullanır. macOS'ta port listesi boş görünebilir.
- Arayüz yalnız Türkçedir (saha aracı).
