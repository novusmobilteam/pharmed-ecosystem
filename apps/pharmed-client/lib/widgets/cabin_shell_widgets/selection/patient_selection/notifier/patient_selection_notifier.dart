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
import 'patient_selection_config.dart';
import 'patient_selection_state.dart';

final patientSelectionNotifierProvider = NotifierProvider<PatientSelectionNotifier, PatientSelectionState>(
  PatientSelectionNotifier.new,
);

class PatientSelectionNotifier extends Notifier<PatientSelectionState> {
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);
  GetHospitalizationsByServiceUseCase get _getHospitalizations => ref.read(getHospitalizationsByServiceUseCaseProvider);
  GetActiveHospitalizationsUseCase get _getActiveHospitalizations => ref.read(getActiveHospitalizationsUseCaseProvider);
  CreateUrgentPatientUseCase get _createUrgent => ref.read(createUrgentPatientUseCaseProvider);
  DeleteUrgentPatientUseCase get _deleteUrgent => ref.read(deleteUrgentPatientUseCaseProvider);

  PatientSelectionConfig _config = const PatientSelectionConfig(showFilters: false);
  PatientSelectionConfig get config => _config;

  @override
  PatientSelectionState build() => const PatientSelectionLoading();

  Future<void> init(PatientSelectionConfig config) async {
    _config = config;
    state = const PatientSelectionLoading();

    final stationResult = await _getStation.call();
    Station? station;
    stationResult.when(ok: (s) => station = s, error: (_) => station = null);

    final isNotOrdered = ref.read(authNotifierProvider.notifier).currentUser?.isNotOrdered ?? false;
    final userOrderStatus = orderStatusFromBool(!isNotOrdered);
    final stationOrderStatus = station?.drugStatus ?? OrderStatus.ordered;

    final viewOrderStatus = stationOrderStatus.isOrderless ? OrderStatus.orderless : OrderStatus.ordered;

    state = PatientSelectionReady(
      station: station,
      viewOrderStatus: viewOrderStatus,
      userOrderStatus: userOrderStatus,
      hospitalizations: const [],
    );

    await _fetchPatients();
  }

  // Öncelik sırası (yalnızca BİRİ uygulanır) — urgentCreate dalı KALKTI:
  //   1. enableTabs + redirected tab → myPatients ise birleşik use case,
  //      değilse GetActiveHospitalizationsUseCase (basit liste)
  //   2. !showFilters                → GetActiveHospitalizationsUseCase
  //   3. varsayılan                  → GetHospitalizationsByServiceUseCase
  Future<void> _fetchPatients() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    state = s.copyWith(isFetching: true);

    final Result<List<Hospitalization>> result;

    if (config.enableTabs && s.tab == PatientSelectionTab.redirected) {
      if (s.viewType == PatientViewType.myPatients) {
        result = await _getHospitalizations.call(serviceId: 0, filter: PatientFilterType.all, myPatients: true);
      } else {
        final apiResult = await _getActiveHospitalizations.call(const PagedQueryParams());
        result = apiResult.when(ok: (r) => Result.ok(r.data ?? const []), error: (e) => Result.error(e));
      }
    } else if (!config.showFilters) {
      if (s.viewType == PatientViewType.myPatients) {
        result = await _getHospitalizations.call(serviceId: 0, filter: PatientFilterType.all, myPatients: true);
      } else {
        final apiResult = await _getActiveHospitalizations.call(const PagedQueryParams());
        result = apiResult.when(ok: (r) => Result.ok(r.data ?? const []), error: (e) => Result.error(e));
      }
    } else {
      result = await _getHospitalizations.call(
        serviceId: s.selectedService?.id ?? 0,
        filter: s.isOrderless ? PatientFilterType.all : s.filter,
        myPatients: s.viewType == PatientViewType.myPatients,
      );
    }

    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (data) {
        final filtered = cur.isOrderless ? data.where((d) => !d.isUrgent).toList() : data;
        state = cur.copyWith(hospitalizations: filtered, isFetching: false);
      },
      error: (e) => state = PatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  Future<void> switchTab(PatientSelectionTab tab) async {
    final s = state;
    if (!config.enableTabs || s is! PatientSelectionReady || s.tab == tab) return;
    state = s.copyWith(tab: tab);
    await _fetchPatients();
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
    state = s.copyWith(viewOrderStatus: next, filter: next.isOrderless ? PatientFilterType.all : s.filter);
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
    if (s.selectedService?.id == service?.id) return;

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

  Future<void> createUrgentPatient({
    required int serviceId,
    void Function(Hospitalization patient)? onSuccess,
    void Function(String message)? onFailed,
  }) async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    state = s.copyWith(isCreatingUrgent: true);
    final result = await _createUrgent.call(serviceId);
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    result.when(
      ok: (hospitalization) {
        state = cur.copyWith(isCreatingUrgent: false, createdUrgentPatient: hospitalization);
        if (hospitalization != null) onSuccess?.call(hospitalization);
      },
      error: (e) {
        state = cur.copyWith(isCreatingUrgent: false);
        onFailed?.call(e.message);
      },
    );
  }

  /// Onay kartındaki "Sil" — normal akışa döner. Başarılıysa liste tazelenir
  /// ve `onDeleted` ile üst kabuğa bildirilir (çağıran taraf `selectedPatient`
  /// olarak hâlâ bu hastayı tutuyorsa temizleyebilsin diye).
  Future<void> deleteUrgentPatient({void Function()? onDeleted, void Function(String message)? onFailed}) async {
    final s = state;
    if (s is! PatientSelectionReady) return;
    final patient = s.createdUrgentPatient;
    if (patient == null) return;

    state = s.copyWith(isDeletingUrgent: true);
    final result = await _deleteUrgent.call(patient.patient!.id!);
    final cur = state;
    if (cur is! PatientSelectionReady) return;

    await result.when(
      ok: (_) async {
        state = cur.copyWith(isDeletingUrgent: false, clearCreatedUrgentPatient: true);
        onDeleted?.call();
        await _fetchPatients();
      },
      error: (e) async {
        state = cur.copyWith(isDeletingUrgent: false);
        onFailed?.call(e.message);
      },
    );
  }

  void dismissError() {
    final s = state;
    if (s is! PatientSelectionError) return;
    state = s.previousState;
  }

  /// Dışarıdan (örn. bir alım/iade/fire-imha kuyruğu tamamlandıktan sonra)
  /// listeyi tazelemek için. Mevcut filtre/tab/arama durumunu KORUR — sadece
  /// _fetchPatients'ı tekrar çalıştırır, state'i sıfırlamaz.
  Future<void> refresh() async {
    if (state is! PatientSelectionReady) return;
    await _fetchPatients();
  }
}
