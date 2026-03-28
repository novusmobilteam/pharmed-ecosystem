import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';
import '../data/datasource/warehouse_data_source.dart';
import '../data/datasource/warehouse_local_data_source.dart';
import '../data/datasource/warehouse_remote_data_source.dart';
import '../data/repository/warehouse_repository.dart';
import '../domain/repository/i_warehouse_repository.dart';
import '../domain/usecase/create_warehouse_usecase.dart';
import '../domain/usecase/delete_warehouse_usecase.dart';
import '../domain/usecase/get_warehouses_usecase.dart';
import '../domain/usecase/update_warehouse_usecase.dart';

class WarehouseProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<WarehouseDataSource>(
        create: (context) {
          if (isDev) {
            return WarehouseLocalDataSource(assetPath: 'assets/mocks/warehouse.json');
          } else {
            return WarehouseRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 2. Repository
      Provider<IWarehouseRepository>(
        create: (context) => WarehouseRepository(
          context.read<WarehouseDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetWarehousesUseCase>(
        create: (context) => GetWarehousesUseCase(context.read()),
      ),
      Provider<CreateWarehouseUseCase>(
        create: (context) => CreateWarehouseUseCase(context.read()),
      ),
      Provider<UpdateWarehouseUseCase>(
        create: (context) => UpdateWarehouseUseCase(context.read()),
      ),
      Provider<DeleteWarehouseUseCase>(
        create: (context) => DeleteWarehouseUseCase(context.read()),
      ),
    ];
  }
}
