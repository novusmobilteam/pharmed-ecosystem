# Kabin kartları RS485 haberleşme protokolü

İlaç bazlı (master) kabin donanımının seri port (RS485, yarı-dupleks) üzerinden konuşma protokolü. Tek kaynak bu dokümandır; kodda karşılığı `packages/pharmed_core/lib/src/utils/command_builder.dart` (komut üretimi) ve `apps/pharmed-client/lib/core/services/cabin_operation/cabin_operation_service.dart` (komut sıralaması) dosyalarıdır.

> Bu doküman, üreticiden gelen ham protokol notunun (eski `apps/pharmed-manager/docs/protokol.txt`) düzenlenmiş halidir. **"Uygulamada"** ile işaretli bölümler orijinal notta yoktur; kodun bugünkü davranışını ve sahada doğrulanması gereken yorumları anlatır.

- [Kartlar ve hat yapısı](#kartlar-ve-hat-yapısı)
- [Genel kurallar](#genel-kurallar)
- [Yönetim kartı komutları (`Y`)](#yönetim-kartı-komutları-y)
- [Çekmece kontrol kartı komutları (`T`)](#çekmece-kontrol-kartı-komutları-t)
- [Kübik komutları (`Z`)](#kübik-komutları-z)
- [Uygulamada kullanılan ek satırlar](#uygulamada-kullanılan-ek-satırlar)
- [Örnek akışlar](#örnek-akışlar)
- [Açık noktalar](#açık-noktalar)

## Kartlar ve hat yapısı

İki tip kart vardır:

| Kart | Adres | Görevi |
| --- | --- | --- |
| **Yönetim kartı** | `a`–`p` (16 adres). Her kabinde bir tane; kabinin `Cabin.no` alanı bu adrestir. | Kendisine bağlı kontrol kartlarından hangisinin komut dinleyeceğini seçer. Sensör (ısı/nem, akü) verir. |
| **Kontrol kartı** | **Adresi yoktur.** Yönetim kartındaki satır (`00`–`26`) ile seçilir. | Çekmece kilidi, kademe/göz, kapak. Kübik çekmecede ayrıca slave kübik kartları sürer. |

Aynı RS485 hattına birden fazla kabin (yani birden fazla yönetim kartı) bağlanabilir. Bilgisayar tek bir COM port üzerinden hepsiyle konuşur.

```
PC ──RS485── Yönetim kartı A (master kabin) ── satır 01..26 ── kontrol kartları
         └── Yönetim kartı C (ek kabin)     ── satır 01..26 ── kontrol kartları
```

## Genel kurallar

- Her komut `:` ile başlar, `;` ile biter. Sonundaki tek karakter (`c`) checksum'dır (aşağıdaki formüller, sonuç `% 10`).
- Kontrol kartı adres taşımadığı için **önce yönetim kartında satır seçilir, sonra kontrol kartına komut gönderilir.**
- `T`/`Z` komutları adres taşımaz: **satırı seçili olan her yönetim kartı** komutu kendi kontrol kartına iletir. Aynı hatta birden fazla kabin varsa, komut gönderilmeyecek kabinlerin seçimi `00` ile bırakılmalıdır (bkz. [Örnek akışlar](#örnek-akışlar)).
- Cevaplar en erken 10 ms, en geç 250 ms sonra gelir.
- Cevap için sabit bekleme konmamalı; gelen veri sürekli dinlenmelidir.

## Yönetim kartı komutları (`Y`)

**PC → Kart:** `:Yattc;`

| Alan | Anlam |
| --- | --- |
| `Y` | Sabit. |
| `a` | Yönetim kartı adresi, `a`–`p`. |
| `tt` | Satır: `00`–`26`. **`00` gönderilirse hiçbir satır seçili olmaz** (seçim bırakılır). |
| `c` | `(ASCII('Y') + ASCII(a) + tt) % 10` |

**Kart → PC:** `+TT-`

| `TT` | Anlam |
| --- | --- |
| `ok` | Komut anlaşıldı. |
| `no` | Anlamsız komut ya da checksum yanlış. |

Örnek: `:Ya000;` → A kartında seçimi bırak. `:Ya262;` → A kartında satır 26'yı seç.

## Çekmece kontrol kartı komutları (`T`)

**PC → Kart:** `:Tkattc;`

| Alan | Anlam |
| --- | --- |
| `T` | Sabit. |
| `k` | Komut: `O` aç, `C` kapat, `S` durum, `M` orada mısın?, `V` tip. (Uygulamada ayrıca `R`: h2 durumunu sıfırla.) |
| `a` | Port: `1`–`8`. Not: 1–5 numaralı portlar yalnızca aç/kapat çalışır (orijinal notta soru işaretiyle belirtilmiş). |
| `tt` | Kademe/göz: `01`–`16`. `00` → dolap, `20` → döner motorlu çekmece. |
| `c` | `(ASCII('T') + ASCII(k) + a + tt) % 10` |

**Kart → PC:** `.TT,`

| Komut | Cevap |
| --- | --- |
| `O`, `C`, `M` | `ok` anlaşıldı · `no` anlamsız komut / checksum yanlış |
| `V` | `vNN` — tip numarası (`01`–`16`). Uygulama bunu backend'deki `DrawerConfig.deviceTypeNo` ile eşleştirir; serum kartı `250` döner. |
| `S` | Aşağıdaki tablo |

| `S` cevabı | Durum |
| --- | --- |
| `h0` | Çekmece kilitlendi. |
| `h1` | Kilit açık, çekmece çekilmedi. |
| `h2` | Kilit açık, çekmece çekildi ama istenen göz sayısı kadar açılmadı. |
| `h3` | Çekmece açıldı, istenen göze gelindi; kapatılması bekleniyor (yanıp sönme). |
| `h4` | Çekmece kapatıldı. |
| `h5` | Çekmece/dolap kapalı. |
| `h6` | Çekmece/dolap açık. |
| `h7` | Döner motorlu çekmeceye sinyal gönderildi, dönmesi bekleniyor. |
| `h8` | Döner motorlu çekmece bir turu başarıyla tamamladı. |
| `h9` | Döner motorlu çekmece turu 5 saniyede tamamlayamadı (hata). |

Örnekler (port 1): `:TO1037;` 3. göze kadar aç · `:TS1031;` durum · `:TV1012;` tip.

## Kübik komutları (`Z`)

Kübik çekmecede iki kart vardır:

- **Çekmece kartı (master):** çekmecenin çekilmesini/kilitlenmesini kontrol eder; normal `T` komutlarıyla konuşulur.
- **Kübik kartları (slave):** kapakları (gözleri) açar. Bir master'a **en fazla 5 slave**, her slave'e **en fazla 4 göz** bağlanır (en fazla 20 göz). Gözler tek tek ya da birleşik olabilir (ör. 1–2 birleşik, 3, 4, 5 ayrı).
- Kübik yakalandığında slave'in varlığı kontrol edilir; slave varsa ona bağlı gözler aktiftir.

Önce yönetim kartında kübik çekmecenin satırı seçilir, sonra:

**PC → Kart:** `:Zkattc;`

| Alan | Anlam |
| --- | --- |
| `Z` | Sabit. |
| `k` | Komut: `O` aç, `S` durum, `M` orada mısın?, `V` tip. |
| `a` | Port: `1`–`4`. |
| `tt` | Kübik sıra no: `00`–`04`. |
| `c` | `(ASCII('Z') + ASCII(k) + a + tt) % 10` — orijinal notta formül `T` ile yazılmış; uygulama `Z` kullanır. |

> **Yorum (sahada doğrulanacak):** 5 slave × 4 göz yapısıyla birlikte okunduğunda `tt` (00–04) slave sırası, `a` (1–4) o slave'deki göz gibi görünüyor. Bu durumda 16 gözlü kübik 4 slave'li, 20 gözlü kübik 5 slave'li bir yapıdır ve göz sayısı `Z M` ile hangi slave'lerin cevap verdiğinden çıkarılabilir.

**Kart → PC:** `TT`

| Cevap | Anlam |
| --- | --- |
| `ok` | `O`, `C`, `M` anlaşıldı. |
| `ac` / `kp` | `S` cevabı: kübik açık / kapalı. |
| `01` | `V` cevabı (tek tip olduğu için hep `01`). |
| `nc` | Checksum yanlış. |
| `no` | Anlamsız veya hatalı komut. |
| `ht` | Çekmece açık değilken kübik aç komutu geldi; kübik açılamaz. |
| `hz` | Master, slave'den 250 ms içinde cevap alamadı; slave kartta sorun olabilir. |

Örnekler: `:ZO1011;` · `:ZM1019;` · `:ZS1015;` (port 1, sıra 01).

## Uygulamada kullanılan ek satırlar

Orijinal notta yoktur; kartlarda kullanılan ve kodda karşılığı olan değerler:

| Değer | Kullanım | Kod |
| --- | --- | --- |
| Yönetim kartı satır `26` | Mobil kabinde serum kartını slave moda alır; sonra `T` komutları port + `drawer 00` ile gönderilir. | `CabinOperationService._serumSlaveRow` |
| Yönetim kartı satır `49` | Seçildiğinde kart akü voltajını `+(...)-` olarak döner. | `CommandBuilder.rowBatteryLevel` |
| Yönetim kartı satır `50` | Seçildiğinde kart ısı/nemi `+(...)-` olarak döner. | `CommandBuilder.rowTempHumidity` |
| Kontrol kartı tipi `250` | Serum kartı. | `ControlCard.isSerum`, `DrawerConfig.isSerum` |

## Örnek akışlar

**Çekmece açma (tek kabin):**

1. `:Ya<satır><c>;` → `+ok-` — A kartında çekmecenin satırını seç.
2. `:TO<port><göz><c>;` → `.ok,` — aç.
3. `:TS<port><göz><c>;` ile `h3`/`h4`/`h0` izlenir.

**Aynı hatta birden fazla kabin:**

1. Daha önce satır seçilmiş diğer yönetim kartlarında seçimi bırak: `:Yc000;` (C kartı için örnek; checksum `(89 + 99 + 0) % 10 = 8` → `:Yc008;`).
2. Hedef kabinin **kendi** yönetim kartında (`Cabin.no`) satırı seç.
3. `T`/`Z` komutunu gönder.

Seçim bırakılmazsa, aynı satırı seçili tutan başka bir kabin de komutu uygular (ör. iki serum kabininin kapağının birlikte açılması).

**Kabin tarama:**

1. Hedef adreste `:Y<adres>00<c>;` ile kartın varlığı yoklanır (`+ok-`).
2. Satır `01`–`26` sırayla seçilip her birine `T V` gönderilir; `.vNN,` dönen satırlarda kontrol kartı vardır.
3. Tarama sonunda kartın seçimi `00` ile bırakılmalıdır.

## Açık noktalar

- `T` portları 1–5 için "yalnızca aç/kapat" notu doğrulanmalı.
- Kübik `a` / `tt` alanlarının anlamı (göz / slave sırası) ve 20 gözlü kübiğin `V` tip cevabı sahada doğrulanmalı.
- Orijinal notta "checksum hatası nedeniyle geçersiz" diye listelenen örnek komutlar (`:TO1308;`, `:Z01019;` …) bu dokümana alınmadı; yukarıdaki örnekler koddaki formülle hesaplanmıştır.
