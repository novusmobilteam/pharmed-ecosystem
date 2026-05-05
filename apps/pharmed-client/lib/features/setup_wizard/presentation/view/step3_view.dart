// [SWREQ-SETUP-UI-009] [IEC 62304 §5.5]
// Wizard Adım 3 — Hizmet Kapsamı.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../domain/entity/cabin_setup_config.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../notifier/step1_notifier.dart';
import '../notifier/step3_notifier.dart';
import '../state/step3_state.dart';
import '../widgets/step_shared_widgets.dart';

part '../widgets/station_scope.dart';
part '../widgets/room_picker.dart';

class Step3View extends ConsumerStatefulWidget {
  const Step3View({super.key});

  @override
  ConsumerState<Step3View> createState() => _Step3ViewState();
}

class _Step3ViewState extends ConsumerState<Step3View> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(step3NotifierProvider.notifier).loadStations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(step3NotifierProvider);
    final notifier = ref.read(step3NotifierProvider.notifier);
    final wizard = ref.read(setupWizardNotifierProvider.notifier);
    final cabinType = ref.watch(step1NotifierProvider);

    final mobileScope = state.serviceScope is MobileScope ? state.serviceScope as MobileScope : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          badge: 'Adım 3 / 5',
          title: context.l10n.wizard_step3Header,
          subtitle: context.l10n.wizard_step3Subtitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                _StationScopeBody(
                  stationsLoadState: state.stationsLoadState,
                  stations: state.stations,
                  stationsError: state.stationsError,
                  selectedStation: state.serviceScope?.station,
                  onStationSelected: (station) => notifier.onStationSelected(station, cabinType ?? CabinType.master),
                  onRetry: notifier.loadStations,
                ),
                if (mobileScope?.station.type == StationType.patientBased && mobileScope != null) ...[
                  const SizedBox(height: 24),
                  SectionLabel(label: context.l10n.wizard_roomBedSelectionLabel),
                  const SizedBox(height: 12),
                  _RoomBedSection(
                    servicesLoadState: state.servicesLoadState,
                    services: state.services,
                    selectedRooms: mobileScope.rooms,
                    selectedBeds: mobileScope.beds,
                    onChanged: (rooms, beds) =>
                        notifier.updateServiceScope(MobileScope(mobileScope.station, rooms: rooms, beds: beds)),
                  ),
                ],
              ],
            ),
          ),
        ),
        StepFooter(onBack: wizard.previousStep, onNext: state.isComplete ? wizard.nextStep : null),
      ],
    );
  }
}
