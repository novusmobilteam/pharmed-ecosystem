import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../data/datasource/cabin_fault_datasource.dart';
import '../data/datasource/cabin_fault_local_datasource.dart';
import '../data/datasource/cabin_fault_remote_datasource.dart';
import '../data/repository/cabin_fault_repository.dart';
import '../domain/repository/i_cabin_fault_repository.dart';
import '../domain/usecase/clear_fault_record_usecase.dart';
import '../domain/usecase/create_fault_record_usecase.dart';
import '../domain/usecase/get_cabin_faults_usecase.dart';

class CabinFaultProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<CabinFaultDataSource>(
        create: (context) {
          if (isDev) {
            return CabinFaultLocalDataSource(assetPath: 'assets/mocks/cabin.json');
          } else {
            return CabinFaultRemoteDataSource(apiManager: context.read());
          }
        },
      ),

      // 2. Repository
      Provider<ICabinFaultRepository>(
        create: (context) => CabinFaultRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<GetCabinFaultsUseCase>(
        create: (context) => GetCabinFaultsUseCase(context.read()),
      ),
      Provider<CreateFaultRecordUseCase>(
        create: (context) => CreateFaultRecordUseCase(context.read()),
      ),
      Provider<ClearFaultRecordUseCase>(
        create: (context) => ClearFaultRecordUseCase(context.read()),
      ),
    ];
  }
}
