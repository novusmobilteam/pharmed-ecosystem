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

/// Liste görünümü: tüm hastalar mı, sadece bana atanmış hastalar mı.
enum PatientViewType { allPatients, myPatients }

sealed class PatientSelectionState {
  const PatientSelectionState();
}

/// İstasyon/hastalar henüz yüklenmedi.
final class PatientSelectionLoading extends PatientSelectionState {
  const PatientSelectionLoading();
}

/// Hasta listesi hazır.
final class PatientSelectionReady extends PatientSelectionState {
  const PatientSelectionReady({
    required this.station,
    required this.viewOrderStatus,
    required this.userOrderStatus,
    this.viewType = PatientViewType.allPatients,
    required this.hospitalizations,
    this.selectedService,
    this.filter = PatientFilterType.ordersDue,
    this.search = '',
    this.isFetching = false,
    this.isCreatingUrgent = false,
    this.showFilters = true,
  });

  final Station? station;

  /// Ekranın o anki order modu (ordered/orderless).
  final OrderStatus viewOrderStatus;

  /// Kullanıcının ordersız yetkisi (toggle görünürlüğü için).
  final OrderStatus userOrderStatus;

  final PatientViewType viewType;

  /// Ham hasta listesi (arama uygulanmadan).
  final List<Hospitalization> hospitalizations;

  /// orderless modda seçili servis (filtre).
  final HospitalService? selectedService;

  /// ordered modda reçete filtresi.
  final PatientFilterType filter;

  final String search;
  final bool isFetching;
  final bool isCreatingUrgent;
  final bool showFilters;

  // ── Türetilen ──────────────────────────────────────────────────────────

  bool get isOrderless => viewOrderStatus.isOrderless;

  OrderStatus get stationOrderStatus => station?.drugStatus ?? OrderStatus.ordered;

  List<HospitalService> get availableServices => station?.services ?? const [];

  /// Toggle butonu: istasyon orderlı VE kullanıcı ordersız yetkisine sahipse.
  bool get isStatusButtonVisible => stationOrderStatus.isOrdered && userOrderStatus.isOrderless;

  /// Acil hasta oluştur: kullanıcı o an ordersız modda işlem yapabiliyorsa.
  bool get isUrgentPatientButtonVisible => viewOrderStatus.isOrderless;

  /// Arama uygulanmış görünür liste.
  List<Hospitalization> get visiblePatients {
    if (search.trim().isEmpty) return hospitalizations;
    final q = search.toLowerCase().trim();
    return hospitalizations.where((h) {
      final name = h.patient?.fullName.toLowerCase() ?? '';
      return name.contains(q);
    }).toList();
  }

  PatientSelectionReady copyWith({
    Station? station,
    OrderStatus? viewOrderStatus,
    OrderStatus? userOrderStatus,
    PatientViewType? viewType,
    List<Hospitalization>? hospitalizations,
    HospitalService? selectedService,
    bool clearSelectedService = false,
    PatientFilterType? filter,
    String? search,
    bool? isFetching,
    bool? isCreatingUrgent,
  }) {
    return PatientSelectionReady(
      station: station ?? this.station,
      viewOrderStatus: viewOrderStatus ?? this.viewOrderStatus,
      userOrderStatus: userOrderStatus ?? this.userOrderStatus,
      viewType: viewType ?? this.viewType,
      hospitalizations: hospitalizations ?? this.hospitalizations,
      selectedService: clearSelectedService ? null : (selectedService ?? this.selectedService),
      filter: filter ?? this.filter,
      search: search ?? this.search,
      isFetching: isFetching ?? this.isFetching,
      isCreatingUrgent: isCreatingUrgent ?? this.isCreatingUrgent,
    );
  }
}

/// Hata.
final class PatientSelectionError extends PatientSelectionState {
  const PatientSelectionError({required this.message, required this.previousState});

  final String message;
  final PatientSelectionState previousState;
}
