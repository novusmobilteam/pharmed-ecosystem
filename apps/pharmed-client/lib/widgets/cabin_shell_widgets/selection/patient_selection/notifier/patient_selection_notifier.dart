// [SWREQ-CLI-PATIENT-002] [IEC 62304 §5.5]
// Master kabin işlemleri için ORTAK hasta seçim çatısının notifier'ı.
//
// Sorumluluk:
//   - İstasyonu çözer, ordered/orderless görünüm modunu belirler
//   - Tek bir birleşik use case ile (serviceId, filter, myPatients) hasta
//     listesini çeker — serviceId=0 "Tümü" (tüm servisler) anlamına gelir.
//   - "Hastalarım" görünümü, arama, acil hasta oluşturma
//
// Hasta seçimi bu notifier'da TUTULMAZ; seçim üst kabuğa (shell) callback /
// dışarıdan yönetilir. Bu notifier yalnızca listeyi ve filtre durumunu yönetir.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../../../core/providers/providers.dart';
import 'patient_selection_state.dart';

final patientSelectionNotifierProvider = NotifierProvider<PatientSelectionNotifier, PatientSelectionState>(
  PatientSelectionNotifier.new,
);

class PatientSelectionNotifier extends Notifier<PatientSelectionState> {
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);
  GetHospitalizationsByServiceUseCase get _getHospitalizations => ref.read(getHospitalizationsByServiceUseCaseProvider);
  GetHospitalizationsUseCase get _getHospitalizationsSimple => ref.read(getHospitalizationsUseCaseProvider);
  CreateUrgentPatientUseCase get _createUrgent => ref.read(createUrgentPatientUseCaseProvider);

  @override
  PatientSelectionState build() => const PatientSelectionLoading();

  Future<void> init({bool showFilters = true}) async {
    state = const PatientSelectionLoading();

    final stationResult = await _getStation.call();
    Station? station;
    stationResult.when(ok: (s) => station = s, error: (_) => station = null);

    final userOrderStatus = orderStatusFromBool(
      ref.read(authNotifierProvider.notifier).currentUser?.isNotOrdered ?? false,
    );
    final stationOrderStatus = station?.drugStatus ?? OrderStatus.ordered;

    final viewOrderStatus = stationOrderStatus.isOrderless
        ? OrderStatus.orderless
        : userOrderStatus.isOrderless
        ? OrderStatus.orderless
        : OrderStatus.ordered;

    state = PatientSelectionReady(
      station: station,
      viewOrderStatus: viewOrderStatus,
      userOrderStatus: userOrderStatus,
      viewType: PatientViewType.allPatients,
      hospitalizations: const [],
      selectedService: null,
      showFilters: showFilters,
    );

    await _fetchPatients();
  }

  // ── Liste çekme ────────────────────────────────────────────────────────────

  /// Birleşik fetch: serviceId (0 = Tümü), filter ve myPatients her zaman
  /// birlikte gönderilir — orderless/ordered ayrımı artık fetch'i dallandırmıyor.
  Future<void> _fetchPatients() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    state = s.copyWith(isFetching: true);

    final Result<List<Hospitalization>> result;
    if (s.showFilters) {
      result = await _getHospitalizations.call(
        serviceId: s.selectedService?.id ?? 0,
        filter: s.filter,
        myPatients: s.viewType == PatientViewType.myPatients,
      );
    } else {
      final apiResult = await _getHospitalizationsSimple.call(const PagedQueryParams());
      result = apiResult.when(ok: (response) => Result.ok(response.data ?? const []), error: (e) => Result.error(e));
    }

    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (data) {
        final filtered = cur.isOrderless ? data.where((d) => !(d.isUrgent)).toList() : data;
        state = cur.copyWith(hospitalizations: filtered, isFetching: false);
      },
      error: (e) => state = PatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  /// "Hastalarım" ↔ "Tüm hastalar".
  Future<void> togglePatientView() async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final next = s.viewType == PatientViewType.allPatients ? PatientViewType.myPatients : PatientViewType.allPatients;
    state = s.copyWith(viewType: next);
    await _fetchPatients();
  }

  /// ordered ↔ orderless mod değişimi (sadece yetki varsa view'da gösterilir).
  /// Servis seçimine artık dokunmuyor — servis/filtre modundan bağımsız.
  Future<void> toggleOrderlessStatus() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    final next = s.viewOrderStatus.isOrderless ? OrderStatus.ordered : OrderStatus.orderless;
    state = s.copyWith(viewOrderStatus: next);
    await _fetchPatients();
  }

  /// Servis filtresi seçimi. `service == null` → "Tümü" (serviceId 0).
  ///
  /// `MedFilterChipGroup` mutually-exclusive bir seçim sunduğu için burada
  /// "tekrar dokununca kapat" (toggle-off) semantiği YOKTUR — seçilen chip
  /// doğrudan uygulanır.
  Future<void> toggleService(HospitalService? service) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    if (s.selectedService?.id == service?.id) return; // zaten seçili, no-op.

    state = s.copyWith(selectedService: service, clearSelectedService: service == null);
    await _fetchPatients();
  }

  /// Reçete/hasta filtresi değiştir (artık orderless modda da geçerli).
  Future<void> changeFilter(PatientFilterType filter) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    state = s.copyWith(filter: filter);
    await _fetchPatients();
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
