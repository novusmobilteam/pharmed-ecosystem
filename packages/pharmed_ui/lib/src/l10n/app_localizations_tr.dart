// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get common_selectCellTitle => 'Bir göz seçin';

  @override
  String get common_noAssignmentBadge => 'Atanmamış';

  @override
  String get common_drugAssignedBadge => 'İlaç Atanmış';

  @override
  String get common_patientAssignedBadge => 'Hasta Atanmış';

  @override
  String get common_noCabinDataTitle => 'Kabin verisi bulunamadı';

  @override
  String get common_noCabinDataDescription =>
      'Kabin henüz yapılandırılmamış olabilir\nveya bağlantı kurulamadı.';

  @override
  String get common_noResultsTitle => 'Sonuç bulunamadı';

  @override
  String get common_noResultsDescription =>
      'Arama kriterlerinizi değiştirmeyi deneyin.';

  @override
  String get common_retryButton => 'Tekrar Dene';

  @override
  String get common_completeButton => 'Tamamla';

  @override
  String get common_cancelButton => 'İptal';

  @override
  String get common_barcodeLabel => 'Karekod';

  @override
  String get common_pageNotFound => 'Sayfa bulunamadı';

  @override
  String get common_minLabel => 'Min';

  @override
  String get common_maxLabel => 'Maks';

  @override
  String get common_criticalLabel => 'Kritik';

  @override
  String get common_boolYes => 'Evet';

  @override
  String get common_boolNo => 'Hayır';

  @override
  String get common_action_discharge => 'Taburcu Et';

  @override
  String get auth_loginSubtitle => 'Sisteme giriş yapın';

  @override
  String get auth_emailLabel => 'E-posta / Kullanıcı Adı';

  @override
  String get auth_passwordLabel => 'Şifre';

  @override
  String get auth_loginButton => 'Giriş Yap';

  @override
  String get auth_genericError => 'Bir hata oluştu';

  @override
  String get dashboard_appBarTitle => 'İLAÇ KABİN YÖNETİMİ';

  @override
  String get dashboard_logoutTooltip => 'Çıkış Yap';

  @override
  String get dashboard_loginBarButton => 'Giriş Yap';

  @override
  String get dashboard_kpiActivePatients => 'Aktif Hasta';

  @override
  String get dashboard_kpiCompletedOps => 'Tamamlanan İşlem';

  @override
  String get dashboard_kpiPendingPrescriptions => 'Bekleyen Reçete';

  @override
  String get dashboard_kpiCriticalAlerts => 'Kritik Uyarı';

  @override
  String get dashboard_cabinStatusHeader => 'KABİN DURUMU';

  @override
  String get dashboard_cabinStatusLabel => 'Kabin Durumu';

  @override
  String get dashboard_kpiLoadError => 'KPI verileri yüklenemedi';

  @override
  String get dashboard_cabinLoadError => 'Kabin verisi yüklenemedi';

  @override
  String get dashboard_treatmentsLoadError => 'Yaklaşan tedaviler yüklenemedi';

  @override
  String get dashboard_sktLoadError => 'SKT verisi yüklenemedi';

  @override
  String get assignment_assignBedPlaceholder =>
      'Yatak atamak için orta\npanelden bir göz seçin.';

  @override
  String get assignment_assignDrugPlaceholder =>
      'Atama yapmak için orta\npanelden bir göz seçin.';

  @override
  String get assignment_hospitalizationSectionLabel => 'HASTA / YATIŞ';

  @override
  String get assignment_hospitalizationSelectorHint => 'Yatış seçin...';

  @override
  String get assignment_selectHospitalizationDialogTitle => 'Yatış Seç';

  @override
  String get assignment_drugSectionLabel => 'İLAÇ';

  @override
  String get assignment_drugSelectorHint => 'İlaç seçin...';

  @override
  String get assignment_selectDrugDialogTitle => 'İlaç Seç';

  @override
  String get assignment_quantitySectionLabel => 'MİKTAR';

  @override
  String get assignment_saveAssignmentButton => 'Atamayı Kaydet';

  @override
  String get assignment_removeAssignmentButton => 'Atamayı Kaldır';

  @override
  String get assignment_changeAssignmentButton => 'Atamayı Değiştir';

  @override
  String get assignment_roomBedLabel => 'Oda / Yatak';

  @override
  String get assignment_serviceLabel => 'Servis';

  @override
  String get assignment_cellNotFoundError => 'Seçili göz bulunamadı';

  @override
  String get assignment_patientSavedSuccess =>
      'Hasta ataması başarıyla kaydedildi';

  @override
  String get assignment_patientRemovedSuccess => 'Hasta ataması kaldırıldı';

  @override
  String get fault_selectCellPlaceholder =>
      'Arıza bildirmek için orta\npanelden bir göz seçin.';

  @override
  String get fault_descriptionSectionLabel => 'AÇIKLAMA';

  @override
  String get fault_descriptionHint => 'Arıza detayını yazın...';

  @override
  String get fault_faultSegmentLabel => 'ARIZA';

  @override
  String get fault_maintenanceSegmentLabel => 'BAKIM';

  @override
  String get fault_historySectionLabel => 'GEÇMİŞ';

  @override
  String get fault_historyStatusCompleted => 'Tamamlandı';

  @override
  String get fault_historyStatusMaintenance => 'Bakım';

  @override
  String get fault_historyStatusFault => 'Arıza';

  @override
  String get fault_historyActiveBadge => 'Aktif';

  @override
  String fault_activeFaultBanner(String label) {
    return 'Bu gözde aktif bir $label kaydı bulunmaktadır. Onayladığınızda bu kayıt sonlandırılacaktır.';
  }

  @override
  String get fault_reportFaultButton => 'Arıza Bildir';

  @override
  String get fault_closeFaultButton => 'Kaydı Sonlandır';

  @override
  String get fault_recordCreatedSuccess => 'Arıza kaydı oluşturuldu.';

  @override
  String get fault_recordClosedSuccess => 'Arıza kaydı kapatıldı.';

  @override
  String get cabin_mobileTypeLabel => 'MOBİL';

  @override
  String get cabin_mobileDrawerTitle => 'Mobil Çekmece';

  @override
  String cabin_cellCountLabel(int count) {
    return '$count göz';
  }

  @override
  String get cabin_drawerStatsLabel => 'Çekmece';

  @override
  String cabin_statsFullEmpty(int full, int empty) {
    return '$full dolu · $empty boş';
  }

  @override
  String get cabin_touchDrawerHint => 'Bir çekmeceye dokunun';

  @override
  String get cabin_mobileGridPlaceholder =>
      'Mobil kabin göz grid\'i görüntülenecek';

  @override
  String get cabin_masterGridPlaceholder =>
      'Kübik · Birim Doz · Serum iç yapıları görüntülenecek';

  @override
  String get cabin_kubikTypeLabel => 'KÜBİK';

  @override
  String get cabin_serumDrawerName => 'Serum Çekmece';

  @override
  String get cabin_kubikDrawerName => 'Kübik Çekmece';

  @override
  String get cabin_unitDoseDrawerName => 'Birim Doz Çekmece';

  @override
  String get cabin_serumRackView => 'Raf görünümü';

  @override
  String get cabin_serumViewTitle => 'Serum görünümü';

  @override
  String get cabin_serumViewTodo =>
      'TODO: Serum iç yapısı netleşince tamamlanacak';

  @override
  String get cabin_openButton => 'Aç';

  @override
  String get cabin_assignDrugButton => 'İlaç Ata';

  @override
  String get cabin_bannerPatientAssign =>
      'Hasta Atama — gözlere hasta / yatış atayın.';

  @override
  String get cabin_bannerDrugAssign =>
      'İlaç Atama — gözlere ilaç atayın, min/maks/kritik değerleri belirleyin.';

  @override
  String get cabin_bannerDrugFill =>
      'İlaç Dolum — dolum yapılacak göze dokunun, miktarı girin.';

  @override
  String get cabin_bannerDrugCount =>
      'Sayım — fiili miktarı girin, sistem farkı hesaplayacak.';

  @override
  String get cabin_bannerFault =>
      'Arıza — arızalı gözü işaretleyin ve açıklama girin.';

  @override
  String get cabin_statusWorking => 'Çalışıyor';

  @override
  String get cabin_statusFaultRecord => 'Arıza Kaydı';

  @override
  String get cabin_statusMaintenanceRecord => 'Bakım Kaydı';

  @override
  String get cabin_modeAssignLabel => 'İlaç Atama';

  @override
  String get cabin_modeFillLabel => 'İlaç Dolum';

  @override
  String get cabin_modeCountLabel => 'İlaç Sayım';

  @override
  String get cabin_modeFaultLabel => 'Çekmece Arıza';

  @override
  String get cabin_operationPanelAssign => 'İLAÇ ATAMA';

  @override
  String get cabin_operationPanelFill => 'İLAÇ DOLUM';

  @override
  String get cabin_operationPanelCount => 'İLAÇ SAYIM';

  @override
  String get cabin_operationPanelFault => 'ARIZA BİLDİR';

  @override
  String get cabin_legendAssignEmpty => 'Boş göz (ata)';

  @override
  String get cabin_legendAssignAssigned => 'İlaç atanmış';

  @override
  String get cabin_legendAssignFault => 'Arızalı';

  @override
  String get cabin_legendAssignMaintenance => 'Bakımda';

  @override
  String get cabin_legendPatientAssigned => 'Hasta atanmış';

  @override
  String get cabin_legendFilled => 'Dolu';

  @override
  String get cabin_legendFillEmpty => 'Boş (dolum yok)';

  @override
  String get cabin_legendCountAssigned => 'Sayılacak (ilaçlı)';

  @override
  String get cabin_legendCountLow => 'Düşük stok';

  @override
  String get cabin_legendCountEmpty => 'Boş (atla)';

  @override
  String get cabin_legendFaultNormal => 'Normal çalışıyor';

  @override
  String get cabin_legendFaultReported => 'Arıza bildirildi';

  @override
  String get cabin_legendFaultEmpty => 'Boş göz';

  @override
  String get wizard_sidebarTitle => 'Kabin Kurulumu';

  @override
  String get wizard_sidebarSubtitle => 'Yeni cihaz yapılandırması';

  @override
  String get wizard_step1SidebarTitle => 'Kabin Tipi';

  @override
  String get wizard_step1SidebarDesc => 'Standart veya Mobil';

  @override
  String get wizard_step2SidebarTitle => 'Temel Bilgiler';

  @override
  String get wizard_step2SidebarDesc => 'Ad, konum, bağlantı';

  @override
  String get wizard_step3SidebarTitle => 'Hizmet Kapsamı';

  @override
  String get wizard_step3SidebarDesc => 'Servis veya oda tanımları';

  @override
  String get wizard_step4SidebarTitle => 'Çekmece Yapısı';

  @override
  String get wizard_step4SidebarDesc => 'Tarama veya manuel giriş';

  @override
  String get wizard_step5SidebarTitle => 'Özet';

  @override
  String get wizard_step5SidebarDesc => 'Gözden geçir ve tamamla';

  @override
  String get wizard_step1Header => 'Kabin Tipini Seçin';

  @override
  String get wizard_step1Subtitle =>
      'Yönetmek istediğiniz kabin türünü belirleyin. Bu seçim sonraki adımları şekillendirecektir.';

  @override
  String get wizard_cabinTypeNote => 'Kabin tipi sonradan değiştirilemez.';

  @override
  String get wizard_masterCabinSpec1 => 'Kübik / Birim Doz';

  @override
  String get wizard_masterCabinSpec2 => 'Servis Bazlı';

  @override
  String get wizard_masterCabinDescription =>
      'Sabit duvara monte veya bağımsız duran, kübik ve birim doz çekmece kombinasyonuna sahip kabin.';

  @override
  String get wizard_mobileCabinSpec1 => 'Tekerlekli';

  @override
  String get wizard_mobileCabinSpec2 => 'Oda Bazlı';

  @override
  String get wizard_mobileCabinDescription =>
      'Tekerlekli, koğuş dolaşımı için tasarlanmış 4 sıralı taşınabilir ilaç ünitesi.';

  @override
  String get wizard_step2Header => 'Temel Bilgiler';

  @override
  String get wizard_step2Subtitle =>
      'Kabin adı, konum ve cihaz bağlantı ayarlarını girin.';

  @override
  String get wizard_cabinNameLabel => 'Kabin Adı';

  @override
  String get wizard_cabinNameHint => 'örn. CB-304';

  @override
  String get wizard_connectionSettingsLabel => 'BAĞLANTI AYARLARI';

  @override
  String get wizard_noComPortWarning =>
      'Aktif COM Port bulunamadı. Sürücülerin yüklü olduğundan emin olun.';

  @override
  String get wizard_antennaSettingsLabel => 'ANTEN AYARLARI';

  @override
  String get wizard_ipAddressLabel => 'IP Adresi';

  @override
  String get wizard_testConnectionButton => 'Bağlantıyı Test Et';

  @override
  String get wizard_step3Header => 'Hizmet Kapsamı';

  @override
  String get wizard_step3Subtitle => 'Servis veya oda tanımları.';

  @override
  String get wizard_roomBedSelectionLabel => 'ODA & YATAK SEÇİMİ';

  @override
  String get wizard_scanTitle => 'Cihazı Tara';

  @override
  String get wizard_scanDescription =>
      'Seri port üzerinden bağlı kabinin çekmece yapısı otomatik okunacaktır.';

  @override
  String get wizard_startScanButton => 'Taramayı Başlat';

  @override
  String get wizard_scanningStatus => 'Kabin Taranıyor...';

  @override
  String wizard_scanSuccessBanner(int count) {
    return 'Tarama Başarılı — $count çekmece bulundu';
  }

  @override
  String get wizard_scanSuccessDescription =>
      'Kabin iç dizaynı cihazdan başarıyla okundu. Aşağıdaki yapıyı onaylayın.';

  @override
  String get wizard_scanWrongStructure =>
      'Yapı yanlışsa geri dönüp bağlantı bilgilerini kontrol edin.';

  @override
  String get wizard_rescanButton => 'Yeniden Tara';

  @override
  String get wizard_scanErrorBanner =>
      'Tarama başarısız. COM port bağlantısını kontrol edip tekrar deneyin.';

  @override
  String get wizard_scanLogConnecting => 'Seri porta bağlanılıyor…';

  @override
  String get wizard_scanLogFetchingMetadata => 'Çekmece tanımları yükleniyor…';

  @override
  String get wizard_scanLogSearchingManager => 'Yönetim kartı aranıyor…';

  @override
  String get wizard_scanLogScanningCards => 'Kontrol kartları taranıyor…';

  @override
  String get wizard_scanLogDrawerFound => 'Çekmece bulundu';

  @override
  String wizard_drawerLabel(int index) {
    return 'ÇEKMECE $index';
  }

  @override
  String wizard_cellCountLabel(int count) {
    return '$count göz';
  }

  @override
  String wizard_rowCountLabel(int count) {
    return '$count sıra';
  }

  @override
  String get wizard_drawerCountLabel => 'Çekmece Sayısı';

  @override
  String get wizard_addRowButton => 'Satır Ekle';

  @override
  String get wizard_removeLastRowButton => 'Son Satırı Sil';

  @override
  String get wizard_step5Header => 'Özet & Tamamla';

  @override
  String get wizard_step5Subtitle =>
      'Girdiğiniz bilgileri onaylayın. Onayladıktan sonra kurulum tamamlanacaktır.';

  @override
  String get wizard_summaryCabinInfoTitle => 'KABİN BİLGİLERİ';

  @override
  String get wizard_summaryServiceScopeTitle => 'HİZMET KAPSAMI';

  @override
  String get wizard_summaryDrawerStructureTitle => 'ÇEKMECE YAPISI';

  @override
  String get wizard_summaryCabinPreviewTitle => 'KABİN ÖNİZLEMESİ';

  @override
  String get wizard_summaryLabelType => 'Tip';

  @override
  String get wizard_summaryLabelName => 'İsim';

  @override
  String get wizard_summaryLabelStation => 'İstasyon';

  @override
  String get wizard_summaryLabelRoomCount => 'Oda sayısı';

  @override
  String get wizard_summaryLabelRooms => 'Odalar';

  @override
  String get wizard_summaryLabelBeds => 'Yataklar';

  @override
  String get wizard_summaryLabelDrawerCount => 'Çekmece sayısı';

  @override
  String get wizard_summaryLabelTotalDrawers => 'Toplam çekmece';

  @override
  String wizard_summaryLabelDrawerIndexed(int index) {
    return '$index. Çekmece';
  }

  @override
  String get wizard_summaryTypeMobile => 'Mobil Kabin';

  @override
  String get wizard_summaryTypeStandard => 'Standart Kabin';

  @override
  String get wizard_summaryLabelComPort => 'COM Port';

  @override
  String get wizard_summaryLabelDvrIp => 'DVR IP';

  @override
  String get wizard_summaryLabelRfidAddress => 'RFID Adresi';

  @override
  String get wizard_summaryLabelRfidPort => 'RFID Portu';

  @override
  String get wizard_savingMessage => 'Kabin kaydediliyor…';

  @override
  String get wizard_successTitle => 'Kurulum Tamamlandı!';

  @override
  String wizard_successMessage(String cabinName) {
    return '$cabinName başarıyla sisteme eklendi.';
  }

  @override
  String wizard_successCabinId(int id) {
    return 'Kabin ID: #$id';
  }

  @override
  String get wizard_successReloginPrompt =>
      'İşleminize devam etmek için giriş yapmalısınız.';

  @override
  String get wizard_successLoginButton => 'Giriş Yap';

  @override
  String get wizard_successDashboardButton => 'Dashboard\'a Git';

  @override
  String get wizard_errorTitle => 'Kayıt Başarısız';

  @override
  String get wizard_retryButton => 'Geri Dön ve Tekrar Dene';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_systemConfigTitle => 'SİSTEM YAPILANDIRMASI';

  @override
  String get settings_appearanceLabel => 'Görünüm';

  @override
  String get settings_generalLabel => 'Genel';

  @override
  String get assignment_patientUpdatedSuccess => 'Hasta ataması güncellendi';

  @override
  String get fault_selectSlotPlaceholder =>
      'Arıza bildirmek için sol\npanelden bir çekmece seçin.';

  @override
  String get assignment_bedSectionLabel => 'Yatak Seçimi';

  @override
  String get assignment_serviceSelectorHint => 'Servis seçin';

  @override
  String get assignment_roomSelectorHint => 'Oda seçin';

  @override
  String get assignment_bedSelectorHint => 'Yatak seçin';

  @override
  String get assignment_patientLabel => 'HASTA';

  @override
  String get settings_languageTitle => 'DİL';

  @override
  String get settings_languageSubtitle => 'Arayüz dili';

  @override
  String get emptyState_cabinDataTitle => 'Kabin verisi bulunamadı';

  @override
  String get emptyState_cabinDataDescription =>
      'Kabin henüz yapılandırılmamış olabilir\nveya bağlantı kurulamadı.';

  @override
  String get emptyState_noResultsTitle => 'Sonuç bulunamadı';

  @override
  String get emptyState_noResultsDescription =>
      'Arama kriterlerinizi değiştirmeyi deneyin.';

  @override
  String get emptyState_noCellSelectedTitle => 'Göz seçilmedi';

  @override
  String get emptyState_noCellSelectedDescription =>
      'Dolum yapmak için önce bir göz seçin.';

  @override
  String get emptyState_noPatientTitle => 'Hasta atanmamış';

  @override
  String get emptyState_noPatientDescription =>
      'Bu göze henüz hasta ataması yapılmamış.';

  @override
  String get emptyState_noPrescriptionTitle => 'Reçete bulunamadı';

  @override
  String get emptyState_noPrescriptionDescription =>
      'Bu hastaya ait aktif reçete bulunmuyor.';

  @override
  String get emptyState_noCabinTitle => 'Kabin Bulunamadı';

  @override
  String get emptyState_noCabinDescription =>
      'Henüz tanımlı bir kabin bulunmuyor. Devam edebilmek için lütfen bir kabin tanımlayın.';

  @override
  String get emptyState_networkErrorTitle => 'İnternet Bağlantısı Yok';

  @override
  String get emptyState_networkErrorDescription =>
      'Lütfen ağ bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get emptyState_serverErrorTitle => 'Sunucuya Erişilemiyor';

  @override
  String get emptyState_serverErrorDescription =>
      'Sunucuya bağlanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get emptyState_errorTitle => 'Bir Hata Oluştu';

  @override
  String get emptyState_errorDescription =>
      'Beklenmeyen bir hata meydana geldi. Lütfen tekrar deneyin veya sistem yöneticinize başvurun.';

  @override
  String get emptyState_noDataTitle => 'Veri Yok';

  @override
  String get emptyState_noDataDescription =>
      'Henüz görüntülenecek veri bulunmuyor.';

  @override
  String get refund_noRefundableDrugs =>
      'Bu hastaya ait iade edilebilir ilaç bulunamadı.';

  @override
  String get refund_selectPatient =>
      'İade işlemi başlatmak için sol listeden bir hasta seçin.';

  @override
  String get waste_noWastableDrugs => 'Fire/imha edilebilir ilaç bulunamadı.';

  @override
  String get waste_selectPatient => 'İşlem yapmak için hasta seçin.';

  @override
  String get common_confirmCancelButton => 'İptal Et';

  @override
  String get common_dismissButton => 'Vazgeç';

  @override
  String get common_action_saving => 'Kaydediliyor';

  @override
  String get common_action_drawerOpening => 'Çekmece açılıyor';

  @override
  String get common_action_connecting => 'Bağlantı kuruluyor';

  @override
  String get common_action_processing => 'İşlem yapılıyor...';

  @override
  String get common_cancelInfo_drawerClose =>
      'İşlemi iptal etmek için çekmeceyi kapatın.';

  @override
  String get common_patientListTitle => 'Hasta Listesi';

  @override
  String common_patientCountSubtitle(int count) {
    return 'Toplam $count hasta';
  }

  @override
  String get assignment_error_stationLoadFailed =>
      'Kabin istasyon bilgisi alınamadı';

  @override
  String get cabinStock_panel_title => 'Hastaya Ait Kabinde Bulunan İlaçlar';

  @override
  String get census_cancelDialog_title => 'Sayımı İptal Et';

  @override
  String get census_cancelDialog_message => 'Sayım işlemi iptal edilsin mi?';

  @override
  String get census_action_start => 'Sayımı Başlat';

  @override
  String get census_action_drawerOpen => 'İlaçları sayın';

  @override
  String get census_action_complete => 'Sayımı tamamla';

  @override
  String get census_action_continue => 'Sayıma devam et';

  @override
  String get census_success_completed => 'Sayım işlemi başarıyla tamamlandı.';

  @override
  String get drugActivity_column_date => 'Tarih';

  @override
  String get drugActivity_column_time => 'Saat';

  @override
  String get drugActivity_column_patient => 'Hasta';

  @override
  String get drugActivity_column_user => 'Kullanıcı';

  @override
  String get drugActivity_column_material => 'Malzeme';

  @override
  String get drugActivity_column_quantity => 'Miktar';

  @override
  String get drugActivity_column_movement => 'Hareket';

  @override
  String get intake_cancelDialog_title => 'Alımı İptal Et';

  @override
  String get intake_cancelDialog_message =>
      'Henüz ilaç alınmadı. Alım işlemi iptal edilsin mi?';

  @override
  String get intake_action_start => 'Alıma başla';

  @override
  String get intake_action_drawerOpen => 'İlaçları alın';

  @override
  String get intake_action_complete => 'Alımı tamamla';

  @override
  String get intake_action_continue => 'Alıma devam et';

  @override
  String get intake_success_completed => 'Alım işlemi başarıyla tamamlandı.';

  @override
  String get intake_action_reportMissingStock => 'Eksik Stok Bildir';

  @override
  String get myPatients_search_hint => 'Hasta, oda, servis ara...';

  @override
  String get refill_cancelDialog_title => 'Dolumu İptal Et';

  @override
  String get refill_cancelDialog_message =>
      'İlaçları çekmeceden çıkardığınız varsayılacak. Dolum iptal edilsin mi?';

  @override
  String get refill_action_start => 'Doluma başla';

  @override
  String get refill_action_placeDrugs => 'İlaçları yerleştirin';

  @override
  String get refill_action_complete => 'Dolumu tamamla';

  @override
  String get refill_action_continue => 'Doluma devam et';

  @override
  String get refill_success_completedMobile =>
      'Dolum işlemi başarıyla tamamlandı.';

  @override
  String get refill_success_completedMaster => 'Dolum başarıyla tamamlandı';

  @override
  String get refill_hint_selectDrawer =>
      'Dolum yapmak için sol panelden bir çekmece seçin.';

  @override
  String get refill_hint_selectCell => 'Çekmeceden bir göz seçin.';

  @override
  String get refill_hint_cellError => 'Bir göz seçin.';

  @override
  String get refill_label_countQty => 'Sayım Miktarı';

  @override
  String get refill_label_fillQty => 'Dolum Miktarı';

  @override
  String get refill_label_expiryDate => 'Son Kullanma Tarihi';

  @override
  String get refill_title_selectMedicines => 'Dolum yapılacak ilaçları seçin';

  @override
  String get refill_title_autoRefill => 'Otomatik dolum';

  @override
  String refill_label_selectedCount(int count) {
    return '$count seçili';
  }

  @override
  String refill_label_cellCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count göz',
      one: '$count göz',
    );
    return '$_temp0';
  }

  @override
  String refill_label_multiMedicine(int count) {
    return '$count ilaç';
  }

  @override
  String get refill_label_targetCells => 'Dolum yapılacak gözler';

  @override
  String refill_label_queueProgress(int done, int total) {
    return '$done / $total çekmece';
  }

  @override
  String refill_label_current(String qty) {
    return 'Mevcut: $qty';
  }

  @override
  String refill_chip_drawer(String address) {
    return 'Çekmece $address';
  }

  @override
  String refill_chip_drawerCell(String address, String cell) {
    return 'Çekmece $address - Göz $cell';
  }

  @override
  String refill_subtitle_kubikCells(String address, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count göz',
      one: '$count göz',
    );
    return 'Çekmece $address · $_temp0';
  }

  @override
  String get refill_status_done => 'Tamam';

  @override
  String get refill_status_open => 'Açık';

  @override
  String get refill_status_queued => 'Sırada';

  @override
  String get refill_status_drawerOpen => 'Çekmece açık';

  @override
  String get refill_status_drawerOpening => 'Çekmece açılıyor';

  @override
  String get refill_hint_searchMedicine => 'İlaç ara…';

  @override
  String get refill_hint_noMedicines => 'Bu kabine atanmış ilaç yok';

  @override
  String get refill_hint_autoQueueOrder =>
      'Seçilen çekmeceler sırayla açılır; biri kapanınca sıradaki açılır.';

  @override
  String get refill_hint_confirmCloses =>
      'Kaydedince çekmece kapanır ve sıradaki açılır.';

  @override
  String get refill_action_startAuto => 'Otomatik Dolum Başlat';

  @override
  String get refill_action_completeFilling => 'Dolumu tamamla';

  @override
  String get refill_action_stop => 'Durdur';

  @override
  String get refill_label_min => 'Min';

  @override
  String get refill_label_critical => 'Kritik';

  @override
  String get refill_label_max => 'Maks';

  @override
  String get refill_error_queueTitle => 'İşlem tamamlanamadı';

  @override
  String get refill_error_queueMessage =>
      'Bu çekmecenin dolumu kaydedilemedi. Lütfen yerleştirdiğiniz ilaçları geri alın.';

  @override
  String get refill_error_continueNext => 'Sonraki çekmece';

  @override
  String get refill_error_endProcess => 'İşlemi sonlandır';

  @override
  String get refill_status_failed => 'Başarısız';

  @override
  String refill_label_cellProgress(int current, int total) {
    return 'Göz $current/$total';
  }

  @override
  String refill_label_cellNo(int no) {
    return '$no. Göz';
  }

  @override
  String get refill_action_nextCell => 'Sonraki göz';

  @override
  String get refill_hint_nextCellOpens =>
      'Kaydedince bu gözün kapağı kapanır, sıradaki açılır.';

  @override
  String get refill_hint_selectionLocked => 'Dolum sürüyor — seçim kilitli.';

  @override
  String get refill_hint_idleExecution => 'Soldan ilaç seçip dolumu başlatın.';

  @override
  String get refund_success_title => 'İade başarılı';

  @override
  String get refund_success_message =>
      'Lütfen iade edilen ilacı eczacıya teslim ediniz.';

  @override
  String get refund_panel_title => 'İade Edilebilir İlaçlar';

  @override
  String get refund_action_checking => 'Kontrol ediliyor...';

  @override
  String get refund_action_refunding => 'İade ediliyor...';

  @override
  String get refund_action_refund => 'İade Et';

  @override
  String get unappliedPrescription_panel_patientTitle => 'Hastalar';

  @override
  String get unload_cancelDialog_title => 'Boşaltmayı İptal Et';

  @override
  String get unload_cancelDialog_message =>
      'Henüz ilaç çıkarılmadı. Boşaltma işlemi iptal edilsin mi?';

  @override
  String get unload_action_start => 'Boşaltmayı Başlat';

  @override
  String get unload_action_drawerOpen => 'İlaçları çıkarın';

  @override
  String get unload_action_complete => 'Boşaltmayı tamamla';

  @override
  String get unload_action_continue => 'Boşaltmaya devam et';

  @override
  String get unload_success_completed =>
      'Boşaltma işlemi başarıyla tamamlandı.';

  @override
  String get waste_panel_title => 'Fire/İmha Edilebilir İlaçlar';

  @override
  String get waste_action_wastage => 'Fire Et';

  @override
  String get waste_action_destruction => 'İmha Et';

  @override
  String get wastage_success_title => 'Fire kaydedildi';

  @override
  String get wastage_success_message =>
      'Lütfen fire kaydı yapılan ilacı fire kutusuna bırakınız.';

  @override
  String get destruction_success_title => 'İmha kaydedildi';

  @override
  String get destruction_success_message =>
      'Lütfen ilacı imha prosedürüne uygun şekilde imha ediniz.';

  @override
  String get assignment_success_created =>
      'Yatak ataması başarıyla kaydedildi.';

  @override
  String get assignment_success_deleted => 'Yatak ataması kaldırıldı.';

  @override
  String get cabin_bannerCensus =>
      'Çekmece açıldıktan sonra kabinde bulunan ilaçları seçin ve sayımı tamamlayın. Durumu \"Alım Bekliyor\" olan ilaçların sayımı yapılabilir ve seçilmeyen ilaçların miktarı 0 kabul edilir.';

  @override
  String get cabin_bannerIntake => 'İlaç Alım';

  @override
  String get cabin_bannerUnload => 'İlaç Boşaltma';

  @override
  String get operationPanel_title_assign => 'İLAÇ ATAMA';

  @override
  String get operationPanel_badge_assign => 'ATAMA';

  @override
  String get operationPanel_title_refill => 'İLAÇ DOLUM';

  @override
  String get operationPanel_badge_refill => 'DOLUM';

  @override
  String get operationPanel_title_census => 'İLAÇ SAYIM';

  @override
  String get operationPanel_badge_census => 'SAYIM';

  @override
  String get operationPanel_title_fault => 'ARIZA BİLDİR';

  @override
  String get operationPanel_badge_fault => 'ARIZA';

  @override
  String get operationPanel_title_intake => 'İLAÇ ALIM';

  @override
  String get operationPanel_badge_intake => 'ALIM';

  @override
  String get operationPanel_title_unload => 'İLAÇ BOŞALTMA';

  @override
  String get operationPanel_badge_unload => 'BOŞALTMA';

  @override
  String get drugAssignment_panel_title => 'İlaç Seç';

  @override
  String get session_timeout_warning => 'Oturum süreniz dolmak üzere.';

  @override
  String get session_timeout_continueButton => 'Devam Et';

  @override
  String get session_timeout_prefix => 'Oturumunuz ';

  @override
  String get session_timeout_suffix => ' saniye içinde kapanacak.';

  @override
  String get session_locked_prefix => 'Oturumunuz ';

  @override
  String get session_locked_reason => 'zaman aşımı';

  @override
  String get session_locked_suffix =>
      ' nedeniyle kapatıldı. İşlem yapmak için giriş yapın.';

  @override
  String get movement_noHistory => 'Hareket kaydı bulunamadı.';

  @override
  String get movement_performedBy => 'İşlemi Yapan';

  @override
  String get common_search_noPatientResults =>
      'Aramayla eşleşen hasta bulunamadı.';

  @override
  String get common_drug_noFilterResults => 'Bu filtrede ilaç bulunamadı.';

  @override
  String get common_unknownName => 'İsimsiz';

  @override
  String get rfidStatus_read => 'Okundu';

  @override
  String get rfidStatus_waiting => 'Bekleniyor';

  @override
  String get rfidStatus_inCabin => 'Kabinde';

  @override
  String get rfidStatus_notInCabin => 'Kabinde değil';

  @override
  String get rfidStatus_taken => 'Alındı';

  @override
  String get rfidStatus_missing => 'Eksik';

  @override
  String get drawerStatus_full => 'Dolu';

  @override
  String get drawerStatus_low => 'Düşük';

  @override
  String get drawerStatus_critical => 'Kritik';

  @override
  String get drawerStatus_empty => 'Boş';

  @override
  String cabin_cellCount(Object count) {
    return '$count göz';
  }

  @override
  String cabin_drawerStats(Object columns, Object rowCount, Object totalCells) {
    return '$rowCount satır · $totalCells göz · $columns sütun';
  }

  @override
  String hospitalization_admissionDate(Object date) {
    return 'Yatış Tarihi | $date';
  }

  @override
  String get movement_dateLabel => 'Tarih';

  @override
  String get movement_quantityLabel => 'Miktar';

  @override
  String get movement_showAll => 'Tüm Hareketleri Göster';

  @override
  String cabin_masterDrawerStats(Object groupCount, Object mult, Object steps) {
    return '$groupCount grup · $steps adım × $mult';
  }

  @override
  String get dashboard_cabinConnectionStatus_connected => 'Bağlı';

  @override
  String get dashboard_cabinConnectionStatus_connecting => 'Bağlanıyor…';

  @override
  String get dashboard_cabinConnectionStatus_error => 'Bağlantı Yok';

  @override
  String get dashboard_cabinConnectionStatus_disconnected => 'Bağlı Değil';

  @override
  String get dashboard_cabinConnection_reconnectButton => 'Yeniden Bağlan';

  @override
  String get prescription_noPatients_title => 'Atanmış Hasta Yok';

  @override
  String get prescription_noPatients_message =>
      'Bu kabine henüz hasta atanmamış. İstem inceleyebilmek için önce kabine hasta atanması gerekir.';

  @override
  String get myPatients_empty_title => 'Henüz Hasta Seçmediniz';

  @override
  String get myPatients_empty_description =>
      'Soldaki listeden hasta seçerek kendi hasta listenize ekleyebilirsiniz. Seçtiğiniz hastalar burada görünür.';

  @override
  String get cabinStock_emptyTitle => 'Bu hastaya ait stok yok';

  @override
  String get cabinStock_emptyDescription =>
      'Seçili hastaya ait bu kabinde henüz stoklanmış ilaç bulunmuyor.';

  @override
  String get prescription_unadministeredEmptyTitle => 'Bekleyen reçete yok';

  @override
  String get prescription_unadministeredEmptyDescription =>
      'Bu hastaya uygulanmayı bekleyen reçete bulunmuyor.';

  @override
  String get emptyState_noPatientSelectedTitle => 'Bir hasta seçin';

  @override
  String get emptyState_noPatientSelectedDescription =>
      'Detayları görüntülemek için listeden bir hasta seçin.';

  @override
  String get dateFilter_todayPreset => 'Bugün';

  @override
  String get dateFilter_tomorrowPreset => 'Yarın';

  @override
  String get dateFilter_last3DaysPreset => 'Son 3 gün';

  @override
  String get dateFilter_last7DaysPreset => 'Son 7 gün';

  @override
  String get dateFilter_allPreset => 'Tümü';

  @override
  String get filter_all => 'Tümü';

  @override
  String get census_action_reportExtraStock => 'Fazla Stok Bildir';

  @override
  String get census_extraStockDialogTitle => 'Fazla Stok Bildir';

  @override
  String get census_extraStockQuantityLabel => 'Adet';

  @override
  String get common_action_add => 'Ekle';

  @override
  String get census_extraStockSummaryTitle => 'Bildirilen Fazla Stoklar';

  @override
  String get core_serialPortDisconnectedLabel => 'Bağlı Değil';

  @override
  String core_serialConnectingStatus(String portName) {
    return 'Porta bağlanılıyor: $portName...';
  }

  @override
  String core_serialConnectSuccessStatus(String portName) {
    return 'Bağlantı başarılı: $portName';
  }

  @override
  String core_serialPortFailedScanningOthersStatus(String portName) {
    return '$portName başarısız. Diğer portlar taranıyor...';
  }

  @override
  String core_serialNoOtherPortsError(String portName) {
    return 'Varsayılan port ($portName) başarısız ve başka port bulunamadı.';
  }

  @override
  String core_serialTryingPortStatus(String portName) {
    return 'Deneniyor: $portName...';
  }

  @override
  String core_serialConnectionEstablishedStatus(String portName) {
    return 'Bağlantı sağlandı: $portName';
  }

  @override
  String get core_serialNoPortConnectedError =>
      'Hiçbir porta bağlanılamadı. Kabloları kontrol edin.';

  @override
  String core_serialPortOpenFailedError(String portName) {
    return 'Port açılamadı ($portName).';
  }

  @override
  String get core_serialNoConnectionError => 'Bağlantı yok.';

  @override
  String get core_serialPortBusyTimeoutError => 'Port zaman aşımı.';

  @override
  String get core_serialWriteFailedError => 'Yazma başarısız.';

  @override
  String get common_defaultSuccessMessage => 'İşlem başarılı';

  @override
  String get common_operationSuccessMessage =>
      'İşleminiz başarıyla tamamlandı.';

  @override
  String get common_loadingEllipsis => 'Yükleniyor...';

  @override
  String get common_searchHint => 'Ara...';

  @override
  String get common_searchTooltip => 'Ara';

  @override
  String get common_addTooltip => 'Ekle';

  @override
  String get common_closeTooltip => 'Kapat';

  @override
  String get common_saveButton => 'Kaydet';

  @override
  String get common_editTooltip => 'Düzenle';

  @override
  String get common_deleteTooltip => 'Sil';

  @override
  String get common_statusLabel => 'Durumu';

  @override
  String get common_emptyListMessage => 'Liste henüz boş';

  @override
  String get common_nameLabel => 'Adı';

  @override
  String get common_requiredFieldsError =>
      'Lütfen zorunlu alanları doldurunuz.';

  @override
  String get common_descriptionLabel => 'Açıklama';

  @override
  String get common_deselectAllButton => 'Seçimi Kaldır';

  @override
  String get common_selectAllButton => 'Tümünü Seç';

  @override
  String get common_defaultUnitFallback => 'Adet';

  @override
  String get common_flagFirstDoseEmergency => 'İlk Doz Acil';

  @override
  String get common_flagAskDoctor => 'Doktora Sor';

  @override
  String get common_flagInCaseOfNecessity => 'Gerektiğinde';

  @override
  String common_addItemHint(String item) {
    return 'Yeni $item eklemek için \"+\" butonuna tıklayın';
  }

  @override
  String get common_genericErrorMessage => 'Bir hata oluştu.';

  @override
  String get hospitalizationCard_noDoctorFallback => 'Doktor Belirtilmemiş';

  @override
  String get hospitalizationCard_nationalIdLabel => 'T.C No';

  @override
  String get hospitalizationCard_admissionDateLabel => 'Giriş Tarihi';

  @override
  String get menuBrowser_categoriesHeader => 'KATEGORİLER';

  @override
  String get menuBrowser_searchHint => 'Kategori ara...';

  @override
  String menuBrowser_selectionCountBadge(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get menuBrowser_emptyCategoryMessage =>
      'Bu kategoride menü bulunamadı';

  @override
  String rxGroup_headerTitle(Object id) {
    return 'Reçete #$id';
  }

  @override
  String rxGroup_headerSubtitle(String doctorName, String date) {
    return '$doctorName · $date';
  }

  @override
  String rxGroup_itemCountBadge(int count) {
    return '$count kalem';
  }

  @override
  String rxGroup_selectableCountLabel(int count) {
    return '$count işlem yapılabilir kalem';
  }

  @override
  String get rxGroup_unknownDoctorFallback => 'Bilinmiyor';

  @override
  String get rxGroup_rfidTagLabel => 'RFID ETİKETİ';

  @override
  String get rxGroup_rfidTagLoadingLabel => 'Etiket bekleniyor...';

  @override
  String get rxGroup_rfidTagUnassignedLabel => 'Henüz etiket atanmadı';

  @override
  String get rxGroup_rfidChangeButton => 'Değiştir';

  @override
  String get rxGroup_rfidAssignButton => 'Etiket Ata';

  @override
  String rxGroup_selectedCountBar(int count) {
    return '$count kalem seçildi';
  }

  @override
  String get rxGroup_approveAction => 'Onayla';

  @override
  String get rxGroup_rejectAction => 'Reddet';

  @override
  String get changePassword_dialogTitle => 'Şifre Değiştirme';

  @override
  String get changePassword_currentPasswordLabel => 'Mevcut Şifre';

  @override
  String get changePassword_newPasswordLabel => 'Yeni Şifre';

  @override
  String get changePassword_confirmPasswordLabel => 'Yeni Şifre Tekrar';

  @override
  String get changePassword_submitButton => 'Şifre Değiştir';

  @override
  String get home_appBarBadgeLabel => 'YÖNETİM PANELİ';

  @override
  String get home_devSettingsTooltip => 'Geliştirici Ayarları';

  @override
  String get home_noAuthorizedMenuTitle => 'Yetkili Menü Bulunamadı';

  @override
  String get home_noAuthorizedMenuDescription =>
      'Hesabınıza tanımlanmış erişim yetkisi bulunmamaktadır.\nErişim sağlamak için sistem yöneticiniz ile iletişime geçiniz.';

  @override
  String get branch_listDialogTitle => 'Branş Tanımlama';

  @override
  String get branch_addTitle => 'Branş Ekle';

  @override
  String get branch_editTitle => 'Branş Düzenle';

  @override
  String get branch_nameLabel => 'Branş Adı';

  @override
  String get firm_createSuccessMessage => 'Firma başarıyla oluşturuldu';

  @override
  String get firm_updateSuccessMessage => 'Firma başarıyla güncellendi';

  @override
  String get firm_createPanelTitle => 'Yeni Firma';

  @override
  String get firm_editPanelTitle => 'Firma Düzenle';

  @override
  String get firm_createPanelSubtitle => 'Firma bilgilerini doldurun';

  @override
  String get firm_editPanelSubtitle => 'Firma bilgilerini güncelleyin';

  @override
  String get firm_nameLabel => 'Firma Adı';

  @override
  String get firm_taxNoLabel => 'Vergi No';

  @override
  String get firm_taxOfficeLabel => 'Vergi Dairesi';

  @override
  String get firm_typeLabel => 'Firma Tipi';

  @override
  String get firm_screenDefaultTitle => 'Firma Tanımlama';

  @override
  String get dosageForm_deleteSuccessMessage =>
      'Dozaj formu silme işlemi başarılı.';

  @override
  String get dosageForm_saveSuccessMessage =>
      'Dozaj formu başarıyla kaydedildi.';

  @override
  String get dosageForm_createTitle => 'Dozaj Formu Oluştur';

  @override
  String get dosageForm_editTitle => 'Dozaj Formu Düzenle';

  @override
  String get dosageForm_listDialogTitle => 'Dozaj Formu';

  @override
  String get dosageForm_emptyTitle => 'Henüz dozaj formu bulunmuyor';

  @override
  String get dosageForm_emptyDescription =>
      'Dozaj formu oluşturmak için \"+\" butonuna tıklayın';

  @override
  String get authorization_userTabTitle => 'Kullanıcı Yetkilendirme';

  @override
  String get authorization_roleTabTitle => 'Rol Yetkilendirme';

  @override
  String get authorization_screenTitleFallback => 'Kullanıcı/Rol Yetkilendirme';

  @override
  String authorization_rolePanelTitle(String roleName) {
    return 'Rol Yetkilendirme - $roleName';
  }

  @override
  String get authorization_tabMenuLabel => 'Menü';

  @override
  String get authorization_tabDrugLabel => 'İlaç';

  @override
  String get authorization_tabConsumableLabel => 'Tıbbi Sarf';

  @override
  String get authorization_drugTable_pullColumn => 'İlaç Çeker';

  @override
  String get authorization_drugTable_fillColumn => 'Dolum';

  @override
  String get authorization_drugTable_returnColumn => 'İade';

  @override
  String get authorization_drugTable_disposeColumn => 'İmha';

  @override
  String get authorization_drugTable_allDrugsRow => 'Tüm İlaçlar';

  @override
  String get authorization_drugTable_unknownDrugFallback => 'Bilinmeyen İlaç';

  @override
  String get settings_updateSuccessMessage => 'Ayarlar başarıyla güncellendi.';

  @override
  String get settingsCabin_drawerOpenWaitLabel =>
      'Çekmece Açık Bekleme Süresi (saniye)';

  @override
  String get settingsCabin_drawerOpenWaitDescription =>
      'Açık olan çekmece kapatılmadığı zaman sistemin çekmeceye ne zaman kapatma komutu göndereceğini belirtir.';

  @override
  String get settingsDeveloper_adminDashboardActiveLabel =>
      'Admin Dashboard Aktif';

  @override
  String get settingsDeveloper_appModeLabel => 'Uygulama Modu';

  @override
  String get settingsDeveloper_clientModeButton => 'Client Modu';

  @override
  String get settingsDeveloper_managerModeButton => 'Manager Modu';

  @override
  String get settingsGeneral_autoStandbyDurationLabel =>
      'Program Otomatik Beklemeye Geçme Süresi (saniye)';

  @override
  String get settingsGeneral_expiryWarningLabel => 'Miad Uyarı';

  @override
  String get settingsGeneral_hbysStockControlLabel => 'HBYS Stok Kontrol';

  @override
  String get settingsGeneral_fingerprintOnlyLabel =>
      'Kabinlerde sadece parmak okuyucu çalışsın.';

  @override
  String get settingsGeneral_allowOutOfWindowOrdersLabel =>
      'Süre dışındaki orderlar alınabilir.';

  @override
  String get settingsGeneral_perCellExpiryDateLabel =>
      'İlaç dolum esnasında birim doz çekmecelerde her bölme için ayrı miad tarihi girilebilsin.';

  @override
  String get settingsGeneral_collectOrderTimeLabel =>
      'Order Listeleme Zaman Aralığı (saat)';

  @override
  String get settingsGeneral_wasteDestructionTimeLabel =>
      'Fire/İmha Süresi (saat)';

  @override
  String get settingsGeneral_wasteOrderReactivateLabel =>
      'Fire yapılan malzeme siparişe tekrar düşsün';

  @override
  String get settingsGeneral_badgeCardPasswordLabel =>
      'Yönetici kartı girişinde şifre istensin';

  @override
  String get settingsPrescription_accessDurationLabel =>
      'Reçete Erişilebilirlik Süresi (dakika)';

  @override
  String get settingsPrescription_accessDurationDescription =>
      'Reçetelerin ürün alım saatlerinden ne kadar önce ve sonra erişilebilir olacağını belirtir.';

  @override
  String get settingsView_cabinTabTitle => 'Kabin Haberleşme Ayarları';

  @override
  String get settingsView_prescriptionTabTitle => 'Reçete Ayarları';

  @override
  String get settingsView_generalTabTitle => 'Genel Ayarlar';

  @override
  String get settingsView_developerTabTitle => 'Geliştirici Ayarları';

  @override
  String get settingsView_refreshPermissionsButton => 'Yetkileri Yenile';

  @override
  String stationSetup_defaultRoomName(int index) {
    return 'Oda $index';
  }

  @override
  String get stationSetup_service_createdSuccessMessage =>
      'Servis başarıyla oluşturuldu';

  @override
  String get stationSetup_service_updatedSuccessMessage =>
      'Servis başarıyla güncellendi';

  @override
  String get stationSetup_roomsSectionTitle => 'Odalar & Yataklar';

  @override
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount) {
    return '$roomCount oda · $bedCount yatak';
  }

  @override
  String get stationSetup_addRoomButton => 'Oda Ekle';

  @override
  String stationSetup_bedCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yatak',
      one: '$count yatak',
    );
    return '$_temp0';
  }

  @override
  String get stationSetup_noBedsAddedYetMessage => 'Henüz yatak eklenmedi';

  @override
  String get stationSetup_addBedButton => 'Yatak Ekle';

  @override
  String get stationSetup_service_formTitleNew => 'Yeni Servis';

  @override
  String get stationSetup_service_formTitleEdit => 'Servis Düzenle';

  @override
  String get stationSetup_service_formSubtitleNew =>
      'Servis bilgilerini doldurun';

  @override
  String get stationSetup_service_formSubtitleEdit =>
      'Servis bilgilerini güncelleyin';

  @override
  String get stationSetup_service_nameLabel => 'Servis Adı';

  @override
  String get stationSetup_service_branchLabel => 'Branş';

  @override
  String get stationSetup_service_branchSelectTitle => 'Branş Seç';

  @override
  String get stationSetup_service_userLabel => 'Kullanıcı';

  @override
  String get stationSetup_common_statusLabel => 'Durumu';

  @override
  String get stationSetup_station_createdSuccessMessage =>
      'İstasyon başarıyla oluşturuldu';

  @override
  String get stationSetup_station_updatedSuccessMessage =>
      'İstasyon başarıyla güncellendi';

  @override
  String get stationSetup_station_formTitleNew => 'Yeni İstasyon';

  @override
  String get stationSetup_station_formTitleEdit => 'İstasyonu Düzenle';

  @override
  String get stationSetup_station_formSubtitleNew =>
      'İstasyon bilgilerini doldurun';

  @override
  String get stationSetup_station_formSubtitleEdit =>
      'İstasyon bilgilerini güncelleyin';

  @override
  String get stationSetup_station_nameLabel => 'İstasyon Adı';

  @override
  String get stationSetup_station_drugWarehouseLabel => 'İlaç Depo';

  @override
  String get stationSetup_station_drugWarehouseSelectTitle => 'İlaç Depo Seç';

  @override
  String get stationSetup_station_drugStatusLabel => 'İlaç Durumu';

  @override
  String get stationSetup_station_consumableWarehouseLabel => 'Tıbbi Sarf Depo';

  @override
  String get stationSetup_station_consumableWarehouseSelectTitle =>
      'Tıbbi Sarf Depo Seç';

  @override
  String get stationSetup_station_consumableStatusLabel => 'Tıbbi Sarf Durumu';

  @override
  String get stationSetup_station_serviceLabel => 'Servis';

  @override
  String get stationSetup_station_serviceSelectTitle => 'Servis Seç';

  @override
  String get stationSetup_station_providedServicesLabel =>
      'Hizmet Verdiği Servisler';

  @override
  String get stationSetup_station_typeLabel => 'İstasyon Tipi';

  @override
  String get stationSetup_station_typePatientBasedLabel => 'Hasta Bazlı';

  @override
  String get stationSetup_station_typeMedicineBasedLabel => 'İlaç Bazlı';

  @override
  String get stationSetup_warehouse_createdSuccessMessage =>
      'Depo başarıyla oluşturuldu';

  @override
  String get stationSetup_warehouse_updatedSuccessMessage =>
      'Depo başarıyla güncellendi';

  @override
  String get stationSetup_warehouse_formTitleNew => 'Yeni Depo';

  @override
  String get stationSetup_warehouse_formTitleEdit => 'Depo Düzenle';

  @override
  String get stationSetup_warehouse_formSubtitleNew =>
      'Depo bilgilerini doldurun';

  @override
  String get stationSetup_warehouse_formSubtitleEdit =>
      'Depo bilgilerini güncelleyin';

  @override
  String get stationSetup_warehouse_codeLabel => 'Depo Kodu';

  @override
  String get stationSetup_warehouse_nameLabel => 'Depo Adı';

  @override
  String get stationSetup_warehouse_typeLabel => 'Depo Türü';

  @override
  String get stationSetup_warehouse_managerLabel => 'Depo Sorumlusu';

  @override
  String get stationSetup_warehouse_managerSelectTitle => 'Depo Sorumlusu Seç';

  @override
  String get stationSetup_screen_stationTabTitle => 'İstasyon Tanımlama';

  @override
  String get stationSetup_screen_serviceTabTitle => 'Servis Tanımlama';

  @override
  String get stationSetup_screen_warehouseTabTitle => 'Depo Tanımlama';

  @override
  String get stationSetup_screen_setupWizardButton => 'Kurulum Sihirbazı';

  @override
  String get stationSetup_wizard_title => 'İstasyon Kurulum Sihirbazı';

  @override
  String get stationSetup_wizard_completeSetupButton => 'Kurulumu Tamamla';

  @override
  String get stationSetup_wizard_continueButton => 'Devam Et';

  @override
  String get stationSetup_wizard_backButton => 'Geri Dön';

  @override
  String get unappliedPrescription_detailDialogTitle => 'Malzeme Listesi';

  @override
  String get unappliedPrescription_screenTitleFallback =>
      'Uygulanmamış Reçeteler';

  @override
  String get unappliedPrescription_viewDetailsTooltip => 'Detayları Görüntüle';

  @override
  String get dashboard_cabinsLoadErrorFallback => 'Kabinler yüklenemedi';

  @override
  String get dashboard_cabinListStaleLabel => 'Kabin listesi güncel değil';

  @override
  String get dashboardDrugActivityPanelTitle => 'İLAÇ HAREKETLERİ';

  @override
  String get dashboardDrugActivityEmptyTitle => 'Hareket yok';

  @override
  String get dashboard_drugActivityDateTimeLabel => 'TARİH / SAAT';

  @override
  String get dashboard_missingStockPanelTitle => 'EKSİK STOK BİLDİRİMLERİ';

  @override
  String get dashboard_missingStockEmptyTitle => 'Eksik stok bildirimi yok';

  @override
  String get dashboard_missingStockTimeLabel => 'SAAT';

  @override
  String get dashboard_missingStockApproveButton => 'Onayla';

  @override
  String get dashboard_missingStockRejectButton => 'Reddet';

  @override
  String get dashboard_otherCabinPlaceholderText =>
      'SKT geçmiş malzemeler & kritik stoklar (sonraki tur)';

  @override
  String get dashboard_unappliedPrescriptionsPanelTitle =>
      'UYGULANMAMIŞ REÇETELER';

  @override
  String get dashboard_unappliedPrescriptionsEmptyTitle =>
      'Uygulanmamış reçete yok';

  @override
  String get dashboard_doctorLabel => 'DOKTOR';

  @override
  String get dashboard_roomBedLabel => 'ODA / YATAK';

  @override
  String get dashboardUpcomingTreatmentsPanelTitle => 'YAKLAŞAN TEDAVİLER';

  @override
  String get dashboardUpcomingTreatmentsEmptyTitle => 'Yaklaşan tedavi yok';

  @override
  String get dashboard_listPanelLoadErrorFallback => 'Yüklenemedi';

  @override
  String get prescription_actionCompletedSuccess =>
      'İşlem başarıyla tamamlandı.';

  @override
  String get prescription_approvedSuccess => 'Reçete başarıyla onaylandı.';

  @override
  String get prescription_detailPanelPatientFallback => 'Hasta';

  @override
  String get prescription_detailPanelSubtitle => 'Reçete Geçmişi';

  @override
  String get prescription_detailStartDateLabel => 'Başlangıç Tarihi';

  @override
  String get prescription_detailEndDateLabel => 'Bitiş Tarihi';

  @override
  String get prescription_detailStatusLabel => 'Durum';

  @override
  String get prescription_checkWarningDialogTitle => 'Kontrol Uyarısı';

  @override
  String get prescription_saveWithTemplateSuccess =>
      'Reçete ve şablon başarıyla kaydedildi.';

  @override
  String get prescription_savedTemplateFailedMessage =>
      'Reçete kaydedildi ancak şablon kaydedilemedi.';

  @override
  String get prescription_savedSuccess => 'Reçete başarıyla kaydedildi.';

  @override
  String get prescription_creatingLoadingMessage =>
      'Reçete oluşturuluyor. Lütfen bekleyiniz.';

  @override
  String get prescription_templateSavingLoadingMessage =>
      'Şablon kaydediliyor.';

  @override
  String get prescription_newTitle => 'Yeni Reçete';

  @override
  String get prescription_newDialogSubtitle =>
      'Reçete oluştur veya geçmiş reçeteden içe aktar';

  @override
  String get prescription_tabHistory => 'Geçmiş';

  @override
  String get prescription_tabTemplates => 'Şablonlar';

  @override
  String get prescription_contentEmptyTitle =>
      'Reçeteye henüz ilaç eklemediniz.';

  @override
  String get prescription_contentEmptyDescription =>
      'Eklediğiniz ilaçlar burada görüntülenecektir.';

  @override
  String get prescription_itemNoTimesLabel => 'Saat eklenmedi';

  @override
  String get prescription_itemNoMedicineSelected => 'Henüz ilaç seçilmedi';

  @override
  String get prescription_patientFieldLabel => 'Hasta';

  @override
  String get prescription_doctorFieldLabel => 'Doktor';

  @override
  String get prescription_saveButton => 'Reçeteyi Kaydet';

  @override
  String get prescription_saveAsTemplateCheckboxLabel =>
      'Şablon olarak da kaydet';

  @override
  String get prescription_templateNameHint => 'Şablon Adı';

  @override
  String get prescription_medicineFieldLabel => 'İlaç / Malzeme';

  @override
  String get prescription_descriptionFieldLabel => 'Açıklama';

  @override
  String get prescription_tomorrowLabel => 'Yarın';

  @override
  String get prescription_timesLabel => 'Saatler';

  @override
  String get prescription_addTimeButton => 'Saat ekle';

  @override
  String get prescription_historySelectPatientTitle => 'Hasta seçin';

  @override
  String get prescription_historySelectPatientDescription =>
      'Geçmiş reçeteleri görmek için önce hasta seçimi yapın';

  @override
  String get prescription_historyEmptyDescription =>
      'Bu hasta için geçmiş reçete yok';

  @override
  String prescription_addToRxButton(int count) {
    return 'Reçeteye Ekle ($count)';
  }

  @override
  String get prescription_templateEmptyTitle => 'Şablon bulunamadı';

  @override
  String get prescription_templateEmptyDescription =>
      'Kaydedilmiş bir reçete şablonu yok';

  @override
  String get prescription_templateNoItemsMessage => 'Bu şablonda kalem yok';

  @override
  String get prescription_screenTitleFallback => 'Reçete İşlemleri';

  @override
  String get prescription_contentTooltip => 'Reçete İçeriği';

  @override
  String get prescription_showActiveButton => 'Aktif yatışları getir';

  @override
  String get prescription_showDischargedButton => 'Taburcu olanları göster';

  @override
  String get cabinTemperature_screenTitle => 'Kabin Isı Kontrol';

  @override
  String get cabinTemperature_formDialogTitle => 'Kabin Düzenleme';

  @override
  String get cabinTemperature_insideBottomLabel => 'İç Alt Sıcaklık';

  @override
  String get cabinTemperature_insideTopLabel => 'İç Üst Sıcaklık';

  @override
  String get cabinTemperature_outsideBottomLabel => 'Dış Alt Sıcaklık';

  @override
  String get cabinTemperature_outsideTopLabel => 'Dış Üst Sıcaklık';

  @override
  String get cabinTemperature_humidityBottomLabel => 'Nem Alt Sınır';

  @override
  String get cabinTemperature_humidityTopLabel => 'Nem Üst Sınır';

  @override
  String cabinTemperature_genericErrorMessage(String error) {
    return 'Bir hata oluştu: $error';
  }

  @override
  String get cabinTemperature_stationNotSelectedError => 'İstasyon seçilmedi';

  @override
  String get cabinTemperature_createSuccess =>
      'Kabin sıcaklık ayarı başarıyla oluşturuldu.';

  @override
  String get cabinTemperature_updateRecordNotFoundError =>
      'Güncellenecek kayıt bulunamadı';

  @override
  String get cabinTemperature_updateSuccess =>
      'Kabin sıcaklık ayarı başarıyla güncellendi.';

  @override
  String get cabinTemperature_unnamedStationFallback => 'İsimsiz İstasyon';

  @override
  String get cabinTemperature_stationsLoadingMessage =>
      'İstasyonlar yükleniyor...';

  @override
  String get cabinTemperature_detailsLoadingMessage =>
      'Sıcaklık detayları yükleniyor...';

  @override
  String get cabinTemperature_columnCabin => 'Kabin';

  @override
  String get directedOrders_screenTitle => 'Yönlendirilmiş Order Listesi';

  @override
  String get directedOrders_columnProtocolNo => 'Protokol No';

  @override
  String get directedOrders_columnBed => 'Yatak';

  @override
  String get directedOrders_columnRoom => 'Oda';

  @override
  String get directedOrders_medicinesTooltip => 'İlaçlar';

  @override
  String get directedOrders_patientsLoadingMessage => 'Hastalar yükleniyor...';

  @override
  String get directedOrders_columnBarcode => 'Barkod';

  @override
  String get medicine_successCreated => 'İlaç oluşturuldu';

  @override
  String get medicine_successUpdated => 'İlaç güncellendi';

  @override
  String get medicalConsumable_successCreated => 'Tıbbi sarf oluşturuldu';

  @override
  String get medicalConsumable_successUpdated => 'Tıbbi sarf güncellendi';

  @override
  String get medicine_formTitleNew => 'Yeni İlaç';

  @override
  String get medicine_formTitleEdit => 'İlaç Düzenle';

  @override
  String get medicine_formSubtitleNew => 'İlaç bilgilerini doldurun';

  @override
  String get medicine_formSubtitleEdit => 'İlaç bilgilerini güncelleyin';

  @override
  String get medicine_fieldDefinitionName => 'Tanım Adı';

  @override
  String get medicine_fieldBarcode => 'Barkod';

  @override
  String get medicine_fieldName => 'İlaç Adı';

  @override
  String get medicine_fieldCode => 'İlaç Kodu';

  @override
  String get medicine_fieldPrescriptionType => 'Reçete Tipi';

  @override
  String get medicine_fieldDose => 'Doz';

  @override
  String get medicine_fieldManufacturer => 'Üretici Firma';

  @override
  String get medicine_fieldDailyMaxUsage => 'Günlük Maks. Kullanım Miktarı';

  @override
  String get medicine_fieldDrugType => 'İlaç Tipi';

  @override
  String get medicine_fieldReturnType => 'İade Şekli';

  @override
  String get medicine_checkboxSerumMaxValue =>
      'Serum kabininde maks. değere bakma';

  @override
  String get medicine_checkboxCubicMaxValue =>
      'Kübik çekmecede maks. değere bakma';

  @override
  String get medicine_checkboxQrCode => 'Karekodlu';

  @override
  String get medicine_fieldPieceCountLabel => 'Adet';

  @override
  String get medicine_fieldDrugClass => 'İlaç Sınıfı';

  @override
  String get medicine_fieldPurchaseType => 'Alım Şekli';

  @override
  String get medicine_checkboxUseMeasurementUnit => 'Ölçü Birimi Kullan';

  @override
  String get medicine_fieldVolume => 'Hacim';

  @override
  String get medicine_fieldDosageForm => 'Dozaj Formu';

  @override
  String get medicine_fieldStatus => 'Durumu';

  @override
  String get medicine_fieldCountType => 'Sayım Tipi';

  @override
  String get medicine_fieldAtcCode => 'ATC Kodu';

  @override
  String get medicine_fieldEquivalentCode => 'Eşdeğer Kod';

  @override
  String get medicine_checkboxWitnessedPurchase => 'Şahitli Alım';

  @override
  String get medicine_checkboxWastageWitnessed => 'Fire/İmha Şahitli';

  @override
  String get medicine_checkboxDestroyable => 'İmha Edilebilir';

  @override
  String get medicine_fieldActiveIngredient => 'Etken Madde';

  @override
  String get medicine_fieldCollectNote => 'Alım Notu';

  @override
  String get medicine_fieldReturnNote => 'İade Notu';

  @override
  String get medicine_fieldDestructionNote => 'İmha Notu';

  @override
  String get medicalConsumable_dialogTitle =>
      'Tıbbi Sarf Malzemesi Ekle/Düzenle';

  @override
  String get medicalConsumable_fieldName => 'Malzeme Adı';

  @override
  String get medicalConsumable_fieldInstitutionCode => 'Kurum Kodu';

  @override
  String get medicalConsumable_fieldSutCode => 'SUT Kodu/Eki';

  @override
  String get medicalConsumable_fieldUbbCode => 'UBB Kodu';

  @override
  String get medicalConsumable_fieldMaterialType => 'Malzeme Tipi';

  @override
  String get medicalConsumable_fieldStatus => 'Durum';

  @override
  String get medicine_screenTitleFallback => 'İlaç/Tıbbi Sarf Tanımlama';

  @override
  String get medicine_newButtonLabel => 'Yeni İlaç';

  @override
  String get medicine_defineMedicalConsumableButton => 'Tıbbi Sarf Tanımlama';

  @override
  String get medicine_defineActiveIngredientButton => 'Etken Madde Tanımlama';

  @override
  String get medicine_defineDrugClassButton => 'İlaç Sınıfı Tanımlama';

  @override
  String get medicine_defineDrugTypeButton => 'İlaç Tipi Tanımlama';

  @override
  String get medicine_createKitButton => 'İlaç Kiti Oluştur';

  @override
  String get medicine_defineMaterialTypeButton => 'Malzeme Tipi Tanımlama';

  @override
  String get medicine_checkboxLowerDose =>
      'Belirtilen dozdan düşük doz alınabilir';

  @override
  String get medicine_checkboxRfid => 'RFID Kullanılabilir';

  @override
  String get medicine_checkboxMultiPatientAccess => 'Çoklu Hasta Erişim';

  @override
  String get medicine_checkboxSingleUse => 'Tek Kullanımlık';

  @override
  String get medicine_checkboxCameraRecording => 'Kamera Kayıt';

  @override
  String get medicine_checkboxIndependentMaterial => 'Serbest İlaç';

  @override
  String get medicine_checkboxWastagePharmacyApproval =>
      'Fire/İmha Eczane Onayı Alınsın mı?';

  @override
  String get medicine_checkboxWastageOrderRenewed =>
      'Fire Order Yenilensin mi?';

  @override
  String get medicine_fieldPersonnel => 'Personel';

  @override
  String get medicine_fieldStation => 'İstasyon';

  @override
  String get medicine_fieldUnit => 'Birim';

  @override
  String get refillList_dialogTitle => 'İlaç Dolum Listesi';

  @override
  String refillList_recordNoLabel(Object id) {
    return 'Dolum Kayıt No: $id';
  }

  @override
  String refillList_createdDateLabel(String date) {
    return 'Oluşturulma Tarihi: $date';
  }

  @override
  String refillList_assignedUserNameLabel(String name) {
    return 'Dolum Yapacak Kişi: $name';
  }

  @override
  String get refillList_formTitleCreate => 'Dolum Listesi Oluşturma';

  @override
  String get refillList_formTitleUpdate => 'Dolum Listesi Güncelleme';

  @override
  String get refillList_fieldAssignedUser => 'Dolum Yapacak Kullanıcı';

  @override
  String get refillList_screenTitleFallback => 'Dolum Listesi';

  @override
  String get refillList_newButtonLabel => 'Yeni Dolum Listesi';

  @override
  String get report_stationsCategoryTitle => 'İstasyonlar';

  @override
  String get refillList_cellValueYes => 'Evet';

  @override
  String get refillList_cellValueNo => 'Hayır';

  @override
  String get refillList_updateStatusTooltip => 'Durum Güncelle';

  @override
  String get refillList_defaultUnitFallback => 'Adet';

  @override
  String get report_expiredItemsTitleFallback => 'S.K.T Geçmiş Malzemeler';

  @override
  String get report_stationStockTitle => 'İstasyon Kabin Stok';

  @override
  String get report_stationTransactionTitleFallback => 'İstasyon Hareketleri';

  @override
  String get report_hospitalStocksTitleFallback => 'Hastane Malzeme Listesi';

  @override
  String get inconsistency_screenTitleFallback => 'Tutarsızlık Hareketleri';

  @override
  String get inconsistency_viewTooltip => 'Görüntüle';

  @override
  String get inconsistency_photoTooltip => 'Fotoğraf';

  @override
  String get hospitalization_formTitleNew => 'Yeni Yatış Gir';

  @override
  String get hospitalization_formTitleEdit => 'Yatış Düzenle';

  @override
  String get hospitalization_fieldPatient => 'Hasta';

  @override
  String get hospitalization_fieldCode => 'Yatış Kodu';

  @override
  String get hospitalization_fieldDoctor => 'Doktor';

  @override
  String get hospitalization_fieldPhysicalService => 'Fiziki Servis';

  @override
  String get hospitalization_fieldInpatientService => 'Yatış Servis';

  @override
  String get hospitalization_fieldRoom => 'Oda';

  @override
  String get hospitalization_roomDialogTitle => 'Oda Seç';

  @override
  String get hospitalization_fieldBed => 'Yatak';

  @override
  String get hospitalization_bedDialogTitle => 'Yatak Seç';

  @override
  String get hospitalization_fieldAdmissionDate => 'Yatış Tarihi';

  @override
  String get hospitalization_fieldExitDate => 'Çıkış Tarihi';

  @override
  String get hospitalization_checkboxBaby => 'Bebek';

  @override
  String get hospitalization_screenTitleFallback => 'Hasta İşlemleri';

  @override
  String get hospitalization_editPatientTooltip => 'Hasta Bilgileri Düzenle';

  @override
  String get hospitalization_showActiveTooltip => 'Aktif yatışları getir';

  @override
  String get hospitalization_showDischargedTooltip => 'Taburcu olanları göster';

  @override
  String get hospitalization_createButton => 'Yeni Yatış Oluştur';

  @override
  String get patient_formTitleNew => 'Yeni Hasta Oluştur';

  @override
  String get patient_formTitleEdit => 'Hasta Düzenle';

  @override
  String get patient_fieldIdentity => 'T.C Kimlik No';

  @override
  String get patient_fieldName => 'Adı';

  @override
  String get patient_fieldSurname => 'Soyadı';

  @override
  String get patient_fieldBirthDate => 'Doğum Tarihi';

  @override
  String get patient_fieldGender => 'Cinsiyet';

  @override
  String get patient_fieldWeight => 'Kilo';

  @override
  String get patient_fieldMotherName => 'Anne Adı';

  @override
  String get patient_fieldFatherName => 'Baba Adı';

  @override
  String get patient_fieldPhone => 'Telefon';

  @override
  String get patient_fieldAddress => 'Adres';

  @override
  String get patient_fieldProtocolNo => 'Protokol No';

  @override
  String get activeIngredient_dialogSelectTitle => 'Etken Madde Seç';

  @override
  String get activeIngredient_dialogTitle => 'Etken Madde Tanımlama';

  @override
  String get activeIngredient_formAddTitle => 'Etken Madde Ekle';

  @override
  String get activeIngredient_formEditTitle => 'Etken Madde Düzenle';

  @override
  String get activeIngredient_listEmptyTitle => 'Henüz etken madde bulunmuyor';

  @override
  String get activeIngredient_itemNameLabel => 'etken madde';

  @override
  String get assignment_screenTitle => 'İstasyon Malzeme Atama';

  @override
  String get assignment_stationSelectPlaceholder => 'İstasyon seçiniz';

  @override
  String get drugClass_dialogSelectTitle => 'İlaç Sınıfı Seç';

  @override
  String get drugClass_dialogTitle => 'İlaç Sınıfı Tanımlama';

  @override
  String get drugClass_formAddTitle => 'İlaç Sınıfı Ekle';

  @override
  String get drugClass_formEditTitle => 'İlaç Sınıfı Düzenle';

  @override
  String get drugClass_formNameLabel => 'İlaç Sınıfı Adı';

  @override
  String get drugClass_listEmptyTitle => 'Henüz ilaç sınıfı bulunmuyor';

  @override
  String get drugClass_itemNameLabel => 'ilaç sınıfı';

  @override
  String get drugType_dialogSelectTitle => 'İlaç Tipi Seç';

  @override
  String get drugType_dialogTitle => 'İlaç Tipi Tanımlama';

  @override
  String get drugType_formAddTitle => 'İlaç Tipi Ekle';

  @override
  String get drugType_formEditTitle => 'İlaç Tipi Düzenle';

  @override
  String get drugType_formNameLabel => 'İlaç Tipi Adı';

  @override
  String get drugType_listEmptyTitle => 'Henüz ilaç tipi bulunmuyor';

  @override
  String get drugType_itemNameLabel => 'ilaç tipi';

  @override
  String get kit_formAddTitle => 'Yeni Kit';

  @override
  String get kit_formEditTitle => 'Kit Düzenle';

  @override
  String get kit_formNameLabel => 'Kit Adı';

  @override
  String get kit_dialogSelectTitle => 'Kit Seç';

  @override
  String get kit_dialogTitle => 'Kit Tanımlama';

  @override
  String get kit_listEmptyTitle => 'Henüz kit bulunmuyor';

  @override
  String get kit_listManageContentTooltip => 'Kit İçeriğini Yönet';

  @override
  String get kit_itemNameLabel => 'kit';

  @override
  String get kitContent_formAddTitle => 'Kit İçeriği Ekle';

  @override
  String get kitContent_formEditTitle => 'Kit İçeriği Düzenle';

  @override
  String get kitContent_formMaterialLabel => 'Malzeme';

  @override
  String get kitContent_formPieceLabel => 'Adet';

  @override
  String get kitContent_dialogTitle => 'Kit İçerik Tanımlama';

  @override
  String get kitContent_listEmptyTitle => 'Henüz kit içeriği bulunmuyor';

  @override
  String get kitContent_itemNameLabel => 'içerik';

  @override
  String get materialType_formAddTitle => 'Yeni Malzeme Tipi';

  @override
  String get materialType_formEditTitle => 'Malzeme Tipi Düzenle';

  @override
  String get materialType_formNameLabel => 'Malzeme Tipi Adı';

  @override
  String get materialType_dialogSelectTitle => 'Malzeme Tipi Seç';

  @override
  String get materialType_dialogTitle => 'Malzeme Tipi Tanımlama';

  @override
  String get materialType_listEmptyTitle => 'Henüz malzeme tipi bulunmuyor';

  @override
  String get materialType_itemNameLabel => 'malzeme tipi';

  @override
  String get role_formEditTitle => 'Rol Düzenle';

  @override
  String get role_formAddTitle => 'Rol Ekle';

  @override
  String get role_formNameLabel => 'Rol Adı';

  @override
  String get role_screenTitle => 'Rol Tanımlama';

  @override
  String get role_screenAddButton => 'Yeni Rol';

  @override
  String get role_deleteSuccessMessage => 'Rol başarıyla silindi';

  @override
  String get unit_formAddTitle => 'Yeni Birim Oluştur';

  @override
  String get unit_formEditTitle => 'Birim Düzenle';

  @override
  String get unit_dialogTitle => 'Birim';

  @override
  String get unit_itemNameLabel => 'birim';

  @override
  String get unit_listEmptyTitle => 'Henüz birim bulunmuyor';

  @override
  String get user_categoryNormalLabel => 'Normal';

  @override
  String get user_categoryTimeBasedLabel => 'Süreli';

  @override
  String get user_categoryTemporaryLabel => 'Geçici';

  @override
  String get user_deleteSuccessMessage => 'Kullanıcı başarıyla silindi';

  @override
  String get user_validDateUpdateSuccessMessage =>
      'Son geçerlilik tarihi güncellendi';

  @override
  String get user_formEditTitle => 'Kullanıcı Düzenle';

  @override
  String get user_formCreateTitle => 'Kullanıcı Oluştur';

  @override
  String get user_registrationNumberLabel => 'Kurum Sicil No';

  @override
  String get user_nameLabel => 'Adı';

  @override
  String get user_surnameLabel => 'Soyadı';

  @override
  String get user_roleTypeLabel => 'Meslek Tipi';

  @override
  String get user_usageTypeLabel => 'Kullanım Türü';

  @override
  String get user_validUntilLabel => 'Son Geçerlilik Tarihi';

  @override
  String get user_emailLabel => 'E-posta';

  @override
  String get user_orderPermissionLabel => 'Ordersız Alım';

  @override
  String get user_witnessedStationEntryLabel => 'İstasyon Şahitli Giriş';

  @override
  String get user_kitPurchaseLabel => 'Kit Alım';

  @override
  String get user_badgeCardLabel => 'Yaka Kartı';

  @override
  String get user_emergencyAccessLabel => 'Acil Hasta Oluşturabilir mi?';

  @override
  String get user_badgeCardHint => 'Kartı okutun';

  @override
  String get user_authorizedStationsLabel => 'Yetki İstasyonlar';

  @override
  String get user_usernameLabel => 'Kullanıcı Adı';

  @override
  String get user_screenTitle => 'Kullanıcı Listesi';

  @override
  String get user_screenAddButton => 'Yeni Kullanıcı';

  @override
  String get user_bulkUpdateValidDateButton => 'Son Geçerlilik Tarihi Güncelle';

  @override
  String get user_validDateDialogTitle => 'Tarih Güncelle';

  @override
  String get user_validDateDialogSaveButton => 'Güncelle';

  @override
  String get user_newValidUntilLabel => 'Yeni Son Geçerlilik Tarihi';

  @override
  String get user_nationalIdColumnHeader => 'T.C Kimlik No';

  @override
  String get warning_formAddTitle => 'Yeni Uyarı';

  @override
  String get warning_formEditTitle => 'Uyarı Düzenle';

  @override
  String get warning_formAddSubtitle => 'Uyarı bilgilerini doldurun';

  @override
  String get warning_formEditSubtitle => 'Uyarı bilgilerini güncelleyin';

  @override
  String get warning_formSubjectLabel => 'Uyarı Konusu';

  @override
  String get warning_formTextLabel => 'Uyarı Metni';

  @override
  String get warning_screenTitle => 'Uyarı Tanımlama';

  @override
  String get dashboard_allSectionsLoadError =>
      'Veriler yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get dashboard_sktCriticalRingLabel => 'Kritik\n(<7 gün)';

  @override
  String get dashboard_sktWarningRingLabel => 'Uyarı\n(7-30 gün)';

  @override
  String get dashboard_sktExpiredRingLabel => 'Geçmiş\nSKT';

  @override
  String get dashboard_sktStatusHeader => 'SKT DURUMU';

  @override
  String dashboard_sktItemCountBadge(int count) {
    return '$count Kalem';
  }

  @override
  String get dashboard_sktExpiredTag => 'GEÇTİ';

  @override
  String get dashboard_sktDestroyHint => 'imha et';

  @override
  String dashboard_sktDaysRemainingLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'gün kaldı',
      one: 'gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsHeader => 'YAKLAŞAN TEDAVİLER';

  @override
  String dashboard_pendingTreatmentsBadge(int count) {
    return '$count Bekliyor';
  }

  @override
  String get dashboard_pendingFilterLabel => 'Bekleyen';

  @override
  String get dashboard_urgentFilterLabel => 'Acil';

  @override
  String get dashboard_treatmentSearchHint => 'Hasta veya ilaç ara...';

  @override
  String get dashboard_newAssignButton => 'Yeni Ata';

  @override
  String get dashboard_noTreatmentsAllFilter => 'Tedavi kaydı bulunamadı';

  @override
  String get dashboard_noTreatmentsPendingFilter => 'Bekleyen tedavi yok';

  @override
  String get dashboard_noTreatmentsUrgentFilter => 'Acil tedavi yok';

  @override
  String get dashboard_priorityUrgentLabel => 'Acil';

  @override
  String get dashboard_priorityNormalLabel => 'Normal';

  @override
  String get dashboard_priorityRoutineLabel => 'Rutin';

  @override
  String get dashboard_statusPendingLabel => 'Bekliyor';

  @override
  String get dashboard_statusDoneLabel => 'Dağıtıldı';

  @override
  String get dashboard_statusReturnedLabel => 'İade';

  @override
  String settings_sectionComingSoon(String label) {
    return '$label ayarları yakında';
  }

  @override
  String get refund_masterScreenNotReady =>
      'Master kabin iade ekranı henüz hazır değil.';

  @override
  String get core_cabinConn_managerNotFoundError => 'Yönetim kartı bulunamadı.';

  @override
  String get core_cabinConn_disconnectedError => 'Bağlantı koptu';

  @override
  String get common_action_pullDrawerTitle => 'Çekmeceyi açınız';

  @override
  String get common_action_pullDrawerSubtitle => 'Kilit açıldı, lütfen çekin.';

  @override
  String get masterDrawer_openingLidTitle => 'Kapaklar açılıyor';

  @override
  String get masterDrawer_openingLidSubtitle =>
      'Kübik çekmece kapakları hazırlanıyor.';

  @override
  String get masterDrawer_readySubtitle => 'İşlemi tamamlayın ve onaylayın.';

  @override
  String get common_action_closeDrawerTitle => 'Çekmeceyi kapatınız';

  @override
  String get common_action_closeDrawerSubtitle =>
      'İşlem onaylandı, lütfen kapatın.';

  @override
  String get common_action_drawerClosed => 'Çekmece kapatıldı';

  @override
  String get common_action_operationCompletedSubtitle => 'İşlem tamamlandı.';

  @override
  String get common_action_drawerError => 'Çekmece hatası';

  @override
  String common_error_unexpectedWithDetail(Object error) {
    return 'Beklenmeyen hata: $error';
  }

  @override
  String masterDrawer_lidOpenFailedError(Object error) {
    return 'Kapak açılamadı: $error';
  }

  @override
  String get common_action_devicePreparing => 'Cihaz hazırlanıyor...';

  @override
  String common_error_connectionErrorWithDetail(Object error) {
    return 'Bağlantı hatası: $error';
  }

  @override
  String get common_action_lockOpening => 'Kilit açılıyor...';

  @override
  String common_error_lockOpenFailedWithDetail(Object error) {
    return 'Kilit açılamadı: $error';
  }

  @override
  String mobileDrawer_portSubtitle(int port) {
    return 'Çekmece $port';
  }

  @override
  String get mobileDrawer_openedSubtitle =>
      'İşlemi tamamlamak için çekmeceyi kapatınız.';

  @override
  String get mobileDrawer_closedSubtitle => 'İşlem onayınızı bekliyor';

  @override
  String common_error_managerConnectFailedWithDetail(Object error) {
    return 'Yönetim kartına bağlanılamadı: $error';
  }

  @override
  String mobileDrawer_openCommandFailedError(Object error) {
    return 'Çekmece açma komutu gönderilemedi: $error';
  }

  @override
  String get mobileDrawer_statusTimeoutError =>
      'Çekmece durumu okunurken zaman aşımı oluştu.';

  @override
  String get mobileDrawer_openNotConfirmedError =>
      'Çekmecenin açıldığı doğrulanamadı.';

  @override
  String mobileDrawer_statusReadError(Object error) {
    return 'Çekmece durumu okunurken hata oluştu: $error';
  }

  @override
  String get patientPicker_searchHint => 'Hasta ara';

  @override
  String get patientPicker_orderlessToggleLabel => 'Ordersız';

  @override
  String get patientPicker_orderedToggleLabel => 'Orderlı';

  @override
  String get patientPicker_myPatientsToggleLabel => 'Hastalarım';

  @override
  String get patientPicker_urgentPatientHint =>
      'Listede olmayan acil hasta için kayıt oluşturun.';

  @override
  String get patientPicker_createUrgentPatientButton => 'Acil Hasta Oluştur';

  @override
  String get patientPicker_urgentPatientCreatedMessage =>
      'Acil hasta oluşturuldu.';

  @override
  String get patientPicker_urgentPatientCardDescription =>
      'Acil hasta oluşturuldu, normal akışa dönmek istiyorsanız acil hastayı silmeniz gerekiyor.';

  @override
  String get hw_cabinOps_serumSlaveModeError =>
      'Serum kartı slave moda alınamadı...';

  @override
  String hw_cabinOps_solenoidMissingError(Object port) {
    return 'Port $port solenoid yok (.no).';
  }

  @override
  String hw_cabinOps_portOpenFailedError(Object port, Object response) {
    return 'Port $port açılamadı. Yanıt: $response';
  }

  @override
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  ) {
    return 'Master çekmece açılamadı (row=$row, port=$port, drawer=$drawer). Yanıt: $response';
  }

  @override
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response) {
    return 'Master serum çekmecesi açılamadı (row=$row). Yanıt: $response';
  }

  @override
  String get hw_cabinOps_sensorLostDuringCloseDetail =>
      'Donanımla iletişim kesildi (kapanış izlenirken sensör yanıt vermiyor).';

  @override
  String get hw_cabinOps_sensorLostDuringOpenDetail =>
      'Donanımla iletişim kesildi (sensör yanıt vermiyor).';

  @override
  String hw_cabinOps_fullyOpenTimeoutDetail(Object timeout) {
    return 'Çekmece $timeout içinde tam açık duruma ulaşamadı.';
  }

  @override
  String hw_serial_connectFailedDetailedError(String portName) {
    return '$portName portuna bağlanılamadı. Cihazın bağlı ve açık olduğundan, portun başka bir uygulama tarafından kullanılmadığından emin olun.';
  }

  @override
  String hw_serial_portConfigFailedError(String portName, Object error) {
    return 'Port konfigürasyonu başarısız ($portName): $error';
  }

  @override
  String hw_serial_systemErrorSuffix(Object error) {
    return 'Sistem hatası: $error';
  }

  @override
  String get hw_serial_portInUseSuffix =>
      'Port başka bir uygulama tarafından kullanılıyor olabilir.';

  @override
  String hw_serial_readErrorWithDetail(Object error) {
    return 'Port okuma hatası: $error';
  }

  @override
  String get hw_serial_reconnectingStatus => 'Bağlantı yeniden başlatılıyor.';

  @override
  String hw_rfid_connectFailedError(Object error) {
    return 'RFID okuyucuya bağlanılamadı: $error';
  }

  @override
  String get hw_rfid_invalidResponseError => 'Geçersiz cevap alındı.';

  @override
  String hw_rfid_unreachableError(Object error) {
    return 'RFID okuyucuya ulaşılamadı: $error';
  }

  @override
  String get hw_rfid_testTimeoutError =>
      'RFID bağlantı testi zaman aşımına uğradı.';

  @override
  String get hw_rfid_powerChangeBlockedError =>
      'Inventory aktifken güç ayarı değiştirilemez. Önce stopInventory() çağırın.';

  @override
  String hw_rfid_setModeRejectedError(Object status) {
    return 'SetWorkingMode reddedildi (status=0x$status)';
  }

  @override
  String hw_rfid_setAntennaRejectedError(Object status) {
    return 'SetWorkingAntenna reddedildi (status=0x$status)';
  }

  @override
  String get hw_rfid_antennaConnFailedHint =>
      ' (anten bağlantı hatası — etkinleştirilen portlardan biri boş)';

  @override
  String get hw_rfid_noAntennaConnectedError =>
      'Hiçbir antene bağlanılamadı (tüm portlar boş).';

  @override
  String get hw_rfid_notConnectedError => 'RFID servisi bağlı değil.';

  @override
  String get hw_rfid_commandPendingError => 'Önceki komut hâlâ cevap bekliyor.';

  @override
  String hw_rfid_commandTimeoutError(Object cmd) {
    return 'Komut cevabı zaman aşımına uğradı (cmd=0x$cmd).';
  }

  @override
  String hw_rfid_commandErrorWithDetail(Object error) {
    return 'Komut hatası: $error';
  }

  @override
  String get hw_rfid_mockNotConnectedError => 'Mock RFID servisi bağlı değil.';

  @override
  String get operationStatus_fatalErrorLabel => 'Kritik Hata';

  @override
  String get operationStatus_errorLabel => 'Hata';

  @override
  String get operationStatus_rollingBackLabel => 'İşlem geri alınıyor';

  @override
  String get operationStatus_finalizingLabel => 'İşlem sonlandırılıyor';

  @override
  String get operationStatus_drugsStillInCabinetLabel => 'İlaçlar hâlâ kabinde';

  @override
  String get operationStatus_incompleteLabel => 'Eksik / Tutarsız';

  @override
  String get operationStatus_scanningLabel => 'Tarama yapılıyor';

  @override
  String get operationStatus_reportedMissingLabel => 'Eksik Bildirildi';

  @override
  String get operationBanner_unplannedMovementTitle =>
      'Plan dışı hareket algılandı';

  @override
  String operationBanner_unplannedMovementMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString etiket plan dışı olarak kabinden çıkarıldı.',
      one: '$countString etiket plan dışı olarak kabinden çıkarıldı.',
    );
    return '$_temp0 Eczaneye bildirim oluşturulacak.';
  }

  @override
  String get operationBanner_unexpectedTagBlockingTitle =>
      'Kabine ait olmayan etiket(ler) tespit edildi';

  @override
  String get operationBanner_unexpectedTagWarningTitle => 'Beklenmeyen ilaç';

  @override
  String operationBanner_unexpectedTagBlockingMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString etiketi',
      one: '$countString etiketi',
    );
    return 'Devam edebilmek için aşağıdaki $_temp0 çekmeceden çıkartın.';
  }

  @override
  String operationBanner_unexpectedTagWarningMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString etiket',
      one: '$countString etiket',
    );
    return 'Kabinde bu kabine ait olmayan $_temp0 okundu. Lütfen çıkarın.';
  }

  @override
  String get operationBanner_missingStockTitle => 'Eksik stok';

  @override
  String operationBanner_missingStockMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ilaç',
      one: '$countString ilaç',
    );
    return '$_temp0 kabinde bulunamadı. Tamamlandığında eksik stok olarak bildirilecek.';
  }

  @override
  String get common_okButton => 'Tamam';

  @override
  String get cabinPatientPicker_searchHint =>
      'Hasta, oda, yatak veya servis ara...';

  @override
  String get common_unknownPatientFallback => 'Bilinmeyen Hasta';

  @override
  String get patientListPanel_searchHint => 'Hasta ara...';

  @override
  String rxItemCard_maxQuantitySuffix(String max, String unit) {
    return '/ maks. $max $unit';
  }

  @override
  String get census_extraStockSummaryMessage =>
      'İşlem sonunda fazla stoklar bildirilecektir.';

  @override
  String get cabinOperation_hint_scanning => 'Kabin taranıyor, lütfen bekleyin';

  @override
  String get census_hint_waitingClose =>
      'Kayıt alındı — sayımı bitirmek için çekmeceyi kapatın';

  @override
  String get census_hint_closedEarly =>
      'Çekmece erken kapandı — tekrar deneyebilir veya iptal edebilirsiniz';

  @override
  String get cabinOperation_hint_error =>
      'Hata oluştu — tekrar deneyebilirsiniz';

  @override
  String get census_hint_unexpectedTag =>
      'Kabine ait olmayan etiket var — çıkarıp devam edin';

  @override
  String get census_hint_readyToComplete =>
      'Sayımı tamamlamak için butona basın';

  @override
  String get cabinOperation_action_closeDrawer => 'Çekmeceyi Kapatın';

  @override
  String get census_label_counted => 'Sayıldı';

  @override
  String get census_label_excess => 'Fazla';

  @override
  String get cabinOperation_label_unexpectedTag => 'Yabancı';

  @override
  String get intake_error_witnessRequired =>
      'Şahit girişi yapılması gerekmektedir.';

  @override
  String get intake_error_noValidTargets =>
      'Seçilen ilaçlar için alım yapılamadı.';

  @override
  String get intake_error_noDrawerFound => 'Alınacak çekmece bulunamadı.';

  @override
  String get intake_hint_noStock => 'Kabinde stok bulunmamaktadır';

  @override
  String intake_label_witnessName(String name) {
    return 'Şahit: $name';
  }

  @override
  String get intake_hint_witnessRequired => 'Şahit girişi gerekli';

  @override
  String get intake_status_checking => 'Kontrol ediliyor...';

  @override
  String get intake_status_readyToTake => 'Alıma hazır';

  @override
  String get intake_status_checkFailed => 'Kontrol başarısız';

  @override
  String get intake_emptyState_selectMedicine =>
      'Alıma başlamak için ilaç seçin.';

  @override
  String intake_label_multiMedicine(int count) {
    return '$count farklı ilaç';
  }

  @override
  String intake_label_takenAmount(String amount, String unit) {
    return 'Alınan: $amount $unit';
  }

  @override
  String intake_label_countFieldLabel(String unit) {
    return 'Sayım ($unit)';
  }

  @override
  String get intake_hint_nextCellOpens =>
      'Onayladığınızda sıradaki göz açılır.';

  @override
  String get intake_hint_confirmCloses => 'Onayladığınızda çekmece kapanır.';

  @override
  String get intake_hint_searchMedicine => 'İlaç ara (ad / barkod)';

  @override
  String get intake_hint_selectionLocked => 'Alım sürüyor — seçim kilitli.';

  @override
  String get intake_hint_autoQueueOrder =>
      'Çekmeceler en kısa yol sırasıyla açılacak.';

  @override
  String intake_info_witnessAutoAssigned(String name) {
    return '$name bu ilaç için de şahit olarak atandı.';
  }

  @override
  String get intake_error_queueTitle => 'Alım tamamlanamadı';

  @override
  String get intake_error_queueMessage =>
      'İlaçları aldığınız yere geri bırakın.';

  @override
  String get intake_error_selfWitness =>
      'İşlemi yapan kullanıcı aynı işleme şahit olamaz.';

  @override
  String intake_success_witnessConfirmed(String name) {
    return '$name şahit olarak onaylandı.';
  }

  @override
  String get intake_witnessDialog_title => 'Şahit Doğrulaması';

  @override
  String get intake_witnessDialog_usernameLabel => 'Şahit Kullanıcı Adı';

  @override
  String get intake_witnessDialog_usernameRequired => 'Kullanıcı adı giriniz';

  @override
  String get intake_witnessDialog_passwordLabel => 'Şahit Şifresi';

  @override
  String get intake_witnessDialog_passwordRequired => 'Şifre giriniz';

  @override
  String get intake_witnessDialog_confirmButton => 'Şahitliği Onayla';

  @override
  String get intake_witnessDialog_anyoneInfo =>
      'Bu işlem için herhangi bir personel şahitlik yapabilir.';

  @override
  String intake_witnessDialog_authorizedWitnesses(int count) {
    return 'Yetkili Şahitler ($count)';
  }

  @override
  String cabinOperation_hint_fatalError(String message) {
    return 'Kritik bir hata oluştu: $message';
  }

  @override
  String get cabinOperation_hint_completed => 'İşlem tamamlandı';

  @override
  String get cabinOperation_hint_waitingCloseGeneric =>
      'Kayıt alındı. İşlemi bitirmek için çekmeceyi kapatın';

  @override
  String get cabinOperation_hint_closedEarlyGeneric =>
      'Çekmece kapatıldı. İptal edebilir veya kaldığınız yerden devam edebilirsiniz';

  @override
  String get cabinOperation_hint_ready => 'Hazır — işlemi tamamlayabilirsiniz';

  @override
  String get intake_hint_extraPlacement =>
      'Kabine olmaması gereken bir ilaç yüklendi, lütfen çıkarın.';

  @override
  String get intake_hint_takeItems =>
      'İlaçları alın, ardından işlemi tamamlayın';

  @override
  String get cabinOperation_action_completeGeneric => 'İşlemi tamamla';

  @override
  String get rfidStatus_notFound => 'Bulunamadı';

  @override
  String get rfidStatus_scanning => 'Taranıyor';

  @override
  String get intake_label_noRfid => 'RFID yok';

  @override
  String get cabinOperation_label_selected => 'Seçili';

  @override
  String get intake_label_readInCabin => 'Kabinde Okunan';

  @override
  String intake_label_tagCount(int count) {
    return '$count etiket';
  }

  @override
  String get intake_label_takenCount => 'Alınan';

  @override
  String get intake_label_unauthorizedTake => 'İzinsiz Alım';

  @override
  String get intake_error_retryOrFinish =>
      'Tekrar deneyebilir ya da yerleştirdiğiniz ilaçları alarak işleminizi sonlandırabilirsiniz.';

  @override
  String get refill_label_placed => 'Yerleştirildi';

  @override
  String get refill_label_placedCount => 'Yerleştirilen';

  @override
  String refill_label_placedProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String get cabinOperation_label_unplanned => 'Plan Dışı';

  @override
  String get refill_label_extraTag => 'Fazla Etiket';

  @override
  String get refill_error_retry => 'Tekrar deneyebilirsiniz.';

  @override
  String get unload_hint_waitingClose =>
      'Kayıt alındı — boşaltmayı bitirmek için çekmeceyi kapatın';

  @override
  String get unload_hint_closedEarly =>
      'Çekmece erken kapandı — tekrar deneyebilir veya iptal edebilirsiniz';

  @override
  String get unload_hint_readyToComplete =>
      'Boşaltmayı tamamlamak için butona basın';

  @override
  String get unload_label_unloaded => 'Boşaltıldı';

  @override
  String unload_label_unloadProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String wizard_stepBadge(int step, int total) {
    return 'Adım $step / $total';
  }

  @override
  String get wizard_step4Header => 'Çekmece Yapılandırması';

  @override
  String get wizard_step4SubtitleMobile =>
      'Mobil kabinin çekmece sayısını, iç bölümlerini ve port bağlantılarını tanımlayın.';

  @override
  String get wizard_step4SubtitleMaster =>
      'Cihazdan kabin iç yapısı otomatik okunacaktır.';

  @override
  String get wizard_backButton => 'Geri';

  @override
  String get wizard_testCabinConnectionButton => 'Kabin Bağlantısını Test Et';

  @override
  String get wizard_testingInProgress => 'Test ediliyor…';

  @override
  String get wizard_connectionSuccessLabel => 'Bağlantı başarılı';

  @override
  String get wizard_retestLink => 'Tekrar test et';

  @override
  String get wizard_cabinConnectionErrorFallback =>
      'Bağlantı kurulamadı. Port bilgisini kontrol edin.';

  @override
  String get wizard_testRfidConnectionButton => 'Anten Bağlantısını Test Et';

  @override
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power) {
    return '· FW $firmwareVersion  $power dBm';
  }

  @override
  String get wizard_rfidConnectionErrorFallback =>
      'Bağlantı kurulamadı. IP ve port bilgilerini kontrol edin.';

  @override
  String get wizard_portLabel => 'Port';

  @override
  String get wizard_rfidReaderToggleLabel => 'RFID okuyucu var';

  @override
  String get wizard_rfidIpAddressLabel => 'RFID IP Adresi';

  @override
  String get wizard_rfidPortFieldLabel => 'RFID Port';

  @override
  String get wizard_drawerCountRangeHint => '1–8 çekmece';

  @override
  String get wizard_sameConfigToggleLabel => 'Tüm çekmeceler aynı yapıda';

  @override
  String get wizard_sameConfigToggleOnDesc =>
      'Tüm çekmeceler aynı satır/sütun konfigürasyonunu kullanır';

  @override
  String get wizard_sameConfigToggleOffDesc =>
      'Kapalıysa her çekmece için satır/sütun ayrı seçilebilir';

  @override
  String wizard_drawerRowCellSummary(int rowCount, int totalCells) {
    return '$rowCount satır · $totalCells hücre';
  }

  @override
  String wizard_drawerPortLabel(Object portNumber) {
    return 'Port $portNumber';
  }

  @override
  String wizard_rowLabel(int rowIndex) {
    return 'SATIR $rowIndex';
  }

  @override
  String get wizard_serviceDetailsLoadError => 'Servis detayları yüklenemedi.';

  @override
  String get wizard_stationDetailsLoadError =>
      'İstasyon detayları yüklenemedi.';

  @override
  String get wizard_stationsLoadErrorFallback => 'İstasyonlar yüklenemedi.';

  @override
  String get wizard_noStationsFoundMessage => 'Kayıtlı istasyon bulunamadı.';

  @override
  String get wizard_noRoomsDefinedMessage =>
      'Bu istasyona bağlı oda tanımlı değil.';

  @override
  String wizard_selectedRoomCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oda',
      one: '$count oda',
    );
    return '$_temp0';
  }

  @override
  String wizard_roomSelectionFraction(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get refill_hint_extraPlacement =>
      'Seçili ilaçlar dışında etiket kondu, lütfen çıkartın';

  @override
  String get refill_hint_placeItems =>
      'İlaçları yerleştirin, ardından işlemi tamamlayın';

  @override
  String get appException_networkUnavailable =>
      'Sunucuya bağlanılamıyor. Ağ bağlantınızı kontrol edin.';

  @override
  String get appException_timeout =>
      'Sunucu yanıt vermedi. Lütfen tekrar deneyin.';

  @override
  String appException_serviceError5xx(Object statusCode) {
    return 'Sunucu hatası ($statusCode). Lütfen tekrar deneyin.';
  }

  @override
  String appException_serviceErrorOther(Object statusCode) {
    return 'İşlem tamamlanamadı ($statusCode).';
  }

  @override
  String get appException_malformedData => 'Sunucudan beklenmedik veri alındı.';

  @override
  String get appException_emptyResponse => 'Sunucu boş yanıt döndürdü.';

  @override
  String appException_validationField(String field) {
    return '$field alanı geçersiz.';
  }

  @override
  String get appException_validationGeneric => 'Girilen bilgiler geçersiz.';

  @override
  String get appException_mapping => 'Veri işlenirken hata oluştu.';

  @override
  String get appException_cache => 'Yerel veri okunamadı.';

  @override
  String get appException_staleCache =>
      'Güncel veriye ulaşılamıyor. Lütfen bağlantıyı kontrol edin.';

  @override
  String appException_notFoundWithType(String resourceType) {
    return '$resourceType bulunamadı.';
  }

  @override
  String get appException_notFoundGeneric => 'Kayıt bulunamadı.';

  @override
  String get appException_unexpected =>
      'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';

  @override
  String get appException_serialPort =>
      'Seri porta bağlanılamadı. Lütfen teknik servis ile iletişime geçiniz.';

  @override
  String get appException_custom =>
      'Bilinmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get dataError_emptyResponse => 'Sunucu boş yanıt döndürdü';

  @override
  String get dataError_malformedResponse => 'Yanıt işlenemedi';

  @override
  String get dataError_requestTimeout => 'İstek zaman aşımına uğradı';

  @override
  String get dataError_networkUnavailable => 'Ağa bağlanılamadı';

  @override
  String get dataError_genericApiError =>
      'Bir hatayla karşılaştık. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get dataError_requestCancelled => 'İstek iptal edildi';

  @override
  String get dataError_envelopeErrorFallback => 'Hata';

  @override
  String get authError_invalidTokenResponse =>
      'Sunucudan geçersiz token yanıtı alındı';

  @override
  String get authError_userInfoFetchFailed => 'Kullanıcı bilgisi alınamadı';

  @override
  String get authError_userInfoEmpty => 'Kullanıcı bilgisi boş döndü';

  @override
  String get authError_genericLoginError => 'Bir hata oluştu';

  @override
  String get authError_invalidCredentialsMock =>
      'Kullanıcı adı veya şifre hatalı.';

  @override
  String get dataGuard_deleteActiveIngredientIdEmpty =>
      'Silinecek etken maddenin id\'si boş olamaz';

  @override
  String get dataGuard_deleteBranchIdEmpty =>
      'Silinecek branşın id\'si boş olamaz';

  @override
  String get dataGuard_deleteCabinIdEmpty =>
      'Silinecek kabinin id\'si boş olamaz';

  @override
  String get dataGuard_deleteDosageFormIdEmpty =>
      'Silinecek dozaj formunun id\'si boş olamaz';

  @override
  String get dataGuard_deleteDrugClassIdEmpty =>
      'Silinecek sınıfın id\'si boş olamaz';

  @override
  String get dataGuard_deleteFirmIdEmpty =>
      'Silinecek firmanın id\'si boş olamaz';

  @override
  String get dataGuard_deleteDrugTypeIdEmpty =>
      'Silinecek tipin id\'si boş olamaz';

  @override
  String get dataGuard_deleteHospitalizationIdEmpty =>
      'Silinecek yatışın id\'si boş olamaz';

  @override
  String get dataGuard_deleteKitIdEmpty => 'Silinecek kitin id\'si boş olamaz';

  @override
  String get dataGuard_deleteKitContentIdEmpty =>
      'Silinecek kit içeriğinin id\'si boş olamaz';

  @override
  String get dataGuard_deleteMaterialTypeIdEmpty =>
      'Silinecek tipin id\'si boş olamaz';

  @override
  String get dataGuard_deleteMedicineIdEmpty =>
      'Silinecek ilacın id\'si boş olamaz';

  @override
  String get dataGuard_deletePatientIdEmpty =>
      'Silinecek hastanın id\'si boş olamaz';

  @override
  String get dataGuard_deleteRoleIdEmpty => 'Silinecek rolün id\'si boş olamaz';

  @override
  String get dataGuard_deleteServiceIdEmpty =>
      'Silinecek servisin id\'si boş olamaz';

  @override
  String get dataGuard_deleteStationIdEmpty =>
      'Silinecek istasyonun id\'si boş olamaz';

  @override
  String get dataGuard_deleteUnitIdEmpty =>
      'Silinecek birimin id\'si boş olamaz';

  @override
  String get dataGuard_deleteWarehouseIdEmpty =>
      'Silinecek deponun id\'si boş olamaz';

  @override
  String get dataGuard_deleteWarningIdEmpty =>
      'Silinecek uyarının id\'si boş olamaz';

  @override
  String get dataGuard_updatePatientIdEmpty =>
      'Güncellenecek hastanın id\'si boş olamaz';

  @override
  String get dataGuard_updateHospitalizationIdEmpty =>
      'Güncellenecek yatışın id\'si boş olamaz';

  @override
  String get dataGuard_dosageFormNameRequired => 'Branş adı zorunludur';

  @override
  String get dataGuard_roleNameRequired => 'Rol adı zorunludur';

  @override
  String get dataGuard_branchNameRequired => 'Branş adı zorunludur';

  @override
  String get dataGuard_warehouseNameRequired => 'Depo adı zorunludur';

  @override
  String get dataGuard_warningTextRequired => 'Uyarı adı zorunludur';

  @override
  String get dataGuard_activeIngredientNameRequired => 'İsim alanı zorunludur';

  @override
  String get core_genericErrorRetryMessage =>
      'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get core_genericErrorShortMessage => 'Bir hata oluştu.';

  @override
  String get common_defaultReportTitle => 'Rapor';

  @override
  String fileExport_savedMessage(String path) {
    return 'Dosya kaydedildi: $path';
  }

  @override
  String fileExport_pdfSaveErrorMessage(Object error) {
    return 'PDF kaydetme hatası: $error';
  }

  @override
  String fileExport_printErrorMessage(Object error) {
    return 'Yazdırma hatası: $error';
  }

  @override
  String get fileExport_saveDialogTitle => 'Dosyayı Kaydet';

  @override
  String fileExport_saveErrorMessage(Object error) {
    return 'Dosya kaydetme hatası: $error';
  }

  @override
  String fileExport_saveToDesktopErrorMessage(Object error) {
    return 'Masaüstüne kaydetme hatası: $error';
  }

  @override
  String fileExport_savedSuccessMessage(String path) {
    return 'Dosya başarıyla kaydedildi: $path';
  }

  @override
  String get fileExport_saveCancelledMessage =>
      'Dosya kaydetme işlemi iptal edildi';

  @override
  String get fileExport_excelCreateFailedMessage =>
      'Excel dosyası oluşturulamadı';

  @override
  String fileExport_excelExportFailedMessage(Object error) {
    return 'Excel export işlemi başarısız: $error';
  }

  @override
  String fileExport_tableExportFailedMessage(Object error) {
    return 'Tablo export işlemi başarısız: $error';
  }

  @override
  String get cabinCore_createError =>
      'Kabin oluşturma işlemi sırasında bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get cabinCore_activeCabinNotFound => 'Aktif kabin bulunamadı';

  @override
  String get cabinCore_mobileCabinDesignNotFound =>
      'Mobil kabin tasarımı bulunamadı';

  @override
  String get cabinCore_cabinDesignNotFound => 'Kabin tasarımı bulunamadı';

  @override
  String get cabinCore_createdButIdMissing =>
      'Kabin oluşturuldu fakat ID alınamadı.';

  @override
  String get cabinCore_definitionsNotFound => 'Tanımlamalar alınamadı.';

  @override
  String get cabinCore_noCardsFound => 'Hiçbir kart bulunamadı.';

  @override
  String get cabinCore_noMatchingDrawerFound => 'Eşleşen çekmece bulunamadı.';

  @override
  String get cabinCore_designDataNotFound => 'Kaydedilecek veri bulunamadı.';

  @override
  String get cabinCore_targetDrawerNotFound => 'Hedef çekmece/göz bulunamadı';

  @override
  String get cabinCore_unknownMedicineFallback => 'Bilinmeyen İlaç';

  @override
  String get cabinAssignmentList_selectColumn => 'Seç';

  @override
  String get cabinAssignmentList_medicineColumn => 'İlaç';

  @override
  String get cabinAssignmentList_locationColumn => 'Konum';

  @override
  String get cabinAssignmentList_stockColumn => 'Stok';

  @override
  String get cabinAssignmentList_fillLevelColumn => 'Doluluk';

  @override
  String cabinAssignmentList_cubicLocationLabel(
    Object drawer,
    Object column,
    Object row,
  ) {
    return 'Çekmece $drawer - Sütun $column - Satır $row';
  }

  @override
  String cabinAssignmentList_unitLocationLabel(Object drawer, Object cell) {
    return 'Çekmece $drawer - Göz $cell';
  }

  @override
  String get cabinOverview_panelTitle => 'KABİN GENEL BAKIŞ';

  @override
  String get cabinOverview_cubicDrawerSubtitle => 'Kübik Çekmece';

  @override
  String get cabinOverview_unitDoseDrawerSubtitle => 'Birim Doz Çekmece';

  @override
  String get cabinOverview_cubicTypeLabel => 'KÜBİK';

  @override
  String get cabinOverview_unitDoseTypeLabel => 'BİRİM DOZ';

  @override
  String get cabinOverview_returnMergedCellLabel => 'İADE';

  @override
  String get cabinOverview_legendFillingLabel => 'Şu an dolduruluyor';

  @override
  String get cabinOverview_legendCompletedLabel => 'Tamamlandı';

  @override
  String get cabinOverview_legendQueuedLabel => 'Sırada';

  @override
  String get cabinOverview_locationGuideLabel => 'KONUM REHBERİ';

  @override
  String get prescriptionCore_createError =>
      'Reçete oluşturulurken bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get prescriptionCore_rfidTagNotFoundInReader =>
      'Okuyucu alanında RFID etiketi bulunamadı.';

  @override
  String prescriptionCore_rfidReadErrorWithDetail(Object error) {
    return 'RFID etiketi okunurken hata oluştu: $error';
  }

  @override
  String get prescriptionCore_actionApproveTitle => 'Seçili Talepleri Onayla';

  @override
  String get prescriptionCore_actionCancelTitle => 'Seçili Talepleri İptal Et';

  @override
  String get prescriptionCore_actionRejectTitle => 'Seçili Talepleri Reddet';

  @override
  String get prescriptionCore_actionRejectAfterApproveTitle =>
      'Seçili Talepleri Reddet';

  @override
  String get tableCore_roleNameColumn => 'Rol Adı';

  @override
  String get tableCore_warningSubjectColumn => 'Uyarı Konusu';

  @override
  String get tableCore_warningTextColumn => 'Uyarı Metni';

  @override
  String get tableCore_warehouseCodeColumn => 'Depo Kodu';

  @override
  String get tableCore_warehouseNameColumn => 'Depo Adı';

  @override
  String get tableCore_warehouseManagerColumn => 'Depo Sorumlusu';

  @override
  String get tableCore_dosageFormBranchColumn => 'Branş Adı';

  @override
  String get tableCore_firmIdColumn => 'Id';

  @override
  String get tableCore_firmNameColumn => 'Adı';

  @override
  String get tableCore_firmTypeColumn => 'Firma Tipi';

  @override
  String get tableCore_firmTaxOfficeColumn => 'Vergi Dairesi';

  @override
  String get tableCore_firmTaxNoColumn => 'Vergi No';

  @override
  String get tableCore_kitNameColumn => 'Kit Adı';

  @override
  String get tableCore_kitContentMaterialNameColumn => 'Malzeme Adı';

  @override
  String get tableCore_kitContentPieceColumn => 'Adet';

  @override
  String get tableCore_drugTypeColumn => 'İlaç Tipi';

  @override
  String get tableCore_drugClassColumn => 'İlaç Sınıfı';

  @override
  String get tableCore_materialTypeColumn => 'Malzeme Tipi';

  @override
  String get tableCore_stationCodeColumn => 'İstasyon Kodu';

  @override
  String get tableCore_stationNameColumn => 'İstasyon Adı';

  @override
  String get tableCore_stationDrugWarehouseColumn => 'İlaç Depo';

  @override
  String get tableCore_stationDrugColumn => 'İlaç';

  @override
  String get tableCore_stationConsumableWarehouseColumn => 'Tıbbi Sarf Depo';

  @override
  String get tableCore_stationConsumableColumn => 'Tıbbi Sarf';

  @override
  String get tableCore_stationWorkingTypeColumn => 'Çalışma Tipi';

  @override
  String get tableCore_hospitalizationProtocolNoColumn => 'Protokol No';

  @override
  String get tableCore_hospitalizationNationalIdColumn => 'T.C No';

  @override
  String get tableCore_hospitalizationPatientColumn => 'Hasta';

  @override
  String get tableCore_patientRowNationalIdColumn => 'Hasta T.C';

  @override
  String get tableCore_patientRowFullNameColumn => 'Ad Soyad';

  @override
  String get tableCore_inconsistencyCabinColumn => 'Kabin';

  @override
  String get tableCore_inconsistencyRowNoColumn => 'Sıra No';

  @override
  String get tableCore_inconsistencyCellColumn => 'Göz';

  @override
  String get tableCore_inconsistencyExpectedColumn => 'Olması Gereken';

  @override
  String get tableCore_inconsistencyCountedColumn => 'Sayım Miktarı';

  @override
  String get tableCore_stockTransactionDateColumn => 'Tarih';

  @override
  String get tableCore_stockTransactionBarcodeColumn => 'Barkod';

  @override
  String get tableCore_stockTransactionTypeColumn => 'İşlem Tipi';

  @override
  String get tableCore_stockTransactionQuantityColumn => 'Miktar';

  @override
  String get tableCore_stockTransactionPreviousQuantityColumn =>
      'Hareket Öncesi Miktar';

  @override
  String get tableCore_stockTransactionActorColumn => 'İşlemi Yapan';

  @override
  String get tableCore_serviceColumn => 'Servis';

  @override
  String get tableCore_admissionDateColumn => 'Yatış Tarihi';

  @override
  String get tableCore_dischargeDateColumn => 'Çıkış Tarihi';

  @override
  String get tableCore_materialColumn => 'Malzeme';

  @override
  String get tableCore_prescriptionMedicineColumn => 'İlaç';

  @override
  String get tableCore_prescriptionDoseColumn => 'Doz';

  @override
  String get tableCore_prescriptionApplicationUserColumn => 'Uygulayan';

  @override
  String get tableCore_prescriptionAppliedQuantityColumn => 'Uygulanan Miktar';

  @override
  String get tableCore_prescriptionApplicationDateColumn => 'Uygulama Tarihi';

  @override
  String get tableCore_prescriptionReturnUserColumn => 'İade Eden';

  @override
  String get tableCore_prescriptionReturnQuantityColumn => 'İade Edilen Miktar';

  @override
  String get tableCore_prescriptionReturnDateColumn => 'İade Tarihi';

  @override
  String get tableCore_prescriptionWastageUserColumn => 'Fire Eden';

  @override
  String get tableCore_prescriptionWastageDateColumn => 'Fire Tarihi';

  @override
  String get tableCore_prescriptionDestructionUserColumn => 'İmha Eden';

  @override
  String get tableCore_prescriptionDestructionDateColumn => 'İmha Tarihi';

  @override
  String get tableCore_prescriptionStatusColumn => 'Durum';

  @override
  String get enumCore_statusActive => 'Aktif';

  @override
  String get enumCore_statusPassive => 'Pasif';

  @override
  String get enumCore_warehouseTypeMain => 'Ana Depo';

  @override
  String get enumCore_firmTypeSupplier => 'Tedarikçi';

  @override
  String get enumCore_firmTypeCustomer => 'Müşteri';

  @override
  String get enumCore_firmTypeManufacturer => 'Üretici';

  @override
  String get enumCore_warningSubjectUntimelyPurchase => 'Zamansız Alım';

  @override
  String get enumCore_warningSubjectWaste => 'Fire';

  @override
  String get enumCore_warningSubjectInconsistencyResolution =>
      'Tutarsızlık Çözümü';

  @override
  String get enumCore_warningSubjectDisposal => 'İmha';

  @override
  String get enumCore_stockTxKindRefill => 'Malzeme Dolum';

  @override
  String get enumCore_stockTxKindStockOut => 'Stok Çıkışı';

  @override
  String get enumCore_stockTxKindConsistent => 'Tutarlı Sayım';

  @override
  String get enumCore_stockTxKindReturnInward => 'İade Alım';

  @override
  String get enumCore_stockTxKindWastage => 'Fire';

  @override
  String get enumCore_stockTxTypeIn => 'Stok Giriş';

  @override
  String get enumCore_stockTxTypeOut => 'Stok Çıkış';

  @override
  String get enumCore_stockTxKindReturn => 'Malzeme İade';

  @override
  String get enumCore_stockTxKindExcess => 'Sayım Fazlası';

  @override
  String get enumCore_stockTxKindShortage => 'Sayım Eksiği';

  @override
  String get enumCore_stockTxKindPurchase => 'Malzeme Alım';

  @override
  String get enumCore_stockTxKindUnload => 'Malzeme Boşaltma';

  @override
  String get enumCore_countTypeNone => 'Sayım Yok';

  @override
  String get enumCore_countTypeNormal => 'Normal Sayım';

  @override
  String get enumCore_countTypeBlind => 'Kör Sayım';

  @override
  String get enumCore_returnTypeToOrigin => 'Yerine İade';

  @override
  String get enumCore_returnTypeToDrawer => 'Çekmeceye İade';

  @override
  String get enumCore_returnTypeToReturnBox => 'İade Kutusuna İade';

  @override
  String get enumCore_returnTypeToPharmacy => 'Eczaneye İade';

  @override
  String get enumCore_requestTypeNormal => 'Normal İstem';

  @override
  String get enumCore_requestTypeUrgent => 'Acil İstem';

  @override
  String get enumCore_purchaseTypeBoth => 'Her İkisi de';

  @override
  String get enumCore_prescriptionTypeWhite => 'Beyaz Reçete';

  @override
  String get enumCore_prescriptionTypeSerumWhite => 'Serum(Beyaz Reçete)';

  @override
  String get enumCore_prescriptionTypeRed => 'Kırmızı Reçete';

  @override
  String get enumCore_prescriptionTypeGreen => 'Yeşil Reçete';

  @override
  String get enumCore_prescriptionTypeOrange => 'Turuncu Reçete';

  @override
  String get enumCore_prescriptionTypePurple => 'Mor Reçete';

  @override
  String get enumCore_refillListStatusToCollect => 'Toplanacak';

  @override
  String get enumCore_refillListStatusCollected => 'Toplandı';

  @override
  String get enumCore_refillListStatusSent => 'Gönderildi';

  @override
  String get enumCore_fillingTypeMinimum => 'Minimum';

  @override
  String get enumCore_fillingTypeCritical => 'Kritik';

  @override
  String get enumCore_fillingTypeMaximum => 'Maksimum';

  @override
  String get enumCore_patientFilterOrderTimeReached => 'Order Saati Gelenler';

  @override
  String get enumCore_patientFilterAll => 'Tüm Hastalar';

  @override
  String get enumCore_patientFilterTimeNotReached => 'Zamanı Gelmemiş';

  @override
  String get enumCore_patientFilterTimePassed => 'Zamanı Geçmiş';

  @override
  String get enumCore_patientFilterReturnable => 'İade Yapılabilir';

  @override
  String get enumCore_patientFilterWasteDisposable => 'Fire/İmha Girilebilir';

  @override
  String get enumCore_cabinTypeStandard => 'Master Kabin';

  @override
  String get enumCore_cabinTypeCloset => 'Dolap';

  @override
  String get enumCore_cabinTypeFridge => 'Buzdolabı';

  @override
  String get enumCore_cabinTypeOpenCloset => 'Açık Dolap';

  @override
  String get enumCore_cabinTypeMobile => 'Mobil Kabin';

  @override
  String get enumCore_cabinTypeExternalReturn => 'Harici İade Kabini';

  @override
  String get enumCore_cabinTypeOpen => 'Açık Kabin';

  @override
  String get enumCore_cabinTypeSerum => 'Serum Kabini';

  @override
  String get enumCore_cabinOpModeAssignDrug => 'İlaç Atama';

  @override
  String get enumCore_cabinOpModeRefill => 'İlaç Dolum';

  @override
  String get enumCore_cabinOpModeCensus => 'İlaç Sayım';

  @override
  String get enumCore_cabinOpModeIntake => 'İlaç Alım';

  @override
  String get enumCore_cabinOpModeFault => 'Çekmece Arıza';

  @override
  String get enumCore_cabinOpModeUnload => 'İlaç Boşaltma';

  @override
  String get enumCore_cabinInventoryTypeRefillOperationLabel => 'Dolum';

  @override
  String get enumCore_cabinInventoryTypeIntakeOperationLabel => 'Alım';

  @override
  String get enumCore_cabinInventoryTypeUnloadOperationLabel => 'Boşaltma';

  @override
  String get enumCore_cabinInventoryTypeCensusOperationLabel => 'Sayım';

  @override
  String get enumCore_cabinInventoryTypeDisposalOperationLabel => 'İmha';

  @override
  String get enumCore_cabinInventoryTypeRefillListOperationLabel => 'Dolum';

  @override
  String get enumCore_cabinInventoryTypeRefillTitle => 'İlaç Dolum';

  @override
  String get enumCore_cabinInventoryTypeRefillListTitle => 'İlaç Dolum Listesi';

  @override
  String get enumCore_cabinInventoryTypeCensusTitle => 'İlaç Sayım';

  @override
  String get enumCore_cabinInventoryTypeDisposalTitle => 'İlaç İmha';

  @override
  String get enumCore_cabinInventoryTypeUnloadTitle => 'İlaç Boşaltma';

  @override
  String get enumCore_cabinInventoryTypeIntakeTitle => 'İlaç Alım';

  @override
  String get enumCore_cabinInventoryTypeRefillButtonText => 'Dolum Yap';

  @override
  String get enumCore_cabinInventoryTypeRefillListButtonText => 'Dolum Yap';

  @override
  String get enumCore_cabinInventoryTypeCensusButtonText => 'Sayım Yap';

  @override
  String get enumCore_cabinInventoryTypeDisposalButtonText => 'İmha Et';

  @override
  String get enumCore_cabinInventoryTypeUnloadButtonText => 'İlaç Boşalt';

  @override
  String get enumCore_cabinInventoryTypeIntakeButtonText => 'İlaç Al';

  @override
  String get enumCore_cabinInventoryTypeRefillFieldText => 'Dolum Miktarı';

  @override
  String get enumCore_cabinInventoryTypeRefillListFieldText => 'Dolum Miktarı';

  @override
  String get enumCore_cabinInventoryTypeCensusFieldText => 'Sayım Miktarı';

  @override
  String get enumCore_cabinInventoryTypeDisposalFieldText => 'İmha Miktarı';

  @override
  String get enumCore_cabinInventoryTypeUnloadFieldText => 'Boşaltım Miktarı';

  @override
  String get enumCore_cabinInventoryTypeIntakeFieldText => 'Alım Miktarı';

  @override
  String get enumCore_cabinInventoryTypeRefillSequentialText =>
      'Otomatik Dolumu Başlat';

  @override
  String get enumCore_cabinInventoryTypeRefillListSequentialText =>
      'Otomatik Dolumu Başlat';

  @override
  String get enumCore_cabinInventoryTypeCensusSequentialText =>
      'Otomatik Sayımı Başlat';

  @override
  String get enumCore_cabinInventoryTypeDisposalSequentialText =>
      'Otomatik İmhayı Başlat';

  @override
  String get enumCore_cabinInventoryTypeUnloadSequentialText =>
      'Otomatik Boşaltmayı Başlat';

  @override
  String get enumCore_cabinInventoryTypeIntakeSequentialText =>
      'Otomatik Alım Başlat';

  @override
  String get enumCore_permissionCan => 'Yapabilir';

  @override
  String get enumCore_permissionCannot => 'Yapamaz';

  @override
  String get enumCore_genderFemale => 'Kadın';

  @override
  String get enumCore_genderMale => 'Erkek';

  @override
  String get enumCore_genderUnknown => 'Bilinmiyor';

  @override
  String get enumCore_userTypeUnlimited => 'Süresiz';

  @override
  String get enumCore_appModeAdmin => 'Admin';

  @override
  String get enumCore_appModeManager => 'Yönetim';

  @override
  String get enumCore_appModeStation => 'İstasyon';

  @override
  String get enumCore_userRoleManager => 'Yönetici';

  @override
  String get enumCore_userRoleStationOperator => 'İstasyon Operatörü';

  @override
  String get enumCore_parityBitNone => 'Hiçbiri';

  @override
  String get enumCore_parityBitEven => 'Çift';

  @override
  String get enumCore_parityBitOdd => 'Tek';

  @override
  String get enumCore_cabinColorBlue => 'Mavi';

  @override
  String get enumCore_cabinColorTurquoise => 'Turkuaz';

  @override
  String get enumCore_cabinColorGreen => 'Yeşil';

  @override
  String get enumCore_cabinColorRed => 'Kırmızı';

  @override
  String get enumCore_cabinColorOrange => 'Turuncu';

  @override
  String get enumCore_cabinColorPurple => 'Mor';

  @override
  String get enumCore_cabinColorGray => 'Gri';

  @override
  String get enumCore_cabinColorBlack => 'Siyah';

  @override
  String get enumCore_cabinColorWhite => 'Beyaz';

  @override
  String get common_confirmButton => 'Onayla';

  @override
  String get common_viewInPreparationMessage => 'Görünüm hazırlanıyor...';

  @override
  String get common_warningTitle => 'Uyarı!';

  @override
  String get dialog_deleteTitle => 'Silme İşlemi';

  @override
  String get dialog_deleteDefaultMessage =>
      'Bu öğeyi silmek istediğinizden emin misiniz?';

  @override
  String dialog_deleteItemMessage(String itemName) {
    return '\"$itemName\" öğesini silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.';
  }

  @override
  String get dialog_exitConfirmButtonText => 'Çıkış Yap';

  @override
  String get dialog_exitConfirmMessage =>
      'Kaydetmediğiniz değişiklikler var. Çıkış yaparsanız bu değişiklikler silinecektir.';

  @override
  String get dialog_exitConfirmMessageNoChanges =>
      'Sayfadan çıkmak istediğinizden emin misiniz?';

  @override
  String get dialog_confirmDiscardButton => 'Evet, İptal Et';

  @override
  String get dialog_logoutTitle => 'Çıkış Yap';

  @override
  String get dialog_logoutMessage =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';

  @override
  String get dialog_exitTitle => 'Çıkış';

  @override
  String get dialog_exitMessage =>
      'Kaydetmediğiniz değişiklikler kaybolabilir.';

  @override
  String get dialog_saveTitle => 'Kaydet';

  @override
  String get dialog_saveMessage => 'Değişiklikleri kaydetmek istiyor musunuz?';

  @override
  String get dialog_discardTitle => 'İptal Et';

  @override
  String get dialog_discardMessage => 'Yapılan değişiklikler geri alınacak.';

  @override
  String get dialog_customConfirmTitle => 'Onay';

  @override
  String get dialog_customConfirmMessage => 'İşlemi onaylıyor musunuz?';

  @override
  String get table_noDataTitle => 'Veri bulunamadı';

  @override
  String get table_defaultPdfReportTitle => 'Tablo Raporu';

  @override
  String get table_actionsColumnHeader => 'İşlemler';

  @override
  String get table_activeFiltersLabel => 'Filtreler:';

  @override
  String get common_clearButton => 'Temizle';

  @override
  String table_selectedCountLabel(int count) {
    return '$count seçili';
  }

  @override
  String table_columnSelectedCountLabel(String column, int count) {
    return '$column: $count seçili';
  }

  @override
  String get table_columnFallbackLabel => 'Sütun';

  @override
  String table_selectAllCountLabel(int count) {
    return 'Tümünü Seç ($count)';
  }

  @override
  String get table_noResultsShort => 'Sonuç yok';

  @override
  String table_applyCountLabel(int count) {
    return 'Uygula ($count)';
  }

  @override
  String get table_applyButton => 'Uygula';

  @override
  String table_recordCountFiltered(int filtered, int total) {
    return '$filtered / $total kayıt';
  }

  @override
  String table_recordCount(int total) {
    return '$total kayıt';
  }

  @override
  String table_totalRecordCount(int total) {
    return 'Toplam $total kayıt';
  }

  @override
  String get table_prevPageTooltip => 'Önceki sayfa';

  @override
  String get table_nextPageTooltip => 'Sonraki sayfa';

  @override
  String get table_exportSelectedTooltip => 'Seçilenleri Aktar';

  @override
  String get table_categoriesDefaultTitle => 'Kategoriler';

  @override
  String table_columnFallback(int index) {
    return 'Sütun $index';
  }

  @override
  String get dateFilter_yesterday => 'Dün';

  @override
  String get dateFilter_lastWeek => 'Son 1 Hafta';

  @override
  String get dateFilter_thisMonth => 'Bu Ay';

  @override
  String get dateFilter_last30Days => 'Son 30 Gün';

  @override
  String get dateFilter_customRange => 'Özel Aralık Belirle...';

  @override
  String get dateFilter_clearFilter => 'Filtreyi Temizle';

  @override
  String get dateFilter_noFilter => 'Filtre Yok';

  @override
  String get dateFilter_selectedRange => 'Seçili Aralık';

  @override
  String get dateFilter_selectRangeTitle => 'Tarih Aralığı Seçin';

  @override
  String get dateFilter_startDate => 'Başlangıç';

  @override
  String get dateFilter_endDate => 'Bitiş';

  @override
  String get common_selectPlaceholder => 'Seçiniz';

  @override
  String selectionDialog_selectedCount(int count) {
    return '$count öğe seçildi';
  }

  @override
  String get selectionDialog_noSelection => 'Seçim yapılmadı';

  @override
  String get selectionDialog_confirmButton => 'Seç';

  @override
  String get dateField_placeholder => 'Tarih seçin';

  @override
  String timeField_helpTextWithDay(String day) {
    return '$day için saat seçin';
  }

  @override
  String get timeField_helpText => 'Saat seçin';

  @override
  String get timeField_placeholder => 'Saat seçin';

  @override
  String doseStepper_manualEntryTitle(String unit) {
    return '$unit Miktarı Giriniz';
  }

  @override
  String get numpad_defaultTitle => 'Miktar Giriniz';

  @override
  String get keyboard_closeButton => 'Kapat';

  @override
  String get keyboard_enterLabel => '↵ Tamam';

  @override
  String get keyboard_dashKeyLabel => '— Çizgi';

  @override
  String get keyboard_periodKeyLabel => '. Nokta';

  @override
  String get keyboard_shiftLabel => '⇧ Büyük';

  @override
  String get keyboard_spaceLabel => 'BOŞLUK';

  @override
  String get staleBanner_justNow => 'az önce';

  @override
  String staleBanner_minutesAgo(int minutes) {
    return '$minutes dk önce';
  }

  @override
  String staleBanner_hoursAgo(int hours) {
    return '$hours sa önce';
  }

  @override
  String get staleBanner_dataStaleMessage => 'Veriler güncel değil. ';

  @override
  String get staleBanner_dataUnavailableMessage =>
      'Güncel veriye ulaşılamıyor. İşlem yapılamaz. ';

  @override
  String staleBanner_lastUpdatedLabel(String time) {
    return 'Son güncelleme: $time';
  }

  @override
  String get staleBanner_blockedBadge => 'Engelli';

  @override
  String timeChip_today(String time) {
    return 'Bugün $time';
  }

  @override
  String timeChip_tomorrow(String time) {
    return 'Yarın $time';
  }

  @override
  String get cabin_lockButton => 'Kilitle';

  @override
  String get cabin_criticalStockLabel => 'Kritik Stok';

  @override
  String get cabin_criticalStockSubLabel => 'yenileme gerekli';

  @override
  String get cabin_legendFillNormal => 'Normal stok';

  @override
  String get cabin_legendFillNeeded => 'Dolum gerekiyor';

  @override
  String get cabin_legendFillUrgent => 'Acil dolum';

  @override
  String get cabin_serumTypeLabel => 'Serum';

  @override
  String get cabin_unitDoseTypeLabel => 'Birim Doz';

  @override
  String get refund_showCompletedTooltip => 'Tamamlananları Göster';

  @override
  String get refund_showIncompleteTooltip => 'Tamamlanmayanları Göster';

  @override
  String get refund_takeTooltip => 'İade Al';

  @override
  String get refund_deleteDialog_title => 'Açıklama';

  @override
  String get refund_deleteDialog_saveButton => 'Sil';

  @override
  String get refund_deleteDialog_reasonLabel => 'Silme nedeninizi açıklayınız';

  @override
  String get refund_pdf_title => 'Eczane İade Raporu';

  @override
  String refund_pdf_station(String station) {
    return 'İstasyon: $station';
  }

  @override
  String refund_pdf_dateRange(String startDate, String endDate) {
    return 'Tarih: $startDate - $endDate';
  }

  @override
  String get dashboard_sensor_title => 'Sensörler';

  @override
  String get dashboard_sensor_temperature => 'Sıcaklık';

  @override
  String get dashboard_sensor_humidity => 'Nem';

  @override
  String get dashboard_sensor_battery => 'Akü';

  @override
  String get dashboard_climate_title => 'Ortam Koşulları';

  @override
  String get dashboard_sensor_outOfRange => 'Aralık dışı';

  @override
  String get dashboard_sensor_paused => 'Duraklatıldı';

  @override
  String get dashboard_upcomingTreatmentsPanelTitle => 'Yaklaşan Tedaviler';

  @override
  String dashboard_upcomingTreatmentsCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planlı',
      one: '$count planlı',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsEmptyTitle => 'Planlanmış tedavi yok';

  @override
  String get dashboard_upcomingTreatmentsOverdueStatus => 'gecikti';

  @override
  String get dashboard_drugActivityPanelTitle => 'İlaç Aktiviteleri';

  @override
  String get dashboard_drugActivityEmptyTitle => 'Henüz hareket yok';

  @override
  String get dashboard_activitiesLoadError => 'İlaç aktiviteleri yüklenemedi';

  @override
  String get dashboard_telemetryPanelTitle => 'Kabin Ortamı';

  @override
  String get dashboard_telemetryPausedStatus => 'Duraklatıldı';

  @override
  String get dashboard_kpiActivePatientsLabel => 'Aktif Hasta';

  @override
  String get dashboard_kpiCompletedOperationsLabel => 'Tamamlanan İşlem';

  @override
  String get dashboard_kpiPendingPrescriptionsLabel => 'Bekleyen Reçete';

  @override
  String get dashboard_kpiCriticalAlertsLabel => 'Kritik Uyarı';

  @override
  String get common_seeAllButton => 'Tümünü Gör';

  @override
  String get common_unknownFallback => 'Bilinmiyor';

  @override
  String get common_justNowStatus => 'az önce';

  @override
  String common_minutesAgoStatus(int count) {
    return '$count dk önce';
  }

  @override
  String common_hoursAgoStatus(int count) {
    return '$count sa önce';
  }

  @override
  String common_daysAgoStatus(int count) {
    return '$count gün önce';
  }

  @override
  String common_minutesRemainingStatus(int count) {
    return '$count dk';
  }

  @override
  String common_hoursRemainingStatus(int count) {
    return '$count sa';
  }

  @override
  String common_daysRemainingStatus(int count) {
    return '$count gün';
  }

  @override
  String get refill_hint_selectSlots =>
      'Doldurulacak gözleri seçin. Az stoklu gözler işaretlenmiştir.';

  @override
  String get refill_title_fillCells => 'Gözleri Doldurun';

  @override
  String get refill_hint_miadRequired => 'Son kullanma tarihi gerekli';

  @override
  String get refill_status_openingTitle => 'Çekmece açılıyor…';

  @override
  String get refill_status_openingBody =>
      'Lütfen bekleyin, fiziksel çekmece açılıyor.';

  @override
  String get refill_status_waitingPullTitle => 'Çekmeceyi çekin';

  @override
  String get refill_status_waitingPullBody =>
      'Kilit açıldı. Devam etmek için çekmeceyi çekin.';

  @override
  String get refill_status_openingLidTitle => 'Göz açılıyor…';

  @override
  String get refill_status_openingLidBody =>
      'Lütfen bekleyin, göz kapağı açılıyor.';

  @override
  String get refill_status_stockOk => 'Stok yeterli';

  @override
  String get refill_status_stockLow => 'Az';

  @override
  String get refill_status_stockCritical => 'Kritik';

  @override
  String get refill_stop_confirmTitle => 'Dolum durdurulsun mu?';

  @override
  String get refill_stop_confirmMessage =>
      'Durdurursanız açık çekmece kilitlenir ve bu dolum \"yarım tamamlandı\" olarak işaretlenir. Girilen sayım ve dolum bilgileri korunur, ancak işleme kaldığı yerden devam edilemez — yeni bir dolum başlatmanız gerekir.';

  @override
  String get refill_stop_confirmYes => 'Evet, Durdur';

  @override
  String get enumCore_prescriptionMovementPendingApprovalLabel =>
      'Onay Bekliyor';

  @override
  String get enumCore_prescriptionMovementPurchasePendingLabel =>
      'Alım Bekliyor';

  @override
  String get enumCore_prescriptionMovementAppliedLabel => 'Uygulandı';

  @override
  String get enumCore_prescriptionMovementReturnedLabel => 'İade Edildi';

  @override
  String get enumCore_prescriptionMovementWastagedLabel => 'Fire Edildi';

  @override
  String get enumCore_prescriptionMovementDestructedLabel => 'İmha Edildi';

  @override
  String get enumCore_prescriptionMovementCancelledLabel => 'İptal Edildi';

  @override
  String get enumCore_prescriptionMovementRejectedLabel => 'Reddedildi';

  @override
  String get enumCore_prescriptionMovementFilledWaitingLabel =>
      'Dolum Bekliyor';

  @override
  String get enumCore_prescriptionMovementReturnPendingLabel =>
      'İade Onayı Bekliyor';

  @override
  String get enumCore_prescriptionMovementUnloadedLabel => 'Boşaltıldı';

  @override
  String get enumCore_prescriptionMovementShortageReportedLabel =>
      'Eksik Bildirildi';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingLabel =>
      'İkmal Bekliyor';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActorLabel =>
      'Oluşturan';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActorLabel =>
      'Dolum Yapan';

  @override
  String get enumCore_prescriptionMovementAppliedActorLabel => 'Uygulayan';

  @override
  String get enumCore_prescriptionMovementReturnedActorLabel => 'İade Eden';

  @override
  String get enumCore_prescriptionMovementWastagedActorLabel => 'Fire Eden';

  @override
  String get enumCore_prescriptionMovementDestructedActorLabel => 'İmha Eden';

  @override
  String get enumCore_prescriptionMovementCancelledActorLabel => 'İptal Eden';

  @override
  String get enumCore_prescriptionMovementRejectedActorLabel => 'Reddeden';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActorLabel =>
      'Onaylayan';

  @override
  String get enumCore_prescriptionMovementReturnPendingActorLabel =>
      'İade Talep Eden';

  @override
  String get enumCore_prescriptionMovementUnloadedActorLabel => 'Boşaltan';

  @override
  String get enumCore_prescriptionMovementShortageReportedActorLabel =>
      'Eksik Bildiren';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActorLabel =>
      'İkmal Onaylayan';

  @override
  String get enumCore_prescriptionMovementRedirectedLabel => 'Yönlendirildi';

  @override
  String get enumCore_prescriptionMovementRedirectedActorLabel => 'Yönlendiren';

  @override
  String get enumCore_prescriptionMovementRedirectedActionLabel =>
      'Yönlendirdi';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActionLabel =>
      'Oluşturuldu';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActionLabel =>
      'Dolum Yapıldı';

  @override
  String get enumCore_prescriptionMovementAppliedActionLabel => 'Uygulandı';

  @override
  String get enumCore_prescriptionMovementReturnedActionLabel => 'İade Edildi';

  @override
  String get enumCore_prescriptionMovementWastagedActionLabel => 'Fire Edildi';

  @override
  String get enumCore_prescriptionMovementDestructedActionLabel =>
      'İmha Edildi';

  @override
  String get enumCore_prescriptionMovementCancelledActionLabel =>
      'İptal Edildi';

  @override
  String get enumCore_prescriptionMovementRejectedActionLabel => 'Reddedildi';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActionLabel =>
      'Onaylandı';

  @override
  String get enumCore_prescriptionMovementReturnPendingActionLabel =>
      'İade Talep Edildi';

  @override
  String get enumCore_prescriptionMovementUnloadedActionLabel => 'Boşaltıldı';

  @override
  String get enumCore_prescriptionMovementShortageReportedActionLabel =>
      'Eksik Bildirildi';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActionLabel =>
      'İkmal Onaylandı';

  @override
  String get userAuth_table_firstNameColumn => 'Adı';

  @override
  String get userAuth_table_lastNameColumn => 'Soyadı';

  @override
  String get userAuth_table_occupationTypeColumn => 'Meslek Tipi';

  @override
  String get userAuth_table_expiryDateColumn => 'Son Geçerlilik Tarihi';

  @override
  String get userAuth_table_remainingDaysColumn => 'Kalan Gün';

  @override
  String get userAuth_table_statusColumn => 'Durumu';

  @override
  String get medicine_table_barcodeColumn => 'Barkod';

  @override
  String get medicine_table_atcCodeColumn => 'ATC Kodu';

  @override
  String get medicine_table_nameColumn => 'Adı';

  @override
  String get medicine_table_materialTypeColumn => 'Malzeme Türü';

  @override
  String get medicine_table_prescriptionTypeColumn => 'Reçete Tipi';

  @override
  String get medicine_table_countTypeColumn => 'Sayım Tipi';

  @override
  String get medicine_table_purchaseTypeColumn => 'Alım Şekli';

  @override
  String get medicine_table_returnTypeColumn => 'İade Şekli';

  @override
  String get medicine_table_statusColumn => 'Aktif';

  @override
  String get enumCore_medicineTypeDrug => 'İlaç';

  @override
  String get enumCore_medicineTypeConsumable => 'Tıbbi Sarf';

  @override
  String get refund_table_patientCodeColumn => 'Hasta Kodu';

  @override
  String get refund_table_patientColumn => 'Hasta';

  @override
  String get refund_table_userColumn => 'Kullanıcı';

  @override
  String get refund_table_medicineColumn => 'Malzeme';

  @override
  String get refund_table_quantityColumn => 'Miktar';

  @override
  String get refund_table_dateColumn => 'Tarih';

  @override
  String get refund_table_approvedUserColumn => 'İade Alan Kullanıcı';

  @override
  String get refund_table_approvedDateColumn => 'İade Alma Tarihi';

  @override
  String get refund_table_descriptionColumn => 'Açıklama';

  @override
  String get authorization_table_userColumn => 'Kullanıcı';

  @override
  String get authorization_table_roleColumn => 'Rol';

  @override
  String get authorization_table_encryptedLoginColumn => 'Şifreli Giriş';

  @override
  String get authorization_table_isDeletedColumn => 'Silinmiş';

  @override
  String get authorization_table_extraAuthCountColumn => 'Yetki Fazlası';

  @override
  String get authorization_summary_viewDetailsTooltip => 'Detayları Gör';

  @override
  String get authorization_summary_dialogTitle => 'Kullanıcı Yetki Özeti';

  @override
  String get authorization_summary_roleMenusTitle =>
      'Rol Bazlı Yetkili Menüler';

  @override
  String get authorization_summary_roleMenusEmptyLabel =>
      'Rol bazlı yetki bulunmuyor';

  @override
  String get authorization_summary_extraMenusTitle => 'Yetki Dışı Menüler';

  @override
  String get authorization_summary_extraMenusEmptyLabel =>
      'Ek yetki bulunmuyor';

  @override
  String get cabinTemperature_table_dateColumn => 'Tarih';

  @override
  String get cabinTemperature_table_cabinColumn => 'Kabin';

  @override
  String get cabinTemperature_table_insideTempColumn => 'İç Sıcaklık';

  @override
  String get cabinTemperature_table_outsideTempColumn => 'Dış Sıcaklık';

  @override
  String get cabinTemperature_table_humidityColumn => 'Nem';

  @override
  String get cabinTemperature_action_showOutOfRange => 'Sınırı Aşanları Göster';

  @override
  String get cabinTemperature_action_showAll => 'Tümünü Göster';

  @override
  String get cabinTemperature_currentStationNotFoundError =>
      'Aktif istasyon bulunamadı';

  @override
  String get expiredItems_table_barcodeColumn => 'Barkod';

  @override
  String get expiredItems_table_medicineColumn => 'Malzeme';

  @override
  String get expiredItems_table_cabinColumn => 'Kabin';

  @override
  String get expiredItems_table_locationColumn => 'Konum';

  @override
  String get expiredItems_table_minQuantityColumn => 'Minimum';

  @override
  String get expiredItems_table_maxQuantityColumn => 'Maksimum';

  @override
  String get expiredItems_table_criticalQuantityColumn => 'Kritik';

  @override
  String get expiredItems_table_quantityColumn => 'Miktar';

  @override
  String get expiredItems_table_expiryDateColumn => 'S.K.T';

  @override
  String get expiredItems_table_remainingDaysColumn => 'Kalan Gün';

  @override
  String get hospitalStock_table_serviceColumn => 'Servis';

  @override
  String get hospitalStock_table_codeColumn => 'Kod';

  @override
  String get hospitalStock_table_medicineColumn => 'Malzeme';

  @override
  String get hospitalStock_table_quantityColumn => 'Miktar';

  @override
  String get patientInventory_table_doctorColumn => 'Doktor';

  @override
  String get patientInventory_table_departmentColumn => 'Bölüm';

  @override
  String get patientInventory_table_barcodeColumn => 'Barkod';

  @override
  String get patientInventory_table_medicineColumn => 'Malzeme';

  @override
  String get patientInventory_table_requestedQuantityColumn => 'İstenen Miktar';

  @override
  String get patientInventory_table_processedQuantityColumn => 'İşlem Miktarı';

  @override
  String get patientInventory_table_requestDateColumn => 'İstem Tarihi';

  @override
  String get patientInventory_table_processDateColumn => 'İşlem Tarihi';

  @override
  String get patientInventory_table_movementColumn => 'İşlem';

  @override
  String patientInventory_pdf_title(String patientName) {
    return '$patientName adlı hastaya ait Hasta Envanter Listesi';
  }

  @override
  String patientInventory_pdf_patientCode(Object code) {
    return 'Hasta Kodu: $code';
  }

  @override
  String patientInventory_pdf_service(String name) {
    return 'Servis: $name';
  }

  @override
  String patientInventory_pdf_bed(String name) {
    return 'Yatak: $name';
  }

  @override
  String patientInventory_pdf_reportDate(String date) {
    return 'Rapor Tarihi: $date';
  }

  @override
  String get service_table_nameColumn => 'Servis Adı';

  @override
  String get service_table_branchColumn => 'Branş';

  @override
  String get service_table_managerColumn => 'Servis Sorumlusu';

  @override
  String get service_table_statusColumn => 'Durum';

  @override
  String get unappliedPrescription_table_serviceColumn => 'Servis';

  @override
  String get unappliedPrescription_table_roomColumn => 'Oda';

  @override
  String get unappliedPrescription_table_bedColumn => 'Yatak';

  @override
  String get unappliedPrescription_table_patientCodeColumn => 'Hasta Kodu';

  @override
  String get unappliedPrescription_table_patientColumn => 'Hasta';

  @override
  String get unappliedPrescription_table_hospitalizationCodeColumn =>
      'Yatış Kodu';

  @override
  String get unappliedPrescription_table_admissionDateColumn => 'Yatış Tarihi';

  @override
  String get unappliedPrescription_table_pendingCountColumn => 'Bekleyen Adet';

  @override
  String get drugActivity_table_dateColumn => 'Tarih';

  @override
  String get drugActivity_table_timeColumn => 'Saat';

  @override
  String get drugActivity_table_patientColumn => 'Hasta';

  @override
  String get drugActivity_table_userColumn => 'Kullanıcı';

  @override
  String get drugActivity_table_medicineColumn => 'Malzeme';

  @override
  String get drugActivity_table_quantityColumn => 'Miktar';

  @override
  String get drugActivity_table_movementColumn => 'Hareket';

  @override
  String get rfid_notConnectedError => 'RFID okuyucuya bağlı değil';

  @override
  String rfid_inventoryStartFailedError(String detail) {
    return 'RFID tarama başlatılamadı: $detail';
  }

  @override
  String rfid_inventoryStreamError(String detail) {
    return 'RFID tarama stream hatası: $detail';
  }

  @override
  String get mobileDrawer_cabinConnectionErrorMessage =>
      'Kabin ile iletişim kurulamadı. Lütfen tekrar deneyin veya yetkili personeli bilgilendirin.';

  @override
  String get settingsView_title => 'Ayarlar';

  @override
  String get settingsView_subtitle => 'SİSTEM YAPILANDIRMASI';

  @override
  String get settingsView_generalNav => 'Genel';

  @override
  String get settingsView_appearanceNav => 'Görünüm';

  @override
  String get settingsView_cabinNav => 'Kabin Ayarları';

  @override
  String get settingsView_prescriptionNav => 'Reçete Ayarları';

  @override
  String get settingsView_developerNav => 'Geliştirici';

  @override
  String get settingsView_debugNav => 'Debug';

  @override
  String get settingsView_sectionComingSoon =>
      'Bu bölüm için içerik yakında eklenecek.';

  @override
  String get census_mode_allCabin => 'Tüm Kabin';

  @override
  String get census_mode_byDrawer => 'Çekmece Bazlı';

  @override
  String get census_mode_byMedicine => 'İlaç Bazlı';

  @override
  String get census_hint_noMedicines => 'Sayılacak ilaç bulunamadı';

  @override
  String census_label_queueProgress(Object current, Object total) {
    return '$current / $total çekmece';
  }

  @override
  String get census_action_stop => 'Dur';

  @override
  String get census_stop_confirmTitle =>
      'Sayımı durdurmak istediğinize emin misiniz?';

  @override
  String get census_stop_confirmMessage =>
      'Sayım işlemi durdurulacak, o ana kadar tamamlanan sayımlar kaydedilmiş olarak kalacak.';

  @override
  String get census_stop_confirmYes => 'Evet, Durdur';

  @override
  String get census_status_waitingPullTitle => 'Çekmece bekleniyor';

  @override
  String get census_status_waitingPullBody => 'Lütfen çekmeceyi çekin';

  @override
  String get census_status_openingLidTitle => 'Göz açılıyor';

  @override
  String get census_status_openingLidBody => 'Lütfen bekleyin, göz açılıyor';

  @override
  String get census_status_openingTitle => 'Çekmece açılıyor';

  @override
  String get census_status_openingBody => 'Lütfen bekleyin, çekmece açılıyor';

  @override
  String get census_action_nextCell => 'Sonraki Göz';

  @override
  String get census_action_completeCensus => 'Sayımı Tamamla';

  @override
  String get census_error_queueTitle => 'Sayım sırasında bir hata oluştu';

  @override
  String get census_error_queueMessage =>
      'İlaçları çekmeceden alıp devam edebilir ya da işlemi burada sonlandırabilirsiniz.';

  @override
  String get census_error_continueNext => 'Devam Et';

  @override
  String get census_error_endProcess => 'Sonlandır';

  @override
  String get census_label_countQty => 'Sayım';

  @override
  String get intake_screenTitle => 'İlaç Alım';

  @override
  String get intake_phase_patientLabel => 'Hasta Seçimi';

  @override
  String get intake_phase_medicineLabel => 'İlaç Seçimi';

  @override
  String get intake_phase_executingLabel => 'Alım İşlemi';

  @override
  String patientPicker_roomLabel(String room) {
    return 'Oda $room';
  }

  @override
  String patientPicker_bedLabel(String bed) {
    return 'Yatak $bed';
  }

  @override
  String intake_label_countFieldLabelIndexed(String unit, int index) {
    return 'Sayım $index ($unit)';
  }

  @override
  String get patientListPanel_filter_patientStatusLabel => 'Hasta Durumu';

  @override
  String get patientListPanel_filter_orderStatusLabel => 'Order Durumu';

  @override
  String get patientListPanel_filter_dialogTitle => 'Filtreler';

  @override
  String get masterDrawer_status_devicePreparingTitle => 'Hazırlanıyor';

  @override
  String get masterDrawer_status_devicePreparingSubtitle =>
      'Sistem hazırlanıyor. Lütfen bir süre bekleyin.';

  @override
  String get masterDrawer_status_lockOpeningTitle => 'Kilit Açılıyor';

  @override
  String get masterDrawer_status_lockOpeningSubtitle =>
      'Çekmece kilidi açılıyor. Lütfen bir süre bekleyin.';

  @override
  String get masterDrawer_status_waitingPullTitle => 'Çekmeceyi Çekiniz';

  @override
  String get masterDrawer_status_waitingPullSubtitle =>
      'Kilit açıldı. Devam etmek için çekmeceyi çekerek açın.';

  @override
  String get masterDrawer_status_openingLidTitle => 'Göz Kapağı Açılıyor';

  @override
  String get masterDrawer_status_openingLidSubtitle =>
      'Göz kapağı açılıyor. Lütfen bir süre bekleyin.';

  @override
  String get masterDrawer_status_waitingCloseTitle => 'Çekmeceyi Kapatınız';

  @override
  String get masterDrawer_status_waitingCloseSubtitle =>
      'Sonraki adıma geçmek için çekmeceyi kapatın.';

  @override
  String get masterDrawer_status_failedTitle => 'Bir Sorun Oluştu';

  @override
  String get masterDrawer_status_failedSubtitle =>
      'Lütfen bekleyin, çekmece durumu kontrol ediliyor.';

  @override
  String get masterDrawer_status_openingTitle => 'Çekmece Açılıyor';

  @override
  String get masterDrawer_status_openingSubtitle =>
      'Çekmece açılıyor. Lütfen bir süre bekleyin.';

  @override
  String get masterDrawer_stop_waitingCloseTitle => 'Açık Çekmeceyi Kapatınız';

  @override
  String get masterDrawer_stop_waitingCloseSubtitle =>
      'Lütfen açık olan çekmeceyi kapatınız. Çekmece kapandıktan sonra işlem durdurulacaktır.';

  @override
  String intake_label_queueProgress(int done, int total) {
    return 'Çekmece $done/$total';
  }

  @override
  String get intake_action_stop => 'Durdur';

  @override
  String get intake_stop_confirmTitle => 'Alım Durdurulsun mu?';

  @override
  String get intake_stop_confirmMessage =>
      'Devam eden alım işlemi durdurulacak. Tamamlanan çekmeceler korunacaktır.';

  @override
  String get intake_stop_confirmYes => 'Evet, Durdur';

  @override
  String intake_hint_mergedFromMultiplePrescriptions(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString reçeteden birleştirildi',
    );
    return '$_temp0';
  }

  @override
  String get refund_hint_searchMedicine => 'İlaç ara';

  @override
  String get refund_hint_selectPatientFirst => 'Önce bir hasta seçin';

  @override
  String get refund_hint_noMedicineFound => 'İade edilebilir ilaç bulunamadı';

  @override
  String get refund_action_start => 'İadeyi Başlat';

  @override
  String get refund_action_nextCell => 'Sonraki Göz';

  @override
  String get refund_action_completeRefund => 'İadeyi Tamamla';

  @override
  String get refund_action_stop => 'Durdur';

  @override
  String get refund_action_stopConfirmTitle => 'İade Durdurulsun mu?';

  @override
  String get refund_action_stopConfirmMessage =>
      'Tamamlanan iadeler korunacak, kalan çekmeceler işlenmeyecek.';

  @override
  String get refund_action_stopConfirmYes => 'Evet, Durdur';

  @override
  String get refund_field_maxAmount => 'Maks. İade Edilebilir';

  @override
  String get refund_field_returnNote => 'İade Notu';

  @override
  String get refund_status_checking => 'Kontrol ediliyor...';

  @override
  String get refund_status_ready => 'Hazır';

  @override
  String get refund_status_checkFailed => 'Kontrol başarısız';

  @override
  String get refund_error_queueTitle => 'İade Hatası';

  @override
  String get refund_error_continueNext => 'Sonrakiyle Devam Et';

  @override
  String get refund_error_endProcess => 'İşlemi Sonlandır';

  @override
  String get refund_error_amountZero => 'İade miktarı 0 olamaz';

  @override
  String get refund_error_amountExceedsMax =>
      'İade edilecek miktar alım miktarını aşamaz';

  @override
  String refund_label_progress(int done, int total) {
    return '$done / $total çekmece';
  }

  @override
  String get waste_hint_searchMedicine => 'İlaç ara';

  @override
  String get waste_hint_selectPatientFirst =>
      'Devam etmek için önce bir hasta seçin';

  @override
  String get waste_hint_noMedicineFound =>
      'Fire/imha edilebilecek ilaç bulunamadı';

  @override
  String waste_label_availableAmount(String amount) {
    return 'Mevcut miktar: $amount';
  }

  @override
  String get waste_error_amountZero => 'Miktar 0 olamaz.';

  @override
  String get waste_error_wastageAmountExceeded =>
      'Fire edilecek miktar alım miktarından fazla olamaz.';

  @override
  String get waste_error_destructionAmountExceeded =>
      'İmha edilecek miktar alım miktarından fazla olamaz.';

  @override
  String get waste_success_operationCompleted => 'Fire/İmha işlemi başarılı.';

  @override
  String get witnessDialog_title => 'Şahit Doğrulama';

  @override
  String get witnessDialog_usernameLabel => 'Kullanıcı Adı';

  @override
  String get witnessDialog_usernameRequired => 'Kullanıcı adı gereklidir';

  @override
  String get witnessDialog_passwordLabel => 'Şifre';

  @override
  String get witnessDialog_passwordRequired => 'Şifre gereklidir';

  @override
  String get witnessDialog_confirmButton => 'Onayla';

  @override
  String get witnessDialog_anyoneInfo =>
      'Bu kalem için herhangi bir kullanıcı şahitlik yapabilir.';

  @override
  String witnessDialog_authorizedWitnesses(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yetkili $countString şahit',
      one: 'Yetkili $countString şahit',
    );
    return '$_temp0';
  }

  @override
  String get witnessDialog_error_selfWitness =>
      'Kendi işleminize şahit olamazsınız.';

  @override
  String witnessDialog_success_confirmed(String witnessName) {
    return '$witnessName şahit olarak onaylandı.';
  }

  @override
  String witnessDialog_assignedLabel(String witnessName) {
    return 'Şahit: $witnessName';
  }

  @override
  String get witnessDialog_requiredHint =>
      'Şahit girişi yapılması gerekmektedir';

  @override
  String witnessDialog_autoAssigned(String witnessName) {
    return '$witnessName bu kalem için şahit olarak otomatik atandı.';
  }

  @override
  String get unload_hint_searchMedicine => 'İlaç veya barkod ara';

  @override
  String get unload_hint_noMedicineFound => 'İlaç bulunamadı';

  @override
  String get unload_action_stop => 'Durdur';

  @override
  String get unload_action_nextCell => 'Sonraki Göz';

  @override
  String get unload_action_completeUnloading => 'Boşaltmayı Tamamla';

  @override
  String get unload_stop_confirmTitle => 'Boşaltma Durdurulsun mu?';

  @override
  String get unload_stop_confirmMessage =>
      'Kuyruktaki kalan çekmeceler boşaltılmayacak. Durdurmak istediğinize emin misiniz?';

  @override
  String get unload_stop_confirmYes => 'Evet, Durdur';

  @override
  String get unload_error_queueTitle => 'Boşaltma Hatası';

  @override
  String get unload_error_continueNext => 'Sonraki Çekmeceye Devam Et';

  @override
  String get unload_error_endProcess => 'İşlemi Sonlandır';

  @override
  String unload_label_queueProgress(int done, int total) {
    return '$total çekmeceden $done.';
  }

  @override
  String get unload_label_countQty => 'Sayım';

  @override
  String get unload_label_unloadQty => 'Boşaltım Miktarı';

  @override
  String get refund_label_quantity => 'Miktar';

  @override
  String destruction_label_queueProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get destruction_action_stop => 'Durdur';

  @override
  String get destruction_stop_confirmTitle => 'İmha durdurulsun mu?';

  @override
  String get destruction_stop_confirmMessage =>
      'İmha işlemi durdurulacak. Şu ana kadar işlenen kayıtlar korunacak.';

  @override
  String get destruction_stop_confirmYes => 'Evet, durdur';

  @override
  String get destruction_label_quantity => 'İmha Miktarı';

  @override
  String get destruction_action_nextCell => 'Sonraki Göz';

  @override
  String get destruction_action_completeDestruction => 'İmhayı Tamamla';

  @override
  String get waste_hint_notAuthorized =>
      'Bu ilacı imha etmeniz için yetkiniz yoktur';

  @override
  String get intake_action_checkEquivalent => 'Muadil Kontrol Et';

  @override
  String get intake_hint_noEquivalentFound => 'Muadil ilaç bulunamadı';

  @override
  String get intake_label_equivalentOptions => 'Mevcut muadiller';

  @override
  String get intake_hint_searchingOtherStations =>
      'Diğer kabinlerde aranıyor...';

  @override
  String get intake_hint_noStockAnywhere => 'Bu ilaç hiçbir kabinde bulunamadı';

  @override
  String get intake_label_otherStationOptions => 'Diğer kabinlerde mevcut';

  @override
  String get intake_action_redirect => 'Yönlendir';

  @override
  String intake_hint_redirectedTo(String stationName) {
    return '$stationName kabinine yönlendirildi';
  }

  @override
  String get intake_status_redirected => 'Yönlendirildi';

  @override
  String get intake_tab_prescriptions => 'Reçeteler';

  @override
  String get intake_tab_redirectedOrders => 'Yönlendirilen Alımlar';

  @override
  String get intake_hint_noRedirectedOrders => 'Yönlendirilen alım bulunmuyor';

  @override
  String intake_status_redirectedFrom(String stationName) {
    return '$stationName kabininden yönlendirildi';
  }

  @override
  String intake_label_redirectedBy(String userName) {
    return '$userName yönlendirdi';
  }

  @override
  String get refund_action_completeDirect => 'İade Et';

  @override
  String get refund_success_dialogTitle => 'İade Tamamlandı';

  @override
  String get refund_success_toPharmacyMessage =>
      'İade işlemi tamamlandı. Lütfen ilacı eczacıya teslim ediniz.';

  @override
  String get refund_success_toReturnBoxMessage =>
      'İade işlemi tamamlandı. Lütfen ilacı iade kutusuna yerleştiriniz.';

  @override
  String get refund_error_amountExceeded =>
      'İade edilecek miktar alım miktarından fazla olamaz';

  @override
  String get refund_error_genericCheckFailed =>
      'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.';

  @override
  String get refund_error_returnDrawerNotDefined =>
      'İade çekmecesi tanımlı değil. Lütfen Kabin Dizaynı ekranından tanımlayın.';

  @override
  String get refund_error_completeFailed => 'İade sırasında bir hata oluştu.';

  @override
  String get cabin_returnDrawerName => 'İade Çekmecesi';

  @override
  String get cabin_returnDrawerView => 'İade Kutusu';

  @override
  String get cabin_returnDrawerViewTitle =>
      'Bu çekmece iade kutusu olarak ayrıldı';

  @override
  String get cabin_returnDrawerViewSubtitle =>
      'Bu alana ilaç ataması/dolumu yapılamaz';

  @override
  String get cabinDesign_dialogTitle => 'Kabin Dizaynı';

  @override
  String get cabinDesign_syncBadge => 'SENKRON';

  @override
  String get cabinDesign_basicSettings_sectionTitle => 'Temel Ayarlar';

  @override
  String get cabinDesign_basicSettings_nameLabel => 'Kabin Adı';

  @override
  String get cabinDesign_basicSettings_stationLabel => 'İstasyon';

  @override
  String get cabinDesign_basicSettings_comPortLabel => 'COM Port';

  @override
  String get cabinDesign_basicSettings_dvrIpLabel => 'DVR IP';

  @override
  String get cabinDesign_detail_sectionTitle => 'Çekmece Detayı';

  @override
  String get cabinDesign_detail_typeLabel => 'Tip';

  @override
  String cabinDesign_detail_typeKubik(int rows, int cols) {
    return 'Kübik $rows×$cols';
  }

  @override
  String get cabinDesign_detail_cellCountLabel => 'Göz Sayısı';

  @override
  String get cabinDesign_detail_addressLabel => 'Adres';

  @override
  String get cabinDesign_detail_configLabel => 'Konfigürasyon';

  @override
  String get cabinDesign_returnDrawer_toggleLabel => 'İade çekmecesi';

  @override
  String get cabinDesign_returnDrawer_toggleHint =>
      'Bu çekmece iade işlemleri için ayrılır';

  @override
  String cabinDesign_returnDrawer_currentInfo(String address) {
    return 'Kabin başına yalnızca bir iade çekmecesi tanımlanabilir. Şu an: $address';
  }

  @override
  String get cabinDesign_returnDrawer_noneInfo =>
      'Kabin başına yalnızca bir iade çekmecesi tanımlanabilir. Henüz tanımlanmadı.';

  @override
  String get cabinDesign_serum_sectionTitle => 'İç Dizayn';

  @override
  String get cabinDesign_serum_manualBadge => 'MANUEL TANIM';

  @override
  String get cabinDesign_serum_infoBanner =>
      'Serum kabininde iç dizayn karttan okunmaz; çekmece ve avadanlık yerleşimini burada tanımlayın.';

  @override
  String get cabinDesign_serum_equipmentLayoutTitle => 'Avadanlık Yerleşimi';

  @override
  String cabinDesign_serum_drawerBadge(int index) {
    return 'S-0$index';
  }

  @override
  String get cabinDesign_serum_topViewLabel => 'Üstten Görünüm';

  @override
  String cabinDesign_serum_shelfCardTitle(int index) {
    return 'Raf $index';
  }

  @override
  String cabinDesign_serum_shelfCardSummary(int used, int total, int count) {
    return '$used/$total alan • $count avadanlık';
  }

  @override
  String get cabinDesign_serum_lockToggleLabel => 'Elektromanyetik Kilit';

  @override
  String get cabinDesign_serum_addSmallButton => 'Küçük';

  @override
  String get cabinDesign_serum_addMediumButton => 'Orta';

  @override
  String get cabinDesign_serum_addLargeButton => 'Büyük';

  @override
  String get cabinDesign_serum_traySizeSmallLabel => 'Küçük';

  @override
  String get cabinDesign_serum_traySizeMediumLabel => 'Orta';

  @override
  String get cabinDesign_serum_traySizeLargeLabel => 'Büyük';

  @override
  String cabinDesign_serum_trayListItemLabel(int index, String sizeLabel) {
    return '$index. Avadanlık • $sizeLabel';
  }

  @override
  String cabinDesign_serum_areaUsedLabel(int used, int total) {
    return '$used/$total alan kullanıldı';
  }

  @override
  String get cabinDesign_serum_capacityFullWarning =>
      'Raf dolu, yeni avadanlık eklenemez';

  @override
  String get cabinDesign_serum_leftLabel => 'Sol';

  @override
  String get cabinDesign_serum_rightLabel => 'Sağ';

  @override
  String get cabinDesign_noSelectionHint =>
      'Detayları görmek için bir çekmece seçin.';

  @override
  String get cabinDesign_scanButton => 'Cihazı Tara';

  @override
  String get cabinDesign_saveButton => 'Dizaynı Kaydet';

  @override
  String get cabinDesign_returnBadge => 'İADE';

  @override
  String get cabin_returnBoxLabel => 'İADE KUTUSU';

  @override
  String get unload_segment_returnDrawer => 'İade Çekmecesi';

  @override
  String get unload_segment_returnBox => 'İade Kutusu';

  @override
  String get unload_hint_noDrawerMedicineFound =>
      'İade çekmecesinde ilaç bulunamadı';

  @override
  String get unload_hint_noBoxMedicineFound => 'İade kutusunda ilaç bulunamadı';

  @override
  String get unload_fieldReturnedBy => 'İade Eden';

  @override
  String get unload_action_startDrawerUnload => 'Çekmece Boşaltmayı Başlat';

  @override
  String get unload_action_completeBoxUnload => 'Kutu Boşaltmayı Tamamla';

  @override
  String get unload_label_drawerInProgress =>
      'İade Çekmecesi Boşaltma Devam Ediyor';

  @override
  String get unload_action_stopConfirmTitle =>
      'Çekmece Boşaltma Durdurulsun mu?';

  @override
  String get unload_action_stopConfirmMessage =>
      'Çekmece kapanacak ve boşaltma tamamlanmayacak. Devam etmek istiyor musunuz?';

  @override
  String get unload_action_stopConfirmYes => 'Evet, Durdur';

  @override
  String get unload_action_completeDrawerUnload => 'Çekmece Boşaltmayı Tamamla';

  @override
  String get masterDrawer_error_managerNotFound =>
      'Yönetim kartı bulunamadı. Kabin bağlantısını kontrol edin.';

  @override
  String get masterDrawer_error_managerConnectFailed =>
      'Kabine bağlanılamadı. Bağlantıyı kontrol edip tekrar deneyin.';

  @override
  String get masterDrawer_error_lockOpenFailed =>
      'Çekmece kilidi açılamadı. Donanımı kontrol edin.';

  @override
  String get masterDrawer_error_lidOpenFailed =>
      'Kapak açılamadı. Çekmecenin tam açık olduğundan emin olun.';

  @override
  String get masterDrawer_error_lockOpenTimeout =>
      'Çekmece zamanında tam açılamadı. Lütfen çekmeceyi elle sonuna kadar çekin.';

  @override
  String get masterDrawer_error_sensorCommunicationLost =>
      'Donanımla iletişim kesildi. Bağlantıyı kontrol edip tekrar deneyin.';

  @override
  String get masterDrawer_error_unexpectedlyClosed =>
      'Çekmece işlem sırasında beklenmedik şekilde kapatıldı. Lütfen tekrar açıp deneyin.';

  @override
  String get masterDrawer_status_completingTitle => 'İşleminiz Tamamlanıyor';

  @override
  String get masterDrawer_status_completingSubtitle => 'Lütfen bekleyiniz';

  @override
  String get cabinDesign_cabinList_sectionTitle => 'Tanımlı Kabinler';

  @override
  String cabinDesign_cabinList_countBadge(int count) {
    return '$count Kabin';
  }

  @override
  String get cabinDesign_cabinList_addCabinButton => 'Yeni Kabin Tanımla';

  @override
  String get cabinDesign_cabinList_noPortLabel => 'Port Yok';

  @override
  String get cabinDesign_cabinList_passiveBadge => 'Pasif';

  @override
  String get cabinDesign_newCabin_typeLabel => 'Kabin Tipi';

  @override
  String get cabinDesign_newCabin_addressLabel => 'Adres';

  @override
  String get cabinDesign_newCabin_noAddressAvailableWarning =>
      'Bu istasyonda tanımlanabilecek adres kalmadı (B-P arası 15 adres kullanımda).';

  @override
  String get cabinDesign_newCabin_saveAndScanButton => 'Kaydet ve Tara';

  @override
  String get cabinDesign_newCabin_invalidAddressError =>
      'Seçilen adres geçersiz.';

  @override
  String get cabinDesign_basicSettings_rescanButton => 'Tekrar Tara';

  @override
  String get cabinDesign_basicSettings_deactivateButton => 'Pasife Al';

  @override
  String get cabinDesign_basicSettings_activateButton => 'Etkinleştir';

  @override
  String get cabinSelection_screenTitle => 'Kabin Seçin';

  @override
  String get cabinSelection_continueButton => 'Devam Et';

  @override
  String get cabinSelection_dataUnavailableLabel => 'Veri Yok';

  @override
  String get cabinOperation_changeCabinButton => 'Kabin Seçimi';

  @override
  String get assignment_idle_kicker => 'KABİN YAPILANDIRMA';

  @override
  String get assignment_idle_title => 'İlaç Atama';

  @override
  String get assignment_idle_description =>
      'Soldaki kabinden bir göze dokunun; o göze ilaç listesinden seçim yapıp minimum, kritik ve maksimum miktarları girin. Dolu bir göze dokunarak mevcut atamayı düzenleyebilirsiniz.';

  @override
  String get assignment_idle_tableTitle => 'Mevcut Atamalar';

  @override
  String get assignment_idle_columnLocation => 'Konum';

  @override
  String get assignment_idle_columnDrug => 'İlaç';

  @override
  String get assignment_idle_columnMin => 'Min';

  @override
  String get assignment_idle_columnCritical => 'Kritik';

  @override
  String get assignment_idle_columnMax => 'Maks';

  @override
  String get assignment_idle_editLink => 'Düzenle';

  @override
  String assignment_idle_locationLabel(String drawer, int cell) {
    return 'Çekmece $drawer — Göz $cell';
  }

  @override
  String get assignment_edit_title => 'Atamayı Düzenle';

  @override
  String get assignment_edit_cancelButton => 'Vazgeç';

  @override
  String get assignment_edit_selectDrugStep => '1 — İlaç Seçin';

  @override
  String get assignment_edit_quantityStep => '2 — Miktarları Girin';

  @override
  String get assignment_edit_searchHint => 'İlaç adı ara...';

  @override
  String get assignment_edit_inCabinBadge => 'Kabinde Var';

  @override
  String get assignment_edit_minQuantityLabel => 'Minimum Miktar';

  @override
  String get assignment_edit_minQuantityHint =>
      'Bu seviyenin altı sipariş önerir';

  @override
  String get assignment_edit_criticalQuantityLabel => 'Kritik Miktar';

  @override
  String get assignment_edit_criticalQuantityHint =>
      'Bu seviyede kritik uyarı verilir';

  @override
  String get assignment_edit_maxQuantityLabel => 'Maksimum Miktar';

  @override
  String get assignment_edit_maxQuantityHint =>
      'Gözün alabileceği en fazla adet';

  @override
  String get assignment_edit_removeLink => 'Atamayı Kaldır';

  @override
  String get assignment_edit_saveButton => 'Değişiklikleri Kaydet';

  @override
  String get assignment_edit_previousPage => 'Önceki';

  @override
  String get assignment_edit_nextPage => 'Sonraki';

  @override
  String assignment_edit_pageIndicator(int current, int total) {
    return 'Sayfa $current / $total';
  }

  @override
  String get unscannedBarcode_scan_actionLabel => 'Karekod Okut';

  @override
  String dashboard_delayMinutesLabel(int minutes) {
    return '$minutes dk';
  }

  @override
  String dashboard_delayHoursMinutesLabel(int hours, int minutes) {
    return '${hours}s ${minutes}dk';
  }

  @override
  String get dashboard_upcomingTreatmentsDelayedTitle => 'Gecikmiş';

  @override
  String get dashboard_upcomingTreatmentsDueSoonTitle => '20 Dakika İçinde';

  @override
  String get dashboard_upcomingTreatmentsUpcomingTitle => '20-60 DK';

  @override
  String dashboard_upcomingTreatmentsDueInMinutesLabel(int minutes) {
    return '$minutes DK SONRA';
  }

  @override
  String get assignment_edit_equivalentMedicinesSegment => 'Muadil İlaçlar';

  @override
  String get assignment_edit_allMedicinesSegment => 'Tüm İlaçlar';

  @override
  String get unapplied_showUnappliedTooltip => 'Uygulanmayanları Göster';

  @override
  String get unapplied_showOverdueTooltip => 'Geciken Uygulamaları Göster';

  @override
  String get stationStock_table_cabinNameColumn => 'Kabin Adı';

  @override
  String get stationStock_table_maxQuantityColumn => 'Maksimum';

  @override
  String get stationStock_table_currentQuantityColumn => 'Mevcut';

  @override
  String get stationStock_table_reservedColumn => 'Rezerve';

  @override
  String get urgentPatient_intakeCompletedMessage =>
      'Acil hasta ilaç alımı tamamlandı';

  @override
  String get urgentPatient_intakeCompletedDescription =>
      'Bu acil hastayı Acil Hasta Sonlandır ekranından sonlandırabilirsiniz.';
}
