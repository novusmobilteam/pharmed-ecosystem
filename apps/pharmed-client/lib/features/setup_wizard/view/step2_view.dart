// [SWREQ-SETUP-UI-012] [IEC 62304 §5.5]
// Adım 2 — Kabin temel bilgileri.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/setup_wizard_notifier.dart';
import '../notifier/step2_notifier.dart';
import '../state/step2_state.dart';
import '../widgets/step_shared_widgets.dart';

part '../widgets/rfid_test_button.dart';
part '../widgets/cabin_card_test_button.dart';

class Step2View extends ConsumerStatefulWidget {
  const Step2View({super.key});

  @override
  ConsumerState<Step2View> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends ConsumerState<Step2View> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rfidPortController;

  late String _ipAddress;
  late String _port;
  late String _dvrIp;
  late bool _rfidEnable;
  late String _rfidIpAddress;

  @override
  void initState() {
    super.initState();
    final info = ref.read(step2NotifierProvider).basicInfo;
    _nameCtrl = TextEditingController(text: info?.cabinName ?? '');
    _rfidPortController = TextEditingController(text: info?.rfidPort ?? '6000');
    _port = info?.comPort ?? '';
    _dvrIp = info?.dvrIp ?? '';
    _ipAddress = info?.ipAddress ?? '';
    _rfidEnable = info?.rfidEnable ?? false;
    _rfidIpAddress = info?.rfidIpAddress ?? '192.168.1.190';
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rfidPortController.dispose();
    super.dispose();
  }

  void _notify() {
    ref
        .read(step2NotifierProvider.notifier)
        .updateBasicInfo(
          WizardBasicInfo(
            comPort: _port,
            dvrIp: _dvrIp,
            cabinName: _nameCtrl.text.trim(),
            ipAddress: _ipAddress,
            rfidPort: _rfidPortController.text.trim(),
            rfidEnable: _rfidEnable,
            rfidIpAddress: _rfidIpAddress,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(step2NotifierProvider);
    final notifier = ref.read(step2NotifierProvider.notifier);
    final wizard = ref.read(setupWizardNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepHeader(
          badge: context.l10n.wizard_stepBadge(2, 5),
          title: context.l10n.wizard_step2Header,
          subtitle: context.l10n.wizard_step2Subtitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MedTextInputField(
                  controller: _nameCtrl,
                  label: context.l10n.wizard_cabinNameLabel,
                  onChanged: (_) => _notify(),
                ),
                const SizedBox(height: 24),

                // ── Bağlantı ──
                SectionLabel(label: context.l10n.wizard_connectionSettingsLabel),
                const SizedBox(height: 12),
                Column(children: [_ipAddressField(state), const SizedBox(height: 12), _dvrIpField()]),
                const SizedBox(height: 12),
                // _CabinCardTestButton(
                //   port: _port,
                //   testState: state.cabinCardTestState,
                //   onTestCabinCard: notifier.testCabinConnection,
                //   cabinCardTestError: state.cabinTestError,
                // ),
                if (state.availablePorts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.wizard_noComPortWarning,
                      style: TextStyle(color: MedColors.ledRed, fontSize: 11),
                    ),
                  ),

                // ── Anten ──
                const SizedBox(height: 24),
                SectionLabel(label: context.l10n.wizard_antennaSettingsLabel),
                _antennaField(state, notifier),
              ],
            ),
          ),
        ),
        StepFooter(onBack: wizard.previousStep, onNext: state.isComplete ? wizard.nextStep : null),
      ],
    );
  }

  Row _ipAddressField(Step2State state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedIpField(
                initialValue: _ipAddress,
                label: context.l10n.wizard_ipAddressLabel,
                onChanged: (ip) {
                  _ipAddress = ip;
                  _notify();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: MedDropdownInputField<String>(
            label: context.l10n.wizard_portLabel,
            enabled: state.availablePorts.isNotEmpty,
            onChanged: (val) {
              setState(() => _port = val ?? '');
              _notify();
            },
            options: state.availablePorts.map((p) => p).toList(),
            labelBuilder: (p) => p,
          ),
        ),
      ],
    );
  }

  Column _dvrIpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedIpField(
          label: context.l10n.wizard_summaryLabelDvrIp,
          initialValue: _dvrIp,
          onChanged: (ip) {
            _dvrIp = ip;
            _notify();
          },
        ),
      ],
    );
  }

  Column _antennaField(Step2State state, Step2Notifier notifier) {
    return Column(
      children: [
        MedToggleField(
          value: _rfidEnable,
          onChanged: (value) {
            setState(() => _rfidEnable = value);
            _notify();
          },
          label: context.l10n.wizard_rfidReaderToggleLabel,
        ),
        if (_rfidEnable)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: MedIpField(
                      label: context.l10n.wizard_rfidIpAddressLabel,
                      initialValue: _rfidIpAddress,
                      onChanged: (ip) {
                        _rfidIpAddress = ip;
                        _notify();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: MedTextInputField(
                      label: context.l10n.wizard_rfidPortFieldLabel,
                      controller: _rfidPortController,
                      enabled: state.availablePorts.isNotEmpty,
                      onChanged: (_) => _notify(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RfidTestButton(
                ipAddress: _rfidIpAddress,
                port: _rfidPortController.text,
                testState: state.rfidTestState,
                readerInfo: state.rfidReaderInfo,
                rfidTestError: state.rfidTestError,
                onTestRfid: notifier.testRfidConnection,
              ),
            ],
          ),
      ],
    );
  }
}
