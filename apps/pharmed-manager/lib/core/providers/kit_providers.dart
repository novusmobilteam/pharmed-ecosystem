import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class KitProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => KitRemoteDataSource(apiManager: context.read())),

      Provider<KitMapper>(create: (_) => const KitMapper()),

      Provider<IKitRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => KitRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => KitRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),
      Provider<GetKitsUseCase>(create: (context) => GetKitsUseCase(context.read())),
      Provider<DeleteKitUseCase>(create: (context) => DeleteKitUseCase(context.read())),
      Provider<CreateKitUseCase>(create: (context) => CreateKitUseCase(context.read())),
      Provider<UpdateKitUseCase>(create: (context) => UpdateKitUseCase(context.read())),
    ];
  }
}
