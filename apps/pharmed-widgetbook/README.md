# PharMed Widgetbook

`pharmed_ui` tasarım sisteminin canlı kataloğu. Tüm ortak widget'ları
parametreleriyle (knob) canlı test etmek, client/manager temalarında
yan yana görmek ve "hangi widget'lar var?" sorusunu tek yerden yanıtlamak için.

## Kurulum (tek seferlik)

Klasör adı **`pharmed-widgetbook`** (tire — client/manager ile tutarlı),
ama pubspec `name:` alanı **`pharmed_widgetbook`** (alt çizgi — Dart kuralı).

1. Platform iskeletini üret (bu ortamda değil, kendi makinende):
   ```bash
   cd apps
   flutter create --template=app --platforms=windows,web \
     --project-name=pharmed_widgetbook pharmed-widgetbook
   ```
   Bu `windows/`, `web/`, `.metadata` gibi platform dosyalarını üretir.

2. Üretilen iskeletteki şu dosyaları buradaki hazır sürümlerle **DEĞİŞTİR**:
   `pubspec.yaml`, `lib/main.dart`, `analysis_options.yaml`. Ayrıca
   `lib/use_cases/` klasörünü olduğu gibi kopyala. (`flutter create`'in
   ürettiği örnek `pubspec.yaml`'ı birleştirme — tamamen benimkiyle değiştir;
   içinde `widgetbook` + `pharmed_ui` path bağımlılığı var.)

3. Kök `melos.yaml`'a paketi ekle (güncel hâli repo kökünde `melos.yaml`
   olarak verildi):
   ```yaml
   packages:
     ...
     - apps/pharmed-widgetbook
   ```

4. Fontları bağla: `pubspec.yaml` içindeki `fonts:` bloğunu client veya
   manager app'inin pubspec'inden birebir kopyala (Sora / DM Sans /
   JetBrains Mono). Aksi halde katalogda tipografi fallback'e düşer ve
   token'ları yanlış değerlendirirsin.

5. Bağımlılıkları çek:
   ```bash
   melos bootstrap        # ya da: melos bs
   # veya tek paket için:
   cd apps/pharmed-widgetbook && flutter pub get
   ```

## Çalıştırma

Kök dizinden tek komut:
```bash
melos run catalog          # tarayıcıda açar (-d chrome)
```

Ya da elle:
```bash
cd apps/pharmed-widgetbook
flutter run -d windows     # masaüstü
flutter run -d chrome      # tarayıcı (paylaşımı en kolay olan)
```

Sol panelden widget seç, sağ üstten **tema** (Client/Manager) ve alttan
**knob'ları** değiştir.

## Yeni widget grubu ekleme

1. `lib/use_cases/` altında `<grup>_use_cases.dart` oluştur.
2. Bir `WidgetbookComponent` tanımla, içine `WidgetbookUseCase`'ler koy.
   Knob'lar için `context.knobs.list / boolean / string / double` kullan.
3. `lib/main.dart` içindeki `directories` ağacına component'i ekle.

Örnek iskelet için `use_cases/selectable_use_cases.dart`'a bak — hem
stateless playground hem stateful grup örneği içerir.

## İki temel amaç (hatırlatma)

- **Tema tutarlılığı denetimi**: sağ üstteki tema anahtarıyla aynı widget'ı
  Client ↔ Manager arasında değiştir. Görsel/davranış farkı token dışı bir
  yerden geliyorsa burada yakalanır.
- **Tekrarı önleme**: yeni bir ekran yaparken önce buraya bak — muhtemelen
  ihtiyacın olan atom zaten var.