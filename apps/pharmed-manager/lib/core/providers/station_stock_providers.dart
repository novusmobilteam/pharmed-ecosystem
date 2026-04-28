import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../flavor/app_flavor.dart';

class StationStockProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => CabinStockRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => CabinStockLocalDataSource()),

      Provider<CabinStockMapper>(create: (_) => const CabinStockMapper()),
      Provider<StationStockMapper>(create: (_) => const StationStockMapper()),

      Provider<ICabinStockRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => MockCabinStockRepository(),
          AppFlavor.dev || AppFlavor.prod => CabinStockRepositoryImpl(
            dataSource: context.read(),
            localDataSource: context.read(),
            cabinMapper: context.read(),
            stationMapper: context.read(),
          ),
        },
      ),
      Provider<GetCurrentCabinStockUseCase>(create: (context) => GetCurrentCabinStockUseCase(context.read())),
      Provider<GetCabinStockUseCase>(create: (context) => GetCabinStockUseCase(context.read())),
      Provider<GetExpiredStocksUseCase>(create: (context) => GetExpiredStocksUseCase(context.read())),
      Provider<GetExpiringStocksUseCase>(create: (context) => GetExpiringStocksUseCase(context.read())),
      Provider<GetStationStocksUseCase>(create: (context) => GetStationStocksUseCase(context.read())),
      Provider<CountMedicineUseCase>(create: (context) => CountMedicineUseCase(context.read())),
    ];
  }
}
