// [SWREQ-SETUP-UI-008] [IEC 62304 §5.5]
// Setup Wizard Adım 3 — hizmet kapsamı state tanımları.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

// ── State ─────────────────────────────────────────────────────────────────

class Step3State {
  const Step3State({
    this.serviceScope,
    this.stationsLoadState = StationsLoadState.idle,
    this.stations = const [],
    this.stationsError,
    this.servicesLoadState = ServicesLoadState.idle,
    this.services = const [],
    this.servicesError,
  });

  final StationScope? serviceScope;

  final StationsLoadState stationsLoadState;
  final List<Station> stations;
  final String? stationsError;

  final ServicesLoadState servicesLoadState;
  final List<HospitalService> services;
  final String? servicesError;

  bool get isComplete => serviceScope != null;

  Step3State copyWith({
    StationScope? serviceScope,
    StationsLoadState? stationsLoadState,
    List<Station>? stations,
    String? stationsError,
    ServicesLoadState? servicesLoadState,
    List<HospitalService>? services,
    String? servicesError,
  }) {
    return Step3State(
      serviceScope: serviceScope ?? this.serviceScope,
      stationsLoadState: stationsLoadState ?? this.stationsLoadState,
      stations: stations ?? this.stations,
      stationsError: stationsError ?? this.stationsError,
      servicesLoadState: servicesLoadState ?? this.servicesLoadState,
      services: services ?? this.services,
      servicesError: servicesError ?? this.servicesError,
    );
  }
}

enum StationsLoadState { idle, loading, loaded, error }

enum ServicesLoadState { idle, loading, loaded, error }
