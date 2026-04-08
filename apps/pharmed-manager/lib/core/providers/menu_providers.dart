import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_manager/core/flavor/app_flavor.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MenuProviders {
  static List<SingleChildWidget> providers() => [
    Provider(create: (context) => DashboardRemoteDataSource(apiManager: context.read())),

    Provider<CabinStockMapper>(create: (_) => const CabinStockMapper()),
    Provider<PrescriptionItemMapper>(create: (_) => const PrescriptionItemMapper()),
    Provider<PrescriptionMapper>(create: (_) => const PrescriptionMapper()),
    Provider<RefundMapper>(create: (_) => const RefundMapper()),
    Provider<MenuTreeMapper>(create: (_) => const MenuTreeMapper()),

    Provider<IDashboardRepository>(
      create: (context) => switch (FlavorConfig.instance.flavor) {
        AppFlavor.mock => MockDashboardRepository(),
        AppFlavor.dev || AppFlavor.prod => DashboardRepositoryImpl(
          dataSource: context.read(),
          cabinStockMapper: context.read(),
          prescriptionItemMapper: context.read(),
          prescriptionMapper: context.read(),
          refundMapper: context.read(),
          menuMapper: context.read(),
        ),
      },
    ),

    Provider(create: (context) => GetFilteredMenusUseCase(context.read(), isManager: true)),
  ];
}
