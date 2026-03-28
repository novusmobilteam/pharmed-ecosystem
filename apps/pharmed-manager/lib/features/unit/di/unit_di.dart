import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/unit_datasource.dart';
import '../data/datasource/unit_local_datasource.dart';
import '../data/datasource/unit_remote_datasource.dart';
import '../data/repository/unit_repository.dart';
import '../domain/repository/i_unit_repository.dart';
import '../domain/usecase/create_unit_usecase.dart';
import '../domain/usecase/delete_unit_usecase.dart';
import '../domain/usecase/get_units_usecase.dart';
import '../domain/usecase/update_unit_usecase.dart';

class UnitProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<UnitDataSource>(
        create: (context) {
          if (isDev) {
            return UnitLocalDataSource(assetPath: 'assets/mocks/unit.json');
          } else {
            return UnitRemoteDataSource(apiManager: context.read());
          }
        },
      ),
      // 2. Repository
      Provider<IUnitRepository>(
        create: (context) => UnitRepository(
          context.read<UnitDataSource>(),
        ),
      ),
      // 3. Use Cases
      Provider<GetUnitsUseCase>(
        create: (context) => GetUnitsUseCase(context.read()),
      ),
      Provider<CreateUnitUseCase>(
        create: (context) => CreateUnitUseCase(context.read()),
      ),
      Provider<UpdateUnitUseCase>(
        create: (context) => UpdateUnitUseCase(context.read()),
      ),
      Provider<DeleteUnitUseCase>(
        create: (context) => DeleteUnitUseCase(context.read()),
      ),
    ];
  }
}
