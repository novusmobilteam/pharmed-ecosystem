// features/intake/patient_selection/notifier/intake_patient_selection_state.dart
//
// [SWREQ-CLI-MINTAKE-XXX] [IEC 62304 §5.5]
// İlaç alım ekranına ÖZEL hasta seçim paneli state'i.
//
// Eski PatientSelectionState'in yerini alır — artık iade/imha ile
// PAYLAŞILMIYOR (bkz. patient-gateway skill notu). Bu state iki ekseni
// birlikte taşır:
//   - tab: prescriptions (reçeteler) / redirected (yönlendirilmiş siparişler)
//   - mode: browse (normal liste) / urgentCreate (acil hasta oluşturma görünümü)
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

enum IntakePatientTab { prescriptions, redirected }

enum PatientViewType { allPatients, myPatients, urgent }

enum PatientListMode { browse, urgentCreate }

sealed class IntakePatientSelectionState {
  const IntakePatientSelectionState();
}

final class IntakePatientSelectionLoading extends IntakePatientSelectionState {
  const IntakePatientSelectionLoading();
}

final class IntakePatientSelectionReady extends IntakePatientSelectionState {
  const IntakePatientSelectionReady({
    required this.station,
    required this.viewOrderStatus,
    required this.userOrderStatus,
    this.tab = IntakePatientTab.prescriptions,
    this.mode = PatientListMode.browse,
    this.viewType = PatientViewType.allPatients,
    required this.hospitalizations,
    this.selectedService,
    this.filter = PatientFilterType.ordersDue,
    this.search = '',
    this.isFetching = false,
    this.urgentTargetService,
    this.isCreatingUrgent = false,
  });

  final Station? station;

  /// Ekranın o anki order modu (ordered/orderless).
  final OrderStatus viewOrderStatus;

  /// Kullanıcının ordersız yetkisi (toggle görünürlüğü için).
  final OrderStatus userOrderStatus;

  final IntakePatientTab tab;
  final PatientListMode mode;
  final PatientViewType viewType;

  /// Ham hasta listesi (arama uygulanmadan). Tab/mode değiştiğinde
  /// _fetchPatients ile yenilenir.
  final List<Hospitalization> hospitalizations;

  /// Reçeteler tabında servis filtresi (Tümü/mode=browse iken).
  final HospitalService? selectedService;

  /// Reçeteler tabında + ordered modda durum filtresi.
  final PatientFilterType filter;

  final String search;
  final bool isFetching;

  /// urgentCreate modunda hedef servis. Tek servis varsa mode'a girişte
  /// otomatik doldurulur, kullanıcı elle seçmez.
  final HospitalService? urgentTargetService;
  final bool isCreatingUrgent;

  // ── Türetilenler ──────────────────────────────────────────────────────

  bool get isOrderless => viewOrderStatus.isOrderless;

  OrderStatus get stationOrderStatus => station?.drugStatus ?? OrderStatus.ordered;

  List<HospitalService> get availableServices => station?.services ?? const [];

  /// Ordered/orderless geçiş toggle'ı: istasyon orderlı ama kullanıcı
  /// ordersız yetkiliyse gösterilir.
  bool get isStatusToggleVisible => userOrderStatus.isOrderless;

  /// Acil hasta segmenti: sadece Reçeteler tabında VE orderless modda.
  bool get isUrgentSegmentVisible => tab == IntakePatientTab.prescriptions && isOrderless;

  /// Filtre dialogu: durum filtresi sadece ordered modda anlamlı.
  bool get showStatusFilter => tab == IntakePatientTab.prescriptions && !isOrderless == false && !isOrderless;
  // ↑ okunabilirlik için ayrıştırıyoruz:
  bool get isOrderedFilterModeActive => tab == IntakePatientTab.prescriptions && !isOrderless;

  /// Servis seçimi elle mi yapılmalı (urgentCreate'e girişte).
  bool get requiresManualUrgentServiceSelection => availableServices.length > 1;

  /// Yönlendirilmiş sipariş tabında "Hastalarım" toggle'ı şu an backend
  /// desteklemiyor — teyit edilene kadar disabled tutulur (bkz. sohbet notu).
  bool get isMyPatientsToggleEnabled => tab == IntakePatientTab.prescriptions;

  /// Durum filtresi sadece Reçeteler tabında + ordered modda anlamlı.
  bool get isOrderedFilterActive => tab == IntakePatientTab.prescriptions && !isOrderless;

  List<Hospitalization> get visiblePatients {
    if (search.trim().isEmpty) return hospitalizations;
    final q = search.toLowerCase().trim();
    return hospitalizations.where((h) => (h.patient?.fullName.toLowerCase() ?? '').contains(q)).toList();
  }

  IntakePatientSelectionReady copyWith({
    Station? station,
    OrderStatus? viewOrderStatus,
    OrderStatus? userOrderStatus,
    IntakePatientTab? tab,
    PatientListMode? mode,
    PatientViewType? viewType,
    List<Hospitalization>? hospitalizations,
    HospitalService? selectedService,
    bool clearSelectedService = false,
    PatientFilterType? filter,
    String? search,
    bool? isFetching,
    HospitalService? urgentTargetService,
    bool clearUrgentTargetService = false,
    bool? isCreatingUrgent,
  }) {
    return IntakePatientSelectionReady(
      station: station ?? this.station,
      viewOrderStatus: viewOrderStatus ?? this.viewOrderStatus,
      userOrderStatus: userOrderStatus ?? this.userOrderStatus,
      tab: tab ?? this.tab,
      mode: mode ?? this.mode,
      viewType: viewType ?? this.viewType,
      hospitalizations: hospitalizations ?? this.hospitalizations,
      selectedService: clearSelectedService ? null : (selectedService ?? this.selectedService),
      filter: filter ?? this.filter,
      search: search ?? this.search,
      isFetching: isFetching ?? this.isFetching,
      urgentTargetService: clearUrgentTargetService ? null : (urgentTargetService ?? this.urgentTargetService),
      isCreatingUrgent: isCreatingUrgent ?? this.isCreatingUrgent,
    );
  }
}

final class IntakePatientSelectionError extends IntakePatientSelectionState {
  const IntakePatientSelectionError({required this.message, required this.previousState});

  final String message;
  final IntakePatientSelectionReady previousState;
}
