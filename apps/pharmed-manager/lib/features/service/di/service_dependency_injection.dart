import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';
import '../data/datasource/service_data_source.dart';
import '../data/datasource/service_local_data_source.dart';
import '../data/datasource/service_remote_data_source.dart';
import '../data/repository/service_repository.dart';
import '../domain/repository/i_service_repository.dart';
import '../domain/usecase/create_service_usecase.dart';
import '../domain/usecase/delete_service_usecase.dart';
import '../domain/usecase/get_services_usecase.dart';
import '../domain/usecase/update_service_usecase.dart';

class ServiceProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<ServiceDataSource>(
        create: (context) {
          if (isDev) {
            return ServiceLocalDataSource(assetPath: 'assets/mocks/hospital_service.json');
          } else {
            return ServiceRemoteDataSource(apiManager: context.read<APIManager>());
          }
        },
      ),

      // 2. Repository
      Provider<IServiceRepository>(
        create: (context) => ServiceRepository(
          context.read<ServiceDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetServicesUseCase>(
        create: (context) => GetServicesUseCase(context.read()),
      ),
      Provider<CreateServiceUseCase>(
        create: (context) => CreateServiceUseCase(context.read()),
      ),
      Provider<UpdateServiceUseCase>(
        create: (context) => UpdateServiceUseCase(context.read()),
      ),
      Provider<DeleteServiceUseCase>(
        create: (context) => DeleteServiceUseCase(context.read()),
      ),
    ];
  }
}
