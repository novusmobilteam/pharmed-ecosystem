# SecuGen FDx SDK Pro (parmak izi okuyucu)

Okuyucu: **SecuGen U10** (Hamster Pro 10, USB VID_1162 / PID_2203, SDK cihaz kodu `SG_DEV_FDU07`)
SDK: FDx SDK Pro for Windows **4.3.1**, x64

| Dosya | Açıklama | SHA-256 |
|---|---|---|
| `sgfplib.dll` | Ana modül. `dart:ffi` ile çalışma anında yüklenir. | `8f06d5a827facd202e8140ed9fbe892ba6816a8507f17055a7c83be21f403cfa` |
| `sgfpamx.dll` | Çıkarma/eşleştirme algoritması (MINEX uyumlu). `sgfplib.dll` yükler. | `5536fe0b0b3ccaf53733d9a2f5409cd5868a5a5daaf03b8c00862df4f2926115` |
| `sgwsqlib.dll` | WSQ modülü. `sgfplib.dll` yükler; VC++ 2015+ çalışma zamanı ister. | `25695e7e71cd1b013338f4fbbe7bb51d8887a323977b68ef259bbea48289db7f` |

`windows/CMakeLists.txt` üçünü de her build'de exe'nin yanına kopyalar. Klasör adı bilerek `x64/` değil
(`windows/.gitignore` `x64/` klasörlerini yok sayar). Bluetooth modülleri (`sgfdusdax64.dll`, `sgbledev.dll`)
gerekmez.

## Kiosk kurulumu

1. **Sürücü:** `WinDriver_u10_v1141` (SecuGen, 1.1.4.1, Microsoft imzalı). Yönetici PowerShell'de:
   `pnputil /add-driver .\WinDriver_u10_v1141\x64\sgfdu07x64.inf /install`, ardından okuyucuyu çıkar-tak.
   Okuyucu Aygıt Yöneticisi'nde **Fingerprint devices › SecuGen U10 USB FRD** olarak görünmelidir.
2. **VC++ 2015-2022 x64 çalışma zamanı** kurulu olmalı (`sgwsqlib.dll` için; Flutter Windows uygulaması da ister).
3. **Doğrulama:** SDK paketindeki `Samples/VisualC++/DeviceTest/x64/release/DeviceTest.exe`.

## Bilinen kısıtlar

- **Canlılık (sahte parmak) kontrolü U10'da yok.** Kılavuz: *"Fake detection functions currently only
  available for U20-based device."* Uygulama U10'da `livenessActive: false` raporlar ve açılışta uyarı loglar.
  Canlılık kontrolü gerekiyorsa U20 ailesi (U20-A, U20-AP, U20-AL) seçilmelidir.
- **İptal:** SDK süren bir okumayı durduramaz; uygulama okumayı 1 sn'lik dilimlere böler, iptal ≤ 1 sn sürer.
- **Parmak sorgusu:** SDK'da karşılığı yok; tek kare alınıp kalitesine bakılır (sezgisel).
- **Kalite ölçeği:** `SGFPM_GetImageQuality`, 0–100. Kılavuz: doğrulama ≥40, kayıt ≥50 (Suprema ölçeğinden farklı).

## SDK sürümü değişirse

`lib/core/hardware/fingerprint/secugen/secugen_bindings.dart` içindeki imzalar, sabitler ve yapı ofsetleri
yeni `sgfplib.h` ile karşılaştırılmalı; bu dosyadaki SHA-256 değerleri güncellenmelidir.
