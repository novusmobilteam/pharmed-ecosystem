// [SWREQ-SETUP-UI-008] [IEC 62304 §5.5]
// Setup Wizard Adım 3 — hizmet kapsamı state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/providers/providers.dart';
import '../state/step3_state.dart';

final step3NotifierProvider = NotifierProvider<Step3Notifier, Step3State>(Step3Notifier.new);

class Step3Notifier extends Notifier<Step3State> {
  @override
  Step3State build() => const Step3State();

  Future<void> loadStations() async {
    if (state.stationsLoadState == StationsLoadState.loading) return;

    MedLogger.info(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-SETUP-UI-008', message: 'İstasyon listesi yükleniyor');

    state = state.copyWith(stationsLoadState: StationsLoadState.loading);

    final result = await ref.read(getUnassignedStationsUseCaseProvider).call();

    result.when(
      ok: (stations) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon listesi yüklendi',
          context: {'count': stations.length},
        );
        state = state.copyWith(stationsLoadState: StationsLoadState.loaded, stations: stations);
      },
      error: (e) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon listesi yüklenemedi',
          error: e,
        );
        state = state.copyWith(stationsLoadState: StationsLoadState.error, stationsError: e.message);
      },
    );
  }

  /// Kabin tipine göre davranır:
  ///   Standart → StandartScope kaydeder, servis yüklenmez
  ///   Mobil    → servis detaylarını yükler, MobileScope oluşturur
  Future<void> onStationSelected(Station station, CabinType cabinType) async {
    final stationId = station.id;
    if (stationId == null) return;

    if (cabinType != CabinType.mobile) {
      state = state.copyWith(serviceScope: StandartScope(station));
      return;
    }

    // Mobil: önce scope'u kaydet, ardından servis detaylarını yükle
    state = state.copyWith(
      serviceScope: MobileScope(station, rooms: [], beds: []),
      servicesLoadState: ServicesLoadState.loading,
      services: [],
    );

    // İstasyon detayını çek
    final stationResult = await ref.read(getStationUseCaseProvider).call(stationId);

    Station? stationDetail;
    stationResult.when(
      ok: (value) => stationDetail = value,
      error: (e) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-008',
          message: 'İstasyon detayı yüklenemedi',
          error: e,
        );
        state = state.copyWith(
          servicesLoadState: ServicesLoadState.error,
          servicesError: contextlessL10n().wizard_stationDetailsLoadError,
        );
      },
    );

    if (stationDetail == null) return;

    // patientBased değilse servis yüklemeye gerek yok
    if (stationDetail!.type != StationType.patientBased) {
      state = state.copyWith(servicesLoadState: ServicesLoadState.loaded, services: []);
      return;
    }

    // Servis ID'lerini topla
    final serviceIds = <int>{
      if (stationDetail!.service?.id != null) stationDetail!.service!.id!,
      ...stationDetail!.services.map((s) => s.id).whereType<int>(),
    }.toList();

    if (serviceIds.isEmpty) {
      state = state.copyWith(servicesLoadState: ServicesLoadState.loaded, services: []);
      return;
    }

    // Servisleri paralel çek
    final serviceResults = await Future.wait(
      serviceIds.map((id) => ref.read(getServiceUseCaseProvider).call(id)),
      eagerError: false,
    );

    final loaded = <HospitalService>[];
    for (final result in serviceResults) {
      result.when(
        ok: (service) {
          if (service != null) loaded.add(service);
        },
        error: (e) {
          MedLogger.error(
            unit: 'SW-UNIT-SETUP',
            swreq: 'SWREQ-SETUP-UI-008',
            message: 'Servis detayı yüklenemedi',
            error: e,
          );
        },
      );
    }

    if (loaded.isEmpty) {
      state = state.copyWith(
        servicesLoadState: ServicesLoadState.error,
        servicesError: contextlessL10n().wizard_serviceDetailsLoadError,
      );
      return;
    }

    MedLogger.info(
      unit: 'SW-UNIT-SETUP',
      swreq: 'SWREQ-SETUP-UI-008',
      message: 'Servis detayları yüklendi',
      context: {'count': loaded.length},
    );

    state = state.copyWith(servicesLoadState: ServicesLoadState.loaded, services: loaded);
  }

  /// Mobil kabinde oda/yatak seçimi değişince çağrılır.
  void updateServiceScope(StationScope scope) {
    state = state.copyWith(serviceScope: scope);
  }
}
