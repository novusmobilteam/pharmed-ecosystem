import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/widgets.dart';
import '../../../auth/auth.dart';
import '../notifier/master_intake_notifier.dart';

part 'selection_view.dart';
part 'witness_confirmation_view.dart';
part 'check_failures_dialog.dart';

class MasterIntakeView extends StatefulWidget {
  const MasterIntakeView({super.key, required this.data});

  final CabinVisualizerData data;

  @override
  State<MasterIntakeView> createState() => _MasterIntakeViewState();
}

class _MasterIntakeViewState extends State<MasterIntakeView> {
  late final PatientSelectionNotifier _patientSelection;
  late final MasterIntakeNotifier _intakeNotifier;
  bool _checkFailuresDialogShown = false;

  @override
  void initState() {
    super.initState();
    _patientSelection = PatientSelectionNotifier(
      config: const PatientSelectionConfig(
        showIntakeTabs: true,
        showViewTypeSelector: true,
        showOrderStatusToggle: true,
        showFilterRow: true,
      ),
      authNotifier: context.read(),
      getStation: context.read(),
      getHospitalizations: context.read(),
      getActiveHospitalizations: context.read(),
      createUrgent: context.read(),
      getServices: context.read(),
    )..init();

    _intakeNotifier = MasterIntakeNotifier(
      patientSelection: _patientSelection,
      getItems: context.read(),
      getStation: context.read(),
      checkIntake: context.read(),
      authNotifier: context.read(),
      checkEquivalentIntake: context.read(),
      getOtherStations: context.read(),
      getEquivalents: context.read(),
      redirectIntake: context.read(),
      getPrescriptionDetail: context.read(),
    );
    _intakeNotifier.addListener(_onIntakeNotifierChanged);
  }

  @override
  void dispose() {
    _intakeNotifier.removeListener(_onIntakeNotifierChanged);
    _intakeNotifier.dispose();
    _patientSelection.dispose();
    super.dispose();
  }

  void _onIntakeNotifierChanged() {
    if (_intakeNotifier.hasPendingCheckFailures && !_checkFailuresDialogShown) {
      _checkFailuresDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => CheckFailuresDialog(
            failures: _intakeNotifier.failedCheckItems,
            onCancel: () {
              Navigator.of(context).pop();
              _intakeNotifier.dismissCheckFailures();
            },
            onProceed: () {
              Navigator.of(context).pop();
              _intakeNotifier.confirmProceedDespiteCheckFailures();
            },
          ),
        );
        _checkFailuresDialogShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PatientSelectionNotifier>.value(value: _patientSelection),
        ChangeNotifierProvider<MasterIntakeNotifier>.value(value: _intakeNotifier),
      ],
      child: const _MasterIntakeContent(),
    );
  }
}

class _MasterIntakeContent extends StatelessWidget {
  const _MasterIntakeContent();

  @override
  Widget build(BuildContext context) {
    final intakeTab = context.select<PatientSelectionNotifier, IntakePatientTab>((n) => n.intakeTab);

    return Stack(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: PatientSelectionPanel()),
            VerticalDivider(color: MedColors.text3, width: 1, thickness: 1),
            Expanded(flex: 7, child: MasterIntakeSelectionView(mode: intakeTab.label(context))),
          ],
        ),
        if (context.select<MasterIntakeNotifier, bool>((n) => n.isWitnessFlowOpen)) const WitnessConfirmationOverlay(),
      ],
    );
  }
}
