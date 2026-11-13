# BioMini SDK (parmak izi okuyucu)

Okuyucu: Suprema/Xperix **BioMini Slim 2S** (USB VID_16D1 / PID_0421)
SDK: BioMini SDK for Windows **3.10.0** (UniFinger Engine), x64

| Dosya | Açıklama |
|---|---|
| `UFScanner.dll` | SDK'nın tarama/çıkarma kütüphanesinin **x64** sürümü (`bin/x64/`). Klasör adı bilerek `x64/` değil: `windows/.gitignore` `x64/` klasörlerini yok sayar. `dart:ffi` ile çalışma anında yüklenir; `windows/CMakeLists.txt` her build'de exe'nin yanına kopyalar. SHA-256: `c167866347667f83b4c20ec3f6046aa48815ac7bdce3b6ff9a49f30eb83a3f9a` |
| `BMS2S_Windows10.reg` | SDK paketindeki kayıt dosyası: okuyucunun USB güç tasarrufunu (`EnhancedPowerManagementEnabled=0`) kapatır. |

`UFScanner.dll` yalnızca Windows sistem DLL'lerine bağlıdır (MFC statik). VC++ redist, `UFMatcher.dll` veya
`NFIQ2.dll` gerekmez: eşleştirme sunucuda yapılır.

## Kiosk kurulumu

1. **Sürücü:** SDK paketindeki `install/drivers/SFR Driver(unified)/Sup_Fingerprint_Driver_v2.2.1.exe`.
   Kurulumdan sonra okuyucu Aygıt Yöneticisi'nde görünmelidir.
2. **Güç yönetimi:** `BMS2S_Windows10.reg` yönetici olarak içe aktarılır, ardından okuyucu çıkarılıp takılır.
   Bu yapılmazsa Windows okuyucuyu uyku moduna alabilir ve okumalar `deviceDisconnected` ile düşer.
3. **Doğrulama:** SDK paketindeki `bin/x64/BioMiniS_DemoCS.exe` ile okuma yapılabildiği görülür.
   Burada sorun varsa sorun sürücü ya da donanımdadır, uygulamada değil.

## Lisans

BioMini SDK ücretli bir üründür ve yeniden dağıtımı Suprema/Xperix ile yapılan anlaşmaya tabidir.
DLL'in bu depoda tutulması ve kiosklara dağıtılması bu anlaşma kapsamında olmalıdır.

## SDK sürümü değişirse

`lib/core/hardware/fingerprint/biomini/biomini_bindings.dart` içindeki imzalar ve sabitler yeni
`UFScanner.h` / `UFScannerDef.h` ile karşılaştırılmalı, ardından bu dosyadaki SHA-256 güncellenmelidir.
