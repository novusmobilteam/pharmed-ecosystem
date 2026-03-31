import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../flavor/app_flavor.dart';
import '../hardware/service/cabin_operation/cabin_operation_service.dart';
import '../hardware/service/cabin_operation/i_cabin_operation_service.dart';
import '../hardware/service/cabin_operation/mock_cabin_operation_service.dart';
import '../hardware/service/serial_communication/i_serial_communication_service.dart';
import '../hardware/service/serial_communication/mock_serial_communication_service.dart';
import '../hardware/service/serial_communication/serial_communication_service.dart';

final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockSerialCommunicationService(),
    AppFlavor.dev || AppFlavor.prod => SerialCommunicationService(),
  };
});

final cabinOperationServiceProvider = Provider<ICabinOperationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockCabinOperationService(),
    AppFlavor.dev || AppFlavor.prod => CabinOperationService(serialService: ref.read(serialServiceProvider)),
  };
});
