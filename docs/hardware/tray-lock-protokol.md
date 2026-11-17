# Avadanlık kilit kartı RS485 protokolü

Serum bölmesindeki avadanlık (tepsi) rafları için elektromanyetik kilit kartının seri port (RS485) protokolü. Kodda karşılığı `packages/pharmed_core/lib/src/services/tray_lock/tray_lock_protocol.dart` (`TrayLockProtocol`: komut üretimi ve cevap ayrıştırma) dosyasıdır. Sahada hw-test'in **Gelişmiş araçlar → Avadanlık kilit kartı** bölümüyle test edilir.

> Bu doküman, üreticiden gelen ham protokol notunun (`protokol.txt`) düzenlenmiş halidir. **"Uygulamada"** ve **"Sahada"** ile işaretli bölümler orijinal notta yoktur; kodun davranışını ve sahada görülenleri anlatır. Kabin kartlarının (`Y`/`T`/`Z`) protokolü ayrıdır: [rs485-protokol.md](rs485-protokol.md).

- [Sistem yapısı](#sistem-yapısı)
- [Komut ve cevap formatı](#komut-ve-cevap-formatı)
- [Durum makinesi](#durum-makinesi)
- [Komutlar](#komutlar)
- [ID değişikliği](#id-değişikliği)
- [Uygulamada](#uygulamada)
- [Sahada görülenler](#sahada-görülenler)
- [Açık noktalar](#açık-noktalar)

## Sistem yapısı

| Kart | Görevi |
| --- | --- |
| **Master kart** | Manyetik kilit kontrolü: 8 switch (avadanlığın çekildiğini algılar), 8 mosfet (kilitleri sürer). PC ile konuşan karttır. |
| **Slave kart** | Buton paneli: 16 tuş (4×4 matris; 8 port × `+`/`−`), 8 LED. Master'a bağlıdır, PC ile doğrudan konuşmaz. |

- Bağlantı: RS485, 9600 baud, 8N1. Kabin kartlarıyla **aynı hat** kullanılır.
- Kilit mantığı: **mosfet enerjili = kilitli**, enerjisiz = serbest. Elektrik kesilince bütün avadanlıklar serbest kalır (fail-open).
- Bir kart bir rafa karşılık gelir; port `1`–`8` raftaki avadanlık konumudur.

## Komut ve cevap formatı

**PC → Master:** `<iXX:YZ>`

| Alan | Anlam |
| --- | --- |
| `<` | Başlangıç karakteri. |
| `i` | Sabit. |
| `XX` | Cihaz ID (`01`–`99`, iki hane). |
| `:` | Ayırıcı. |
| `Y` | Port numarası (`1`–`8`). |
| `Z` | Komut karakteri: `o`, `c`, `s`, `t`, `k`, `x`. |
| `>` | Bitiş karakteri. |

**Master → PC:** `/xxxxx\` (`/` başlangıç, `\` bitiş). Checksum yoktur; cevapta cihaz ID'si ve port geçmez.

| Cevap | Anlam |
| --- | --- |
| `/okkk\` | İşlem başarılı. |
| `/noo1\` | Geçersiz ID değeri (ID değişikliğinde `1`–`99` dışı). |
| `/noo2\` | Çekmece açık, işlem yapılamaz (`k`/`x` çekmece çekilmişken). |
| `/noo3\` | Geçersiz port numarası (`1`–`8` dışı). |
| `/noo4\` | Sistem müsait değil, başka çekmece işlemi devam ediyor. |
| `/noo5\` | Çekmece çekilmiş, iptal (`c`) yapılamaz. |
| `/noo6\` | Bilinmeyen komut karakteri. |
| `/s:01\` | Durum: kilit açıldı, çekmece henüz çekilmedi (`STATE_UNLOCKED`). |
| `/s:02\` | Durum: çekmece çekildi, göz aktif, `+`/`−` yapılıyor (`STATE_OPEN`). |
| `/s:03\` | Durum: kapalı / idle (`STATE_IDLE`). |
| `/t:xx\` | Tuş değeri (`00`–`99`). |

> Orijinal notta "çekmece" kelimesi avadanlık için kullanılmıştır.

## Durum makinesi

Kart tek durumludur: aynı anda yalnızca bir portta açma işlemi yürür.

```
            o (port N)                 çekme (switch)            itme (switch)
STATE_IDLE ───────────► STATE_UNLOCKED ──────────────► STATE_OPEN ─────────────► STATE_IDLE
  s:03                    s:01                           s:02                       s:03
     ▲                       │ c (iptal)
     └───────────────────────┘
```

- `STATE_OPEN → STATE_IDLE` geçişi (yerine itme) notta yazılmamıştır; switch ile algılandığı varsayılır. Kart bunu kendiliğinden bildirmez, durum `s` ile sorgulanır.

## Komutlar

### `o` — kilidi aç

Örnek: `<i01:3o>` (ID 01, port 3).

- Sistem `IDLE` olmalıdır; değilse hata döner (sahada `/noo4\`).
- Seçilen port dışındaki bütün mosfetler enerjilenir (kilitlenir).
- Seçilen portun mosfeti enerjisiz yapılır (kilit açılır, avadanlık çekilebilir).
- Sistem `STATE_UNLOCKED` durumuna geçer.

### `c` — işlemi iptal et

Örnek: `<i01:3c>`.

- Yalnızca `STATE_UNLOCKED` durumunda çalışır (avadanlık henüz çekilmemişken).
- Avadanlık çekilmişse (`STATE_OPEN`) çalışmaz (`/noo5\`).
- Sistem `STATE_IDLE` durumuna döner.

### `s` — durum sorgula

Örnek: `<i01:3s>`. İlgili portun durumunu döner: `/s:01\`, `/s:02\` ya da `/s:03\`.

### `t` — tuş değeri

Örnek: `<i01:5t>` → `/t:05\`. İlgili gözün `+`/`−` butonlarıyla girilen sayıyı döner (`00`–`99`).

### `k` — bütün kilitler enerjili

Örnek: `<i01:0k>` (port herhangi).

- Avadanlık çekilmişse (`STATE_OPEN`) çalışmaz (`/noo2\`).
- Bütün mosfetler enerjilenir (bütün avadanlıklar kilitlenir).
- Sistem `STATE_IDLE` durumuna döner.

### `x` — bütün kilitler enerjisiz

Örnek: `<i01:0x>` (port herhangi).

- Avadanlık çekilmişse (`STATE_OPEN`) çalışmaz (`/noo2\`).
- Bütün mosfetler enerjisiz yapılır (bütün avadanlıklar serbest).
- Sistem `STATE_IDLE` durumuna döner.

## ID değişikliği

`<i00;XX>` — örnek `<i00;07>` (ID'yi 07 yap).

- `i00` özel adrestir, hattaki bütün cihazlar dinler.
- Ayırıcı `:` yerine `;`.
- Yeni ID EEPROM'a kaydedilir.
- **Hatta tek cihaz varken yapılmalıdır.** Birden fazla cihaz varsa hepsi aynı ID'yi alır ve cevaplar çakışır.

Cevap: `/okkk\` ya da geçersiz ID için `/noo1\`.

## Uygulamada

- **Kod:** `TrayLockProtocol.build` komutu üretir, `TrayLockProtocol.parse` cevabı `TrayLockOk` / `TrayLockStatusResponse` / `TrayLockKeypadResponse` / `TrayLockErrorResponse` olarak ayrıştırır.
- **Hat paylaşımı:** Kabin kartlarıyla aynı `SerialCommunicationService` ve aynı kilit (mutex) kullanılır; ayrı port açılmaz.
- **Kart geneli komutlar:** `k` ve `x` port olarak `0` ile gönderilir (`<i01:0k>`). Sahada `/okkk\` dönüyor.
- **`s` kilidin fiziksel durumunu göstermez.** Kartın o porttaki işlem durumunu gösterir. `k` ya da `x` sonrası her zaman `s:03` döner; kilitlerin enerjili mi serbest mi olduğu `s` ile okunamaz. hw-test bu yüzden son kart geneli komutu (`k`/`x`) ayrıca gösterir.
- **Serum akışı (olması gereken):** kilitler normalde serbest → serum kapağı açılır → `k` → `o` (hedef port) → çekme (`s:02`) → `+`/`−` ile sayım (`t`) → yerine itme (`s:03`) → kapak kapanır → `x`.
- **hw-test araçları:** elle komut, kart ID taraması (1–16), bütün portları sorgula, canlı durum, tek port teşhisi (`k` → `s` → `o` → durum ×6 + fiziksel gözlem), çek / say / it testi (`k` → `o` → canlı `s` + `t` → LED sorusu).

## Sahada görülenler

| Tarih | Gözlem |
| --- | --- |
| 12.10.2026 | Mıknatıslar bağlıyken `k` ya da `o` sırasında RS485 cevapları bozulabiliyor (çöp baytlar) ve kart ~1 sn meşgul kalıyor. `o` sonrası kart `s:01`'de beklemeden ~1 sn içinde `s:03`'e dönüyordu. |
| 16.10.2026 | `o` ile hedef port serbest kaldı, diğerleri kilitlendi; **port LED'i kendiliğinden yandı**. `t` panelden `+`/`−` ile girilen değeri okudu. |
| 12.11.2026 | `k` / `x` doğru çalıştı. `o` kabul edildi (`s:01`) ama fiziksel olarak hedef açılmadı (#221). |
| 17.11.2026 | Kilit kablolaması düzeltildi; tek port açma çalışıyor. **Cevap süreleri:** `o` / `k` / `x` / `c` ≈ 600 ms, `s` / `t` ≈ 100 ms; `o`'dan hemen sonraki `s` bazen 0,6–1,1 sn. **`s:01` davranışı tutarsız:** bazı denemelerde 30 sn'den uzun sabit kaldı, bazılarında 2–4 sn sonra (≈ 0,8–1 sn süren bir cevapla) `s:03`'e döndü, bazılarında `o`'dan hemen sonra `s:03` geldi. Avadanlık çekildiği hâlde **`s:02` hiç görülmedi**. `t` her zaman `00` döndü, port LED'i yanmadı (#263). |

## Açık noktalar

- **Hata kodları:** Komut açıklamalarında `/nooo\`, hata tablosunda `/noo1\`–`/noo6\` geçiyor. Sahada `o` meşgulken `/noo4\` görüldü; `/nooo\` ayrı bir kod olarak hiç görülmedi.
- **`STATE_UNLOCKED` zaman aşımı:** Notta yok. Sahada kart bazen `s:01`'den kendiliğinden `s:03`'e dönüyor, bazen dönmüyor; kuralı üreticiden öğrenilmeli.
- **Çekme algılama:** `s:02`'ye geçiş master karttaki switch'e bağlı. 17.11'de hiç görülmedi; switch kablolaması / port eşlemesi kontrol edilmeli.
- **LED:** Notta LED'in ne zaman yandığı yazmıyor (16.10'da `o` ile yandı).
- **`t` değeri:** Mutlak sayı mı, delta mı; yeni `o`'da sıfırlanıyor mu; yalnızca `STATE_OPEN`'da mı değişiyor? Notta yok.
- **Bütünlük:** Cevaplarda checksum, cihaz ID'si ve port yok. Bozulmuş bir `/t:05\` fark edilemez; aynı hatta gecikmiş bir cevap sonraki komutun cevabıyla karışabilir.
- **Aktif port sorgusu:** "Şu an hangi port açık" sorusunu soracak komut yok; uygulama yeniden başladığında kurtarma için bütün portlar tek tek sorgulanmalı.
- **Güç kesintisi:** Açılışta durumun hep `IDLE` mı başladığı ve o sırada dışarıda olan avadanlığın ne olacağı tanımlı değil.
- **Yazma komutu yok:** PC'den slave panele değer ya da LED yazan komut yok; panel → PC tek yönlü.
