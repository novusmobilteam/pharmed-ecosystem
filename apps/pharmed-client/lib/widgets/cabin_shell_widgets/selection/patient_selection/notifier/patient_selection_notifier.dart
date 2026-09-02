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

import 'dart:async';

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
  GetHospitalizationsByServiceUseCase get _getHospitalizations => ref.read(getHospitalizationsByServiceUseCaseProvider);
  GetActiveHospitalizationsUseCase get _getActiveHospitalizations => ref.read(getActiveHospitalizationsUseCaseProvider);
  CreateUrgentPatientUseCase get _createUrgent => ref.read(createUrgentPatientUseCaseProvider);
  DeleteUrgentPatientUseCase get _deleteUrgent => ref.read(deleteUrgentPatientUseCaseProvider);

  PatientSelectionConfig _config = const PatientSelectionConfig(showFilters: false);
  PatientSelectionConfig get config => _config;

  List<PatientIntakeMode> _availableIntakeModes(PatientSelectionReady s) {
    final canToggleOrderStatus = _config.enableOrderlessToggle && s.isStatusToggleVisible;
    if (canToggleOrderStatus) {
      return const [PatientIntakeMode.ordered, PatientIntakeMode.orderless, PatientIntakeMode.free];
    }
    final fixed = s.viewOrderStatus.isOrderless ? PatientIntakeMode.orderless : PatientIntakeMode.ordered;
    return [fixed, PatientIntakeMode.free];
  }

  @override
  PatientSelectionState build() => const PatientSelectionLoading();

  Future<void> init(PatientSelectionConfig config, Station station) async {
    _config = config;
    state = const PatientSelectionLoading();

    final currentUser = ref.read(authNotifierProvider.notifier).currentUser;

    final isNotOrdered = currentUser?.isNotOrdered ?? false;
    final userOrderStatus = orderStatusFromBool(!isNotOrdered);
    final stationOrderStatus = station.drugStatus;
    final viewOrderStatus = stationOrderStatus.isOrderless ? OrderStatus.orderless : OrderStatus.ordered;

    final canCreateFullCabinUrgent =
        (currentUser?.canCreateEmergencyPatient ?? false) && station.canCreateEmergencyPatient;

    // "Hastalarım" sekmesinde hasta varsa varsayılan görünüm ona göre başlar —
    // ilk fetch'ten ÖNCE bir prob sorgusu atıp bunu kontrol ediyoruz.
    final probeResult = await _fetchMyPatientsProbe(isOrderless: viewOrderStatus.isOrderless);
    final rawMyPatients = probeResult.when(ok: (data) => data, error: (_) => const <Hospitalization>[]);
    // _fetchPatients'taki filtreyle tutarlı: orderless modda acil hastalar hariç.
    final myPatientsList = viewOrderStatus.isOrderless
        ? rawMyPatients.where((d) => !d.isUrgent).toList()
        : rawMyPatients;
    final initialViewType = myPatientsList.isNotEmpty ? PatientViewType.myPatients : PatientViewType.allPatients;

    state = PatientSelectionReady(
      station: station,
      viewOrderStatus: viewOrderStatus,
      userOrderStatus: userOrderStatus,
      intakeMode: viewOrderStatus.isOrderless ? PatientIntakeMode.orderless : PatientIntakeMode.ordered,
      canCreateFullCabinUrgent: canCreateFullCabinUrgent,
      viewType: initialViewType,
      // myPatients ise probe sonucunu doğrudan reuse ediyoruz — allPatients ise
      // aşağıdaki _fetchPatients() dolduracak.
      hospitalizations: initialViewType == PatientViewType.myPatients ? myPatientsList : const [],
    );

    if (initialViewType == PatientViewType.allPatients) {
      await _fetchPatients();
    }
  }

  /// init()'te "Hastalarım" sekmesinin varsayılan olup olmayacağını belirlemek
  /// için atılan tek seferlik sorgu. _fetchPatients()'taki myPatients=true
  /// dallarıyla AYNI çağrı şeklini kullanır (redirected tab hariç — init
  /// her zaman prescriptions sekmesiyle başlar, bu yüzden o dal burada yok).
  Future<Result<List<Hospitalization>>> _fetchMyPatientsProbe({required bool isOrderless}) async {
    if (!config.showFilters) {
      return _getHospitalizations.call(serviceId: 0, filter: PatientFilterType.all, myPatients: true);
    }
    return _getHospitalizations.call(
      serviceId: 0,
      filter: isOrderless ? PatientFilterType.all : PatientFilterType.ordersDue,
      myPatients: true,
    );
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
  Future<void> cycleIntakeMode() async {
    final s = state;
    if (s is! PatientSelectionReady) return;

    final modes = _availableIntakeModes(s);
    final currentIndex = modes.indexOf(s.intakeMode);
    final next = modes[(currentIndex + 1) % modes.length];

    final nextIsOrderStatus = next == PatientIntakeMode.ordered || next == PatientIntakeMode.orderless;
    final nextOrderStatus = next == PatientIntakeMode.orderless
        ? OrderStatus.orderless
        : next == PatientIntakeMode.ordered
        ? OrderStatus.ordered
        : s.viewOrderStatus; // free'ye geçerken viewOrderStatus'a dokunma

    state = s.copyWith(
      intakeMode: next,
      viewOrderStatus: nextOrderStatus,
      filter: nextIsOrderStatus && nextOrderStatus.isOrderless ? PatientFilterType.all : s.filter,
    );
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

  void selectIntakeMode(PatientIntakeMode mode) {
    final s = state;
    if (s is! PatientSelectionReady) return;
    state = s.copyWith(intakeMode: mode);
    // free ↔ ordered/orderless arası geçişte hasta listesi DEĞİŞMİYOR — aynı
    // hospitalization listesi kalıyor, sadece seçimde IntakeType farklılaşıyor.
    // ordered ⟷ orderless arası geçişte ise mevcut _fetchPatients tetiklenmeli.
    if (mode != PatientIntakeMode.free) unawaited(_fetchPatients());
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

  /// İntake kuyruğu tamamlandığında (acil/serbest tek seferlik akış) çağrılır.
  /// deleteUrgentPatient()'tan farkı: backend'e SİLME isteği ATMAZ (alım zaten
  /// tamamlandı, kayıt geçerliliğini korumalı) — sadece panel'in yerelde
  /// tuttuğu "oluşturulan acil hasta" referansını temizleyip normal listeye
  /// döner.
  void clearCreatedUrgentPatient() {
    final s = state;
    if (s is! PatientSelectionReady) return;
    state = s.copyWith(clearCreatedUrgentPatient: true);
  }
}
