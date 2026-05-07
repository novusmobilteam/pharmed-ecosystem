import 'package:pharmed_core/pharmed_core.dart';

class Step2State {
  const Step2State({
    this.basicInfo,
    this.availablePorts = const [],
    this.rfidTestState = RfidTestState.idle,
    this.rfidReaderInfo,
    this.rfidTestError,
    this.cabinCardTestState = CabinCardTestState.idle,
    this.cabinTestError,
  });

  final WizardBasicInfo? basicInfo;
  final List<String> availablePorts;

  final RfidTestState rfidTestState;
  final RfidReaderInfo? rfidReaderInfo;
  final String? rfidTestError;

  final CabinCardTestState cabinCardTestState;
  final String? cabinTestError;

  bool get isComplete => basicInfo != null && basicInfo!.comPort!.isNotEmpty;

  Step2State copyWith({
    WizardBasicInfo? basicInfo,
    List<String>? availablePorts,
    RfidTestState? rfidTestState,
    RfidReaderInfo? rfidReaderInfo,
    String? rfidTestError,
    CabinCardTestState? cabinCardTestState,
    String? cabinTestError,
  }) {
    return Step2State(
      basicInfo: basicInfo ?? this.basicInfo,
      availablePorts: availablePorts ?? this.availablePorts,
      rfidTestState: rfidTestState ?? this.rfidTestState,
      rfidReaderInfo: rfidReaderInfo ?? this.rfidReaderInfo,
      rfidTestError: rfidTestError ?? this.rfidTestError,
      cabinCardTestState: cabinCardTestState ?? this.cabinCardTestState,
      cabinTestError: cabinTestError ?? this.cabinTestError,
    );
  }
}

enum RfidTestState { idle, testing, success, failure }

enum CabinCardTestState { idle, testing, success, failure }
