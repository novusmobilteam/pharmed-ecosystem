import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../flavor/app_flavor.dart';

class UnitProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => UnitRemoteDataSource(apiManager: context.read())),

      Provider<UnitMapper>(create: (_) => const UnitMapper()),

      Provider<IUnitRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => UnitRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => UnitRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetUnitsUseCase>(create: (context) => GetUnitsUseCase(context.read())),
      Provider<CreateUnitUseCase>(create: (context) => CreateUnitUseCase(context.read())),
      Provider<UpdateUnitUseCase>(create: (context) => UpdateUnitUseCase(context.read())),
      Provider<DeleteUnitUseCase>(create: (context) => DeleteUnitUseCase(context.read())),
    ];
  }
}
