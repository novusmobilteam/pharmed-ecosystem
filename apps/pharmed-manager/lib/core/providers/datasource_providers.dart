import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DatasourceProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(create: (context) => ActiveIngredientRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => BranchRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => DosageFormRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => DrugClassRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => DrugTypeRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => FirmRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => HospitalizationRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => InconsistencyRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => KitContentRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => KitRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => MaterialTypeRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => MedicineRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => DashboardRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => PatientRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => PrescriptionRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => RefundRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => RoleRemoteDataSource(apiManager: context.read<APIManager>())),
      Provider(create: (context) => ServiceRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => StationRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => CabinStockRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => CabinStockLocalDataSource()),
      Provider(create: (context) => UnitRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => UserRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => WarehouseRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => WarningRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => RoleAuthorizationRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => UserAuthorizationRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => StockTransactionRemoteDataSource(apiManager: context.read())),
      Provider(create: (context) => CabinRemoteDataSource(apiManager: context.read())),
      Provider<ICabinLocalDataSource>(create: (context) => CabinLocalDataSource()),
      Provider(create: (context) => RefillListRemoteDataSource(apiManager: context.read())),
    ];
  }
}
