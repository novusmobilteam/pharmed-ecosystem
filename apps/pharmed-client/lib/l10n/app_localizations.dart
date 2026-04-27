import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  /// Placeholder title shown in right panel before any cell is selected
  ///
  /// In tr, this message translates to:
  /// **'Bir göz seçin'**
  String get common_selectCellTitle;

  /// Badge shown on a cell that has no drug or patient assignment
  ///
  /// In tr, this message translates to:
  /// **'Atanmamış'**
  String get common_noAssignmentBadge;

  /// Badge shown on a cell that has a drug assignment
  ///
  /// In tr, this message translates to:
  /// **'İlaç Atanmış'**
  String get common_drugAssignedBadge;

  /// Badge shown on a cell that has a patient assignment
  ///
  /// In tr, this message translates to:
  /// **'Hasta Atanmış'**
  String get common_patientAssignedBadge;

  /// Empty-state title when cabin data is unavailable
  ///
  /// In tr, this message translates to:
  /// **'Kabin verisi bulunamadı'**
  String get common_noCabinDataTitle;

  /// Empty-state description when cabin data is unavailable
  ///
  /// In tr, this message translates to:
  /// **'Kabin henüz yapılandırılmamış olabilir\nveya bağlantı kurulamadı.'**
  String get common_noCabinDataDescription;

  /// Empty-state title when a search or filter returns no results
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get common_noResultsTitle;

  /// Empty-state description when a search or filter returns no results
  ///
  /// In tr, this message translates to:
  /// **'Arama kriterlerinizi değiştirmeyi deneyin.'**
  String get common_noResultsDescription;

  /// Generic retry button label used in error states
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get common_retryButton;

  /// Generic cancel button label used in dialogs
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get common_cancelButton;

  /// Fallback message shown for unknown dashboard routes
  ///
  /// In tr, this message translates to:
  /// **'Sayfa bulunamadı'**
  String get common_pageNotFound;

  /// Minimum quantity field label in drug assignment panel
  ///
  /// In tr, this message translates to:
  /// **'Min'**
  String get common_minLabel;

  /// Maximum quantity field label in drug assignment panel
  ///
  /// In tr, this message translates to:
  /// **'Maks'**
  String get common_maxLabel;

  /// Critical quantity field label in drug assignment panel
  ///
  /// In tr, this message translates to:
  /// **'Kritik'**
  String get common_criticalLabel;

  /// Subtitle below the logo on the login screen
  ///
  /// In tr, this message translates to:
  /// **'Sisteme giriş yapın'**
  String get auth_loginSubtitle;

  /// Label for the email/username field on the login screen
  ///
  /// In tr, this message translates to:
  /// **'E-posta / Kullanıcı Adı'**
  String get auth_emailLabel;

  /// Label for the password field on the login screen
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get auth_passwordLabel;

  /// Login button on the login screen
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get auth_loginButton;

  /// Generic error message shown when login fails without a specific message
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get auth_genericError;

  /// Application name shown in the top app bar
  ///
  /// In tr, this message translates to:
  /// **'İLAÇ KABİN YÖNETİMİ'**
  String get dashboard_appBarTitle;

  /// Tooltip for the logout icon button in the top app bar
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get dashboard_logoutTooltip;

  /// Login button shown in the app bar when no user is logged in
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get dashboard_loginBarButton;

  /// KPI card label for active patients count
  ///
  /// In tr, this message translates to:
  /// **'Aktif Hasta'**
  String get dashboard_kpiActivePatients;

  /// KPI card label for completed operations count
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan İşlem'**
  String get dashboard_kpiCompletedOps;

  /// KPI card label for pending prescriptions count
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen Reçete'**
  String get dashboard_kpiPendingPrescriptions;

  /// KPI card label for critical alerts count
  ///
  /// In tr, this message translates to:
  /// **'Kritik Uyarı'**
  String get dashboard_kpiCriticalAlerts;

  /// Section header for the cabin status card on the dashboard
  ///
  /// In tr, this message translates to:
  /// **'KABİN DURUMU'**
  String get dashboard_cabinStatusHeader;

  /// Label for the cabin working-status row inside the cabin card
  ///
  /// In tr, this message translates to:
  /// **'Kabin Durumu'**
  String get dashboard_cabinStatusLabel;

  /// Error label shown in place of the KPI section when loading fails
  ///
  /// In tr, this message translates to:
  /// **'KPI verileri yüklenemedi'**
  String get dashboard_kpiLoadError;

  /// Error label shown in place of the cabin section when loading fails
  ///
  /// In tr, this message translates to:
  /// **'Kabin verisi yüklenemedi'**
  String get dashboard_cabinLoadError;

  /// Error label shown in place of the treatments section when loading fails
  ///
  /// In tr, this message translates to:
  /// **'Tedavi listesi yüklenemedi'**
  String get dashboard_treatmentsLoadError;

  /// Error label shown in place of the expiry-date section when loading fails
  ///
  /// In tr, this message translates to:
  /// **'SKT verisi yüklenemedi'**
  String get dashboard_sktLoadError;

  /// Placeholder description in patient-assignment right panel before a cell is selected
  ///
  /// In tr, this message translates to:
  /// **'Yatak atamak için orta\npanelden bir göz seçin.'**
  String get assignment_assignBedPlaceholder;

  /// Placeholder description in drug-assignment right panel before a cell is selected
  ///
  /// In tr, this message translates to:
  /// **'Atama yapmak için orta\npanelden bir göz seçin.'**
  String get assignment_assignDrugPlaceholder;

  /// Section label above the hospitalization selector in the patient-assignment panel
  ///
  /// In tr, this message translates to:
  /// **'HASTA / YATIŞ'**
  String get assignment_hospitalizationSectionLabel;

  /// Hint text in the hospitalization selector button when nothing is selected
  ///
  /// In tr, this message translates to:
  /// **'Yatış seçin...'**
  String get assignment_hospitalizationSelectorHint;

  /// Title of the dialog for selecting a hospitalization/bed
  ///
  /// In tr, this message translates to:
  /// **'Yatış Seç'**
  String get assignment_selectHospitalizationDialogTitle;

  /// Section label above the drug selector in the drug-assignment panel
  ///
  /// In tr, this message translates to:
  /// **'İLAÇ'**
  String get assignment_drugSectionLabel;

  /// Hint text in the drug selector button when nothing is selected
  ///
  /// In tr, this message translates to:
  /// **'İlaç seçin...'**
  String get assignment_drugSelectorHint;

  /// Title of the dialog for selecting a drug/medicine
  ///
  /// In tr, this message translates to:
  /// **'İlaç Seç'**
  String get assignment_selectDrugDialogTitle;

  /// Section label above the min/max/critical quantity input fields
  ///
  /// In tr, this message translates to:
  /// **'MİKTAR'**
  String get assignment_quantitySectionLabel;

  /// Primary button to save a new drug or patient assignment
  ///
  /// In tr, this message translates to:
  /// **'Atamayı Kaydet'**
  String get assignment_saveAssignmentButton;

  /// Danger button to remove an existing drug or patient assignment
  ///
  /// In tr, this message translates to:
  /// **'Atamayı Kaldır'**
  String get assignment_removeAssignmentButton;

  /// Primary button to update an existing patient assignment to a different hospitalization
  ///
  /// In tr, this message translates to:
  /// **'Atamayı Değiştir'**
  String get assignment_changeAssignmentButton;

  /// Label for the room/bed info row inside the patient card
  ///
  /// In tr, this message translates to:
  /// **'Oda / Yatak'**
  String get assignment_roomBedLabel;

  /// Label for the physical service info row inside the patient card
  ///
  /// In tr, this message translates to:
  /// **'Servis'**
  String get assignment_serviceLabel;

  /// Error message shown when the selected cell ID cannot be resolved before saving
  ///
  /// In tr, this message translates to:
  /// **'Seçili göz bulunamadı'**
  String get assignment_cellNotFoundError;

  /// Success snackbar/state message after a patient assignment is saved
  ///
  /// In tr, this message translates to:
  /// **'Hasta ataması başarıyla kaydedildi'**
  String get assignment_patientSavedSuccess;

  /// Success snackbar/state message after a patient assignment is removed
  ///
  /// In tr, this message translates to:
  /// **'Hasta ataması kaldırıldı'**
  String get assignment_patientRemovedSuccess;

  /// Placeholder description in the fault right panel before a cell/slot is selected
  ///
  /// In tr, this message translates to:
  /// **'Arıza bildirmek için orta\npanelden bir göz seçin.'**
  String get fault_selectCellPlaceholder;

  /// Section label above the fault description text field
  ///
  /// In tr, this message translates to:
  /// **'AÇIKLAMA'**
  String get fault_descriptionSectionLabel;

  /// Hint text inside the fault description multi-line text field
  ///
  /// In tr, this message translates to:
  /// **'Arıza detayını yazın...'**
  String get fault_descriptionHint;

  /// Left segment button label for selecting 'fault' status when reporting a new record
  ///
  /// In tr, this message translates to:
  /// **'ARIZA'**
  String get fault_faultSegmentLabel;

  /// Right segment button label for selecting 'maintenance' status when reporting a new record
  ///
  /// In tr, this message translates to:
  /// **'BAKIM'**
  String get fault_maintenanceSegmentLabel;

  /// Section label above the fault history list
  ///
  /// In tr, this message translates to:
  /// **'GEÇMİŞ'**
  String get fault_historySectionLabel;

  /// Status label for a resolved/closed fault record in the history list
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get fault_historyStatusCompleted;

  /// Status label for a maintenance record in the history list
  ///
  /// In tr, this message translates to:
  /// **'Bakım'**
  String get fault_historyStatusMaintenance;

  /// Status label for an active fault record in the history list
  ///
  /// In tr, this message translates to:
  /// **'Arıza'**
  String get fault_historyStatusFault;

  /// Badge shown next to active (not yet closed) fault records in the history list
  ///
  /// In tr, this message translates to:
  /// **'Aktif'**
  String get fault_historyActiveBadge;

  /// Warning banner shown when the selected cell already has an active fault/maintenance record
  ///
  /// In tr, this message translates to:
  /// **'Bu gözde aktif bir {label} kaydı bulunmaktadır. Onayladığınızda bu kayıt sonlandırılacaktır.'**
  String fault_activeFaultBanner(String label);

  /// Submit button label when creating a new fault/maintenance record
  ///
  /// In tr, this message translates to:
  /// **'Arıza Bildir'**
  String get fault_reportFaultButton;

  /// Submit button label when closing an existing active fault/maintenance record
  ///
  /// In tr, this message translates to:
  /// **'Kaydı Sonlandır'**
  String get fault_closeFaultButton;

  /// Success message shown after a fault record is successfully created
  ///
  /// In tr, this message translates to:
  /// **'Arıza kaydı oluşturuldu.'**
  String get fault_recordCreatedSuccess;

  /// Success message shown after a fault record is successfully closed
  ///
  /// In tr, this message translates to:
  /// **'Arıza kaydı kapatıldı.'**
  String get fault_recordClosedSuccess;

  /// Type badge label shown on the mobile cabin slot card in the left overview panel
  ///
  /// In tr, this message translates to:
  /// **'MOBİL'**
  String get cabin_mobileTypeLabel;

  /// Header title of the mobile cabin drawer panel (center panel)
  ///
  /// In tr, this message translates to:
  /// **'Mobil Çekmece'**
  String get cabin_mobileDrawerTitle;

  /// Cell count label on the mobile cabin slot card
  ///
  /// In tr, this message translates to:
  /// **'{count} göz'**
  String cabin_cellCountLabel(int count);

  /// Label for the drawer count stat box in the cabin stats grid
  ///
  /// In tr, this message translates to:
  /// **'Çekmece'**
  String get cabin_drawerStatsLabel;

  /// Sub-label for the drawer stat box showing full and empty counts
  ///
  /// In tr, this message translates to:
  /// **'{full} dolu · {empty} boş'**
  String cabin_statsFullEmpty(int full, int empty);

  /// Hint text shown in the center panel when no drawer/slot is selected
  ///
  /// In tr, this message translates to:
  /// **'Bir çekmeceye dokunun'**
  String get cabin_touchDrawerHint;

  /// Subtitle of the empty-state shown in the mobile drawer panel before a slot is selected
  ///
  /// In tr, this message translates to:
  /// **'Mobil kabin göz grid\'i görüntülenecek'**
  String get cabin_mobileGridPlaceholder;

  /// Subtitle of the empty-state shown in the master drawer panel before a drawer is selected
  ///
  /// In tr, this message translates to:
  /// **'Kübik · Birim Doz · Serum iç yapıları görüntülenecek'**
  String get cabin_masterGridPlaceholder;

  /// Uppercase drawer-type badge shown on kubik drawer cards in the master overview panel
  ///
  /// In tr, this message translates to:
  /// **'KÜBİK'**
  String get cabin_kubikTypeLabel;

  /// Header name for serum-type drawers in the master drawer panel
  ///
  /// In tr, this message translates to:
  /// **'Serum Çekmece'**
  String get cabin_serumDrawerName;

  /// Header name for kubik-type drawers in the master drawer panel
  ///
  /// In tr, this message translates to:
  /// **'Kübik Çekmece'**
  String get cabin_kubikDrawerName;

  /// Header name for unit-dose drawers in the master drawer panel
  ///
  /// In tr, this message translates to:
  /// **'Birim Doz Çekmece'**
  String get cabin_unitDoseDrawerName;

  /// Sub-label shown below the serum drawer header in the master panel
  ///
  /// In tr, this message translates to:
  /// **'Raf görünümü'**
  String get cabin_serumRackView;

  /// Placeholder title inside the serum drawer content area (not yet implemented)
  ///
  /// In tr, this message translates to:
  /// **'Serum görünümü'**
  String get cabin_serumViewTitle;

  /// Placeholder note inside the serum drawer content area shown until implementation is complete
  ///
  /// In tr, this message translates to:
  /// **'TODO: Serum iç yapısı netleşince tamamlanacak'**
  String get cabin_serumViewTodo;

  /// Button label to open the cabin on the cabin action bar
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get cabin_openButton;

  /// Button label to enter drug-assignment mode from the cabin action bar
  ///
  /// In tr, this message translates to:
  /// **'İlaç Ata'**
  String get cabin_assignDrugButton;

  /// Info banner shown at the top of the drawer panel when in patient-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'Hasta Atama — gözlere hasta / yatış atayın.'**
  String get cabin_bannerPatientAssign;

  /// Info banner shown at the top of the drawer panel when in drug-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'İlaç Atama — gözlere ilaç atayın, min/maks/kritik değerleri belirleyin.'**
  String get cabin_bannerDrugAssign;

  /// Info banner shown at the top of the drawer panel when in drug-fill mode
  ///
  /// In tr, this message translates to:
  /// **'İlaç Dolum — dolum yapılacak göze dokunun, miktarı girin.'**
  String get cabin_bannerDrugFill;

  /// Info banner shown at the top of the drawer panel when in drug-count mode
  ///
  /// In tr, this message translates to:
  /// **'Sayım — fiili miktarı girin, sistem farkı hesaplayacak.'**
  String get cabin_bannerDrugCount;

  /// Info banner shown at the top of the drawer panel when in fault-reporting mode
  ///
  /// In tr, this message translates to:
  /// **'Arıza — arızalı gözü işaretleyin ve açıklama girin.'**
  String get cabin_bannerFault;

  /// CabinWorkingStatus display label for a normally working cabin/cell
  ///
  /// In tr, this message translates to:
  /// **'Çalışıyor'**
  String get cabin_statusWorking;

  /// CabinWorkingStatus display label for a cabin/cell with an active fault record
  ///
  /// In tr, this message translates to:
  /// **'Arıza Kaydı'**
  String get cabin_statusFaultRecord;

  /// CabinWorkingStatus display label for a cabin/cell in maintenance
  ///
  /// In tr, this message translates to:
  /// **'Bakım Kaydı'**
  String get cabin_statusMaintenanceRecord;

  /// Display name for CabinOperationMode.assign
  ///
  /// In tr, this message translates to:
  /// **'İlaç Atama'**
  String get cabin_modeAssignLabel;

  /// Display name for CabinOperationMode.fill
  ///
  /// In tr, this message translates to:
  /// **'İlaç Dolum'**
  String get cabin_modeFillLabel;

  /// Display name for CabinOperationMode.count
  ///
  /// In tr, this message translates to:
  /// **'İlaç Sayım'**
  String get cabin_modeCountLabel;

  /// Display name for CabinOperationMode.fault
  ///
  /// In tr, this message translates to:
  /// **'Çekmece Arıza'**
  String get cabin_modeFaultLabel;

  /// Header title in the right operation panel when in drug-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'İLAÇ ATAMA'**
  String get cabin_operationPanelAssign;

  /// Header title in the right operation panel when in drug-fill mode
  ///
  /// In tr, this message translates to:
  /// **'İLAÇ DOLUM'**
  String get cabin_operationPanelFill;

  /// Header title in the right operation panel when in drug-count mode
  ///
  /// In tr, this message translates to:
  /// **'İLAÇ SAYIM'**
  String get cabin_operationPanelCount;

  /// Header title in the right operation panel when in fault-reporting mode
  ///
  /// In tr, this message translates to:
  /// **'ARIZA BİLDİR'**
  String get cabin_operationPanelFault;

  /// Legend item label for empty cells in drug-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'Boş göz (ata)'**
  String get cabin_legendAssignEmpty;

  /// Legend item label for drug-assigned cells in drug-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'İlaç atanmış'**
  String get cabin_legendAssignAssigned;

  /// Legend item label for faulty cells in assignment mode
  ///
  /// In tr, this message translates to:
  /// **'Arızalı'**
  String get cabin_legendAssignFault;

  /// Legend item label for cells under maintenance in assignment mode
  ///
  /// In tr, this message translates to:
  /// **'Bakımda'**
  String get cabin_legendAssignMaintenance;

  /// Legend item label for cells with a patient assignment in patient-assignment mode
  ///
  /// In tr, this message translates to:
  /// **'Hasta atanmış'**
  String get cabin_legendPatientAssigned;

  /// Legend item label for filled cells in non-assignment modes
  ///
  /// In tr, this message translates to:
  /// **'Dolu'**
  String get cabin_legendFilled;

  /// Legend item label for empty (no fill needed) cells in drug-fill mode
  ///
  /// In tr, this message translates to:
  /// **'Boş (dolum yok)'**
  String get cabin_legendFillEmpty;

  /// Legend item label for cells to be counted in drug-count mode
  ///
  /// In tr, this message translates to:
  /// **'Sayılacak (ilaçlı)'**
  String get cabin_legendCountAssigned;

  /// Legend item label for cells with low stock in drug-count mode
  ///
  /// In tr, this message translates to:
  /// **'Düşük stok'**
  String get cabin_legendCountLow;

  /// Legend item label for empty cells to skip in drug-count mode
  ///
  /// In tr, this message translates to:
  /// **'Boş (atla)'**
  String get cabin_legendCountEmpty;

  /// Legend item label for normally operating cells in fault mode
  ///
  /// In tr, this message translates to:
  /// **'Normal çalışıyor'**
  String get cabin_legendFaultNormal;

  /// Legend item label for cells with a reported fault in fault mode
  ///
  /// In tr, this message translates to:
  /// **'Arıza bildirildi'**
  String get cabin_legendFaultReported;

  /// Legend item label for empty cells in fault mode
  ///
  /// In tr, this message translates to:
  /// **'Boş göz'**
  String get cabin_legendFaultEmpty;

  /// Title shown at the top of the setup wizard sidebar
  ///
  /// In tr, this message translates to:
  /// **'Kabin Kurulumu'**
  String get wizard_sidebarTitle;

  /// Subtitle shown below the title in the setup wizard sidebar
  ///
  /// In tr, this message translates to:
  /// **'Yeni cihaz yapılandırması'**
  String get wizard_sidebarSubtitle;

  /// Step 1 title in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Kabin Tipi'**
  String get wizard_step1SidebarTitle;

  /// Step 1 description in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Standart veya Mobil'**
  String get wizard_step1SidebarDesc;

  /// Step 2 title in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Temel Bilgiler'**
  String get wizard_step2SidebarTitle;

  /// Step 2 description in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Ad, konum, bağlantı'**
  String get wizard_step2SidebarDesc;

  /// Step 3 title in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Kapsamı'**
  String get wizard_step3SidebarTitle;

  /// Step 3 description in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Servis veya oda tanımları'**
  String get wizard_step3SidebarDesc;

  /// Step 4 title in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Çekmece Yapısı'**
  String get wizard_step4SidebarTitle;

  /// Step 4 description in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Tarama veya manuel giriş'**
  String get wizard_step4SidebarDesc;

  /// Step 5 title in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Özet'**
  String get wizard_step5SidebarTitle;

  /// Step 5 description in the wizard sidebar step list
  ///
  /// In tr, this message translates to:
  /// **'Gözden geçir ve tamamla'**
  String get wizard_step5SidebarDesc;

  /// Step 1 header title shown at the top of the cabin-type selection step
  ///
  /// In tr, this message translates to:
  /// **'Kabin Tipini Seçin'**
  String get wizard_step1Header;

  /// Step 1 header subtitle describing the purpose of the cabin-type selection step
  ///
  /// In tr, this message translates to:
  /// **'Yönetmek istediğiniz kabin türünü belirleyin. Bu seçim sonraki adımları şekillendirecektir.'**
  String get wizard_step1Subtitle;

  /// Footer note on step 1 warning that the cabin type cannot be changed after completion
  ///
  /// In tr, this message translates to:
  /// **'Kabin tipi sonradan değiştirilemez.'**
  String get wizard_cabinTypeNote;

  /// First spec pill label on the standard (master) cabin type card
  ///
  /// In tr, this message translates to:
  /// **'Kübik / Birim Doz'**
  String get wizard_masterCabinSpec1;

  /// Second spec pill label on the standard cabin type card
  ///
  /// In tr, this message translates to:
  /// **'Servis Bazlı'**
  String get wizard_masterCabinSpec2;

  /// Description text on the standard (master) cabin type card on step 1
  ///
  /// In tr, this message translates to:
  /// **'Sabit duvara monte veya bağımsız duran, kübik ve birim doz çekmece kombinasyonuna sahip kabin.'**
  String get wizard_masterCabinDescription;

  /// First spec pill label on the mobile cabin type card
  ///
  /// In tr, this message translates to:
  /// **'Tekerlekli'**
  String get wizard_mobileCabinSpec1;

  /// Second spec pill label on the mobile cabin type card
  ///
  /// In tr, this message translates to:
  /// **'Oda Bazlı'**
  String get wizard_mobileCabinSpec2;

  /// Description text on the mobile cabin type card on step 1
  ///
  /// In tr, this message translates to:
  /// **'Tekerlekli, koğuş dolaşımı için tasarlanmış 4 sıralı taşınabilir ilaç ünitesi.'**
  String get wizard_mobileCabinDescription;

  /// Step 2 header title for basic cabin info (name, location, connection)
  ///
  /// In tr, this message translates to:
  /// **'Temel Bilgiler'**
  String get wizard_step2Header;

  /// Step 2 header subtitle
  ///
  /// In tr, this message translates to:
  /// **'Kabin adı, konum ve cihaz bağlantı ayarlarını girin.'**
  String get wizard_step2Subtitle;

  /// Label for the cabin name text field on step 2
  ///
  /// In tr, this message translates to:
  /// **'Kabin Adı'**
  String get wizard_cabinNameLabel;

  /// Hint text for the cabin name text field on step 2
  ///
  /// In tr, this message translates to:
  /// **'örn. CB-304'**
  String get wizard_cabinNameHint;

  /// Section label for the connection settings group on step 2
  ///
  /// In tr, this message translates to:
  /// **'BAĞLANTI AYARLARI'**
  String get wizard_connectionSettingsLabel;

  /// Warning text shown on step 2 when no active COM port is detected
  ///
  /// In tr, this message translates to:
  /// **'Aktif COM Port bulunamadı. Sürücülerin yüklü olduğundan emin olun.'**
  String get wizard_noComPortWarning;

  /// Section label for the antenna/RFID settings group on step 2
  ///
  /// In tr, this message translates to:
  /// **'ANTEN AYARLARI'**
  String get wizard_antennaSettingsLabel;

  /// Label for the IP address input field on step 2
  ///
  /// In tr, this message translates to:
  /// **'IP Adresi'**
  String get wizard_ipAddressLabel;

  /// Button to test the cabin card serial connection on step 2
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı Test Et'**
  String get wizard_testConnectionButton;

  /// Step 3 header title for service/station scope selection
  ///
  /// In tr, this message translates to:
  /// **'Hizmet Kapsamı'**
  String get wizard_step3Header;

  /// Step 3 header subtitle
  ///
  /// In tr, this message translates to:
  /// **'Servis veya oda tanımları.'**
  String get wizard_step3Subtitle;

  /// Section label for the room and bed selection area on step 3 for mobile cabins
  ///
  /// In tr, this message translates to:
  /// **'ODA & YATAK SEÇİMİ'**
  String get wizard_roomBedSelectionLabel;

  /// Title of the idle scan state on step 4
  ///
  /// In tr, this message translates to:
  /// **'Cihazı Tara'**
  String get wizard_scanTitle;

  /// Description text shown in the idle scan state on step 4
  ///
  /// In tr, this message translates to:
  /// **'Seri port üzerinden bağlı kabinin çekmece yapısı otomatik okunacaktır.'**
  String get wizard_scanDescription;

  /// Button to start the cabinet hardware scan on step 4
  ///
  /// In tr, this message translates to:
  /// **'Taramayı Başlat'**
  String get wizard_startScanButton;

  /// Header text shown while the cabinet hardware scan is in progress
  ///
  /// In tr, this message translates to:
  /// **'Kabin Taranıyor...'**
  String get wizard_scanningStatus;

  /// Success banner title shown after a successful hardware scan on step 4
  ///
  /// In tr, this message translates to:
  /// **'Tarama Başarılı — {count} çekmece bulundu'**
  String wizard_scanSuccessBanner(int count);

  /// Description text in the scan success banner on step 4
  ///
  /// In tr, this message translates to:
  /// **'Kabin iç dizaynı cihazdan başarıyla okundu. Aşağıdaki yapıyı onaylayın.'**
  String get wizard_scanSuccessDescription;

  /// Hint text at the bottom of the scan-found state telling the user to re-check connections if the result is wrong
  ///
  /// In tr, this message translates to:
  /// **'Yapı yanlışsa geri dönüp bağlantı bilgilerini kontrol edin.'**
  String get wizard_scanWrongStructure;

  /// Button to reset and re-run the hardware scan on step 4
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Tara'**
  String get wizard_rescanButton;

  /// Error banner message shown when the hardware scan fails on step 4
  ///
  /// In tr, this message translates to:
  /// **'Tarama başarısız. COM port bağlantısını kontrol edip tekrar deneyin.'**
  String get wizard_scanErrorBanner;

  /// Scan log entry message while connecting to the serial port
  ///
  /// In tr, this message translates to:
  /// **'Seri porta bağlanılıyor…'**
  String get wizard_scanLogConnecting;

  /// Scan log entry message while fetching drawer type metadata
  ///
  /// In tr, this message translates to:
  /// **'Çekmece tanımları yükleniyor…'**
  String get wizard_scanLogFetchingMetadata;

  /// Scan log entry message while searching for the management card
  ///
  /// In tr, this message translates to:
  /// **'Yönetim kartı aranıyor…'**
  String get wizard_scanLogSearchingManager;

  /// Scan log entry message while scanning control cards
  ///
  /// In tr, this message translates to:
  /// **'Kontrol kartları taranıyor…'**
  String get wizard_scanLogScanningCards;

  /// Scan log entry message when a drawer is found during the hardware scan
  ///
  /// In tr, this message translates to:
  /// **'Çekmece bulundu'**
  String get wizard_scanLogDrawerFound;

  /// Label prefix for each scanned drawer row in the scan results list (1-based index)
  ///
  /// In tr, this message translates to:
  /// **'ÇEKMECE {index}'**
  String wizard_drawerLabel(int index);

  /// Cell count chip shown on scanned drawer rows for kubik drawers
  ///
  /// In tr, this message translates to:
  /// **'{count} göz'**
  String wizard_cellCountLabel(int count);

  /// Row count chip shown on scanned drawer rows for unit-dose drawers
  ///
  /// In tr, this message translates to:
  /// **'{count} sıra'**
  String wizard_rowCountLabel(int count);

  /// Label for the drawer count input in the manual mobile cabinet configuration on step 4
  ///
  /// In tr, this message translates to:
  /// **'Çekmece Sayısı'**
  String get wizard_drawerCountLabel;

  /// Button to add a row to the current drawer configuration in mobile manual setup
  ///
  /// In tr, this message translates to:
  /// **'Satır Ekle'**
  String get wizard_addRowButton;

  /// Button to remove the last row from the current drawer configuration in mobile manual setup
  ///
  /// In tr, this message translates to:
  /// **'Son Satırı Sil'**
  String get wizard_removeLastRowButton;

  /// Step 5 header title for the summary and confirmation step
  ///
  /// In tr, this message translates to:
  /// **'Özet & Tamamla'**
  String get wizard_step5Header;

  /// Step 5 header subtitle
  ///
  /// In tr, this message translates to:
  /// **'Girdiğiniz bilgileri onaylayın. Onayladıktan sonra kurulum tamamlanacaktır.'**
  String get wizard_step5Subtitle;

  /// Summary card title for the cabin basic information section on step 5
  ///
  /// In tr, this message translates to:
  /// **'KABİN BİLGİLERİ'**
  String get wizard_summaryCabinInfoTitle;

  /// Summary card title for the service scope section on step 5
  ///
  /// In tr, this message translates to:
  /// **'HİZMET KAPSAMI'**
  String get wizard_summaryServiceScopeTitle;

  /// Summary card title for the drawer structure section on step 5
  ///
  /// In tr, this message translates to:
  /// **'ÇEKMECE YAPISI'**
  String get wizard_summaryDrawerStructureTitle;

  /// Summary card title for the cabin visual preview section on step 5
  ///
  /// In tr, this message translates to:
  /// **'KABİN ÖNİZLEMESİ'**
  String get wizard_summaryCabinPreviewTitle;

  /// Row label for the cabin type in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'Tip'**
  String get wizard_summaryLabelType;

  /// Row label for the cabin name in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get wizard_summaryLabelName;

  /// Row label for the station in the service scope summary card
  ///
  /// In tr, this message translates to:
  /// **'İstasyon'**
  String get wizard_summaryLabelStation;

  /// Row label for the room count in the service scope summary card (mobile cabin)
  ///
  /// In tr, this message translates to:
  /// **'Oda sayısı'**
  String get wizard_summaryLabelRoomCount;

  /// Row label for the room names list in the service scope summary card (mobile cabin)
  ///
  /// In tr, this message translates to:
  /// **'Odalar'**
  String get wizard_summaryLabelRooms;

  /// Row label for the bed names list in the service scope summary card (mobile cabin)
  ///
  /// In tr, this message translates to:
  /// **'Yataklar'**
  String get wizard_summaryLabelBeds;

  /// Row label for the drawer count in the drawer structure summary card (mobile cabin)
  ///
  /// In tr, this message translates to:
  /// **'Çekmece sayısı'**
  String get wizard_summaryLabelDrawerCount;

  /// Row label for the total drawer count in the drawer structure summary card (standard cabin)
  ///
  /// In tr, this message translates to:
  /// **'Toplam çekmece'**
  String get wizard_summaryLabelTotalDrawers;

  /// Row label for an individual drawer in the drawer structure summary card
  ///
  /// In tr, this message translates to:
  /// **'{index}. Çekmece'**
  String wizard_summaryLabelDrawerIndexed(int index);

  /// Cabin type value in the summary card when the selected type is mobile
  ///
  /// In tr, this message translates to:
  /// **'Mobil Kabin'**
  String get wizard_summaryTypeMobile;

  /// Cabin type value in the summary card when the selected type is standard/master
  ///
  /// In tr, this message translates to:
  /// **'Standart Kabin'**
  String get wizard_summaryTypeStandard;

  /// Row label for the COM port value in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'COM Port'**
  String get wizard_summaryLabelComPort;

  /// Row label for the DVR IP value in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'DVR IP'**
  String get wizard_summaryLabelDvrIp;

  /// Row label for the RFID IP address value in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'RFID Adresi'**
  String get wizard_summaryLabelRfidAddress;

  /// Row label for the RFID port value in the cabin info summary card
  ///
  /// In tr, this message translates to:
  /// **'RFID Portu'**
  String get wizard_summaryLabelRfidPort;

  /// Text shown below the loading spinner while the cabin is being saved to the server
  ///
  /// In tr, this message translates to:
  /// **'Kabin kaydediliyor…'**
  String get wizard_savingMessage;

  /// Title of the wizard success screen after the cabin is saved
  ///
  /// In tr, this message translates to:
  /// **'Kurulum Tamamlandı!'**
  String get wizard_successTitle;

  /// Success message on the wizard completion screen
  ///
  /// In tr, this message translates to:
  /// **'{cabinName} başarıyla sisteme eklendi.'**
  String wizard_successMessage(String cabinName);

  /// Cabin ID badge shown on the wizard success screen
  ///
  /// In tr, this message translates to:
  /// **'Kabin ID: #{id}'**
  String wizard_successCabinId(int id);

  /// Button on the wizard success screen to navigate to the dashboard
  ///
  /// In tr, this message translates to:
  /// **'Dashboard\'a Git'**
  String get wizard_successDashboardButton;

  /// Title of the wizard error screen when cabin save fails
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Başarısız'**
  String get wizard_errorTitle;

  /// Button on the wizard error screen to go back and retry
  ///
  /// In tr, this message translates to:
  /// **'Geri Dön ve Tekrar Dene'**
  String get wizard_retryButton;

  /// Title label in the settings modal header
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings_title;

  /// Section title for the system configuration area in the settings modal
  ///
  /// In tr, this message translates to:
  /// **'SİSTEM YAPILANDIRMASI'**
  String get settings_systemConfigTitle;

  /// Label for the appearance/theme section in the settings sidebar and modal
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settings_appearanceLabel;

  /// Label for the general section in the settings modal
  ///
  /// In tr, this message translates to:
  /// **'Genel'**
  String get settings_generalLabel;

  /// Success snackbar/state message after a patient assignment is updated to a different hospitalization
  ///
  /// In tr, this message translates to:
  /// **'Hasta ataması güncellendi'**
  String get assignment_patientUpdatedSuccess;

  /// Placeholder description in the fault right panel before a mobile slot is selected
  ///
  /// In tr, this message translates to:
  /// **'Arıza bildirmek için sol\npanelden bir çekmece seçin.'**
  String get fault_selectSlotPlaceholder;

  /// Section label for bed selection dropdowns in right panel
  ///
  /// In tr, this message translates to:
  /// **'Yatak Seçimi'**
  String get assignment_bedSectionLabel;

  /// Hint text for service dropdown
  ///
  /// In tr, this message translates to:
  /// **'Servis seçin'**
  String get assignment_serviceSelectorHint;

  /// Hint text for room dropdown
  ///
  /// In tr, this message translates to:
  /// **'Oda seçin'**
  String get assignment_roomSelectorHint;

  /// Hint text for bed dropdown
  ///
  /// In tr, this message translates to:
  /// **'Yatak seçin'**
  String get assignment_bedSelectorHint;

  /// Label for patient info row in bed card
  ///
  /// In tr, this message translates to:
  /// **'HASTA'**
  String get assignment_patientLabel;

  /// Settings > General section header for language selection
  ///
  /// In tr, this message translates to:
  /// **'DİL'**
  String get settings_languageTitle;

  /// Subtitle shown under language section header
  ///
  /// In tr, this message translates to:
  /// **'Arayüz dili'**
  String get settings_languageSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
