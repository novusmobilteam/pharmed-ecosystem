# PharMed Log Paneli

Kiosklardan (pharmed-client) gelen logları izlemek, aynı hataları gruplamak ve yarıda kalan bir işlemin sebebini bulmak için web paneli.

Backend endpoint'leri **"PharMed Cihaz Logları — Backend API Sözleşmesi"** belgesinde tanımlı. Backend hazır olana kadar panel aynı sözleşmeyi taklit eden sahte veriyle çalışır.

## Çalıştırma

```bash
cd apps/pharmed-log-panel
npm install
npm run dev          # http://localhost:5173 — sahte veri
npm run build        # dist/ — statik dosyalar
```

Gerçek backend'e bağlamak için:

```bash
VITE_API_BASE_URL=https://sunucu.ornek npm run build
```

Token şimdilik `localStorage['pharmed-log-panel:token']` değerinden okunup `Authorization: Bearer …` olarak gönderilir. Panelin kendi giriş ekranı, backend'deki yetki modeli netleşince eklenecek.

`dist/` klasörü herhangi bir statik sunucudan (IIS sanal dizini dahil) yayınlanabilir; yönlendirme hash tabanlı olduğu için sunucu tarafında ek ayar gerekmez.

## Ekranlar

| Ekran | Ne için |
| --- | --- |
| Genel bakış | Seçili aralıkta hata/uyarı grafiği, en sık açık sorunlar, kural redleri, en çok hata veren ve en yavaş istekler, sessiz kiosklar |
| Sorunlar | Aynı `fingerprint`'e sahip hataların grupları; durum (açık / çözüldü / yok sayıldı), "geri döndü" uyarısı, teşhis kartı, sürüm/kiosk/kullanıcı/ekran dağılımı |
| Loglar | Zaman, seviye, istasyon, kiosk, kullanıcı, kural, sürüm ve metin filtreleri; histogram; canlı izleme; CSV/NDJSON dışa aktarım. Filtreler URL'de durur — bağlantı paylaşılabilir |
| Kayıt detayı | Teşhis kartı, bağlam (iç içe JSON açılır), oturum, önceki adımlar, stack trace; isteğin izi, kioskta öncesi/sonrası, sorun grubu bağlantıları |
| Kiosklar | Sürüm, son sinyal, sessiz kiosk uyarısı (15 dk+), 24 saatlik hata/uyarı sayıları |

## Yapı

```
src/
  api/types.ts        Sözleşmedeki veri şekilleri ve LogApi arayüzü
  api/http.ts         Gerçek backend istemcisi (/api/DeviceLog)
  api/mock.ts         Sahte veri: gerçekçi senaryolar + bellekte sorgu motoru
  api/fingerprint.ts  Sözleşmedeki fingerprint kuralı (yalnızca sahte veri için)
  diagnosis.ts        Teşhis kataloğu: kural kodu / hata türü → ne oldu, sebep, kontrol adımları
  pages/              Ekranlar
  components/         Ortak bileşenler (tablo, grafik, JSON görünümü, teşhis kartı)
```

## Teşhis kataloğu

`diagnosis.ts` içindeki `RULES` haritası, pharmed-client'taki `MedLogger.ruleRejected(rule: …)` ve `setFailed(rule: …)` kodlarıyla birebir eşleşir. İstemciye yeni bir kural kodu eklendiğinde buraya da bir girdi eklenmeli; eklenmezse kayıt "Sınıflandırılmamış" görünür.
