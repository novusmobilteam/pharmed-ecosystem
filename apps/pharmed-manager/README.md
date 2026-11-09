# pharmed-manager

Windows masaüstünde çalışan yönetim paneli: ilaç, kullanıcı, rol ve istasyon tanımları, reçete onayı, dolum listeleri ve raporlar.

Kurulum, flavor'lar, Windows/macOS build ve CI için kökteki [README](../../README.md).

## Kısa yol

```bash
flutter run -d windows -t lib/main_dev.dart
flutter run -d macos -t lib/main_dev.dart
flutter build windows --release -t lib/main_prod.dart --dart-define=APP_VERSION=v0.4.1
```

## Klasörler

| Klasör | İçerik |
| --- | --- |
| `lib/features/` | Ekranlar (Provider / ChangeNotifier) |
| `lib/core/flavor/` | `mock` / `dev` / `prod` ayarları |
| `docs/` | Donanım protokol notları |
