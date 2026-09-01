// [SWREQ-CLI-PATIENT-001] [IEC 62304 §5.5]
// Master kabin işlemleri (alım/iade/imha) için ORTAK hasta seçim çatısının
// state'i. Manager'daki MedicineManagementNotifier'ın Riverpod + sealed-state
// karşılığıdır.
//
// Çatı mantığı:
//   - İstasyon ordered/orderless durumu + kullanıcı yetkisi → viewOrderStatus
//   - orderless: servis filtresi + yatan hasta listesi (+ acil hasta oluştur)
//   - ordered:   reçete filtresi (PatientFilterType) + reçeteli hasta listesi
//   - "Hastalarım" görünümü (her iki modda)
//   - Arama (hasta adı)
//
// Bu state yalnızca hasta SEÇİMİNİ yönetir. Hasta seçilince üst kabuk (shell)
// seçilen Hospitalization'ı alıp alım/iade ekranına geçer.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum PatientSelectionTab { prescriptions, redirected }

enum PatientViewType { allPatients, myPatients }

enum PatientIntakeMode { ordered, orderless, free }

sealed class PatientSelectionState {
  const PatientSelectionState();
}

/// İstasyon/hastalar henüz yüklenmedi.
final class PatientSelectionLoading extends PatientSelectionState {
  const PatientSelectionLoading();
}

final class PatientSelectionReady extends PatientSelectionState {
  const PatientSelectionReady({
    required this.station,
    required this.viewOrderStatus,
    required this.userOrderStatus,
    this.tab = PatientSelectionTab.prescriptions,
    this.viewType = PatientViewType.allPatients,
    required this.hospitalizations,
    this.selectedService,
    this.filter = PatientFilterType.ordersDue,
    this.search = '',
    this.isFetching = false,
    this.isCreatingUrgent = false,
    this.isDeletingUrgent = false,
    // Acil hasta oluşturulunca dolar — dolu olduğu sürece liste yerine
    // onay kartı gösterilir. Silinince (veya hiç oluşturulmadıysa) null.
    this.createdUrgentPatient,
    required this.intakeMode,
    required this.canCreateFullCabinUrgent,
  });

  final Station? station;
  final OrderStatus viewOrderStatus;
  final OrderStatus userOrderStatus;
  final PatientSelectionTab tab;
  final PatientViewType viewType;
  final List<Hospitalization> hospitalizations;
  final HospitalService? selectedService;
  final PatientFilterType filter;
  final String search;
  final bool isFetching;
  final bool isCreatingUrgent;
  final bool isDeletingUrgent;
  final Hospitalization? createdUrgentPatient;
  final PatientIntakeMode intakeMode;
  final bool canCreateFullCabinUrgent;

  // ── Türetilenler ──────────────────────────────────────────────────────

  bool get isOrderless => viewOrderStatus.isOrderless;
  bool get isFreeMode => intakeMode == PatientIntakeMode.free;

  OrderStatus get stationOrderStatus => station?.drugStatus ?? OrderStatus.ordered;
  List<HospitalService> get availableServices => station?.services ?? const [];
  bool get isStatusToggleVisible => userOrderStatus.isOrderless;

  /// Acil hasta oluştur BUTONU (config.enableUrgentPatient ile birlikte
  /// çalışır — bkz. PatientSelectionPanel). Sadece Reçeteler sekmesinde +
  /// orderless modda anlamlı; bir acil hasta zaten oluşturulmuşken de
  /// gizlenir (onun yerine onay kartı gösterilir).
  bool get isUrgentActionVisible => tab == PatientSelectionTab.prescriptions && createdUrgentPatient == null;

  bool get isOrderedFilterActive => tab == PatientSelectionTab.prescriptions && !isOrderless;
  bool get isMyPatientsToggleEnabled => tab == PatientSelectionTab.prescriptions;

  List<Hospitalization> get visiblePatients {
    if (search.trim().isEmpty) return hospitalizations;
    final q = search.toLowerCase().trim();
    return hospitalizations.where((h) => (h.patient?.fullName.toLowerCase() ?? '').contains(q)).toList();
  }

  PatientSelectionReady copyWith({
    Station? station,
    OrderStatus? viewOrderStatus,
    OrderStatus? userOrderStatus,
    PatientSelectionTab? tab,
    PatientViewType? viewType,
    List<Hospitalization>? hospitalizations,
    HospitalService? selectedService,
    bool clearSelectedService = false,
    PatientFilterType? filter,
    String? search,
    bool? isFetching,
    bool? isCreatingUrgent,
    bool? isDeletingUrgent,
    Hospitalization? createdUrgentPatient,
    bool clearCreatedUrgentPatient = false,
    PatientIntakeMode? intakeMode,
    bool? canCreateFullCabinUrgent,
  }) {
    return PatientSelectionReady(
      station: station ?? this.station,
      viewOrderStatus: viewOrderStatus ?? this.viewOrderStatus,
      userOrderStatus: userOrderStatus ?? this.userOrderStatus,
      tab: tab ?? this.tab,
      viewType: viewType ?? this.viewType,
      hospitalizations: hospitalizations ?? this.hospitalizations,
      selectedService: clearSelectedService ? null : (selectedService ?? this.selectedService),
      filter: filter ?? this.filter,
      search: search ?? this.search,
      isFetching: isFetching ?? this.isFetching,
      isCreatingUrgent: isCreatingUrgent ?? this.isCreatingUrgent,
      isDeletingUrgent: isDeletingUrgent ?? this.isDeletingUrgent,
      createdUrgentPatient: clearCreatedUrgentPatient ? null : (createdUrgentPatient ?? this.createdUrgentPatient),
      intakeMode: intakeMode ?? this.intakeMode,
      canCreateFullCabinUrgent: canCreateFullCabinUrgent ?? this.canCreateFullCabinUrgent,
    );
  }
}

/// Hata.
final class PatientSelectionError extends PatientSelectionState {
  const PatientSelectionError({required this.message, required this.previousState});

  final String message;
  final PatientSelectionReady previousState;
}
