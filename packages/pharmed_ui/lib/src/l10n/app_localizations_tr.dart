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
  String get common_cancelButton => 'İptal';

  @override
  String get common_pageNotFound => 'Sayfa bulunamadı';

  @override
  String get common_minLabel => 'Min';

  @override
  String get common_maxLabel => 'Maks';

  @override
  String get common_criticalLabel => 'Kritik';

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
  String get dashboard_treatmentsLoadError => 'Tedavi listesi yüklenemedi';

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
  String get emptyStateCabinDataTitle => 'Kabin verisi bulunamadı';

  @override
  String get emptyStateCabinDataDescription =>
      'Kabin henüz yapılandırılmamış olabilir\nveya bağlantı kurulamadı.';

  @override
  String get emptyStateNoResultsTitle => 'Sonuç bulunamadı';

  @override
  String get emptyStateNoResultsDescription =>
      'Arama kriterlerinizi değiştirmeyi deneyin.';

  @override
  String get emptyStateNoCellSelectedTitle => 'Göz seçilmedi';

  @override
  String get emptyStateNoCellSelectedDescription =>
      'Dolum yapmak için önce bir göz seçin.';

  @override
  String get emptyStateNoPatientTitle => 'Hasta atanmamış';

  @override
  String get emptyStateNoPatientDescription =>
      'Bu göze henüz hasta ataması yapılmamış.';

  @override
  String get emptyStateNoPrescriptionTitle => 'Reçete bulunamadı';

  @override
  String get emptyStateNoPrescriptionDescription =>
      'Bu hastaya ait aktif reçete bulunmuyor.';

  @override
  String get emptyStateNoCabinTitle => 'Kabin Bulunamadı';

  @override
  String get emptyStateNoCabinDescription =>
      'Henüz tanımlı bir kabin bulunmuyor. Devam edebilmek için lütfen bir kabin tanımlayın.';

  @override
  String get emptyStateNetworkErrorTitle => 'İnternet Bağlantısı Yok';

  @override
  String get emptyStateNetworkErrorDescription =>
      'Lütfen ağ bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get emptyStateServerErrorTitle => 'Sunucuya Erişilemiyor';

  @override
  String get emptyStateServerErrorDescription =>
      'Sunucuya bağlanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get emptyStateErrorTitle => 'Bir Hata Oluştu';

  @override
  String get emptyStateErrorDescription =>
      'Beklenmeyen bir hata meydana geldi. Lütfen tekrar deneyin veya sistem yöneticinize başvurun.';

  @override
  String get refundNoRefundableDrugs =>
      'Bu hastaya ait iade edilebilir ilaç bulunamadı.';

  @override
  String get refundSelectPatient =>
      'İade işlemi başlatmak için sol listeden bir hasta seçin.';

  @override
  String get wasteNoWastableDrugs => 'Fire/imha edilebilir ilaç bulunamadı.';

  @override
  String get wasteSelectPatient => 'İşlem yapmak için hasta seçin.';

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
  String get census_action_start => 'Sayıma başla';

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
  String get refill_success_completedMaster => 'Dolum başarıyla kaydedildi';

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
  String get refund_success_completed => 'İade başarıyla tamamlandı.';

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
  String get unload_action_start => 'Boşaltmaya başla';

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
  String get waste_success_wastage => 'Fire işlemi başarıyla tamamlandı.';

  @override
  String get waste_success_destruction => 'İmha işlemi başarıyla tamamlandı.';

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
}
