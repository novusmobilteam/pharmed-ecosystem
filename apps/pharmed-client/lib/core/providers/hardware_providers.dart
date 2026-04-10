import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../flavor/app_flavor.dart';
import '../hardware/service/cabin_operation/cabin_operation_service.dart';
import '../hardware/service/cabin_operation/i_cabin_operation_service.dart';
import '../hardware/service/cabin_operation/mock_cabin_operation_service.dart';
import '../hardware/service/rfid/i_rfid_service.dart';
import '../hardware/service/rfid/mock_rfid_service.dart';
import '../hardware/service/rfid/rfid_service.dart';
import '../hardware/service/rfid/usecase/test_rfid_connection_usecase.dart';
import '../hardware/service/serial_communication/i_serial_communication_service.dart';
import '../hardware/service/serial_communication/mock_serial_communication_service.dart';
import '../hardware/service/serial_communication/serial_communication_service.dart';
import '../hardware/service/serial_communication/usecase/test_cabin_connection_usecase.dart';

final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock || AppFlavor.dev => MockSerialCommunicationService(),
    AppFlavor.prod => SerialCommunicationService(),
  };
});

final cabinOperationServiceProvider = Provider<ICabinOperationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock || AppFlavor.dev => MockCabinOperationService(),
    AppFlavor.prod => CabinOperationService(serialService: ref.read(serialServiceProvider)),
  };
});

final rfidServiceProvider = Provider<IRfidService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockRfidService(),
    AppFlavor.prod || AppFlavor.dev => RfidService(),
  };
});

final testRfidConnectionUseCaseProvider = Provider<TestRfidConnectionUseCase>((ref) {
  return TestRfidConnectionUseCase(ref.read(rfidServiceProvider));
});

final testCabinConnectionUseCaseProvider = Provider<TestCabinConnectionUseCase>((ref) {
  return TestCabinConnectionUseCase(ref.read(serialServiceProvider));
});
