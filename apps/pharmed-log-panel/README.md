# PharMed Log Paneli

Kiosklardan (pharmed-client) gelen logları ve backend'de yakalanmamış hataları izlemek, aynı hataları gruplamak ve yarıda kalan bir işlemin sebebini bulmak için web paneli.

## Çalıştırma

```bash
cd apps/pharmed-log-panel
npm install
npm run dev          # http://localhost:5173 — sahte veri
npm run build        # dist/ — statik dosyalar
```

Gerçek backend'e bağlamak için (değer `/api` olmadan sunucu kökü):

```bash
VITE_API_BASE_URL=https://agena.novusyazilim.com npm run dev
VITE_API_BASE_URL=https://agena.novusyazilim.com npm run build
```

Bu durumda panel açılışta **yönetici girişi** ister (`POST /api/Login/login`). Token tarayıcıda saklanır; süresi dolunca ya da backend 401 dönünce giriş ekranına dönülür. Yönetici olmayan hesapla giriş yapılamaz.

`dist/` klasörü herhangi bir statik sunucudan (IIS sanal dizini dahil) yayınlanabilir; yönlendirme hash tabanlı olduğu için sunucu tarafında ek ayar gerekmez. Backend farklı bir adreste olduğu için CORS'un panelin adresine açık olması gerekir.

## Kullanılan servisler

| Servis | Panelde |
| --- | --- |
| `GET /api/FrontendLog` | Loglar, istek izi, kioskta öncesi/sonrası; ayrıca son 7 günün kayıtları (aşağıya bakın) |
| `GET /api/FrontendLog/{id}` | Kayıt detayı: bağlam, oturum, önceki adımlar, stack trace |
| `GET /api/BackendLog`, `GET /api/BackendLog/{id}` | Sunucu hataları ekranı; istemci kaydının detayındaki "Sunucu tarafı" bölümü |
| `GET /api/User`, `GET /api/Station` | Kullanıcı ve istasyon adları |

Backend'de gruplama ve istatistik servisi henüz yok. **Sorunlar, genel bakış grafikleri, en çoklar ve kiosk listesi** son 7 günün kayıtları çekilip panelde hesaplanır (`api/engine.ts`). Pencere ilk açılışta bir kez yüklenir, sonra 30 saniyede bir yalnızca yeni kayıtlar eklenir; 30.000 kaydı aşarsa ekranlarda uyarı görünür. Bu yüzden şimdilik:

- Sorun durumları (çözüldü / yok sayıldı) **yalnızca o tarayıcıda** saklanır.
- Kiosk sinyalleri backend'de saklanmadığı için "sessiz kiosk" tespiti yapılamaz; son kayıt zamanı gösterilir.
- Liste kayıtlarında oturum gelmediği için bu hesaplarda kullanıcı ve istasyon, backend'in gönderim token'ından aldığı değerlerdir. Kayıt detayında kaydın kendi oturumu gösterilir; ikisi farklıysa belirtilir.

İstemci kaydı ile sunucu hatası `operationId` üzerinden eşleşir: başarılı yazmalarda `relatedOperationId`, hata yanıtlarında yanıt gövdesindeki `operationId` kullanılır.

## Ekranlar

| Ekran | Ne için |
| --- | --- |
| Genel bakış | Seçili aralıkta hata/uyarı grafiği, en sık açık sorunlar, kural redleri, en çok hata veren ve en yavaş istekler |
| Sorunlar | Aynı `fingerprint`'e sahip hataların grupları; durum (açık / çözüldü / yok sayıldı), "geri döndü" uyarısı, teşhis kartı, sürüm/kiosk/kullanıcı/ekran dağılımı |
| Loglar | Zaman, seviye, istasyon, kiosk, kullanıcı, kural, sürüm, işlem ve metin filtreleri; histogram; canlı izleme; CSV/NDJSON dışa aktarım. Filtreler URL'de durur — bağlantı paylaşılabilir |
| Kayıt detayı | Teşhis kartı, bağlam (iç içe JSON açılır), oturum, önceki adımlar, stack trace, ilgili sunucu hatası; isteğin izi, kioskta öncesi/sonrası, sorun grubu bağlantıları |
| Kiosklar | Sürüm, son kayıt, 24 saatlik hata/uyarı sayıları |
| Sunucu hataları | Backend'de yakalanmamış hatalar: istek, hata tipi, maskelenmiş parametreler, stack trace; aynı işlemin kiosk kayıtlarına bağlantı |

## Yapı

```
src/
  auth.ts             Giriş, token saklama, oturum süresi
  api/types.ts        Panelin veri şekilleri ve LogApi arayüzü
  api/http.ts         Gerçek backend istemcisi (FrontendLog / BackendLog → panel şekilleri)
  api/engine.ts       Bellekteki kayıtlar üzerinde gruplama ve istatistik (iki kaynak da kullanır)
  api/mock.ts         Sahte veri: gerçekçi senaryolar
  api/fingerprint.ts  Hata gruplama anahtarı
  diagnosis.ts        Teşhis kataloğu: kural kodu / hata türü → ne oldu, sebep, kontrol adımları
  pages/              Ekranlar
  components/         Ortak bileşenler (tablo, grafik, JSON görünümü, teşhis kartı)
```

## Teşhis kataloğu

`diagnosis.ts` içindeki `RULES` haritası, pharmed-client'taki `MedLogger.ruleRejected(rule: …)` ve `setFailed(rule: …)` kodlarıyla birebir eşleşir. İstemciye yeni bir kural kodu eklendiğinde buraya da bir girdi eklenmeli; eklenmezse kayıt "Sınıflandırılmamış" görünür.
