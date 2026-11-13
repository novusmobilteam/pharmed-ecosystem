# pharmed-hw-test — Donanım test uygulaması

Saha teknisyenlerinin kabin donanımını client/manager kullanmadan test etmesi için ayrı Windows uygulaması. Kabin kartları ve RFID okuyucuyla client'ın kullandığı **aynı servis koduyla** (`packages/pharmed_hardware`) konuşur; sahada görülen davranış client'taki davranışın aynısıdır.

Protokol: [`docs/hardware/rs485-protokol.md`](../../docs/hardware/rs485-protokol.md)

## Kullanım

1. **Giriş:** Kullanıcı kendi hesabıyla giriş yapar (ek şifre yok). Çekmece tanımları servisten çekildiği için giriş gerekir.
   **Kabin tipi:** Girişten sonra **İlaç Bazlı Kabin** ya da **Hasta Bazlı Kabin** seçilir. Menüde yalnızca o kabinle ilgili testler görünür: İlaç Bazlı'da kart taraması, master çekmece ve serum kabini; Hasta Bazlı'da mobil kabin. Bağlantı, hat taraması, RFID, konsol ve rapor iki tipte de vardır. Tip üst çubuktan değiştirilebilir (COM bağlantısı korunur) ve rapora yazılır.
2. **Bağlantı:** COM porta bağlanılır. Uygulama istasyondan bağımsızdır.
   **Kabin:** Uygulama bu bilgisayardaki client kabin tanımını arar. Bulursa "Tanımlı cihaz var, bununla devam etmek ister misiniz?" diye sorar; teknisyen tanımla devam eder ya da kabini yeniden tarar. Client'ın Hive dosyaları (Belgeler klasörü: `app_settings`, `cabin_cache`, `drawer_slot_cache`, `cabin_meta_cache`) geçici bir klasöre **kopyalanıp** okunur, kopya silinir; client dosyaları hiç açılmaz ve yazılmaz. Yalnızca client'ın istasyonundaki kabinler gösterilir. "Kabini tara" hat taraması (a–p) ve kart taramasını (satır 01–26) tek seferde yapar, sonucu adres → kabin → çekmece/kapak olarak anlamlı adlarla gösterir (master kabin, serum kartına bağlı kabin, serum kabini). Client tanımı varsa tarama onunla karşılaştırılır ve farklar listelenir. Tarama sonucu yalnızca bu oturumda tutulur.
   **Testler:** Kabin tanımından test senaryoları otomatik üretilir ve her birinin sonucu ayrı görünür (Bekliyor / Çalışıyor / Başarılı / Başarısız / Atlandı). Yalnızca komutu client ile birebir aynı olan senaryolar üretilir: kübik çekmece ana kilidi (`DrawerAddress.cubicMaster`), serum kapağı, raf kilit kartı, avadanlık akış testi (kilitli raflar, Serum sayfasındaki tanımdan) ve mobil çekmece (client tanımındaki portlar). Kapı/kapak açan testlerde teknisyen "Açıldı / Açılmadı" onayı verir. "Sıradaki testi çalıştır" sonucu olmayan ilk senaryoyu başlatır; senaryo atlanabilir ya da tekrarlanabilir. Serum sayfasında yapılan testler aynı sonuçlara yazılır. Birim doz gözleri ve kübik kapaklar Master çekmece sayfasında kalır.
3. **Gelişmiş araçlar → Hat taraması:** a–p adreslerine `:Y?00c;` gönderilir. Cevap veren yönetim kartları (kabinler) listelenir, ısı/nem ve akü okunur. Satır 00 seçimi de bıraktığı için tarama hatta açık seçim bırakmaz.
4. **Gelişmiş araçlar → Kart taraması:** Seçilen yönetim kartında satır 01–26 taranır (client'taki `discoverControlCards`). Her kart için ham tip cevabı, tip numarasıyla eşleşen **tüm** servis tanımları ve göz sayısı gösterilir; birden fazla tanım eşleşirse uyarı verilir. Sonuç client'taki kuralla sınıflandırılır: master kabin, serum kartına bağlı kabin (satır 26'daki `.250` çekmece sayılmaz) ya da bağımsız serum kabini (#195). "Kübik gözleri yokla" ile `Z M` komutu sıra 00–04 × port 1–4 için gönderilir ve cevap veren gözler tabloda görünür (16/20 gözlü kübik ayrımı).
5. **Master çekmece:** Standart çekmece aç / durum (h0–h9), kübik kapak aç / durum (ac/kp), serum kapağı aç / durum. Çoklu kabinde açma sonrası "Yalnız hedef açıldı" / "Başka kabin de açıldı" gözlemi rapora işlenir; "Tüm kabinlerde seçimi bırak" ile hattaki seçimler sıfırlanır.
6. **Mobil kabin:** Yönetim kartında satır 26 (serum kartı slave modu) seçilip port 1–8 çekmeceleri açılır / durumu okunur (`h3` açık, `h0`/`h4` kilitli). Port başına canlı durum izleme (1 sn) ve "tüm portları sırayla test et" vardır; çoklu açılma gözlemi rapora işlenir.
7. **Serum** (İlaç Bazlı): Kabin tanımındaki serum bölmeleri (master) ve serum kabinleri listelenir. Serum kabininde kapak sayısı (1–4) seçilir. Her kapakta 3 raf tanımlanır: açık raf ya da avadanlık (küçük 1, orta 2, büyük 4 alan; 8 alan), elektromanyetik kilit var/yok. Client tanımından gelindiyse yerleşim servisten salt okunur yüklenir; değişiklikler kaydedilmez. Raf 8 alanlık şerit olarak görünür, avadanlıklar sağdan sola dizilir ve kilit portu client kuralıyla (`SerumTrayAddress`: kart ID = raf sırası, port = en sağdaki alan) hesaplanır. Testler: kapağı aç + "Açıldı / Açılmadı" onayı, kapak durumu, raf kilit kartı cevap veriyor mu, rafın tüm kilitlerini kilitle (`k`) / serbest bırak (`x`), avadanlık başına `o` / `c` / `s` / `t` ve akış testi (`x` → kapak aç → `k` → `o` → çek/it → kapak kapan → `x`).
8. **Gelişmiş araçlar → Serum keşfi ve kilit kartı:** Serum (tip 250) kartının kapakları nasıl adreslediğini bulmak içindir (#183). (1) "Serum kartını bul" satırları tarar, `.250` dönen kartları ve servisteki 250 tanımının göz sayısını gösterir (client taramada bu göz sayısını kullanır). (2) "Kapak keşfi" seçilen satırda `M` / `V` / `S` komutlarını **port 1–8 · göz 00** ya da **port 1 · göz 01–08** şemasıyla gönderir ve cevapları tabloda gösterir. Açma komutu göndermez. (3) "Kapak aç ve eşleştir" seçilen adresi açar, durumu 1 sn'de bir izler. Teknisyen hangi fiziksel kapağın açıldığını işaretler, adres → kapak tablosu rapora eklenir. (4) "Kapak testi" client'ın kullandığı komutla kapak 1–N'yi (kapak N → port N · göz 00) tek tek açar. Teknisyen her kapak için "Açıldı / Açılmadı" onayı verir (#197). (5) "Avadanlık kilitleri" serum rafının elektromanyetik kilit kartını (`<iXX:YZ>`) test eder. Elle `k`/`x`/`o`/`c`/`s`/`t` komutları, kart ID taraması (1–16), canlı durum ve tuş değeri izleme, fiziksel gözlem kaydı. Olması gereken akışın testi raf tanımıyla birlikte Serum sayfasındadır (#217).
9. **RFID:** UHFEx10 okuyucuya TCP ile bağlanılır (varsayılan `192.168.1.190:6000`): bağlantı testi (firmware, güç), güç ayarı, envanter başlat/durdur ve canlı etiket listesi (EPC, okuma sayısı, RSSI, anten). Envanter durdurulunca okunan etiketler rapora eklenir.
10. **Gelişmiş araçlar → Konsol:** `Y` / `T` / `Z` komutları alanlardan checksum'ıyla üretilir ya da elle yazılır.
11. **Rapor:** Ekranda önce senaryo sonuçları (kabin bazında: başarılı / başarısız / atlandı / yapılmadı), altında zaman sıralı adımlar görünür. Dosya (`Belgeler\PharMed-HwTest\rapor-<tarih>.txt`): başlık (kullanıcı, COM port, kabin tipi), kabin tanımı ve kaynağı, bu testte kullanılan serum tanımı, senaryo sonuçları, zaman sıralı adımlar ve seri hat trafiği. Hatalı her adımın altına, bir önceki adımdan o adıma kadarki ham trafik (en fazla 40 satır) eklenir.

Menü: İlaç Bazlı → Bağlantı, Kabin, Testler, Master çekmece, Serum, RFID, Gelişmiş araçlar, Rapor; Hasta Bazlı → Bağlantı, Kabin, Testler, Mobil kabin, RFID, Gelişmiş araçlar, Rapor. **Gelişmiş araçlar** arıza teşhisi içindir (hat / kart taraması, serum keşfi ve kilit kartı elle komutları, konsol); herkes görebilir, günlük testte gerekmez.

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
- Pencere sabit boyutludur (1280×720), ekranın ortasında açılır. Boyutlandırma, büyütme ve tam ekran yoktur; yalnızca küçült ve kapat vardır (Windows ve macOS).
