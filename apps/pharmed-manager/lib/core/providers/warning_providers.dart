import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class WarningProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => WarningRemoteDataSource(apiManager: context.read())),

      Provider<WarningMapper>(create: (_) => const WarningMapper()),

      Provider<IWarningRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => WarningRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => WarningRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),
      Provider<GetWarningsUseCase>(create: (context) => GetWarningsUseCase(context.read())),
      Provider<CreateWarningUseCase>(create: (context) => CreateWarningUseCase(context.read())),
      Provider<UpdateWarningUseCase>(create: (context) => UpdateWarningUseCase(context.read())),
      Provider<DeleteWarningUseCase>(create: (context) => DeleteWarningUseCase(context.read())),
    ];
  }
}
