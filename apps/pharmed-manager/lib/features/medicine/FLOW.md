---
name: medicine-unit-mode
description: >
  Medicine (Drug/MedicalConsumable) içeren her ekranda birim hesaplama,
  gösterim ve validasyon kuralları için çalışır. İlaç atama, dolum, sayım,
  reçete, boşaltma, iade, fire/imha ekranlarında mutlaka bu skill okunmalıdır.
---

# Medicine Birim Modu — Kural Rehberi

## 1. Genel Bakış

`Medicine` sealed sınıfının iki alt tipi vardır: `Drug` ve `MedicalConsumable`.
Her ekranda hangi birimin kullanılacağı bu tipe ve `Drug.isMeasureUnit` alanına göre belirlenir.

```
Medicine
├── MedicalConsumable          → Her zaman ADET
└── Drug
    ├── isMeasureUnit = false  → Her zaman ADET
    └── isMeasureUnit = true   → KARMA MOD (ekrana göre değişir)
```

---

## 2. Karma Mod Nedir?

`Drug.isMeasureUnit = true` olduğunda ilaç için iki ayrı birim tanımlanmıştır:

| Alan | Örnek | Anlamı |
|---|---|---|
| `dose` + `doseUnit` | 100 ml | Bu ilacın **1 adeti** kaç ml'dir |
| `doseMeasureUnit` + `unitMeasure` | 25 ml | Reçete edilebilecek **en küçük birim** |

> **Örnek:** Parol 100ml/doz, 25ml ölçü birimi.
> Kabinde 40 adet var → 40 × 100ml = 4.000ml mevcut.
> Reçetede en az 25ml, sonraki geçerli değer 50ml, 75ml, 100ml...

---

## 3. Ekran Bazında Kurallar

### ADET kullanan ekranlar
Aşağıdaki ekranlar isMeasureUnit değerinden bağımsız olarak her zaman **adet** kullanır:

- **İlaç Atama** — Min, Max, Kritik değerleri adet olarak girilir
- **İlaç Dolum** — Kaç adet dolulduğu girilir
- **İlaç Sayım** — Mevcut adet sayılır
- **Dolum Listesi oluşturma ve dolum** — Adet bazında işlem yapılır

### ÖLÇÜ BİRİMİ / ML kullanan ekranlar

**Reçete Oluşturma**
- Kullanıcıya `doseMeasureUnit` cinsinden giriş yaptırılır
- Sadece `doseMeasureUnit`'in tam katları geçerlidir
- Validasyon: `girilen % doseMeasureUnit == 0`
- Örnek: doseMeasureUnit = 25ml → 25✅ 50✅ 75✅ 30❌ 40❌

**Reçete Görüntüleme**
- Reçetedeki miktar ml olarak gösterilir (ölçü birimi cinsinden)

**İlaç Boşaltma**
- Kullanıcıya önce mevcut stok gösterilir: `adet × dose ml`
- Kullanıcı serbest ml girer (ölçü birimi katı zorunluluğu yoktur)
- Yarım adet sonucu verebilir: `30ml ÷ 100ml = 0.3 adet` → geçerlidir

**İade / Fire / İmha**
- Reçeteden gelen değer referans alınır (ml cinsinden)
- Kullanıcı serbest ml girer, tam kat şartı yoktur
- Bu ekranlar ters dolum gibi çalışır — ml → adete dönüşüm yapılır

---

## 4. Dönüşüm Formülleri

```dart
// Stok → ml gösterimi
double stockInMl = adet * drug.dose;

// Reçete validasyonu (tam kat kontrolü)
bool isValidPrescription = girilen % drug.doseMeasureUnit == 0;

// ml → adet (kesirli sonuç normaldir)
double adetEquivalent = mlMiktar / drug.dose;
// Örnek: 30ml / 100ml = 0.3 adet → KABUL EDİLİR

// Boşaltma / iade geri dönüşümü (ml → adet stok düşümü)
double stokDüşümü = mlMiktar / drug.dose;
```

---

## 5. Hangi Ekranda Ne Gösterilir — Özet Tablo

| Ekran | isMeasureUnit=false | isMeasureUnit=true |
|---|---|---|
| İlaç Atama | Adet | Adet |
| İlaç Dolum | Adet | Adet |
| İlaç Sayım | Adet | Adet (ml gösterimi opsiyonel) |
| Dolum Listesi | Adet | Adet |
| Reçete Oluşturma | Adet | doseMeasureUnit katları (ml) |
| Reçete Görüntüleme | Adet | ml |
| İlaç Boşaltma | Adet | Serbest ml (stok: adet×dose gösterilir) |
| İade | Adet | Serbest ml |
| Fire / İmha | Adet | Serbest ml |

---

## 6. Yeni Ekran Eklerken Kontrol Listesi

Bir ekran `Medicine` nesnesiyle çalışıyorsa şu soruları sormak gerekir:

1. Bu ekran hangi gruba giriyor? (Dolum grubu mu, Reçete grubu mu?)
2. `isMeasureUnit` kontrolü yapılıyor mu?
3. Dolum grubundaysa: ml gösterimi gerekmez, adet yeterli
4. Reçete grubundaysa: `doseMeasureUnit` validasyonu var mı?
5. Boşaltma/İade/Fire grubundaysa: serbest ml girişine izin veriliyor mu?

---

## 7. Sık Yapılan Hatalar

❌ Boşaltma ekranında ölçü birimi katı validasyonu uygulamak
→ Boşaltmada serbest ml serbesttir, 30ml de girilebilir

❌ Reçetede serbest ml girişine izin vermek
→ Reçetede sadece `doseMeasureUnit` katları geçerlidir

❌ İlaç dolumunda ml kullanmak
→ Dolum her zaman adettir, isMeasureUnit değeri dolumu etkilemez

❌ isMeasureUnit kontrolü yapmadan direkt adet kullanmak
→ Reçete, boşaltma, iade, fire/imha ekranlarında bu kontrol şarttır

❌ `MedicalConsumable` için ölçü birimi kontrolü yapmak
→ MedicalConsumable her zaman adettir, hiçbir özel kontrol gerekmez