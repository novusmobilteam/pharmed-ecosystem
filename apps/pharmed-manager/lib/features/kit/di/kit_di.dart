import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/kit_datasource.dart';
import '../data/datasource/kit_local_datasource.dart';
import '../data/datasource/kit_remote_datasource.dart';
import '../data/repository/kit_repository.dart';
import '../domain/repository/i_kit_repository.dart';
import '../domain/usecase/create_kit_usecase.dart';
import '../domain/usecase/delete_kit_usecase.dart';
import '../domain/usecase/get_kits_usecase.dart';
import '../domain/usecase/update_kit_usecase.dart';

class KitProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<KitDataSource>(
        create: (context) {
          if (isDev) {
            return KitLocalDataSource(assetPath: 'assets/mocks/kit.json');
          } else {
            return KitRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IKitRepository>(
        create: (context) => KitRepository(
          context.read<KitDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetKitsUseCase>(
        create: (context) => GetKitsUseCase(context.read()),
      ),
      Provider<DeleteKitUseCase>(
        create: (context) => DeleteKitUseCase(context.read()),
      ),
      Provider<CreateKitUseCase>(
        create: (context) => CreateKitUseCase(context.read()),
      ),
      Provider<UpdateKitUseCase>(
        create: (context) => UpdateKitUseCase(context.read()),
      ),
    ];
  }
}
