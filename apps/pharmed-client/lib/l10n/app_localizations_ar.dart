// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get common_selectCellTitle => 'اختر خانة';

  @override
  String get common_noAssignmentBadge => 'غير مُعيَّن';

  @override
  String get common_drugAssignedBadge => 'دواء مُعيَّن';

  @override
  String get common_patientAssignedBadge => 'مريض مُعيَّن';

  @override
  String get common_noCabinDataTitle => 'بيانات الخزانة غير متوفرة';

  @override
  String get common_noCabinDataDescription =>
      'ربما لم تُهيَّأ الخزانة بعد\nأو تعذّر الاتصال بها.';

  @override
  String get common_noResultsTitle => 'لا توجد نتائج';

  @override
  String get common_noResultsDescription => 'جرّب تغيير معايير البحث.';

  @override
  String get common_retryButton => 'إعادة المحاولة';

  @override
  String get common_cancelButton => 'إلغاء';

  @override
  String get common_pageNotFound => 'الصفحة غير موجودة';

  @override
  String get common_minLabel => 'الحد الأدنى';

  @override
  String get common_maxLabel => 'الحد الأقصى';

  @override
  String get common_criticalLabel => 'حرج';

  @override
  String get auth_loginSubtitle => 'تسجيل الدخول إلى النظام';

  @override
  String get auth_emailLabel => 'البريد الإلكتروني / اسم المستخدم';

  @override
  String get auth_passwordLabel => 'كلمة المرور';

  @override
  String get auth_loginButton => 'تسجيل الدخول';

  @override
  String get auth_genericError => 'حدث خطأ';

  @override
  String get dashboard_appBarTitle => 'إدارة خزانة الأدوية';

  @override
  String get dashboard_logoutTooltip => 'تسجيل الخروج';

  @override
  String get dashboard_loginBarButton => 'تسجيل الدخول';

  @override
  String get dashboard_kpiActivePatients => 'المرضى النشطون';

  @override
  String get dashboard_kpiCompletedOps => 'العمليات المكتملة';

  @override
  String get dashboard_kpiPendingPrescriptions => 'الوصفات المعلّقة';

  @override
  String get dashboard_kpiCriticalAlerts => 'التنبيهات الحرجة';

  @override
  String get dashboard_cabinStatusHeader => 'حالة الخزانة';

  @override
  String get dashboard_cabinStatusLabel => 'حالة الخزانة';

  @override
  String get dashboard_kpiLoadError => 'تعذّر تحميل بيانات KPI';

  @override
  String get dashboard_cabinLoadError => 'تعذّر تحميل بيانات الخزانة';

  @override
  String get dashboard_treatmentsLoadError => 'تعذّر تحميل قائمة العلاجات';

  @override
  String get dashboard_sktLoadError => 'تعذّر تحميل بيانات تواريخ الانتهاء';

  @override
  String get assignment_assignPatientPlaceholder =>
      'لتعيين مريض، اختر\nخانة من اللوحة الوسطى.';

  @override
  String get assignment_assignDrugPlaceholder =>
      'لإجراء التعيين، اختر\nخانة من اللوحة الوسطى.';

  @override
  String get assignment_hospitalizationSectionLabel => 'المريض / الإدخال';

  @override
  String get assignment_hospitalizationSelectorHint => 'اختر إدخالاً...';

  @override
  String get assignment_selectHospitalizationDialogTitle => 'اختر إدخالاً';

  @override
  String get assignment_drugSectionLabel => 'الدواء';

  @override
  String get assignment_drugSelectorHint => 'اختر دواءً...';

  @override
  String get assignment_selectDrugDialogTitle => 'اختر دواءً';

  @override
  String get assignment_quantitySectionLabel => 'الكمية';

  @override
  String get assignment_saveAssignmentButton => 'حفظ التعيين';

  @override
  String get assignment_removeAssignmentButton => 'إزالة التعيين';

  @override
  String get assignment_changeAssignmentButton => 'تغيير التعيين';

  @override
  String get assignment_roomBedLabel => 'الغرفة / السرير';

  @override
  String get assignment_serviceLabel => 'الجناح';

  @override
  String get assignment_cellNotFoundError => 'تعذّر العثور على الخانة المحددة';

  @override
  String get assignment_patientSavedSuccess => 'تم حفظ تعيين المريض بنجاح';

  @override
  String get assignment_patientRemovedSuccess => 'تم إزالة تعيين المريض';

  @override
  String get fault_selectCellPlaceholder =>
      'لإبلاغ عن عطل، اختر\nخانة من اللوحة الوسطى.';

  @override
  String get fault_descriptionSectionLabel => 'الوصف';

  @override
  String get fault_descriptionHint => 'اكتب تفاصيل العطل...';

  @override
  String get fault_faultSegmentLabel => 'عطل';

  @override
  String get fault_maintenanceSegmentLabel => 'صيانة';

  @override
  String get fault_historySectionLabel => 'السجل';

  @override
  String get fault_historyStatusCompleted => 'مُغلق';

  @override
  String get fault_historyStatusMaintenance => 'صيانة';

  @override
  String get fault_historyStatusFault => 'عطل';

  @override
  String get fault_historyActiveBadge => 'نشط';

  @override
  String fault_activeFaultBanner(String label) {
    return 'تحتوي هذه الخانة على سجل $label نشط. سيتم إنهاء هذا السجل عند التأكيد.';
  }

  @override
  String get fault_reportFaultButton => 'الإبلاغ عن عطل';

  @override
  String get fault_closeFaultButton => 'إغلاق السجل';

  @override
  String get fault_recordCreatedSuccess => 'تم إنشاء سجل العطل.';

  @override
  String get fault_recordClosedSuccess => 'تم إغلاق سجل العطل.';

  @override
  String get cabin_mobileTypeLabel => 'متنقل';

  @override
  String get cabin_mobileDrawerTitle => 'درج متنقل';

  @override
  String cabin_cellCountLabel(int count) {
    return '$count خانة';
  }

  @override
  String get cabin_drawerStatsLabel => 'الأدراج';

  @override
  String cabin_statsFullEmpty(int full, int empty) {
    return '$full ممتلئ · $empty فارغ';
  }

  @override
  String get cabin_touchDrawerHint => 'المس أحد الأدراج';

  @override
  String get cabin_mobileGridPlaceholder =>
      'سيتم عرض شبكة خانات الخزانة المتنقلة';

  @override
  String get cabin_masterGridPlaceholder =>
      'سيتم عرض محتويات أدراج التكعيب والجرعة الفردية والمصل';

  @override
  String get cabin_kubikTypeLabel => 'تكعيبي';

  @override
  String get cabin_serumDrawerName => 'درج المصل';

  @override
  String get cabin_kubikDrawerName => 'درج تكعيبي';

  @override
  String get cabin_unitDoseDrawerName => 'درج الجرعة الفردية';

  @override
  String get cabin_serumRackView => 'عرض الرف';

  @override
  String get cabin_serumViewTitle => 'عرض المصل';

  @override
  String get cabin_serumViewTodo => 'TODO: سيكتمل عند تحديد بنية درج المصل';

  @override
  String get cabin_openButton => 'فتح';

  @override
  String get cabin_assignDrugButton => 'تعيين دواء';

  @override
  String get cabin_bannerPatientAssign =>
      'تعيين المرضى — عيّن مريضاً / إدخالاً لكل خانة.';

  @override
  String get cabin_bannerDrugAssign =>
      'تعيين الأدوية — عيّن أدويةً للخانات وحدد قيم الحد الأدنى/الأقصى/الحرج.';

  @override
  String get cabin_bannerDrugFill =>
      'تعبئة الأدوية — المس الخانة المراد تعبئتها وأدخل الكمية.';

  @override
  String get cabin_bannerDrugCount =>
      'الجرد — أدخل الكمية الفعلية وسيحسب النظام الفارق.';

  @override
  String get cabin_bannerFault =>
      'العطل — ضع علامة على الخانة المعطوبة وأدخل الوصف.';

  @override
  String get cabin_statusWorking => 'يعمل';

  @override
  String get cabin_statusFaultRecord => 'سجل عطل';

  @override
  String get cabin_statusMaintenanceRecord => 'سجل صيانة';

  @override
  String get cabin_modeAssignLabel => 'تعيين الأدوية';

  @override
  String get cabin_modeFillLabel => 'تعبئة الأدوية';

  @override
  String get cabin_modeCountLabel => 'جرد الأدوية';

  @override
  String get cabin_modeFaultLabel => 'عطل الدرج';

  @override
  String get cabin_operationPanelAssign => 'تعيين الأدوية';

  @override
  String get cabin_operationPanelFill => 'تعبئة الأدوية';

  @override
  String get cabin_operationPanelCount => 'جرد الأدوية';

  @override
  String get cabin_operationPanelFault => 'الإبلاغ عن عطل';

  @override
  String get cabin_legendAssignEmpty => 'خانة فارغة (تعيين)';

  @override
  String get cabin_legendAssignAssigned => 'دواء مُعيَّن';

  @override
  String get cabin_legendAssignFault => 'معطوبة';

  @override
  String get cabin_legendAssignMaintenance => 'قيد الصيانة';

  @override
  String get cabin_legendPatientAssigned => 'مريض مُعيَّن';

  @override
  String get cabin_legendFilled => 'ممتلئة';

  @override
  String get cabin_legendFillEmpty => 'فارغة (لا تعبئة)';

  @override
  String get cabin_legendCountAssigned => 'للجرد (بها دواء)';

  @override
  String get cabin_legendCountLow => 'مخزون منخفض';

  @override
  String get cabin_legendCountEmpty => 'فارغة (تخطّ)';

  @override
  String get cabin_legendFaultNormal => 'تعمل بشكل طبيعي';

  @override
  String get cabin_legendFaultReported => 'عطل مُبلَّغ عنه';

  @override
  String get cabin_legendFaultEmpty => 'خانة فارغة';

  @override
  String get wizard_sidebarTitle => 'إعداد الخزانة';

  @override
  String get wizard_sidebarSubtitle => 'تهيئة جهاز جديد';

  @override
  String get wizard_step1SidebarTitle => 'نوع الخزانة';

  @override
  String get wizard_step1SidebarDesc => 'ثابتة أو متنقلة';

  @override
  String get wizard_step2SidebarTitle => 'المعلومات الأساسية';

  @override
  String get wizard_step2SidebarDesc => 'الاسم والموقع والاتصال';

  @override
  String get wizard_step3SidebarTitle => 'نطاق الخدمة';

  @override
  String get wizard_step3SidebarDesc => 'تعريف الأجنحة أو الغرف';

  @override
  String get wizard_step4SidebarTitle => 'بنية الأدراج';

  @override
  String get wizard_step4SidebarDesc => 'مسح ضوئي أو إدخال يدوي';

  @override
  String get wizard_step5SidebarTitle => 'الملخص';

  @override
  String get wizard_step5SidebarDesc => 'مراجعة وإتمام';

  @override
  String get wizard_step1Header => 'اختر نوع الخزانة';

  @override
  String get wizard_step1Subtitle =>
      'حدّد نوع الخزانة التي تريد إدارتها. سيؤثر هذا الاختيار على الخطوات التالية.';

  @override
  String get wizard_cabinTypeNote =>
      'لا يمكن تغيير نوع الخزانة بعد اكتمال الإعداد.';

  @override
  String get wizard_masterCabinSpec1 => 'تكعيبي / جرعة فردية';

  @override
  String get wizard_masterCabinSpec2 => 'على مستوى الجناح';

  @override
  String get wizard_masterCabinDescription =>
      'خزانة ثابتة مثبتة على الجدار أو قائمة بذاتها، تحتوي على مجموعة من أدراج التكعيب والجرعة الفردية.';

  @override
  String get wizard_mobileCabinSpec1 => 'بعجلات';

  @override
  String get wizard_mobileCabinSpec2 => 'على مستوى الغرفة';

  @override
  String get wizard_mobileCabinDescription =>
      'وحدة أدوية متنقلة بعجلات مكوّنة من 4 صفوف، مصممة للتجول في الأجنحة.';

  @override
  String get wizard_step2Header => 'المعلومات الأساسية';

  @override
  String get wizard_step2Subtitle =>
      'أدخل اسم الخزانة وموقعها وإعدادات اتصال الجهاز.';

  @override
  String get wizard_cabinNameLabel => 'اسم الخزانة';

  @override
  String get wizard_cabinNameHint => 'مثال: CB-304';

  @override
  String get wizard_connectionSettingsLabel => 'إعدادات الاتصال';

  @override
  String get wizard_noComPortWarning =>
      'لم يتم العثور على COM Port نشط. تأكد من تثبيت برامج التشغيل.';

  @override
  String get wizard_antennaSettingsLabel => 'إعدادات الهوائي';

  @override
  String get wizard_ipAddressLabel => 'عنوان IP';

  @override
  String get wizard_testConnectionButton => 'اختبار الاتصال';

  @override
  String get wizard_step3Header => 'نطاق الخدمة';

  @override
  String get wizard_step3Subtitle => 'تعريف الأجنحة أو الغرف.';

  @override
  String get wizard_roomBedSelectionLabel => 'اختيار الغرفة والسرير';

  @override
  String get wizard_scanTitle => 'مسح الجهاز';

  @override
  String get wizard_scanDescription =>
      'سيتم قراءة بنية أدراج الخزانة المتصلة تلقائياً عبر المنفذ التسلسلي.';

  @override
  String get wizard_startScanButton => 'بدء المسح';

  @override
  String get wizard_scanningStatus => 'جارٍ مسح الخزانة...';

  @override
  String wizard_scanSuccessBanner(int count) {
    return 'نجح المسح — تم العثور على $count درج';
  }

  @override
  String get wizard_scanSuccessDescription =>
      'تمت قراءة التصميم الداخلي للخزانة من الجهاز بنجاح. يرجى تأكيد البنية أدناه.';

  @override
  String get wizard_scanWrongStructure =>
      'إذا كانت البنية غير صحيحة، ارجع وتحقق من معلومات الاتصال.';

  @override
  String get wizard_rescanButton => 'إعادة المسح';

  @override
  String get wizard_scanErrorBanner =>
      'فشل المسح. تحقق من اتصال COM Port وأعد المحاولة.';

  @override
  String get wizard_scanLogConnecting => 'جارٍ الاتصال بالمنفذ التسلسلي…';

  @override
  String get wizard_scanLogFetchingMetadata => 'جارٍ تحميل تعريفات الأدراج…';

  @override
  String get wizard_scanLogSearchingManager => 'جارٍ البحث عن بطاقة الإدارة…';

  @override
  String get wizard_scanLogScanningCards => 'جارٍ مسح بطاقات التحكم…';

  @override
  String get wizard_scanLogDrawerFound => 'تم العثور على درج';

  @override
  String wizard_drawerLabel(int index) {
    return 'الدرج $index';
  }

  @override
  String wizard_cellCountLabel(int count) {
    return '$count خانة';
  }

  @override
  String wizard_rowCountLabel(int count) {
    return '$count صف';
  }

  @override
  String get wizard_drawerCountLabel => 'عدد الأدراج';

  @override
  String get wizard_addRowButton => 'إضافة صف';

  @override
  String get wizard_removeLastRowButton => 'حذف آخر صف';

  @override
  String get wizard_step5Header => 'الملخص والإتمام';

  @override
  String get wizard_step5Subtitle =>
      'أكّد المعلومات التي أدخلتها. بعد التأكيد سيكتمل الإعداد.';

  @override
  String get wizard_summaryCabinInfoTitle => 'معلومات الخزانة';

  @override
  String get wizard_summaryServiceScopeTitle => 'نطاق الخدمة';

  @override
  String get wizard_summaryDrawerStructureTitle => 'بنية الأدراج';

  @override
  String get wizard_summaryCabinPreviewTitle => 'معاينة الخزانة';

  @override
  String get wizard_summaryLabelType => 'النوع';

  @override
  String get wizard_summaryLabelName => 'الاسم';

  @override
  String get wizard_summaryLabelStation => 'المحطة';

  @override
  String get wizard_summaryLabelRoomCount => 'عدد الغرف';

  @override
  String get wizard_summaryLabelRooms => 'الغرف';

  @override
  String get wizard_summaryLabelBeds => 'الأسرّة';

  @override
  String get wizard_summaryLabelDrawerCount => 'عدد الأدراج';

  @override
  String get wizard_summaryLabelTotalDrawers => 'إجمالي الأدراج';

  @override
  String wizard_summaryLabelDrawerIndexed(int index) {
    return 'الدرج $index';
  }

  @override
  String get wizard_summaryTypeMobile => 'خزانة متنقلة';

  @override
  String get wizard_summaryTypeStandard => 'خزانة ثابتة';

  @override
  String get wizard_summaryLabelComPort => 'COM Port';

  @override
  String get wizard_summaryLabelDvrIp => 'DVR IP';

  @override
  String get wizard_summaryLabelRfidAddress => 'عنوان RFID';

  @override
  String get wizard_summaryLabelRfidPort => 'منفذ RFID';

  @override
  String get wizard_savingMessage => 'جارٍ حفظ الخزانة…';

  @override
  String get wizard_successTitle => 'اكتمل الإعداد!';

  @override
  String wizard_successMessage(String cabinName) {
    return 'تمت إضافة $cabinName إلى النظام بنجاح.';
  }

  @override
  String wizard_successCabinId(int id) {
    return 'معرّف الخزانة: #$id';
  }

  @override
  String get wizard_successDashboardButton => 'الانتقال إلى Dashboard';

  @override
  String get wizard_errorTitle => 'فشل الحفظ';

  @override
  String get wizard_retryButton => 'العودة وإعادة المحاولة';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_systemConfigTitle => 'تهيئة النظام';

  @override
  String get settings_appearanceLabel => 'المظهر';

  @override
  String get settings_generalLabel => 'عام';

  @override
  String get assignment_patientUpdatedSuccess => 'تم تحديث تعيين المريض';

  @override
  String get fault_selectSlotPlaceholder =>
      'لإبلاغ عن عطل، اختر\nدرجاً من اللوحة اليسرى.';
}
