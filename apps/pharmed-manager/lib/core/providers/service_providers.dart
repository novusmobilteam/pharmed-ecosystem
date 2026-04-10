import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ServiceProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => ServiceRemoteDataSource(apiManager: context.read())),

      Provider<ServiceMapper>(create: (_) => const ServiceMapper()),

      Provider<IServiceRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => ServiceRepositoryImpl(dataSource: context.read(), mapper: context.read()),
          AppFlavor.dev || AppFlavor.prod => ServiceRepositoryImpl(dataSource: context.read(), mapper: context.read()),
        },
      ),

      Provider<GetServicesUseCase>(create: (context) => GetServicesUseCase(context.read())),
      Provider<CreateServiceUseCase>(create: (context) => CreateServiceUseCase(context.read())),
      Provider<UpdateServiceUseCase>(create: (context) => UpdateServiceUseCase(context.read())),
      Provider<DeleteServiceUseCase>(create: (context) => DeleteServiceUseCase(context.read())),
      Provider<DeleteRoomUseCase>(create: (context) => DeleteRoomUseCase(context.read())),
      Provider<DeleteBedUseCase>(create: (context) => DeleteBedUseCase(context.read())),
    ];
  }
}
