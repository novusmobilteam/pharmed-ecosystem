import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class KitContentProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => KitContentRemoteDataSource(apiManager: context.read())),

      Provider<KitContentMapper>(create: (_) => const KitContentMapper()),

      Provider<IKitContentRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => KitContentRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev ||
          AppFlavor.prod => KitContentRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetKitContentUseCase>(create: (context) => GetKitContentUseCase(context.read())),
      Provider<DeleteKitContentUseCase>(create: (context) => DeleteKitContentUseCase(context.read())),
      Provider<CreateKitContentUseCase>(create: (context) => CreateKitContentUseCase(context.read())),
      Provider<UpdateKitContentUseCase>(create: (context) => UpdateKitContentUseCase(context.read())),
    ];
  }
}
