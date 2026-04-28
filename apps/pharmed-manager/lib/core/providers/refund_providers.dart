import 'package:pharmed_manager/core/core.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class RefundProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      Provider(
        create: (context) {
          return RefundRemoteDataSource(apiManager: context.read());
        },
      ),

      Provider<RefundMapper>(create: (_) => const RefundMapper()),
      Provider<MedicineWithdrawItemMapper>(create: (_) => const MedicineWithdrawItemMapper()),

      Provider<IRefundRepository>(
        create: (context) => switch (FlavorConfig.instance.flavor) {
          AppFlavor.mock => RefundRepositoryImpl(
            dataSource: context.read(),
            refundMapper: context.read(),
            withdrawItemMapper: context.read(),
          ),
          AppFlavor.dev || AppFlavor.prod => RefundRepositoryImpl(
            dataSource: context.read(),
            refundMapper: context.read(),
            withdrawItemMapper: context.read(),
          ),
        },
      ),

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
