// [SWREQ-SETUP-UI-009] [IEC 62304 §5.5]
// Wizard Adım 3 — Hizmet Kapsamı.
// Standart kabin: istasyon listesinden tek seçim.
// Mobil kabin: manuel oda numarası girişi (tag input).
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/setup_wizard/domain/model/cabin_setup_config.dart';
import 'package:pharmed_client/features/setup_wizard/presentation/state/setup_wizard_ui_state.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../widgets/step_shared_widgets.dart';

part 'station_scope.dart';
part 'room_picker.dart';

class Step3StationScope extends StatelessWidget {
  const Step3StationScope({
    super.key,
    required this.cabinetType,
    required this.currentScope,
    required this.stationsLoadState,
    required this.stations,
    required this.stationsError,
    required this.onStationSelected,
    required this.onScopeChanged,
    required this.onRetryStations,
    required this.servicesLoadState,
    required this.services,
    required this.onNext,
    required this.onBack,
  });

  final CabinType cabinetType;
  final StationScope? currentScope;
  final StationsLoadState stationsLoadState;
  final List<Station> stations;
  final String? stationsError;
  final ValueChanged<Station> onStationSelected;
  final ValueChanged<StationScope> onScopeChanged;
  final VoidCallback onRetryStations;
  final ServicesLoadState servicesLoadState;
  final List<HospitalService> services;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final mobileScope = currentScope is MobileScope ? currentScope as MobileScope : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // MARK: Header
        StepHeader(badge: 'Adım 3 / 5', title: 'Hizmet Kapsamı', subtitle: 'Servis veya oda tanımları.'),

        // MARK: Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _StationScopeBody(
                  stationsLoadState: stationsLoadState,
                  stations: stations,
                  stationsError: stationsError,
                  selectedStation: currentScope?.station,
                  onStationSelected: onStationSelected,
                  onRetry: onRetryStations,
                ),
                // Mobil kabin: istasyon seçildiyse oda/yatak picker'ı göster
                if (mobileScope?.station.type == StationType.patientBased && mobileScope != null) ...[
                  const SizedBox(height: 24),
                  SectionLabel(label: 'ODA & YATAK SEÇİMİ'),
                  const SizedBox(height: 12),
                  _RoomBedSection(
                    servicesLoadState: servicesLoadState,
                    services: services,
                    selectedRooms: mobileScope.rooms,
                    selectedBeds: mobileScope.beds,
                    onChanged: (rooms, beds) =>
                        onScopeChanged(MobileScope(mobileScope.station, rooms: rooms, beds: beds)),
                  ),
                ],
              ],
            ),
          ),
        ),

        // MARK: Footer
        StepFooter(onBack: onBack, onNext: onNext),
      ],
    );
  }
}
