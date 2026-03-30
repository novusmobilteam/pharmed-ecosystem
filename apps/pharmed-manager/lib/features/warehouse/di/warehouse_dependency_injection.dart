import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class WarehouseProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 3. Use Cases
      Provider<GetWarehousesUseCase>(create: (context) => GetWarehousesUseCase(context.read())),
      Provider<CreateWarehouseUseCase>(create: (context) => CreateWarehouseUseCase(context.read())),
      Provider<UpdateWarehouseUseCase>(create: (context) => UpdateWarehouseUseCase(context.read())),
      Provider<DeleteWarehouseUseCase>(create: (context) => DeleteWarehouseUseCase(context.read())),
    ];
  }
}
