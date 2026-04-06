import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class CabinFaultProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<CabinFaultDataSource>(
      //   create: (context) {
      //     if (isDev) {
      //       return CabinFaultLocalDataSource(assetPath: 'assets/mocks/cabin.json');
      //     } else {
      //       return CabinFaultRemoteDataSource(apiManager: context.read());
      //     }
      //   },
      // ),

      // // 2. Repository
      // Provider<ICabinFaultRepository>(create: (context) => CabinFaultRepository(context.read())),

      // 3. Use Cases
      Provider<GetCabinFaultsUseCase>(create: (context) => GetCabinFaultsUseCase(context.read())),
      Provider<CreateFaultRecordUseCase>(create: (context) => CreateFaultRecordUseCase(context.read())),
      Provider<ClearFaultRecordUseCase>(create: (context) => ClearFaultRecordUseCase(context.read())),
    ];
  }
}
