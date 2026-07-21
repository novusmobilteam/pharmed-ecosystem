import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_manager/features/assignment/view/assignment_screen.dart';
import 'package:pharmed_manager/features/auth/notifier/auth_notifier.dart';
import 'package:pharmed_manager/features/cabin_temperature/view/cabin_temperature_screen.dart';
import 'package:pharmed_manager/features/firm/view/firm_screen.dart';
import 'package:pharmed_manager/features/prescription/view/prescription_screen.dart';
import 'package:pharmed_manager/features/reports/auth_summary/view/auth_summary_report_screen.dart';
import 'package:pharmed_manager/features/reports/expired_items/view/expired_items_report_screen.dart';
import 'package:pharmed_manager/features/reports/station_transaction/view/station_transaction_report_screen.dart';
import 'package:pharmed_manager/features/role/view/role_screen.dart';
import 'package:pharmed_manager/features/warning/view/warning_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../auth/notifier/auth_state.dart';
import '../../authorization/authorization_screen.dart';
import '../../dashboard/view/dashboard_view.dart';
import '../../hospitalization/view/hospitalization_screen.dart';
import '../../medicine/view/medicine_screen.dart';

import '../../refund/view/pharmacy_refund_screen.dart';
import '../../reports/cabin_temperature/view/cabin_temperature_report_screen.dart';
import '../../reports/hospital_stocks/view/hospital_stocks_report_screen.dart';
import '../../reports/material_usage/view/material_usage_report_screen.dart';
import '../../reports/patient_inventory/view/patient_inventory_report_screen.dart';
import '../../settings/presentation/notifier/settings_notifier.dart';
import '../../station_setup/view/station_screen.dart';
import '../../unapplied_prescriptions/view/unapplied_prescriptions_screen.dart';
import '../../user/view/user_screen.dart';
import '../notifier/home_notifier.dart';

part 'home_sidebar.dart';
part 'home_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Bu oturumda menüler çekildi mi. Logout'ta sıfırlanır, tekrar login'de
  /// yeniden çekilir. Kalıcı token (Loading→LoggedIn) ve modal login
  /// (LoggedOut→LoggedIn) geçişlerini tek noktadan kapsar.
  bool _menusFetchedForSession = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<HomeNotifier, AuthNotifier>(
        builder: (context, notifier, authNotifier, _) {
          final isLoggedIn = authNotifier.state is AuthLoggedIn;

          // Login'e geçiş yakalandı + bu oturumda henüz çekilmedi → menüleri çek
          if (isLoggedIn && !_menusFetchedForSession) {
            _menusFetchedForSession = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.read<HomeNotifier>().fetchMenus();
            });
          } else if (!isLoggedIn && _menusFetchedForSession) {
            // Logout → bayrağı sıfırla (sonraki login'de yeniden çekilsin)
            _menusFetchedForSession = false;
          }

          // Login olduğunda menü yükleniyorsa spinner (mevcut davranış)
          if (isLoggedIn && notifier.isFetching && notifier.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          // Login olmuş ama yetkili menü yok → mevcut boş durum ekranı
          if (isLoggedIn && notifier.isEmpty) {
            return _NoMenuContent();
          }

          return Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              children: [
                HomeAppBar(
                  isLoggedIn: isLoggedIn,
                  user: notifier.currentUser,
                  onHomeTap: () => context.read<HomeNotifier>().navigateHome(),
                  onLogoutTap: () => context.read<AuthNotifier>().logout(),
                  onLoginTap: () => _onLoginTap(context),
                  onSettingsTap: () {},
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.pagePadding.top),
                    color: MedColors.bg,
                    child: Row(
                      spacing: 16.0,
                      children: [
                        if (isLoggedIn) HomeSidebar(),
                        Expanded(child: _HomeContent()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onLoginTap(BuildContext context) async {
    final authNotifier = context.read<AuthNotifier>();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        // AuthNotifier'ı dinleyerek isLoading ve başarı durumunu yönet
        return Consumer<AuthNotifier>(
          builder: (ctx, auth, _) {
            // Login başarılı olunca modal'ı kapat
            if (auth.state is AuthLoggedIn) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
              });
            }
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: LoginModal(
                isLoading: auth.state is AuthLoading,
                onLogin: (email, password, onError) async {
                  await authNotifier.login(email: email, password: password, onError: onError);
                  // Login başarılıysa menüleri çek
                  if (authNotifier.state is AuthLoggedIn && context.mounted) {
                    context.read<HomeNotifier>().fetchMenus();
                  }
                },
                currentLanguage: context.watch<SettingsNotifier>().language,
                onLanguageChanged: (lang) => context.read<SettingsNotifier>().setLanguage(lang),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthNotifier>().state is AuthLoggedIn;
    final notifier = context.watch<HomeNotifier>();
    final activeMenu = isLoggedIn ? notifier.activeChildMenu : null;
    final contentKey = isLoggedIn ? (activeMenu?.route ?? 'dashboard') : 'dashboard';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(contentKey), child: _buildContent(context, activeMenu)),
    );
  }

  Widget _buildContent(BuildContext context, MenuItem? menu) {
    return switch (menu?.route) {
      'dashboard' || null => DashboardView(),
      'station' => StationSetupScreen(menu: menu!),
      'firm' => FirmScreen(menu: menu!),
      'drug' => MedicineScreen(menu: menu!),
      'warning' => WarningScreen(menu: menu!),
      'patientRegistration' => HospitalizationScreen(menu: menu!),
      'prescription' => PrescriptionScreen(menu: menu!),
      'refund' => PharmacyRefundScreen(menu: menu!),
      //'refundDrawer' => DrawerRefundScreen(menu: menu!),
      'role' => RoleScreen(menu: menu!),
      'authorization' => AuthorizationScreen(menu: menu!),
      'user' => UserScreen(menu: menu!),
      'unappliedPrescriptions' => UnappliedPrescriptionsScreen(menu: menu!),
      //'inconsistency' => InconsistencyScreen(menu: menu!),
      'expiring-materials-report' => ExpiredItemsReportScreen(menu: menu!),
      'cabin-transaction-report' => StationTransactionReportScreen(menu: menu!),
      'hospital-material-list' => HospitalStocksReportScreen(menu: menu!),
      //'refill' => RefillListScreen(menu: menu!),
      'tray' => AssignmentScreen(menu: menu!),
      'patient-inventory-list' => PatientInventoryReportScreen(menu: menu!),
      'material-usage-list' => MaterialUsageReportScreen(menu: menu!),
      'authorization-list' => AuthSummaryReportScreen(menu: menu!),
      'heatControl' => CabinTemperatureScreen(menu: menu!),
      'station-temperature-list' => CabinTemperatureReportScreen(menu: menu!),

      _ => const _NotFoundView(),
    };
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.common_pageNotFound));
  }
}

class _NoMenuContent extends StatelessWidget {
  const _NoMenuContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyStateWidget(
          icon: PhosphorIcons.fingerprint(),
          variant: EmptyStateVariant.custom,
          title: context.l10n.home_noAuthorizedMenuTitle,
          description: context.l10n.home_noAuthorizedMenuDescription,
        ),
        SizedBox(
          width: 200,
          child: MedButton(
            onPressed: () {
              context.read<AuthNotifier>().logout();
            },
            label: context.l10n.dashboard_logoutTooltip,
          ),
        ),
      ],
    );
  }
}
