// [SWREQ-CLI-SERVICE-001] [IEC 62304 §5.5]
// Donanım servis katmanı provider'ları — flavor'a göre gerçek/mock seçimi.
// Sınıf: Class B

import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/core/setup/app_setup_notifier.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../cache/app_settings_cache.dart';
import '../hardware/cabin/sensor/cabin_sensor_logger.dart';
import '../hardware/hardware.dart';
import '../services/service.dart';

class CoreProviders {
  static List<SingleChildWidget> providers() => [
    Provider(create: (context) => AppSettingsCache()),

    ChangeNotifierProvider(create: (context) => AppSetupStatusNotifier(appSettingsCache: context.read())),

    Provider<ISerialCommunicationService>(
      create: (_) => switch (FlavorConfig.instance.flavor) {
        AppFlavor.mock => MockSerialCommunicationService(),
        AppFlavor.prod || AppFlavor.dev => SerialCommunicationService(),
      },
    ),

    Provider<ICabinOperationService>(
      create: (ctx) => switch (FlavorConfig.instance.flavor) {
        AppFlavor.mock => MockCabinOperationService(),
        AppFlavor.prod || AppFlavor.dev => CabinOperationService(
          serialService: ctx.read<ISerialCommunicationService>(),
          appSettingsCache: ctx.read<AppSettingsCache>(),
        ),
      },
    ),

    Provider<IRfidService>(
      create: (_) => switch (FlavorConfig.instance.flavor) {
        AppFlavor.mock => MockRfidService(),
        AppFlavor.prod || AppFlavor.dev => RfidService(),
      },
    ),

    Provider(create: (context) => ScanManagerUseCase(context.read())),

    ChangeNotifierProvider<CabinConnectionNotifier>(
      create: (ctx) => CabinConnectionNotifier(scanManager: ctx.read<ScanManagerUseCase>()),
    ),

    ChangeNotifierProvider<RfidScanSessionNotifier>(
      create: (ctx) => RfidScanSessionNotifier(rfid: ctx.read<IRfidService>()),
    ),

    ChangeNotifierProvider<CabinSensorNotifier>(
      create: (ctx) => CabinSensorNotifier(
        streamSensors: ctx.read<StreamCabinSensorsUseCase>(),
        logger: ctx.read<CabinSensorLogger>(),
        settings: ctx.read<AppSettingsCache>(),
        getCabinThresholds: ctx.read<GetCabinThresholdsUseCase>(),
      ),
    ),
  ];
}
