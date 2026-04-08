import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class WarehouseProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => WarehouseRemoteDataSource(apiManager: context.read())),

      Provider<WarehouseMapper>(create: (_) => const WarehouseMapper()),

      Provider<IWarehouseRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => WarehouseRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => WarehouseRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetWarehousesUseCase>(create: (context) => GetWarehousesUseCase(context.read())),
      Provider<CreateWarehouseUseCase>(create: (context) => CreateWarehouseUseCase(context.read())),
      Provider<UpdateWarehouseUseCase>(create: (context) => UpdateWarehouseUseCase(context.read())),
      Provider<DeleteWarehouseUseCase>(create: (context) => DeleteWarehouseUseCase(context.read())),
    ];
  }
}
