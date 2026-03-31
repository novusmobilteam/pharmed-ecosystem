import 'package:pharmed_core/pharmed_core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DrugClassProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<DrugClassDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return DrugClassLocalDataSource(assetPath: 'assets/mocks/drug_class.json');
      //     } else {
      //       return DrugClassRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),
      // // 2. Repository
      // Provider<IDrugClassRepository>(
      //   create: (context) => DrugClassRepository(
      //     context.read<DrugClassDataSource>(),
      //   ),
      // ),
      // 3. Use Cases
      Provider<GetDrugClassUseCase>(create: (context) => GetDrugClassUseCase(context.read())),
      Provider<CreateDrugClassUseCase>(create: (context) => CreateDrugClassUseCase(context.read())),
      Provider<UpdateDrugClassUseCase>(create: (context) => UpdateDrugClassUseCase(context.read())),
      Provider<DeleteDrugClassUseCase>(create: (context) => DeleteDrugClassUseCase(context.read())),
    ];
  }
}
