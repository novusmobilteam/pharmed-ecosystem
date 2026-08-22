# PharMed Lokalizasyon Denetimi — Faz 1 Envanter Raporu

Tarih: 2026-08-22
Kapsam: `apps/pharmed-client`, `apps/pharmed-manager`, `packages/pharmed_core`, `packages/pharmed_data`, `packages/pharmed_ui`, `packages/pharmed_utils`
ARB kaynağı: `packages/pharmed_ui/lib/src/l10n/{app_en,app_tr,app_fr,app_ar}.arb`

> Bu rapor **Faz 1 (Envanter)** çıktısıdır. Hiçbir dosya değiştirilmedi. Faz 2 (Düzeltme) için modül modül onay bekleniyor.

---

## 0. Sayısal Özet

| Metrik | Sayı |
|---|---|
| EN key sayısı | 1778 |
| TR key sayısı | 1778 |
| FR key sayısı | 1379 (**399 eksik**) |
| AR key sayısı | 408 (dokunulmayacak, sadece bilgi) |
| Description yanlış konumda (TR-dışı) | 1531 key |
| Description hiçbir dosyada yok | 76 key |
| Description doğru (sadece TR'de) | 171 key |
| İsimlendirme ihlali — prefix'siz düz camelCase | 189 key |
| İsimlendirme ihlali — aşırı parçalı snake_case | 12 key |
| Kod içinde tespit edilen hardcoded string/hata mesajı (canlı kod) | ~154 bulgu (44 client + 68 manager + ~36 core/data + 8 ui, bkz. modül detayı) |
| Ölü/erişilemeyen koddaki hardcoded string (referans amaçlı, düzeltme kapsamı dışı önerilir) | ~50 bulgu (`old_features/`, yorumlu dosyalar) |
| Tespit edilen gerçek kod hatası (sadece lokalizasyon değil) | 5 (bkz. §4) |

---

## 1. ARB Dosyası Analizi

### 1.1 Key Parity (EN/TR/FR)

- EN ↔ TR arasında fark yok (1778 = 1778).
- **FR'de 399 key eksik.** Eksik key'lerin tam listesi `/tmp/missing_report.txt` içinde (oturum sonunda kaybolabilir — Faz 2'de yeniden üretilecek). Bu, "her yeni key'de FR'yi de senkron tut" kuralının geçmişte sistematik olarak atlandığını gösteriyor; muhtemelen büyük bir modülün (veya birkaç özelliğin) FR çevirisi hiç yapılmamış.
- AR: 408 key — kasıtlı olarak dondurulmuş, üzerine hiçbir işlem yapılmayacak.

**Faz 2 önerisi:** FR eksiklerini modül bazlı gruplayıp, önce hangi modüllerin toptan eksik olduğunu belirleyip o sırayla tamamlamak (muhtemelen yeni eklenen özellikler — cabin-visual, multi-cabin, drug-assignment redesign gibi son commit'lerle ilişkili).

### 1.2 `@key` Description Konumu

Kural: description sadece `app_tr.arb`'de olmalı.

| Durum | Key sayısı |
|---|---|
| EN + FR + TR üçünde birden (silinmesi gereken: EN, FR) | 1081 |
| Sadece EN'de (taşınması gereken: EN → TR) | 231 |
| EN + TR'de (silinmesi gereken: EN) | 216 |
| Sadece TR'de (**doğru, dokunma**) | 171 |
| EN + FR'de (taşınması gereken: EN veya FR → TR) | 3 |
| Hiçbirinde yok (description hiç yazılmamış — Faz 2'de yazılmalı) | 76 |

**Faz 2 işlemi:** 1531 key için description'ı TR'ye taşı/birleştir, EN ve FR'deki `@key` bloklarından `description` alanını sil (placeholders/type varsa korunacak). 76 key için sıfırdan description yazılacak.

### 1.3 İsimlendirme Standardı İhlalleri (skill: arb-key-naming)

**a) Prefix'siz düz camelCase (189 key)** — modül adı var ama alt çizgi ile ayrılmamış (skill'in "Kaçın" bölümünde açıkça örneklenen disiplin dışı desen). Örnek kümeler:
- `activeIngredient*` (5 key), `cabinTemperature*` (14 key), `dashboard*` (13 key), `directedOrders*` (7 key), `drugClass*` (6 key), `drugType*` (6 key), `emptyState*` (16 key), `kitContent*`/`kit*` (12 key), `materialType*` (6 key), `prescription*` (~35 key), `refund*` (2 key), `role*` (6 key), `unit*` (4 key), `user*` (20 key), `warning*` (7 key), `waste*` (2 key).

Bunlar muhtemelen tek modül prefix'i altında toplanmalı: örn. `activeIngredientDialogTitle` → `activeIngredient_dialogTitle`, `userNameLabel` → `user_nameLabel`, `prescriptionSaveButton` → `prescription_saveButton` vb.

**b) Aşırı parçalı snake_case, descriptor camelCase'e çevrilmeli (12 key):**
```
cabin_stock_empty_description        → cabinStock_emptyDescription (veya cabinStock_empty_description'ı module_submodule olarak tutup descriptor'ı tekleştir)
cabin_stock_empty_title              → cabinStock_emptyTitle
census_action_report_extra_stock     → census_action_reportExtraStock
census_extra_stock_dialog_title      → census_extraStockDialogTitle
census_extra_stock_quantity_label    → census_extraStockQuantityLabel
census_extra_stock_summary_title     → census_extraStockSummaryTitle
date_preset_last_3_days              → dateFilter_last3DaysPreset (modül belirsiz, bkz §5)
date_preset_last_7_days              → dateFilter_last7DaysPreset (modül belirsiz, bkz §5)
empty_state_no_patient_selected_description → emptyState_noPatientSelectedDescription
empty_state_no_patient_selected_title       → emptyState_noPatientSelectedTitle
unadministered_prescriptions_empty_description → prescription_unadministeredEmptyDescription (veya dashboard_, kullanım yerine bağlı)
unadministered_prescriptions_empty_title       → prescription_unadministeredEmptyTitle
```

**c) Kullanım yerinde tespit edilen ek isimlendirme tutarsızlıkları** (pharmed_ui agent bulgusu):
- `empty_state_no_patient_selected_title/description` — aynı dosyadaki diğer `emptyState*` key'leriyle tutarsız (camelCase değil).
- `session_timeout_warning`, `session_timeout_continueButton`, `session_timeout_prefix`, `session_timeout_suffix` — `med_stale_banner.dart` içinde `staleBanner_*` prefix'i kullanılan bir widget'ta farklı/standart-dışı bir modül adı (`session_timeout`) ile karışık kullanılıyor. Muhtemelen `staleBanner_` altına taşınmalı.

---

## 2. Kod Tabanında Hardcoded String Bulguları (Canlı Kod)

### 2.1 `apps/pharmed-client` (44 bulgu, 13 dosya)

| Modül | Dosya | Bulgu sayısı | Not |
|---|---|---|---|
| dashboard | `cabin_telemetry_panel.dart:104` | 1 | **KOD HATASI** — `context.l10n.dashboard_sensor_paused` tırnak içine alınmış, literal string olarak ekrana basılıyor. Key de ARB'de yok. |
| census (master) | `master_census_selection_view.dart:58` | 1 (3 literal) | `// TODO : Localization` yorumu mevcut — segment buton etiketleri ("Tüm Kabin"/"Çekmece Bazlı"/"İlaç Bazlı") |
| cabin_shell_widgets (paylaşılan — refill/census/intake/unload/refund/waste/destruction) | `cabin_assignment_list_view.dart` | 6 | Tablo başlıkları (Seç/Konum/Stok/Doluluk) + konum string interpolasyonu (Çekmece/Sütun/Satır/Göz) |
| cabin_shell_widgets | `cabin_overview_execution_panel.dart` | 16 (tekrarlı) | "KABİN GENEL BAKIŞ", "KÜBİK", "İADE", legend etiketleri x3 (3 kez tekrar ediyor), "KONUM REHBERİ" |
| cabin_shell_widgets | `med_cabin_overview_panel.dart` | 2 | Yukarıdakiyle aynı stringler, paralel/olası duplicate implementasyon — **Faz 2 öncesi netleştirilmeli** (bkz §5) |
| cabin_shell_widgets | `patient_selection_filter_dialog.dart:37` | 1 | "Filtreler" dialog başlığı |
| cabin_shell_widgets | `patient_selection_panel.dart:371` | 1 | Kod içinde `// TODO(Feyzullah): gerçek ARB key'ini oluştur.` yorumu — bilinçli olarak ertelenmiş |
| waste (master) | `master_waste_notifier.dart` | 4 | Validasyon + başarı mesajları |
| refund (master) | `master_refund_notifier.dart` | 6 | Validasyon + hata mesajları (2 tanesi birebir tekrar) |
| settings (debug ekranı, `kDebugMode` korumalı) | `debug_settings_view.dart` | ~13 | Düşük öncelik — sadece debug build'de görünür |
| app shell | `main.dart:47` | 1 | `MaterialApp(title: 'Pharmed')` — marka adı, muhtemelen çevrilmemeli |

Belirsiz: `cabin_overview_selection_panel.dart:155` — `'G-${index+1}'` hücre etiketi (Göz kısaltması mı, yapısal kod mu belirsiz).

### 2.2 `apps/pharmed-manager` (68 canlı bulgu + ~50 ölü kod bulgusu)

| Modül | Dosya | Bulgu | Not |
|---|---|---|---|
| dashboard | `dashboard_view.dart:285` | 1 | "SERVİS" label |
| refund (eczane) | `pharmacy_refund_screen.dart`, `table_view.dart`, `pharmacy_refund_notifier.dart` | 12 | Dialog başlığı/buton, tooltip, PDF başlıkları, validasyon/başarı mesajları |
| reports/auth_summary | `user_auth_summary_view.dart`, `table_view.dart` | 6 | Dialog başlığı, kolon başlıkları, boş durum metinleri, tooltip |
| medicine / material_type | `material_type_notifier.dart`, `drug_form_notifier.dart`, `medical_consumable_form_notifier.dart` | 3 | Başarı mesajları |
| **Sistemik**: `common_addItemHint` | 7 çağrı yeri (`unit`, `drug_type`, `kit`, `drug_class`, `material_type`, `kit_content`, `active_ingredient`) | 7 | ARB key'i doğru ama `{item}` parametresine hardcoded Türkçe isim geçiliyor (örn. `'birim'`, `'ilaç tipi'`) — EN/FR'de cümle çevrilse bile isim Türkçe kalıyor. Her çağrı yeri kendi `xxx_itemName` key'ine kavuşturulmalı. |
| RFID servis katmanı | `core/services/rfid/rfid_service.dart`, `mock_rfid_service.dart` | ~20 | Şu an hiçbir ekran tarafından tüketilmiyor gibi görünüyor — canlı mı ölü mü doğrulanmalı (bkz §5) |
| **Ölü kod** (`old_features/*`, `features/unscanned_barcodes/*` — tamamen yorum satırı, `features/inconsistency/` bazı dosyalar) | — | ~50 | Kullanıcıya ulaşmıyor. Faz 2 kapsamı dışında bırakılması önerilir; ekip canlandırmayı planlıyorsa ayrıca ele alınmalı. |

### 2.3 `packages/pharmed_core` + `packages/pharmed_data`

| Katman/Modül | Dosya | Bulgu | Not |
|---|---|---|---|
| `enumCore_` | `enums/cabin_inventory_type.dart:16-88` | 30 literal | Tüm enum tamamen lokalize değil (operationLabel/title/buttonText/fieldText/sequentialText getter'ları). Kardeş dosyalar (`status.dart`, `order_status.dart`) doğru şekilde `contextlessL10n()` kullanıyor — bu gerçek bir eksik, istisna değil. |
| `tableCore_` | `prescription_item.dart:205-217` | 13 literal | `PrescriptionColumn.label` getter'ı — tüm tablo kolon başlıkları hardcoded |
| `prescriptionCore_` | `submit_prescription_action_usecase.dart:4-7` | 4 literal | Aksiyon buton/menü başlıkları |
| `dataGuard_` | 6 entity dosyası (`dosage_form`, `role`, `branch`, `warehouse`, `warning`, `active_ingredient`) | 6 | Form validasyon mesajları. **Ayrıca `dosage_form.dart:31`'de kopyala-yapıştır hatası var** — Branch hata metnini döndürüyor (bkz §4). |
| `dataGuard_` (yanlış katman) | `cabin_temperature_remote_datasource.dart:37` | 1 | `CustomException` içinde geliştirici mesajı — şu an `CustomException.message` kullanıcıya gösterilmiyor (generic mesaja map ediliyor) ama tutarsız, temizlenmeli |
| `appException_`/`cabinCore_` | `get_cabin_thresholds_usecase.dart:27`, `save_sensor_values_usecase.dart:26` | 2 | **KOD HATASI** — `ServiceException(message: '', statusCode: 400)`: statusCode<500 olduğu için boş mesaj doğrudan kullanıcıya gösteriliyor (bkz §4) |
| `prescriptionCore_`/`cabinCore_` | `check_intake_usecase.dart:103` | 1 | `CheckFailed.message` — kullanıcıya gösteriliyor |
| `prescriptionCore_` (ölü) | `create_prescription_template_usecase.dart:21` | 1 | Şu an gösterilmiyor (CustomException swallows message) ama kardeş usecase doğru pattern'i kullanıyor — tutarsızlık |
| `cabinCore_` | `cabin_targeted_prescription_item.dart:54` | 1 | `'Bilinmeyen İlaç'` fallback, doc comment kullanıcıya gösterileceğini teyit ediyor |
| Dosya servisleri (PDF/Excel/native dialog) | `pdf_export_service.dart`, `excel_export_service.dart`, `desktop_file_service.dart` | ~14 | Snackbar mesajları, varsayılan rapor/dialog başlıkları — bunlar `pharmed_core` içinde ama fiilen UI'a çıkıyor |

Belirsiz (bkz §5): `MasterDrawerFailure`/`MobileDrawerFailure.detail` alanları, `command_builder.dart` ArgumentError'ları, `test_cabin_connection_usecase.dart` (statusCode≥500 olduğu için şu an ölü), enum `fromString()` parse hataları.

### 2.4 `packages/pharmed_ui` (8 canlı bulgu + 3 isimlendirme tutarsızlığı)

| Modül | Dosya | Bulgu | Not |
|---|---|---|---|
| `dialog_` (öneri) | `message_utils.dart:390-418` | 8 literal | `MessageUtils._getConfirmDialogContent` — exit/save/discard/custom onay dialoglarının varsayılan başlık+mesajları hardcoded Türkçe. Paylaşılan yardımcı, her iki app'i de etkiliyor. En kritik bulgulardan biri. |
| `common_` (öneri) | `med_mobile_layout.dart:8`, `med_tablet_layout.dart:8` | 2 | Aynı literal ("Mobil görünüm hazırlanıyor...") iki dosyada tekrarlanıyor — **kopyala-yapıştır hatası: tablet layout'ta "Mobile view" mesajı var** (bkz §4) |
| `table_` (öneri) | `med_table_view.dart:432` | 1 | Varsayılan PDF başlığı "Tablo Raporu" |

Belirsiz: `cabin_summary_view.dart:249` "SRM" (sabit kod mu?), `med_on_screen_keyboard.dart:195,200` "ABC"/"123" (klavye mod etiketleri, muhtemelen çevrilmemeli).

---

## 3. Modül Bazlı Faz 2 Sıralama Önerisi

Rapor kapsamındaki modülleri büyükten küçüğe / bağımlılık sırasına göre önerilen işlem sırası:

1. **pharmed_ui ortak katman** (`message_utils.dart` dialogları + layout placeholder'ları) — her iki app'i etkiliyor, önce düzeltilmeli.
2. **cabin_shell_widgets** (client) — refill/census/intake/unload/refund/waste/destruction'ın hepsini besliyor, tek seferde büyük kazanım.
3. **enumCore_ (`cabin_inventory_type.dart`)** — birçok ekranda kullanılan enum, geniş etki alanı.
4. **prescription / prescriptionCore / tableCore** (prescription_item kolonları + submit_prescription_action_usecase)
5. **dataGuard_ entity validasyonları** (6 dosya, aynı kalıp — toplu düzeltilebilir; `dosage_form.dart` kopyala-yapıştır hatası dahil)
6. **census (master, client)**
7. **waste / refund (master, client)**
8. **refund (eczane, manager) + reports/auth_summary (manager)**
9. **material_type / medicine (manager) + common_addItemHint sistemik düzeltmesi**
10. **cabin_temperature usecase bug fix'leri (boş mesaj)**
11. **Dosya servisleri (pdf/excel/desktop_file_service)**
12. **dashboard (client + manager) küçük bulgular**
13. **debug_settings_view (client, düşük öncelik)**
14. **FR eksik 399 key'in modül modül tamamlanması** (paralel yürütülebilir)
15. **Description merkezi TR'ye taşıma + isimlendirme standardizasyonu** — bu, key bazlı mekanik bir iş; büyük ölçekte tek seferde (script destekli) yapılması, modül modül elle yapılmasından daha güvenli olabilir — onayınızı isteyeceğim.

---

## 4. Tespit Edilen Gerçek Kod Hataları (Sadece Lokalizasyon Değil)

1. **`cabin_telemetry_panel.dart:104`** (client) — `Text('context.l10n.dashboard_sensor_paused')` tırnaklanmış, literal string ekrana basılıyor + key ARB'de yok.
2. **`dosage_form.dart:31`** (core) — `nameError` getter'ı yanlışlıkla "Branş adı zorunludur" döndürüyor (branch.dart'tan kopyalanmış).
3. **`get_cabin_thresholds_usecase.dart:27`** ve **`save_sensor_values_usecase.dart:26`** (core) — `ServiceException(message: '', statusCode: 400)`: boş hata mesajı doğrudan kullanıcıya gösteriliyor.
4. **`med_mobile_layout.dart:8`** vs **`med_tablet_layout.dart:8`** (pharmed_ui) — tablet layout'ta yanlışlıkla "Mobil görünüm hazırlanıyor..." mesajı var (kopyala-yapıştır).
5. **`common_addItemHint` sistemik kullanım hatası** (manager, 7 çağrı yeri) — doğru ARB key'i kullanılıyor ama parametreye hardcoded Türkçe isim geçiliyor, EN/FR'de karışık dilli cümle üretiyor.

Bunlar Faz 2'de ilgili modülle birlikte düzeltilecek, ancak önceliğinizi netleştirmeniz için ayrıca öne çıkarıyorum.

---

## 5. Belirsiz / Manuel Karar Gerektiren Durumlar

Aşağıdakiler için tahmin yürütüp otomatik key üretmedim — onayınızı bekliyorum:

1. **`cabin_overview_execution_panel.dart` vs `med_cabin_overview_panel.dart`** (client) — aynı legend/etiket stringleri iki paralel widget'ta tekrarlanıyor. Biri eskiyen/duplicate implementasyon olabilir. Lokalize etmeden önce hangisinin canlı/hedef olduğunu netleştirmek gerekiyor — yoksa aynı işi iki kez yapıp key çoğaltmış oluruz.
2. **`old_features/*` (manager)** — `medicine_withdraw`, `cabin` (shared), `medicine_define`, `medicine_disposal` altında ~23 hardcoded string. Hiçbir aktif ekran tarafından import edilmiyor gibi görünüyor. Silinecek mi, canlandırılacak mı, yoksa referans olarak mı tutulacak?
3. **`features/unscanned_barcodes/`** (manager) — view katmanı tamamen yorum satırı. Aynı soru: kapsam dışı mı bırakılsın?
4. **`features/inconsistency/`** (manager) — bazı dosyalar (`inconsistency_detail_view_model.dart`, `inconsistency_summary_view.dart`, `inconsistency_detail_view.dart`) yorumlu/`part of` stub; canlı `inconsistency_screen.dart` zaten doğru lokalize. Ölü dosyalar dahil edilsin mi?
5. **`core/services/rfid/rfid_service.dart` / `mock_rfid_service.dart`** (manager) — ~20 hardcoded hata mesajı içeriyor ama hiçbir `features/*` ekranı tarafından şu an tüketilmiyor gibi görünüyor. Gerçekten ölü mü, yoksa gelecekte bağlanacak donanım katmanı mı?
6. **`MasterDrawerFailure`/`MobileDrawerFailure.detail`** (core, `monitor_drawer_closure_usecase.dart`, `start_master_drawer_session_usecase.dart`) — hardcoded Türkçe detay metinleri, ana `failure` enum'u zaten lokalize gösteriliyor olabilir ama `detail` alanının UI'a gidip gitmediği bu paketlerden doğrulanamadı.
7. **`cabin_overview_selection_panel.dart:155`** (client) — `'G-${index+1}'` hücre etiketindeki "G" harfi (Göz kısaltması) — yapısal kod mu, çevrilecek metin mi?
8. **`date_preset_last_3_days` / `date_preset_last_7_days`** (ARB) — hangi modüle ait olduğu net değil (`dateFilter_` mi, ekrana özel mi?).
9. **`unadministered_prescriptions_empty_*`** (ARB) — `prescription_` mi `dashboard_` mu daha doğru, kullanım yerine bakılmadan karar verilemez.
10. **`debug_settings_view.dart`** (client) — sadece `kDebugMode`'da erişilebilir. Faz 2 kapsamına alınsın mı, yoksa düşük öncelik/atlansın mı?
11. **RFID/donanım katmanındaki `ArgumentError`/`StateError`'lar** (`command_builder.dart`, `drawer_address.dart`, `drawer_config.dart`, `drawer_slot_visual.dart`) — geliştirici guard clause'ları, muhtemelen kullanıcıya hiç ulaşmıyor. Kapsam dışı bırakılması öneriliyor, onay istiyorum.
12. **`main.dart:47`** (`MaterialApp(title: 'Pharmed')`) ve **manager'daki "DEV" badge** — marka adı/iç geliştirici etiketleri, muhtemelen lokalize edilmemeli — onay istiyorum.

---

## 6. `app_ar.arb` Notu

`app_ar.arb` sadece mevcut durumun kaydı için sayıldı: **408 key**, EN/TR/FR'nin çok gerisinde (1778 key'e göre ~1370 key eksik). Talimat gereği:
- Bu denetimde üretilecek hiçbir yeni key AR'ye eklenmeyecek.
- Mevcut AR key'lerine dokunulmayacak.
- Eksik AR çevirileri "sorun" olarak işlenmeyecek — bilinçli askıya alma durumu.

---

## Sonraki Adım

Faz 1 tamamlandı. Yukarıdaki modül sıralamasını (bkz §3) onaylarsanız, sırayla (önce **pharmed_ui ortak katman**) Faz 2'ye geçeceğim. §5'teki 12 belirsiz durum için de karar/yönlendirmenizi bekliyorum — bunlardan bazıları (özellikle 1, 2, 5) sonraki modüllerin kapsamını doğrudan etkiliyor.
