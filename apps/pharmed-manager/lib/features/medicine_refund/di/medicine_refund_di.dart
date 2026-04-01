import 'package:pharmed_manager/core/core.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MedicineRefundProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // // 1. Data Source
      // Provider<MedicineRefundDataSource>(
      //   create: (context) {
      //     return MedicineRefundRemoteDataSource(apiManager: context.read());
      //   },
      // ),

      // // 2. Repository
      // Provider<IMedicineRefundRepository>(create: (context) => MedicineRefundRepository(context.read())),

      // 3. Use Cases
      Provider<GetRefundablesUseCase>(create: (context) => GetRefundablesUseCase(context.read())),
      Provider<CheckRefundStatusUseCase>(
        create: (context) =>
            CheckRefundStatusUseCase(refundRepository: context.read(), cabinRepository: context.read()),
      ),
      Provider<CompleteRefundUseCase>(create: (context) => CompleteRefundUseCase(context.read())),
      Provider<CompletePharmacyRefundUseCase>(create: (context) => CompletePharmacyRefundUseCase(context.read())),
      Provider<GetCompletedPharmacyRefundsUseCase>(
        create: (context) => GetCompletedPharmacyRefundsUseCase(context.read()),
      ),
      Provider<GetPharmacyRefundsUseCase>(create: (context) => GetPharmacyRefundsUseCase(context.read())),
      Provider<GetDrawerRefundsUseCase>(create: (context) => GetDrawerRefundsUseCase(context.read())),
      Provider<DeletePharmacyRefundUseCase>(create: (context) => DeletePharmacyRefundUseCase(context.read())),
    ];
  }
}
