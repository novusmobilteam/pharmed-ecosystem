// [SWREQ-SETUP-UI-009] [IEC 62304 §5.5]
// Wizard Adım 3 — Hizmet Kapsamı.
// Standart kabin: istasyon listesinden tek seçim.
// Mobil kabin: manuel oda numarası girişi (tag input).
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/setup_wizard/domain/model/cabin_setup_config.dart';
import 'package:pharmed_client/features/setup_wizard/presentation/state/setup_wizard_ui_state.dart';
import 'package:pharmed_client/shared/widgets/atoms/med_button.dart';
import 'package:pharmed_client/shared/widgets/atoms/med_tokens.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../widgets/step_shared_widgets.dart';

part 'room_scope.dart';
part 'station_scope.dart';

class Step3ServiceScope extends StatelessWidget {
  const Step3ServiceScope({
    super.key,
    required this.cabinetType,
    required this.currentScope,
    required this.stationsLoadState,
    required this.stations,
    required this.stationsError,
    required this.onScopeChanged,
    required this.onRetryStations,
    required this.onNext,
    required this.onBack,
  });

  final CabinType cabinetType;
  final ServiceScope? currentScope;
  final StationsLoadState stationsLoadState;
  final List<Station> stations;
  final String? stationsError;
  final ValueChanged<ServiceScope> onScopeChanged;
  final VoidCallback onRetryStations;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // MARK: Header
        StepHeader(badge: 'Adım 3 / 5', title: 'Hizmet Kapsamı', subtitle: 'Servis veya oda tanımları.'),

        // MARK: Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: cabinetType == CabinType.mobile
                ? _RoomScopeBody(
                    currentScope: currentScope is RoomBased ? currentScope as RoomBased : null,
                    onScopeChanged: onScopeChanged,
                  )
                : _StationScopeBody(
                    stationsLoadState: stationsLoadState,
                    stations: stations,
                    stationsError: stationsError,
                    selectedStationId: currentScope is ServiceBased
                        ? int.tryParse((currentScope as ServiceBased).departmentId ?? '')
                        : null,
                    onStationSelected: (station) => onScopeChanged(
                      ServiceBased(serviceName: station.name ?? '', departmentId: station.id?.toString()),
                    ),
                    onRetry: onRetryStations,
                  ),
          ),
        ),

        // MARK: Footer
        StepFooter(onBack: onBack, onNext: onNext),
      ],
    );
  }
}
