import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class InconsistencyProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => InconsistencyRemoteDataSource(apiManager: context.read())),

      Provider<InconsistencyMapper>(create: (_) => InconsistencyMapper()),

      Provider<IInconsistencyRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => InconsistencyRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => InconsistencyRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),
      Provider<GetInconsistenciesUseCase>(create: (context) => GetInconsistenciesUseCase(context.read())),
    ];
  }
}
