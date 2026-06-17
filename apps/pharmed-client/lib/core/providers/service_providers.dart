import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../cache/app_settings_cache.dart';
import '../flavor/app_flavor.dart';
import '../services/cabin_operation/cabin_operation_service.dart';
import '../services/cabin_operation/mock_cabin_operation_service.dart';
import '../services/rfid/mock_rfid_service.dart';
import '../services/rfid/rfid_service.dart';
import '../services/serial_communication/mock_serial_communication_service.dart';
import '../services/serial_communication/serial_communication_service.dart';

final serialServiceProvider = Provider<ISerialCommunicationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockSerialCommunicationService(),
    AppFlavor.mock || AppFlavor.prod || AppFlavor.dev => SerialCommunicationService(),
  };
});

final cabinOperationServiceProvider = Provider<ICabinOperationService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockCabinOperationService(),
    AppFlavor.mock || AppFlavor.prod || AppFlavor.dev => CabinOperationService(
      serialService: ref.read(serialServiceProvider),
      appSettingsCache: ref.read(appSettingsCacheProvider),
    ),
  };
});

final rfidServiceProvider = Provider<IRfidService>((ref) {
  return switch (FlavorConfig.instance.flavor) {
    AppFlavor.mock => MockRfidService(),
    AppFlavor.mock || AppFlavor.prod || AppFlavor.dev => RfidService(),
  };
});
