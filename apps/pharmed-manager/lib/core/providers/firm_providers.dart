import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class FirmProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => FirmRemoteDataSource(apiManager: context.read())),

      Provider<FirmMapper>(create: (_) => const FirmMapper()),

      Provider<IFirmRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => FirmRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => FirmRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),
      Provider<GetFirmsUseCase>(create: (context) => GetFirmsUseCase(context.read<IFirmRepository>())),
      Provider<CreateFirmUseCase>(create: (context) => CreateFirmUseCase(context.read<IFirmRepository>())),
      Provider<UpdateFirmUseCase>(create: (context) => UpdateFirmUseCase(context.read<IFirmRepository>())),
      Provider<DeleteFirmUseCase>(create: (context) => DeleteFirmUseCase(context.read<IFirmRepository>())),
    ];
  }
}
