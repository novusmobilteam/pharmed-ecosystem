import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../core/core.dart';
import '../data/datasource/firm_data_source.dart';
import '../data/datasource/firm_local_data_source.dart';
import '../data/datasource/firm_remote_data_source.dart';
import '../data/repository/firm_repository.dart';
import '../domain/repository/i_firm_repository.dart';
import '../domain/usecase/create_firm_usecase.dart';
import '../domain/usecase/delete_firm_usecase.dart';
import '../domain/usecase/get_firms_usecase.dart';
import '../domain/usecase/update_firm_usecase.dart';

class FirmProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<FirmDataSource>(
        create: (context) {
          if (isDev) {
            final local = FirmLocalDataSource(assetPath: 'assets/mocks/firm.json');
            return local as FirmDataSource;
          } else {
            final remote = FirmRemoteDataSource(apiManager: context.read<APIManager>());
            return remote as FirmDataSource;
          }
        },
      ),
      // 2. Repository
      Provider<IFirmRepository>(
        create: (context) => FirmRepository(
          context.read<FirmDataSource>(),
        ),
      ),

      // 3. Use Cases
      Provider<GetFirmsUseCase>(
        create: (context) => GetFirmsUseCase(context.read<IFirmRepository>()),
      ),
      Provider<CreateFirmUseCase>(
        create: (context) => CreateFirmUseCase(context.read<IFirmRepository>()),
      ),
      Provider<UpdateFirmUseCase>(
        create: (context) => UpdateFirmUseCase(context.read<IFirmRepository>()),
      ),
      Provider<DeleteFirmUseCase>(
        create: (context) => DeleteFirmUseCase(context.read<IFirmRepository>()),
      ),
    ];
  }
}
