import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class StationProviders {
  static List<SingleChildWidget> providers() => [
    Provider(create: (context) => StationRemoteDataSource(apiManager: context.read())),

    Provider<StationMapper>(create: (_) => const StationMapper()),

    Provider<IStationRepository>(
      create: (context) => switch (FlavorConfig.instance.flavor) {
        AppFlavor.mock => MockStationRepository(),
        AppFlavor.dev || AppFlavor.prod => StationRepositoryImpl(dataSource: context.read(), mapper: context.read()),
      },
    ),
    Provider<GetStationsUseCase>(create: (context) => GetStationsUseCase(context.read())),
    Provider<GetStationUseCase>(create: (context) => GetStationUseCase(context.read())),
    Provider<GetCurrentStationUseCase>(create: (context) => GetCurrentStationUseCase(context.read())),
    Provider<CreateStationUseCase>(create: (context) => CreateStationUseCase(context.read())),
    Provider<UpdateStationUseCase>(create: (context) => UpdateStationUseCase(context.read())),
    Provider<DeleteStationUseCase>(create: (context) => DeleteStationUseCase(context.read())),
    Provider<UpdateStationMacAddressUseCase>(create: (context) => UpdateStationMacAddressUseCase(context.read())),
  ];
}
