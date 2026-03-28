# Kabin İşlem Süreci — Akış Dokümanı

## Genel Bakış

Kabin işlemleri (dolum, sayım, boşaltma, imha) fiziksel bir çekmecelerin
açılıp kapanmasını gerektiren bir süreç üzerinden yürür.
Bu süreç üç bileşen tarafından yönetilir:

| Bileşen | Sorumluluk |
|---|---|
| `CabinProcessWrapper` | Listener kurulumu, stage geçişlerini UI'a yansıtma |
| `CabinStatusNotifier` | Fiziksel çekmece durumunu takip etme, stage yönetimi |
| `CabinStatusDialog` | Kullanıcıya anlık durumu gösterme |

---

## Tam Akış

```
Kullanıcı butona basar
         │
         ▼
CabinStatusNotifier.startOperation(assignment)
         │
         ├─ reset() → temiz başlangıç
         ├─ _openDrawerUseCase.call() → fiziksel çekmece açma
         │
         ▼
  DrawerStage.connecting
         │  → CabinStatusDialog açılır ("Bağlantı kuruluyor")
         ▼
  DrawerStage.unlockingMaster
         │  → Dialog güncellenir ("Çekmece açılıyor")
         ▼
  DrawerStage.waitingForPull
         │  → Dialog güncellenir ("Lütfen çekmeceyi açınız")
         ▼
  DrawerStage.openingLid  [sadece kübik + openCubicLid=true]
         │  → Dialog güncellenir ("Kapak açılıyor")
         ▼
  DrawerStage.readyForFilling
         │  → Dialog KAPANIR
         │  → onDrawerReady(context, assignment) çağrılır
         │  → CabinInventoryView açılır (dolum/sayım ekranı)
         │  → Kullanıcı işlemi tamamlar
         │
         ▼
  confirmFillingCompleted() [UI tetikler]
         │  → triggerManualClose() → fiziksel kapama sinyali
         ▼
  DrawerStage.waitingForClose
         │  → CabinStatusDialog açılır ("Lütfen çekmeceyi kapatınız")
         │  → Kullanıcı fiziksel çekmeceyi kapatır
         ▼
  DrawerStage.completed [sensör tetikler]
         │  → Dialog KAPANIR
         │  → notifier.reset()
         │  → 1 saniye beklenir
         │  → onProcessCompleted(assignment) çağrılır
         ▼
  İşlem tamamlandı
```

---

## Hata Durumu

```
DrawerStage.error
  → Dialog güncellenir ("İşlem sırasında bir hatayla karşılaşıldı")
  → İşlem sonlandırılır
```

---

## İki Tetikleyici Mod

### Manuel
Kullanıcı `_SelectedDrawerPanel` içindeki `PharmedButton`'a basar.
`CabinStatusNotifier.startOperation()` direkt çağrılır.
`CabinProcessWrapper` listener'ı tüm stage geçişlerini yakalar.

### Sıralı (Sequential)
`startSequentialProcess()` → `_executeNext()` → `onExecuteNext?.call()` → `startOperation()`

Her çekmece tamamlandığında `onProcessCompleted` içinden `proceedToNext()` çağrılır,
sıradaki çekmece için süreç yeniden başlar.

```
Sıralı İşlem:
  [A, B, C] kuyruğu
       │
       ├─ A başlar → tamamlanır → markCurrentAsDone(A) → proceedToNext()
       ├─ B başlar → tamamlanır → markCurrentAsDone(B) → proceedToNext()
       └─ C başlar → tamamlanır → markCurrentAsDone(C) → queue boş → getAssignments()
```

---

## Kübik vs Normal Çekmece Farkı

| Durum | Normal | Kübik |
|---|---|---|
| `openCubicLid` | false | true (iade'de false) |
| `openingLid` stage | Atlanır | Geçilir |
| Sensör tipi | `monitorDrawerStatus` | `monitorSerumStatus` (serum ise) |

---

## Provider Yapısı

```
Main (uygulama geneli)
  └─ CabinStatusNotifier  ← global, tüm ekranlar paylaşır

MedicineRefillView
  ├─ MedicineRefillNotifier
  └─ CabinAssignmentPickerNotifier
       └─ CabinAssignmentPickerView
            └─ CabinProcessWrapper  ← listener burada kurulur
```

`CabinStatusNotifier` global olduğu için farklı ekranlardan aynı anda
iki işlem başlatılmamalıdır.

---

## Önemli Kurallar

- `_handleDrawerStateChange` listener'da `context.read` kullanılmaz
  — context deaktive olmuş olabilir. Notifier referansı `initState`'te alınır.
- Dialog açık/kapalı durumu global flag yerine wrapper instance'ında tutulur
  — farklı wrapper'lar birbirini etkilemez, dispose sonrası otomatik sıfırlanır.
- `readyForFilling` stage'inde çift tetiklenmeyi `_isProcessingReadyState` flag'i önler.
- `confirmFillingCompleted()` sadece `readyForFilling` sonrası çağrılır;
  `completed` veya `error` stage'inde çağrılırsa erken çıkış yapar.
