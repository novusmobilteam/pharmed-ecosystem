# PharMed

Hastane ilaç kabini yönetim sistemi. Kabinlerin yanındaki dokunmatik kiosk uygulaması, eczane/yönetim için masaüstü yönetim paneli, cihaz loglarını izleme paneli ve ortak paketler bu monorepo'da. Yazılım IEC 62304 Class B tıbbi cihaz yazılımı olarak geliştirilir; kodda `SWREQ-…` izlenebilirlik etiketleri ve `MedLogger` ile yapılandırılmış loglama kullanılır.

> **Bu dosyayı güncel tutun.** Build adımı, GitHub Actions iş akışı, flavor, `--dart-define` ayarı, yeni bir uygulama/paket ya da çalıştırma komutu değiştiğinde README aynı PR'da güncellenir.

## İçindekiler

- [Parçalar](#parçalar)
- [Gereksinimler](#gereksinimler)
- [İlk kurulum](#ilk-kurulum)
- [Flavor'lar](#flavorlar)
- [Test sürümleri: bilgisayar ve kabin](#test-sürümleri-bilgisayar-ve-kabin)
- [Windows'ta çalıştırma ve derleme](#windowsta-çalıştırma-ve-derleme)
- [macOS'ta çalıştırma ve derleme](#macosta-çalıştırma-ve-derleme)
- [Derleme ayarları (`--dart-define`)](#derleme-ayarları---dart-define)
- [GitHub Actions](#github-actions)
- [Log paneli](#log-paneli)
- [Cihazdaki loglar](#cihazdaki-loglar)
- [Geliştirme akışı](#geliştirme-akışı)

## Parçalar

| Klasör | Ne | Teknoloji | Nerede çalışır |
| --- | --- | --- | --- |
| `apps/pharmed-client` | Kiosk uygulaması: ilaç alım, iade, dolum, sayım, boşaltma, imha; kabin donanımı (RS485, RFID), parmak izi, fiş yazıcı, kamera kaydı | Flutter, Riverpod | Kabin yanındaki Windows kiosk |
| `apps/pharmed-manager` | Yönetim paneli: ilaç/kullanıcı/rol/istasyon tanımları, reçete onayı, raporlar | Flutter, Provider/ChangeNotifier | Windows masaüstü |
| `apps/pharmed-log-panel` | Kiosk ve sunucu loglarını izleme paneli: sorun grupları, log gezgini, istek izi, teşhis kartı, sunucu hataları | Vite, React, TypeScript | Tarayıcı (statik dosyalar) |
| `apps/pharmed-widgetbook` | `pharmed_ui` bileşen kataloğu | Flutter, Widgetbook | Tarayıcı / Windows |
| `packages/pharmed_core` | Domain: entity'ler, use case'ler, `Result<T>`, `AppException` | Dart | client + manager |
| `packages/pharmed_data` | Veri katmanı: `APIManager`, remote/local datasource'lar, repository'ler, ağ loglama | Dart, Dio, Hive | client + manager |
| `packages/pharmed_ui` | Tasarım sistemi (`MedColors`, `MedTextStyles`…), ortak widget'lar, l10n (TR/EN/FR), `MedLogger` | Flutter | client + manager |
| `packages/pharmed_utils` | Ortak yardımcılar | Dart | client + manager |

Her uygulamanın kendi README'si o uygulamaya özel ayrıntıları içerir.

## Gereksinimler

| Araç | Sürüm | Not |
| --- | --- | --- |
| Flutter | **3.38.6** | `.fvmrc` ile sabit. [FVM](https://fvm.app) kullanıyorsanız `fvm use` yeterli |
| Dart | `^3.10.7` | Flutter ile gelir |
| Melos | `^7.5.0` | Kökte `dev_dependency`; `dart run melos <komut>` |
| Windows derleme | Visual Studio 2022, "Desktop development with C++" | Windows build için |
| macOS derleme | Xcode | macOS'ta geliştirme için |
| Node.js | 20.19+ (22 önerilir) | Yalnızca log paneli |

## İlk kurulum

```bash
git clone https://github.com/novusmobilteam/pharmed-ecosystem.git
cd pharmed-ecosystem

# Pub workspace: tüm Flutter paketleri kökten tek seferde çözülür.
flutter pub get

# Üretilen dosyalar (*.g.dart, *.freezed.dart) repoda YOK — üretilmezse
# derleme "part file not found" ile kırılır. Model değiştikçe tekrar çalıştırın.
cd packages/pharmed_data
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

Melos betikleri (kökte):

| Komut | Ne yapar |
| --- | --- |
| `dart run melos run get` | Tüm paketlerde `flutter pub get` |
| `dart run melos run analyze` | Tüm paketlerde `flutter analyze` |
| `dart run melos run test` | Tüm paketlerde `flutter test` |
| `dart run melos run run:client:dev` | Client'ı dev flavor ile çalıştırır |
| `dart run melos run run:manager:dev` | Manager'ı dev flavor ile macOS'ta çalıştırır |

Widgetbook kataloğu workspace dışındadır (kendi `pubspec.lock`'u var); kurulumu için `apps/pharmed-widgetbook/README.md`.

## Flavor'lar

Her Flutter uygulamasının üç giriş noktası var: `lib/main_<flavor>.dart`. Flavor derleme zamanında seçilir, çalışırken değişmez.

| Flavor | Giriş | Servis | Ne zaman |
| --- | --- | --- | --- |
| `mock` | `lib/main_mock.dart` | Servise çıkılmaz, sahte veri | Arayüz geliştirme, demo |
| `dev` | `lib/main_dev.dart` | `https://agena.novusyazilim.com/api` | Geliştirme ve test |
| `prod` | `lib/main_prod.dart` | `https://agena.novusyazilim.com/api` | Sahadaki kurulum |

> Şu an `dev` ve `prod` aynı sunucuyu gösteriyor (`apps/*/lib/core/flavor/app_flavor.dart`). Ayrı ortam açıldığında burayı da güncelleyin.

Flavor'lar dev ve mock'ta konsola ayrıntılı log yazar; prod'da konsola yalnızca hatalar düşer. Üçünde de loglar cihazdaki dosyaya yazılır (bkz. [Cihazdaki loglar](#cihazdaki-loglar)).

Flavor yalnızca **hangi backend'e** gidileceğini belirler. Cihazların (seri port, kabin kartı, tepsi kilidi, RFID, parmak izi okuyucu, fiş yazıcı) gerçek mi sahte mi olacağı ayrı bir ayardır: `--dart-define=HARDWARE=mock|real` (client). Verilmezse `prod` → gerçek, `dev` ve `mock` → sahte cihaz.

## Test sürümleri: bilgisayar ve kabin

Testçilere iki client paketi gider; ikisi de gerçek API'ye (`dev`) bağlanır, yalnızca cihaz servisleri farklıdır:

| Paket | Derleme | Cihazlar | Kim kullanır |
| --- | --- | --- | --- |
| `pharmed-client-…-dev-pc-windows.zip` | `-t lib/main_dev.dart --dart-define=HARDWARE=mock` | Sahte — kabin ve diğer cihazlar "varmış gibi" davranır | Bilgisayarda test edenler |
| `pharmed-client-…-dev-kabin-windows.zip` | `-t lib/main_dev.dart --dart-define=HARDWARE=real` | Gerçek kabin donanımı | Kabinde test edenler |

- Release yayınlanınca ikisi otomatik üretilir (bkz. [GitHub Actions](#github-actions)).
- Uygulamanın sol alt köşesinde sürüm etiketi görünür: **DEV · PC — sahte cihaz** ya da **DEV · KABİN**. `prod` + gerçek cihazda etiket yoktur.
- Loglarda ve log panelinde sürüm `dev-pc` / `dev-kabin` olarak görünür (gönderimdeki `device.flavor`).
- Kabin sürümünde tek bir cihaz eksikse yalnızca onu sahtelemek için `FINGERPRINT_MOCK=true` / `PRINTER_MOCK=true` kullanılabilir.

## Windows'ta çalıştırma ve derleme

Kiosklar ve yönetim bilgisayarları Windows'tadır; sahaya giden sürüm Windows build'idir.

```bash
cd apps/pharmed-client          # ya da apps/pharmed-manager

# Geliştirme
flutter run -d windows -t lib/main_dev.dart

# Release build
flutter build windows --release -t lib/main_prod.dart --dart-define=APP_VERSION=v0.4.1
```

Çıktı: `build/windows/x64/runner/Release/` — klasörün tamamı dağıtılır (exe tek başına çalışmaz).

Dikkat edilecekler:

- **Video bileşeni (media_kit):** CMake aşamasında ANGLE ve libmpv arşivleri GitHub'dan indirilir. İlk build internet ister; arşivler `build/windows/x64/*.7z` altında kalır ve sonraki build'lerde tekrar indirilmez.
- **Kamera kaydı (client):** `ffmpeg.exe`, exe'nin yanındaki `ffmpeg\` klasöründe aranır; yoksa `PATH`'teki `ffmpeg` kullanılır. CI build'i ffmpeg'i paketlemez, kurulumda ayrıca konur. Geliştirmede `--dart-define=FFMPEG_PATH=C:\...\ffmpeg.exe` verilebilir.
- **Cihazlar (client):** `dev` build varsayılan olarak sahte cihazlarla çalışır; kabinde `--dart-define=HARDWARE=real` verin (bkz. [Test sürümleri](#test-sürümleri-bilgisayar-ve-kabin)).
- **Parmak izi (client):** SecuGen / Suprema BioMini SDK DLL'leri gerekir. Okuyucusuz makinede `--dart-define=FINGERPRINT_MOCK=true`.
- **Fiş yazıcı (client):** Yazıcısız makinede `--dart-define=PRINTER_MOCK=true` — fişler PNG olarak kaydedilir.

## macOS'ta çalıştırma ve derleme

macOS geliştirme ortamı olarak kullanılır; sahaya macOS build'i gitmez ve CI'da macOS build'i yoktur.

```bash
cd apps/pharmed-client          # ya da apps/pharmed-manager
flutter run -d macos -t lib/main_dev.dart

# Gerekirse yerel release build
flutter build macos --release -t lib/main_dev.dart
# Çıktı: build/macos/Build/Products/Release/<uygulama>.app
```

Dikkat edilecekler:

- **Donanım:** Parmak izi SDK'ları ve kamera kaydı (ffmpeg) Windows'a göre kurgulandı. macOS'ta `--dart-define=FINGERPRINT_MOCK=true --dart-define=PRINTER_MOCK=true` ile ya da `mock` flavor ile çalışın.
- **Sandbox:** Uygulama macOS sandbox'ında çalışır (`macos/Runner/*.entitlements`). Dosyalar uygulamanın container'ına yazılır, örneğin loglar `~/Library/Containers/com.example.pharmedClient/Data/Library/Logs/PharMed/`.
- **Bundle id:** Şu an Flutter şablonundaki `com.example.pharmedClient`. Değiştirilirse yukarıdaki yollar da değişir.

## Derleme ayarları (`--dart-define`)

Hepsi derleme zamanında verilir: `flutter run|build … --dart-define=AD=değer`. Verilmeyen ayar varsayılan değerini alır.

**Genel (client)**

| Ayar | Varsayılan | Ne yapar |
| --- | --- | --- |
| `APP_VERSION` | `dev` | Loglarda ve log panelinde görünen sürüm. CI otomatik verir |
| `LOG_UPLOAD_ENABLED` | `true` | Logların backend'e (`POST /api/FrontendLog/batch`) gönderimi. Kapatmak için `false` |
| `RECORDING_UPLOAD_ENABLED` | `true` | Kamera kayıtlarının backend'e yüklenmesi |

**Donanım (client)**

| Ayar | Varsayılan | Ne yapar |
| --- | --- | --- |
| `HARDWARE` | `prod`'da `real`, diğerlerinde `mock` | Cihaz servisleri: `mock` = sahte (bilgisayarda test), `real` = gerçek kabin donanımı |
| `FINGERPRINT_MOCK` | `false` | Okuyucusuz makinede sahte parmak izi okuyucu |
| `FINGERPRINT_VENDOR` | `auto` | `secugen` / `suprema` ile tek üreticiye sabitler |
| `SECUGEN_DLL_PATH`, `SECUGEN_LIVENESS`, `SECUGEN_SMART_CAPTURE`, `SECUGEN_AREA_QUALITY`, `SECUGEN_FAKE_LEVEL` | — / `true` / `true` / `50` / `0` | SecuGen ayarları |
| `BIOMINI_DLL_PATH`, `BIOMINI_CAPTURE_MODE`, `BIOMINI_LFD_LEVEL`, `BIOMINI_SECURITY_LEVEL` | — / `device` / `3` / `0` | Suprema BioMini ayarları |
| `PRINTER_MOCK` | `false` | Fişleri yazıcı yerine PNG olarak kaydeder |
| `FFMPEG_PATH` | — | ffmpeg yolu (verilmezse exe yanı, sonra `PATH`) |
| `CAMERA_HOST`, `CAMERA_USER`, `CAMERA_PASSWORD`, `CAMERA_CHANNEL` | — / `admin` / — / `101` | Varsayılan kamera bağlantısı (kameralar kabin dizayn ekranından da tanımlanır) |

Yeni bir ayar eklendiğinde bu tabloya da eklenir.

## GitHub Actions

### Windows Build (`.github/workflows/windows-build.yml`)

client ve/veya manager için Windows build'i alır ve zip olarak yayınlar.

**Ne zaman çalışır**

| Tetikleyici | Ne derlenir | Çıktı nereye gider |
| --- | --- | --- |
| Elle: Actions → "Windows Build" → Run workflow | Seçilen dal, uygulama (`client` / `manager` / `both`), flavor (`dev` / `prod` / `mock`) ve client için cihaz (`both` / `pc` / `kabin`) | Çalıştırma sayfasının altındaki **Artifacts** (14 gün saklanır) |
| Release yayınlanınca (`release: published`) | Release etiketinin kodu, **dev** flavor: client `pc` + client `kabin` + manager | Artifacts + release'e zip olarak eklenir |

Aynı dal ve uygulama için yeni bir çalıştırma başlarsa eskisi iptal edilir.

**Adımlar**

1. `plan` (Ubuntu): seçime göre derlenecek paket listesini üretir (client `pc` / `kabin`, manager).
2. `build` (Windows, paket başına paralel):
    1. Flutter 3.38.6 kurulur (cache'li).
    2. Kökte `flutter pub get`, ardından `packages/pharmed_data`'da `build_runner`.
    3. media_kit'in ANGLE ve libmpv arşivleri, eklentinin kendi `CMakeLists.txt`'inden okunan adres ve MD5 ile önceden indirilip cache'lenir (geçici ağ hatalarında tekrar dener).
    4. `flutter build windows --release -t lib/main_<flavor>.dart --dart-define=APP_VERSION=<sürüm>`; client'ta ayrıca `--dart-define=HARDWARE=mock|real`. Sürüm: release'te etiket (ör. `v0.4.1`), elle çalıştırmada `<dal>-<kısa commit>`.
    5. `build/windows/x64/runner/Release/` zip'lenir. Ad: `<uygulama>-<YYYYMMDD-HHMM>-<etiket ya da dal-commit>-<flavor>[-pc|-kabin]-windows.zip` (saat Türkiye saati).
    6. Zip artifact olarak, release'te ayrıca release'e yüklenir.

CI'da şu an test, analiz, macOS build'i ve log paneli build'i **yoktur**; bunlar yerelde çalıştırılır.

## Log paneli

```bash
cd apps/pharmed-log-panel
npm install
npm run dev                                       # http://localhost:5173 — sahte veri
npm run build                                     # dist/ — statik dosyalar
VITE_API_BASE_URL=https://agena.novusyazilim.com npm run build    # gerçek backend'e bağlı build
```

`VITE_API_BASE_URL` verilmezse panel sahte veriyle çalışır; verilirse yönetici girişi ister (`/api/Login/login`) ve `FrontendLog` / `BackendLog` servislerinden okur. Değer `/api` olmadan sunucu kökü olmalı. `dist/` herhangi bir statik sunucudan (IIS sanal dizini dahil) yayınlanır; yönlendirme hash tabanlı olduğu için sunucuda ek ayar gerekmez. Ekranlar, kullanılan servisler ve teşhis kataloğu: `apps/pharmed-log-panel/README.md`.

## Cihazdaki loglar

client, `MedLogger` kayıtlarını cihazda günlük dosyalara yazar: `pharmed-client-YYYY-MM-DD.log`, 14 gün saklanır.

| Platform | Klasör |
| --- | --- |
| Windows | `%LOCALAPPDATA%\PharMed\logs` |
| macOS | `~/Library/Logs/PharMed` (sandbox'ta container içi, bkz. macOS bölümü) |

Klasöre uygulamada **Ayarlar → Debug → Uygulama logları → Klasörü aç** ile ulaşılır.

Log politikası: işlem yapan istekler (POST/PUT/DELETE), hatalı istekler, 5 sn'yi aşan yanıtlar, uygulama kuralı redleri ve yakalanmamış hatalar yazılır. Başarılı okuma istekleri yazılmaz; son 100 adım bellekte tutulur ve bir hata yazıldığında kaydın altına "önceki adımlar" olarak eklenir. Ayrıntı: `packages/pharmed_data/lib/src/network/network_log_interceptor.dart`.

INFO/WARN/ERROR kayıtları diskte bir kuyruğa (`<veri kökü>/log-outbox`) da yazılır ve arka planda `POST /api/FrontendLog/batch` ile backend'e gönderilir (`apps/pharmed-client/lib/core/logging/shipping/`). Gönderim oturumdaki Bearer token ile yapılır; backend kullanıcı ve istasyonu token'dan alır, bu yüzden giriş yapılmamışken kayıtlar kuyrukta bekler. Backend'in kabul ettiği/yinelenen saydığı kayıtlar kuyruktan silinir, reddettikleri tekrar gönderilmez. `LOG_UPLOAD_ENABLED=false` ile kapatılabilir.

## Geliştirme akışı

**Dallar:** `dev` → `test` → `main`, hepsi korumalı ve PR ile güncellenir.

- `dev`: varsayılan dal; tüm iş dalları buraya birleşir.
- `test`: yalnızca `dev`'den PR alır; QA adayı, `vX.Y.Z-rc.N` etiketlenir.
- `main`: yalnızca `test`'ten PR alır; QA'dan geçen sürüm, `vX.Y.Z` etiketlenir.

**Bir iş için:**

1. GitHub issue açılır. Etiketler: `type:*` (bug / feature / docs…), `scope:*` (client / manager…), gerekirse `area:*`.
2. Dal: `<tür>/<issue-no>-<kısa-açıklama>`, örn. `fix/107-census-default-selection`, `feature/111-operation-failure-logging`.
3. Commit mesajı İngilizce ve kısa; gövdede `Refs #<issue-no>`.
4. `dev`'e PR açılır; açıklamada `Refs #<issue-no>`.
5. Davranışı, build'i ya da ayarları değiştiren her PR, ilgili README'yi de günceller.
