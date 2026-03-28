import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/datasource/dashboard_datasource.dart';
import '../data/datasource/dashboard_local_datasource.dart';
import '../data/datasource/dashboard_remote_datasource.dart';
import '../data/repository/dashboard_repository.dart';
import '../domain/repository/i_dashboard_repository.dart';
import '../domain/usecase/get_critical_stocks_usecase.dart';
import '../domain/usecase/get_expiring_materials_usecase.dart';
import '../domain/usecase/get_general_stocks_usecase.dart';
import '../domain/usecase/get_refunds_usecase.dart';
import '../domain/usecase/get_unapplied_prescriptions_usecase.dart';
import '../domain/usecase/get_unread_qrcodes_usecase.dart';
import '../domain/usecase/get_upcoming_treatmens_usecase.dart';

class DashboardProviders {
  static List<SingleChildWidget> providers({bool isDev = false}) {
    return [
      // 1. Data Source
      Provider<DashboardDataSource>(
        create: (context) {
          if (isDev) {
            return DashboardLocalDataSource(
              prescriptionPath: 'assets/mocks/prescription.json',
              prescriptionItemPath: 'assets/mocks/prescription_detail.json',
              cabinStockPath: 'assets/mocks/cabin_drawer_stock.json',
              refundPath: 'assets/mocks/refund.json',
            );
          } else {
            return DashboardRemoteDataSource(apiManager: context.read());
          }
        },
      ),

      // 2. Repository
      Provider<IDashboardRepository>(
        create: (context) => DashboardRepository(
          context.read(),
        ),
      ),

      // 3. Use Cases
      Provider<GetCriticalStocksUseCase>(
        create: (context) => GetCriticalStocksUseCase(
          context.read(),
        ),
      ),
      Provider<GetExpiringMaterialsUseCase>(
        create: (context) => GetExpiringMaterialsUseCase(
          context.read(),
        ),
      ),
      Provider<GetGeneralStocksUseCase>(
        create: (context) => GetGeneralStocksUseCase(
          context.read(),
        ),
      ),
      Provider<GetRefundsUseCase>(
        create: (context) => GetRefundsUseCase(
          context.read(),
        ),
      ),
      Provider<GetUnappliedPrescriptionsUseCase>(
        create: (context) => GetUnappliedPrescriptionsUseCase(
          context.read(),
        ),
      ),
      Provider<GetUnreadQrcodesUsecase>(
        create: (context) => GetUnreadQrcodesUsecase(
          context.read(),
        ),
      ),
      Provider<GetUpcomingTreatmensUseCase>(
        create: (context) => GetUpcomingTreatmensUseCase(
          context.read(),
        ),
      ),
    ];
  }
}
