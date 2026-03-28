import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/cabin_stock_datasource.dart';
import '../data/datasource/cabin_stock_local_datasource.dart';
import '../data/datasource/cabin_stock_remote_datasource.dart';
import '../data/repository/cabin_stock_repository.dart';
import '../domain/repository/i_cabin_stock_repository.dart';
import '../domain/usecase/get_cabin_stock_usecase.dart';
import '../domain/usecase/get_current_cabin_stock_usecase.dart';
import '../domain/usecase/get_expired_stocks_usecase.dart';
import '../domain/usecase/get_expiring_stocks_usecase.dart';
import '../domain/usecase/get_station_stocks_usecase.dart';
import '../domain/usecase/count_medicine_usecase.dart';

class CabinStockProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<CabinStockDataSource>(
        create: (context) {
          if (isDev) {
            return CabinStockLocalDataSource(assetPath: 'assets/mocks/cabin_drawer_stock.json');
          } else {
            return CabinStockRemoteDataSource(apiManager: context.read());
          }
        },
      ),

      // 2. Repository
      Provider<ICabinStockRepository>(
        create: (context) => CabinStockRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<GetCurrentCabinStockUseCase>(
        create: (context) => GetCurrentCabinStockUseCase(context.read()),
      ),
      Provider<GetCabinStockUseCase>(
        create: (context) => GetCabinStockUseCase(context.read()),
      ),
      Provider<GetExpiredStocksUseCase>(
        create: (context) => GetExpiredStocksUseCase(context.read()),
      ),
      Provider<GetExpiringStocksUseCase>(
        create: (context) => GetExpiringStocksUseCase(context.read()),
      ),
      Provider<GetStationStocksUseCase>(
        create: (context) => GetStationStocksUseCase(context.read()),
      ),
      Provider<CountMedicineUseCase>(
        create: (context) => CountMedicineUseCase(context.read()),
      ),
    ];
  }
}
