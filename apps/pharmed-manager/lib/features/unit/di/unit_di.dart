import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class UnitProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<UnitDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return UnitLocalDataSource(assetPath: 'assets/mocks/unit.json');
      //     } else {
      //       return UnitRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),
      // // 2. Repository
      // Provider<IUnitRepository>(
      //   create: (context) => UnitRepository(
      //     context.read<UnitDataSource>(),
      //   ),
      // ),
      // 3. Use Cases
      Provider<GetUnitsUseCase>(create: (context) => GetUnitsUseCase(context.read())),
      Provider<CreateUnitUseCase>(create: (context) => CreateUnitUseCase(context.read())),
      Provider<UpdateUnitUseCase>(create: (context) => UpdateUnitUseCase(context.read())),
      Provider<DeleteUnitUseCase>(create: (context) => DeleteUnitUseCase(context.read())),
    ];
  }
}
