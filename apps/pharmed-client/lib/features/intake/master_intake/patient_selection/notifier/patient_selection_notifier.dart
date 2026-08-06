// features/intake/patient_selection/notifier/intake_patient_selection_notifier.dart
//
// [SWREQ-CLI-MINTAKE-XXX] [IEC 62304 §5.5]
// İlaç alım ekranına özel hasta seçim notifier'ı. Reçeteler + Yönlendirilmiş
// Siparişler tab'larını TEK panel içinde, tek fetch stratejisiyle yönetir.
// Acil hasta oluşturma ayrı bir mod (urgentCreate) olarak ele alınır, dialog
// DEĞİLDİR.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../../../../core/providers/providers.dart';
import 'patient_selection_state.dart';

final intakePatientSelectionNotifierProvider =
    NotifierProvider<IntakePatientSelectionNotifier, IntakePatientSelectionState>(IntakePatientSelectionNotifier.new);

class IntakePatientSelectionNotifier extends Notifier<IntakePatientSelectionState> {
  GetCurrentStationUseCase get _getStation => ref.read(getCurrentStationUseCaseProvider);
  GetHospitalizationsByServiceUseCase get _getHospitalizations => ref.read(getHospitalizationsByServiceUseCaseProvider);
  GetActiveHospitalizationsUseCase get _getActiveHospitalizations => ref.read(getActiveHospitalizationsUseCaseProvider);
  CreateUrgentPatientUseCase get _createUrgent => ref.read(createUrgentPatientUseCaseProvider);
  GetUrgentPatientsUseCase get _getUrgentPatients => ref.read(getUrgentPatientsUseCaseProvider);

  @override
  IntakePatientSelectionState build() => const IntakePatientSelectionLoading();

  Future<void> init() async {
    state = const IntakePatientSelectionLoading();

    final stationResult = await _getStation.call();
    Station? station;
    stationResult.when(ok: (s) => station = s, error: (_) => station = null);

    final isNotOrdered = ref.read(authNotifierProvider.notifier).currentUser?.isNotOrdered ?? false;
    final userOrderStatus = orderStatusFromBool(!isNotOrdered);

    final stationOrderStatus = station?.drugStatus ?? OrderStatus.ordered;

    final viewOrderStatus = stationOrderStatus.isOrderless
        ? OrderStatus.orderless
        : userOrderStatus.isOrderless
        ? OrderStatus.orderless
        : OrderStatus.ordered;

    state = IntakePatientSelectionReady(
      station: station,
      viewOrderStatus: viewOrderStatus,
      userOrderStatus: userOrderStatus,
      hospitalizations: const [],
    );

    await _fetchPatients();
  }

  // ── Liste çekme ────────────────────────────────────────────────────────

  Future<void> _fetchPatients() async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;

    state = s.copyWith(isFetching: true);

    final Result<List<Hospitalization>> result;
    switch (s.tab) {
      case IntakePatientTab.prescriptions:
        if (s.mode == PatientListMode.urgentCreate) {
          result = await _getUrgentPatients.call();
        } else {
          result = await _getHospitalizations.call(
            serviceId: s.selectedService?.id ?? 0,
            filter: s.isOrderless ? PatientFilterType.all : s.filter,
            myPatients: s.viewType == PatientViewType.myPatients,
          );
        }

      case IntakePatientTab.redirected:
        if (s.viewType == PatientViewType.myPatients) {
          // "Hastalarım" her zaman aktif yatışlar arasında olduğu için,
          // redirected tab'da da ayrı bir uç nokta yerine aynı birleşik
          // use case'e myPatients:true ile gidiyoruz. Servis/durum filtresi
          // redirected'de gösterilmediği için nötr değerlerle çağrılır.
          result = await _getHospitalizations.call(serviceId: 0, filter: PatientFilterType.all, myPatients: true);
        } else {
          final apiResult = await _getActiveHospitalizations.call(const PagedQueryParams());
          result = apiResult.when(
            ok: (response) => Result.ok(response.data ?? const []),
            error: (e) => Result.error(e),
          );
        }
    }

    final cur = state;
    if (cur is! IntakePatientSelectionReady) return;

    result.when(
      ok: (data) {
        var filtered = data;
        if (cur.mode == PatientListMode.urgentCreate) {
          final serviceId = cur.selectedService?.id;
          if (serviceId != null) {
            filtered = filtered.where((h) => h.physicalService?.id == serviceId).toList();
          }
        }
        state = cur.copyWith(hospitalizations: filtered, isFetching: false);
      },
      error: (e) =>
          state = IntakePatientSelectionError(message: e.message, previousState: cur.copyWith(isFetching: false)),
    );
  }

  // ── Tab geçişi ────────────────────────────────────────────────────────

  Future<void> switchTab(IntakePatientTab tab) async {
    final s = state;
    if (s is! IntakePatientSelectionReady || s.tab == tab) return;
    state = s.copyWith(tab: tab, mode: PatientListMode.browse, clearUrgentTargetService: true);
    await _fetchPatients();
  }

  // ── Hastalarım ↔ Tüm hastalar ────────────────────────────────────────

  Future<void> togglePatientView() async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return; // isMyPatientsToggleEnabled kontrolü kaldırıldı
    final next = s.viewType == PatientViewType.allPatients ? PatientViewType.myPatients : PatientViewType.allPatients;
    state = s.copyWith(viewType: next);
    await _fetchPatients();
  }

  // ── Ordered ↔ Orderless ──────────────────────────────────────────────

  Future<void> toggleOrderlessStatus() async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;

    final next = s.viewOrderStatus.isOrderless ? OrderStatus.ordered : OrderStatus.orderless;

    state = s.copyWith(
      viewOrderStatus: next,
      mode: PatientListMode.browse,
      clearUrgentTargetService: true,
      // Durum filtresi (PatientFilterType) sadece ordered modda anlamlı.
      // Orderless'a geçerken sıfırlanmazsa bir önceki ordered filtresi
      // (örn. "Order saati gelenler") boş sonuç dönene kadar sessizce
      // backend'e gitmeye devam eder.
      filter: next.isOrderless ? PatientFilterType.all : s.filter,
    );
    await _fetchPatients();
  }

  // ── Servis filtresi (browse modu) ────────────────────────────────────

  Future<void> toggleService(HospitalService? service) async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;
    if (s.selectedService?.id == service?.id) return;
    state = s.copyWith(selectedService: service, clearSelectedService: service == null);
    await _fetchPatients();
  }

  Future<void> changeFilter(PatientFilterType filter) async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;
    state = s.copyWith(filter: filter);
    await _fetchPatients();
  }

  void onSearchChanged(String value) {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;
    state = s.copyWith(search: value);
  }

  // ── Acil hasta modu ───────────────────────────────────────────────────

  Future<void> enterUrgentCreateMode() async {
    final s = state;
    if (s is! IntakePatientSelectionReady || !s.isUrgentSegmentVisible) return;

    final autoService = s.requiresManualUrgentServiceSelection ? null : s.availableServices.firstOrNull;
    state = s.copyWith(
      mode: PatientListMode.urgentCreate,
      urgentTargetService: autoService,
      clearUrgentTargetService: autoService == null,
    );
    await _fetchPatients();
  }

  Future<void> exitUrgentCreateMode() async {
    final s = state;
    if (s is! IntakePatientSelectionReady || s.mode != PatientListMode.urgentCreate) return;
    state = s.copyWith(mode: PatientListMode.browse, clearUrgentTargetService: true);
    await _fetchPatients();
  }

  Future<void> selectUrgentTargetService(HospitalService service) async {
    final s = state;
    if (s is! IntakePatientSelectionReady || s.mode != PatientListMode.urgentCreate) return;
    if (s.urgentTargetService?.id == service.id) return;
    state = s.copyWith(urgentTargetService: service);
    await _fetchPatients();
  }

  /// Acil hasta oluştur. Dönen hasta listenin BAŞINA eklenir; seçim işi
  /// (onCreated callback ile) çağıran view'a bırakılır — view bu hastayı
  /// hem `selectedPatient` yapar hem downstream notifier'a iletir.
  Future<void> createUrgentPatient({
    required int serviceId,
    required void Function(Hospitalization patient) onCreated,
    void Function(String message)? onFailed,
  }) async {
    final s = state;
    if (s is! IntakePatientSelectionReady) return;

    state = s.copyWith(isCreatingUrgent: true);
    final result = await _createUrgent.call(serviceId);
    final cur = state;
    if (cur is! IntakePatientSelectionReady) return;

    await result.when(
      ok: (hospitalization) async {
        if (hospitalization == null) {
          state = cur.copyWith(isCreatingUrgent: false);
          return;
        }
        state = cur.copyWith(isCreatingUrgent: false);
        onCreated(hospitalization); // downstream'e (selectPatient) hemen iletilir
        if (cur.mode == PatientListMode.urgentCreate) {
          await _fetchPatients(); // liste tazelenir, tam veriyle
        }
      },
      error: (e) async {
        state = cur.copyWith(isCreatingUrgent: false);
        onFailed?.call(e.message);
      },
    );
  }

  void dismissError() {
    final s = state;
    if (s is! IntakePatientSelectionError) return;
    state = s.previousState;
  }

  /// Sekme/hasta bağlamı sıfırlanırken (örn. kuyruk bitti, ekran kapandı)
  /// çağrılır — mevcut tab/mode korunur, sadece seçim üst kabuğa aittir,
  /// buradan sıfırlanacak bir şey yok (notifier zaten seçim tutmuyor).
}
