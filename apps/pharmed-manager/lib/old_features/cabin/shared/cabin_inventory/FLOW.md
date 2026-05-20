# Kabin Stok İşlemleri — Akış Dokümanı

## Genel Bakış

`CabinInventoryView`, kabine ait ilaç giriş/çıkış işlemlerinin yapıldığı ortak ekrandır.
Aşağıdaki operasyon tipleri bu ekranı kullanır:

| Operasyon Tipi | Enum | Açıklama |
|---|---|---|
| İlaç Dolum | `refill` | Çekmeceye ilaç ekleme |
| İlaç Sayım | `count` | Çekmecedeki mevcut stoğu sayma |
| İlaç Boşaltma | `discharge` | Çekmeceden ilaç çıkarma |
| İlaç İmha | `destruction` | İlacı imha etme |
| İlaç Dolum Listesi | `refillList` | Dolum listesinden gelen planlı dolum *(yakında)* |

Ekran `showCabinInventoryView()` fonksiyonu çağrılarak açılır ve
`CabinInventoryNotifier` ile yönetilir.

---

## Çekmece Tiplerine Göre Görünüm

### Kübik Çekmece (`isKubik = true`)
Tek bir işlem alanı gösterilir. Tüm göz tek blok olarak yönetilir.

```
┌─────────────────────────────────┐
│  QuantityInfoCard               │
│  RatioProgressIndicator         │
│  Miad Tarihi (tek alan)         │
│  Sayım Miktarı | Dolum Miktarı  │
└─────────────────────────────────┘
```

### Birim Doz Çekmece (`isKubik = false`)
`numberOfSteps` kadar satır gösterilir. Her satır bir göze karşılık gelir.

```
┌─────────────────────────────────────────────────────────┐
│  QuantityInfoCard                                       │
│  RatioProgressIndicator                                 │
│  Miad Tarihi (isPerCellMiad=false ise tek alan)         │
│  ┌──────────┬────────────┬────────────┬──────────────┐  │
│  │ Kademe   │ Sayım Mikt.│ Dolum Mikt.│ Miad Tarihi  │  │
│  ├──────────┼────────────┼────────────┼──────────────┤  │
│  │ 1. Göz   │ ...        │ ...        │ ...          │  │
│  │ 2. Göz   │ ...        │ ...        │ ...          │  │
│  │ ...      │            │            │              │  │
│  └──────────┴────────────┴────────────┴──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Operasyon Tipine Göre Açılan Alanlar

| Alan | count | refill | discharge | destruction | refillList |
|---|---|---|---|---|---|
| Sayım Miktarı | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dolum/İşlem Miktarı | ❌ | ✅ | ✅ | ✅ | ✅ |
| Miad Tarihi | ✅ | ✅ | ❌ | ❌ | ✅ |

> `enableMiadDateInput` alanı bu kontrolü sağlar.

---

## Miktar Girişi — Medicine Unit Mode Entegrasyonu

Bu ekrandaki miktar girişleri **medicine-unit-mode** skill kurallarına tabidir.

| Operasyon | Giriş Birimi | Backend'e Gönderilen |
|---|---|---|
| Sayım | Adet | Adet |
| Dolum | Adet | `toFillingBackendValue(adet)` → ml (isMeasureUnit=true ise) |
| Boşaltma | Serbest ml (isMeasureUnit=true) / Adet | Girilen değer |
| İmha | Adet | Adet |

**Dolum backend dönüşümü:**
```dart
// Kullanıcı 3 adet girdi, ilaç dozu 100ml
toFillingBackendValue(3) → 3 × 100 = 300ml  // backend'e gider

// Backend'den 300ml geldi, kullanıcıya gösterilecek
fromFillingBackendValue(300) → 300 / 100 = 3 adet
```

---

## Miad Tarihi Yönetimi

### İki Mod

**Tekil Miad (`isPerCellMiad = false`)**
- Tüm gözler için tek miad tarihi girilir
- Başlangıç değeri: mevcut stoktaki en eski miad tarihi

**Göz Bazlı Miad (`isPerCellMiad = true`)**
- Her gözün kendi miad tarihi vardır
- Başlangıç değeri: her gözün kendi stok kaydındaki miad tarihi
- Miktar girilmeden miad tarihi alanı pasif görünür, hata verir

### Mod Geçişi (Settings'ten değiştirildiğinde)
Kullanıcı `isPerCellMiad: true → false` geçişi yaptığında:
- Tüm göz miad tarihlerinden **en eskisi** alınır
- Tek miad alanına sessizce yüklenir, uyarı gösterilmez

### Validasyon Kuralları

| Kural | Kapsam |
|---|---|
| Geçmiş tarihli miad girişi yasak | Tüm tipler, tüm gözler |
| Herhangi bir gözde **stoklu** miad geçmişse → tüm dolum engellenir | Sadece `refill` ve `count` |
| Stok = 0 olan gözün miad tarihi geçmişse → **engelleme yok** | Tüm tipler |
| Miad girilmeden miktar girilmişse kayıt atılamaz | `isPerCellMiad=true` durumunda |

> **Önemli:** Boşaltma ve İmha operasyonlarında miad geçmişse bloklama yapılmaz.

---

## Boş Göz — Miad Tarihi Davranışı

Birim Doz çekmecede `numberOfSteps = 12` ise ve kullanıcı sadece 6 göze dolum yaptıysa:

- **Dolum yapılan gözler:** Normal miad tarihi atanır
- **Boş kalan gözler (`quantity = 0 && censusQuantity = 0`):** `miadDate = null` gönderilir

```dart
miadDate: (fillingQuantity == 0 && countQuantity == 0)
    ? null
    : isPerCellMiadEnabled
        ? (_drawerMiadDates[i] ?? _miadDate)
        : _miadDate,
```

> ⚠️ Backend'in null miad kabul ettiği doğrulandı, bu davranış korunmalıdır.

---

## QuantityInfoCard

Her operasyon tipinde üst kısımda gösterilen bilgi kartıdır.

### Her zaman gösterilen alanlar
- İlaç adı ve barkodu
- Min / Kritik / Maksimum değerleri *(atama değerinden gelir)*
- Mevcut Miktar *(o an çekmecedeki stok)*

### `refillList` tipinde ek gösterim
`plannedQuantity` parametresi dolum listesinden geçirilir ve
"Planlanan Dolum" başlığıyla ek bir stat olarak gösterilir.

```dart
QuantityInfoCard(
  data: assignment,
  quantity: currentStock,
  type: CabinInventoryType.refillList,
  plannedQuantity: listItem.plannedAmount, // sadece refillList'te
)
```

---

## Kayıt Akışı

```
Kullanıcı "Kaydet" tıklar
    │
    ├─ Validasyon (miad tarihi geçmiş mi?)
    │       ├─ Geçmişse → onFailed snackbar, işlem durur
    │       └─ Geçerli → devam
    │
    ├─ CabinInputData listesi oluşturulur
    │       ├─ Kübik → 1 eleman
    │       └─ Birim Doz → numberOfSteps kadar eleman
    │               └─ Boş gözler → miadDate: null
    │
    ├─ onSave(inputs) çağrılır (dışarıdan inject edilir)
    │
    └─ onSuccess → SnackBar + dialog kapanır (true döner)
       onFailed  → SnackBar, dialog açık kalır
```