import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/warning_datasource.dart';
import '../data/datasource/warning_local_datasource.dart';
import '../data/datasource/warning_remote_datasource.dart';
import '../data/repository/warning_repository.dart';
import '../domain/repository/i_warning_repository.dart';
import '../domain/usecase/create_warning_usecase.dart';
import '../domain/usecase/delete_warning_usecase.dart';
import '../domain/usecase/get_warnings_usecase.dart';
import '../domain/usecase/update_warning_usecase.dart';

class WarningProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<WarningDataSource>(
        create: (context) {
          if (isDev) {
            return WarningLocalDataSource(assetPath: 'assets/mocks/warning.json');
          } else {
            return WarningRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IWarningRepository>(
        create: (context) => WarningRepository(
          context.read<WarningDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetWarningsUseCase>(
        create: (context) => GetWarningsUseCase(context.read()),
      ),
      Provider<CreateWarningUseCase>(
        create: (context) => CreateWarningUseCase(context.read()),
      ),
      Provider<UpdateWarningUseCase>(
        create: (context) => UpdateWarningUseCase(context.read()),
      ),
      Provider<DeleteWarningUseCase>(
        create: (context) => DeleteWarningUseCase(context.read()),
      ),
    ];
  }
}
