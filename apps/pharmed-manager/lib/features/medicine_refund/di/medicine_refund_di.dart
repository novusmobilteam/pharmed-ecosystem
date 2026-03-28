import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/medicine_refund_datasource.dart';
import '../data/datasource/medicine_refund_remote_datasource.dart';
import '../data/repository/medicine_refund_repository.dart';
import '../domain/repository/i_medicine_refund_repository.dart';
import '../domain/usecase/check_refund_status_usecase.dart';
import '../domain/usecase/complete_pharmacy_refund_usecase.dart';
import '../domain/usecase/complete_refund_usecase.dart';
import '../domain/usecase/delete_pharmacy_refund_usecase.dart';
import '../domain/usecase/get_completed_pharmacy_refunds_usecase.dart';
import '../domain/usecase/get_drawer_refunds_usecase.dart';
import '../domain/usecase/get_pharmacy_refunds_usecase.dart';
import '../domain/usecase/get_refundables_usecase.dart';

class MedicineRefundProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<MedicineRefundDataSource>(
        create: (context) {
          return MedicineRefundRemoteDataSource(apiManager: context.read());
        },
      ),

      // 2. Repository
      Provider<IMedicineRefundRepository>(
        create: (context) => MedicineRefundRepository(context.read()),
      ),

      // 3. Use Cases
      Provider<GetRefundablesUseCase>(
        create: (context) => GetRefundablesUseCase(context.read()),
      ),
      Provider<CheckRefundStatusUseCase>(
        create: (context) => CheckRefundStatusUseCase(
          refundRepository: context.read(),
          cabinRepository: context.read(),
        ),
      ),
      Provider<CompleteRefundUseCase>(
        create: (context) => CompleteRefundUseCase(context.read()),
      ),
      Provider<CompletePharmacyRefundUseCase>(
        create: (context) => CompletePharmacyRefundUseCase(context.read()),
      ),
      Provider<GetCompletedPharmacyRefundsUseCase>(
        create: (context) => GetCompletedPharmacyRefundsUseCase(context.read()),
      ),
      Provider<GetPharmacyRefundsUseCase>(
        create: (context) => GetPharmacyRefundsUseCase(context.read()),
      ),
      Provider<GetDrawerRefundsUseCase>(
        create: (context) => GetDrawerRefundsUseCase(context.read()),
      ),
      Provider<DeletePharmacyRefundUseCase>(
        create: (context) => DeletePharmacyRefundUseCase(context.read()),
      ),
    ];
  }
}
