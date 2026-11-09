# pharmed-client

Kabin yanındaki Windows kioskta çalışan dokunmatik uygulama: ilaç alım, iade, dolum, sayım, boşaltma ve imha işlemleri; kabin donanımı (RS485 çekmece kartları, RFID), parmak izi ile giriş, fiş yazıcı ve işlem sırasında kamera kaydı.

Kurulum, flavor'lar, Windows/macOS build, `--dart-define` ayarları ve CI için kökteki [README](../../README.md).

## Kısa yol

```bash
flutter run -d windows -t lib/main_dev.dart     # Windows
flutter run -d macos -t lib/main_dev.dart \
  --dart-define=FINGERPRINT_MOCK=true --dart-define=PRINTER_MOCK=true   # macOS
flutter run -t lib/main_mock.dart               # sahte veri, donanımsız
```

## Klasörler

| Klasör | İçerik |
| --- | --- |
| `lib/features/` | Ekranlar; her biri `notifier/` + `view/` |
| `lib/core/hardware/` | Seri port, kabin kartları, RFID, parmak izi, yazıcı, kamera |
| `lib/core/logging/` | Dosyaya loglama, yakalanmamış hatalar, backend'e log gönderimi (`shipping/`) |
| `lib/core/recording/` | Kamera kayıtlarının saklanması ve yüklenmesi |
| `lib/core/providers/` | Riverpod provider'ları |
| `lib/core/flavor/` | `mock` / `dev` / `prod` ayarları |
| `test/` | Birim testleri (`flutter test`) |
