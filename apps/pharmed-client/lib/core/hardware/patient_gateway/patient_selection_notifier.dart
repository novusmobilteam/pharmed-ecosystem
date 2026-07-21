// [SWREQ-CLI-PATIENT-002] [IEC 62304 §5.5]
// Master kabin işlemleri için ORTAK hasta seçim çatısının notifier'ı.
// Manager'daki MedicineManagementNotifier'ın Riverpod + sealed-state karşılığı.
//
// Sorumluluk:
//   - İstasyonu çözer, ordered/orderless görünüm modunu belirler
//   - orderless: servis bazlı yatan hasta listesi; ordered: filtreli reçete listesi
//   - "Hastalarım" görünümü, arama, acil hasta oluşturma
//
// Hasta seçimi bu notifier'da TUTULMAZ; seçim üst kabuğa (shell) callback /
// dışarıdan yönetilir. Bu notifier yalnızca listeyi ve filtre durumunu yönetir.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import 'patient_selection_state.dart';

final patientSelectionNotifierProvider = NotifierProvider<PatientSelectionNotifier, PatientSelectionState>(
  PatientSelectionNotifier.new,
);

class PatientSelectionNotifier extends Notifier<PatientSelectionState> {
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);
  GetHospitalizationsByServiceUseCase get _getByService => ref.read(getHospitalizationsByServiceUseCaseProvider);
  GetFilteredHospitalizationsUseCase get _getFiltered => ref.read(getFilteredHospitalizationsUseCaseProvider);
  GetMyPatientsUseCase get _getMyPatients => ref.read(getMyPatientsUseCaseProvider);
  CreateUrgentPatientUseCase get _createUrgent => ref.read(createUrgentPatientUseCaseProvider);

  @override
  PatientSelectionState build() => const PatientSelectionLoading();

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    state = const PatientSelectionLoading();

    final stationResult = await _getStation.call();
    Station? station;
    stationResult.when(ok: (s) => station = s, error: (_) => station = null);

    // Görünüm modu kararı (MedicineManagementNotifier.initialize mantığı).
    // TODO[imza-teyit]: kullanıcı order yetkisi kaynağı. Manager'da sabit
    // OrderStatus.ordered dönüyordu; client'ta auth/kullanıcıdan gelebilir.

    final userOrderStatus = orderStatusFromBool(
      ref.read(authNotifierProvider.notifier).currentUser?.isNotOrdered ?? false,
    );
    final stationOrderStatus = station?.drugStatus ?? OrderStatus.ordered;

    final viewOrderStatus = stationOrderStatus.isOrderless
        ? OrderStatus.orderless
        : userOrderStatus.isOrderless
        ? OrderStatus.orderless
        : OrderStatus.ordered;

    final services = station?.services ?? const [];
    final selectedService = (viewOrderStatus.isOrderless && services.isNotEmpty) ? services.first : null;

    state = PatientSelectionReady(
      station: station,
      viewOrderStatus: viewOrderStatus,
      userOrderStatus: userOrderStatus,
      viewType: PatientViewType.allPatients,
      hospitalizations: const [],
      selectedService: selectedService,
    );

    await _fetchPatients();
  }

  // ── Liste çekme ────────────────────────────────────────────────────────────

  Future<void> _fetchPatients() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    if (s.viewType == PatientViewType.myPatients) {
      await _fetchMyPatients();
    } else if (s.isOrderless) {
      await _fetchByService();
    } else {
      await _fetchFiltered();
    }
  }

  Future<void> _fetchByService() async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final serviceId = s.selectedService?.id;
    if (serviceId == null) {
      state = s.copyWith(hospitalizations: const [], isFetching: false);
      return;
    }

    state = s.copyWith(isFetching: true);
    final result = await _getByService.call(serviceId);
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (data) =>
          state = cur.copyWith(hospitalizations: data.where((d) => !(d.isUrgent)).toList(), isFetching: false),
      error: (e) => state = PatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  Future<void> _fetchFiltered() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    state = s.copyWith(isFetching: true);
    final result = await _getFiltered.call(s.filter);
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (data) => state = cur.copyWith(hospitalizations: data, isFetching: false),
      error: (e) => state = PatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  Future<void> _fetchMyPatients() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    state = s.copyWith(isFetching: true);
    final result = await _getMyPatients.call();
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (data) => state = cur.copyWith(
        hospitalizations: data.map((d) => d.hospitalization ?? Hospitalization()).toList(),
        isFetching: false,
      ),
      error: (e) => state = PatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  // ── Toggle / filtre ────────────────────────────────────────────────────────

  /// "Hastalarım" ↔ "Tüm hastalar".
  Future<void> togglePatientView() async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final next = s.viewType == PatientViewType.allPatients ? PatientViewType.myPatients : PatientViewType.allPatients;
    state = s.copyWith(viewType: next);
    await _fetchPatients();
  }

  /// ordered ↔ orderless mod değişimi (sadece yetki varsa view'da gösterilir).
  Future<void> toggleOrderlessStatus() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    final next = s.viewOrderStatus.isOrderless ? OrderStatus.ordered : OrderStatus.orderless;
    final services = s.availableServices;
    final selectedService = (next.isOrderless && services.isNotEmpty) ? services.first : null;

    state = s.copyWith(
      viewOrderStatus: next,
      selectedService: selectedService,
      clearSelectedService: selectedService == null,
    );
    await _fetchPatients();
  }

  /// orderless modda servis seç/çıkar.
  Future<void> toggleService(HospitalService? service) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final same = s.selectedService?.id == service?.id;
    state = s.copyWith(selectedService: same ? null : service, clearSelectedService: same);
    await _fetchByService();
  }

  /// ordered modda reçete filtresi değiştir.
  Future<void> changeFilter(PatientFilterType filter) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    state = s.copyWith(filter: filter);
    await _fetchFiltered();
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! PatientSelectionReady) return;
    state = s.copyWith(search: value);
  }

  /// Acil hasta oluştur. Başarılıysa onSuccess ile oluşan hospitalization döner
  /// (shell doğrudan alım ekranına geçebilir).
  Future<void> createUrgentPatient({
    void Function(Hospitalization patient)? onSuccess,
    void Function(String message)? onFailed,
  }) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final serviceId = s.selectedService?.id ?? 0;

    state = s.copyWith(isCreatingUrgent: true);
    final result = await _createUrgent.call(serviceId);
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (hospitalization) {
        state = cur.copyWith(isCreatingUrgent: false);
        onSuccess?.call(hospitalization!);
        _fetchPatients();
      },
      error: (e) {
        state = cur.copyWith(isCreatingUrgent: false);
        onFailed?.call(e.message);
      },
    );
  }

  void dismissError() {
    final s = state;
    if (s is! PatientSelectionError) return;
    state = s.previousState;
  }
}
