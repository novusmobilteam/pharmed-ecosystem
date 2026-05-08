// [SWREQ-SETUP-UI-004] [IEC 62304 §5.5]
// Setup Wizard Adım 2 — kabin temel bilgileri state yöneticisi.
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/providers/providers.dart';
import '../state/step2_state.dart';

final step2NotifierProvider = NotifierProvider<Step2Notifier, Step2State>(Step2Notifier.new);

class Step2Notifier extends Notifier<Step2State> {
  @override
  Step2State build() {
    final ports = ref.read(serialServiceProvider).getAvailablePorts();
    return Step2State(availablePorts: ports);
  }

  void updateBasicInfo(WizardBasicInfo info) {
    state = state.copyWith(basicInfo: info);
  }

  /// [SWREQ-RFID-004]
  Future<void> testRfidConnection() async {
    final basicInfo = state.basicInfo;
    final rfidIp = basicInfo?.rfidIpAddress;
    final rfidPort = int.tryParse(basicInfo?.rfidPort ?? '');

    if (rfidIp == null || rfidIp.isEmpty || rfidPort == null) return;

    state = state.copyWith(rfidTestState: RfidTestState.testing, rfidReaderInfo: null, rfidTestError: null);

    final result = await ref.read(testRfidConnectionUseCaseProvider).call(ip: rfidIp, port: rfidPort);

    result.when(
      ok: (info) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-RFID-004',
          message: 'RFID test başarılı',
          context: {'fw': info.firmwareVersion, 'power': info.currentPower},
        );
        state = state.copyWith(rfidTestState: RfidTestState.success, rfidReaderInfo: info);
      },
      error: (e) {
        MedLogger.error(unit: 'SW-UNIT-SETUP', swreq: 'SWREQ-RFID-004', message: 'RFID test başarısız', error: e);
        state = state.copyWith(rfidTestState: RfidTestState.failure, rfidTestError: e.message);
      },
    );
  }

  /// [SWREQ-SETUP-UI-016]
  Future<void> testCabinConnection() async {
    final port = state.basicInfo?.comPort;
    if (port == null || port.isEmpty) return;

    state = state.copyWith(cabinCardTestState: CabinCardTestState.testing, cabinTestError: null);

    final result = await ref.read(testCabinConnectionUseCaseProvider).call(port);

    result.when(
      ok: (_) {
        MedLogger.info(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-016',
          message: 'Kabin kartı bağlantı testi başarılı',
          context: {'port': port},
        );
        state = state.copyWith(cabinCardTestState: CabinCardTestState.success);
      },
      error: (e) {
        MedLogger.error(
          unit: 'SW-UNIT-SETUP',
          swreq: 'SWREQ-SETUP-UI-016',
          message: 'Kabin kartı bağlantı testi başarısız',
          error: e,
        );
        state = state.copyWith(cabinCardTestState: CabinCardTestState.failure, cabinTestError: e.message);
      },
    );
  }
}
