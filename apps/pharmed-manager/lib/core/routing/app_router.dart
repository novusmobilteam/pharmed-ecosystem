import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmed_manager/core/auth/auth_manager_notifier.dart';
import '../../features/cabin_assignment/presentation/view/station_cabin_assignment_screen.dart';
import '../../features/cabin_stock/presentation/view/expired_stocks_screen.dart';
import '../../features/cabin_stock/presentation/view/station_stock_screen.dart';
import '../../features/dashboard/presentation/view/client_dashboard_screen.dart';
import '../../features/dashboard/presentation/view/manager_dashboard_screen.dart';
import '../../features/station/presentation/view/station_setup_screen.dart';
import '../../features/onboarding/view/cabin_setup_screen.dart';
import '../../features/stock_transaction/presentation/screens/pharmacy_transaction_screen.dart';
import 'package:provider/provider.dart';

import '../../features/cabin_stock/presentation/view/expiring_stocks_screen.dart';
import '../../features/inventory/view/inventory_screen.dart';
import '../../features/directed_orders/view/directed_orders_screen.dart';
import '../../features/job_list/view/job_list_screen.dart';
import '../../features/medicine_activity/view/medicine_activity_screen.dart';
import '../../features/station_inventory/view/station_inventory_screen.dart';
import '../../features/client/unscanned_barcodes/view/unscanned_barcodes_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/medicine_refund/presentation/view/drawer_refund_screen.dart';
import '../../features/medicine_refund/presentation/view/pharmacy_refund_screen.dart';
import '../../features/onboarding/view/platform_selection_screen.dart';
import '../../features/cabin_temperature/view/cabin_temperature_screen.dart';
import '../../features/firm/presentation/view/firm_screen.dart';
import '../../features/medicine/presentation/view/medicine_screen.dart';
import '../../features/warning/presentation/view/warning_screen.dart';
import '../../features/hospitalization/presentation/view/hospitalization_screen.dart';
import '../../features/unscanned_barcodes/view/unscanned_barcodes_screen.dart';
import '../../features/filling_list/presentation/view/filling_list_screen.dart';
import '../../features/inconsistency/view/inconsistency_screen.dart';
import '../../features/unapplied_prescriptions/view/unapplied_prescriptions_screen.dart';
import '../../features/authentication/presentation/authentication_screen.dart';
import '../../features/role/presentation/view/role_screen.dart';
import '../../features/user/presentation/view/user_screen.dart';
import '../../features/prescription/presentation/view/prescription_screen.dart';
import '../../features/settings/presentation/notifier/settings_notifier.dart';
import '../../features/stock_transaction/presentation/screens/stock_transaction_report_screen.dart';
import '../../main.dart';
import '../core.dart';
import 'router_notifier.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final settings = context.read<SettingsNotifier>();
    final auth = context.read<AuthManagerNotifier>();

    return GoRouter(
      initialLocation: '/',
      //debugLogDiagnostics: true,
      refreshListenable: RouterNotifier(auth: auth, settings: settings),
      navigatorKey: navigatorKey,
      redirect: (context, state) {
        final bool isFirstRun = settings.isFirstRun;
        final bool isLoggedIn = auth.accessToken != null;
        final bool hasUserData = auth.user != null;

        final AppMode? mode = settings.currentMode;
        final String currentLocation = state.matchedLocation;

        // 1. DURUM: İLK KURULUM
        if (isFirstRun) {
          return currentLocation == AppRoute.platformSelection.path ? null : AppRoute.platformSelection.path;
        }

        // if (!isFirstRun && currentLocation == AppRoute.platformSelection.path && mode == AppMode.client) {
        //   return AppRoute.cabinSetup.path;
        // }

        // Kullanıcı bilgisi yüklenene kadar bekle
        if (isLoggedIn && !hasUserData) return null;

        // 2. DURUM: GİRİŞ YAPILMIŞSA
        if (isLoggedIn) {
          if (currentLocation == '/' ||
              currentLocation == AppRoute.managerDashboard.path ||
              currentLocation == AppRoute.clientDashboard.path) {
            return AppRoute.home.path;
          }
          return currentLocation;
        }
        // 3. DURUM: GİRİŞ YAPILMAMIŞSA
        if (!isLoggedIn) {
          final String targetDashboard = (mode == AppMode.manager || mode == AppMode.admin)
              ? AppRoute.managerDashboard.path
              : AppRoute.clientDashboard.path;

          if (currentLocation != targetDashboard) {
            return targetDashboard;
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'root',
          builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
        ),
        // Kurulum Ekranı (PlatformSelection)
        GoRoute(path: AppRoute.home.path, name: AppRoute.home.name, builder: (context, state) => HomeScreen()),
        GoRoute(
          path: AppRoute.platformSelection.path,
          name: AppRoute.platformSelection.name,
          builder: (context, state) => PlatformSelectionScreen(),
        ),
        GoRoute(
          path: AppRoute.cabinSetup.path,
          name: AppRoute.cabinSetup.name,
          builder: (context, state) => CabinSetupScreen(),
        ),
        GoRoute(
          path: AppRoute.clientDashboard.path,
          name: AppRoute.clientDashboard.name,
          builder: (context, state) => ClientDashboardScreen(),
        ),
        GoRoute(
          path: AppRoute.managerDashboard.path,
          name: AppRoute.managerDashboard.name,
          builder: (context, state) => ManagerDashboardScreen(),
        ),

        GoRoute(path: AppRoute.firm.path, name: AppRoute.firm.name, builder: (context, state) => FirmScreen()),

        GoRoute(
          path: AppRoute.station.path,
          name: AppRoute.station.name,
          builder: (context, state) => StationSetupScreen(),
        ),

        GoRoute(
          path: AppRoute.heatControl.path,
          name: AppRoute.heatControl.name,
          builder: (context, state) => CabinTemperatureScreen(),
        ),
        GoRoute(path: AppRoute.warning.path, name: AppRoute.warning.name, builder: (context, state) => WarningScreen()),
        GoRoute(
          path: AppRoute.medicine.path,
          name: AppRoute.medicine.name,
          builder: (context, state) => MedicineScreen(),
        ),

        /// Kullanıcı İşlemleri
        GoRoute(path: AppRoute.role.path, name: AppRoute.role.name, builder: (context, state) => RoleScreen()),
        GoRoute(path: AppRoute.user.path, name: AppRoute.user.name, builder: (context, state) => UserScreen()),

        GoRoute(
          path: AppRoute.authorization.path,
          name: AppRoute.authorization.name,
          builder: (context, state) => AuthenticationScreen(),
        ),

        /// Hastane Veri İşlemleri
        GoRoute(
          path: AppRoute.hospitalization.path,
          name: AppRoute.hospitalization.name,
          builder: (context, state) => HospitalizationScreen(),
        ),
        GoRoute(
          path: AppRoute.prescription.path,
          name: AppRoute.prescription.name,
          builder: (context, state) => PrescriptionScreen(),
        ),
        GoRoute(
          path: AppRoute.unReadQrCode.path,
          name: AppRoute.unReadQrCode.name,
          builder: (context, state) => ManagerUnscannedBarcodesScreen(),
        ),
        GoRoute(
          path: AppRoute.refundPharmacy.path,
          name: AppRoute.refundPharmacy.name,
          builder: (context, state) => PharmacyRefundScreen(),
        ),

        /// Kat Stokları
        GoRoute(
          path: AppRoute.stationStock.path,
          name: AppRoute.stationStock.name,
          builder: (context, state) => StationStockScreen(),
        ),
        GoRoute(
          path: AppRoute.unappliedPrescriptions.path,
          name: AppRoute.unappliedPrescriptions.name,
          builder: (context, state) => UnappliedPrescriptionsScreen(),
        ),
        GoRoute(
          path: AppRoute.refundDrawer.path,
          name: AppRoute.refundDrawer.name,
          builder: (context, state) => DrawerRefundScreen(),
        ),
        GoRoute(
          path: AppRoute.inconsistency.path,
          name: AppRoute.inconsistency.name,
          builder: (context, state) => InconsistencyScreen(),
        ),
        GoRoute(
          path: AppRoute.refill.path,
          name: AppRoute.refill.name,
          builder: (context, state) => FillingListScreen(),
        ),
        GoRoute(
          path: AppRoute.stationCabinStock.path,
          name: AppRoute.stationCabinStock.name,
          builder: (context, state) => StationCabinAssignmentScreen(),
        ),

        /// Eczane
        GoRoute(
          path: AppRoute.stockTransactions.path,
          name: AppRoute.stockTransactions.name,
          builder: (context, state) => PharmacyTransactionScreen(),
        ),

        GoRoute(
          path: AppRoute.inventory.path,
          name: AppRoute.inventory.name,
          builder: (context, state) => InventoryScreen(),
        ),

        /// Tedavi
        GoRoute(
          path: AppRoute.directedOrders.path,
          name: AppRoute.directedOrders.name,
          builder: (context, state) => DirectedOrdersScreen(),
        ),

        GoRoute(
          path: AppRoute.expiringStocks.path,
          name: AppRoute.expiringStocks.name,
          builder: (context, state) => ExpiringStocksScreen(),
        ),
        GoRoute(path: AppRoute.jobList.path, name: AppRoute.jobList.name, builder: (context, state) => JobListScreen()),

        GoRoute(
          path: AppRoute.stationInventory.path,
          name: AppRoute.stationInventory.name,
          builder: (context, state) => StationInventoryScreen(),
        ),
        GoRoute(
          path: AppRoute.unscannedBarcodes.path,
          name: AppRoute.unscannedBarcodes.name,
          builder: (context, state) => UnscannedBarcodesScreen(),
        ),

        GoRoute(
          path: AppRoute.medicineActivity.path,
          name: AppRoute.medicineActivity.name,
          builder: (context, state) => MedicineActivityScreen(),
        ),

        /// Raporlar
        GoRoute(
          path: AppRoute.expiredStocks.path,
          name: AppRoute.expiredStocks.name,
          builder: (context, state) => ExpiredStocksScreen(),
        ),
        GoRoute(
          path: AppRoute.cabinTransactionReport.path,
          name: AppRoute.cabinTransactionReport.name,
          builder: (context, state) => StockTransactionReportScreen(),
        ),
      ],
    );
  }
}
