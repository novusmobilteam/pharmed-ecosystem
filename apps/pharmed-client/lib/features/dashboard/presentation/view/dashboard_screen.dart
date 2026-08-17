import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pharmed_client/features/assignment/assignment_view.dart';
import 'package:pharmed_client/features/cabin_design/view/cabin_design_dialog.dart';
import 'package:pharmed_client/features/cabin_stock/cabin_stock.dart';
import 'package:pharmed_client/features/fault/fault_view.dart';
import 'package:pharmed_client/features/job_list/view/job_list_screen.dart';
import 'package:pharmed_client/features/my_patients/view/my_patients_screen.dart';
import 'package:pharmed_client/features/prescription/view/prescription_view.dart';
import 'package:pharmed_client/features/unapplied_prescription/unapplied_prescription.dart';
import 'package:pharmed_client/features/unscanned_barcodes/view/unscanned_barcodes_screen.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../../../auth/auth.dart';
import '../../../census/census.dart';
import '../../../destruction/view/destruction_view.dart';
import '../../../drug_activity/drug_activity.dart';
import '../../../expiring_items/view/expiring_items_screen.dart';
import '../../../intake/intake.dart';
import '../../../refill/refill.dart';
import '../../../settings/notifier/settings_notifier.dart';
import '../../../settings/view/settings_view.dart';

import '../../../unload/unload.dart';
import '../notifier/dashboard_notifier.dart';
import 'dashboard_app_bar.dart';

part 'dashboard_content.dart';
part 'cabin_telemetry_panel.dart';
part 'tables_view.dart';
part 'kpi_view.dart';
part 'menu_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DashboardNotifier>(
      create: (ctx) => DashboardNotifier(
        getUpcomingTreatments: ctx.read(),
        getDrugActivities: ctx.read(),
        getUnapplied: ctx.read(),
        getCabinVisualizer: ctx.read(),
        getFilteredMenus: ctx.read(),
        getAllRooms: ctx.read(),
        getAllBeds: ctx.read(),
        getAllServices: ctx.read(),
        getDeviceMode: ctx.read<SettingsNotifier>().getDeviceMode,
        settings: ctx.read(),
        authNotifier: ctx.read<AuthNotifier>(),
        settingsNotifier: ctx.read<SettingsNotifier>(),
        cabinConnection: ctx.read<CabinConnectionNotifier>(),
      )..initialize(),
      child: const _DashboardScreenContent(),
    );
  }
}

class _DashboardScreenContent extends StatelessWidget {
  const _DashboardScreenContent();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DashboardNotifier>();

    final menuTree = notifier.menuTree;
    final flattenedMenus = notifier.flattenedMenus ?? const <MenuItem>[];
    final currentRoute = notifier.activeRoute;

    return Material(
      child: GestureDetector(
        onTap: () => context.read<AuthNotifier>().onUserActivity(),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  _DashboardAppBarSection(
                    notifier: notifier,
                    menuTree: menuTree,
                    flattenedMenus: flattenedMenus,
                    currentRoute: currentRoute,
                  ),
                  Expanded(child: _DashboardRouteContent(notifier: notifier)),
                ],
              ),
            ),
            const _SessionTimeoutOverlay(),
          ],
        ),
      ),
    );
  }
}

class _DashboardAppBarSection extends StatelessWidget {
  const _DashboardAppBarSection({
    required this.notifier,
    required this.menuTree,
    required this.flattenedMenus,
    required this.currentRoute,
  });

  final DashboardNotifier notifier;
  final List<MenuItem> menuTree;
  final List<MenuItem> flattenedMenus;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    // isLoggedIn ve currentUser countdown tick'inde DEĞİŞMEZ — sadece gerçek
    // login/logout/session-timeout anında değişir. select() bu yüzden
    // saniyede bir değil, sadece o an gerçekten tetikler.
    final isLoggedIn = context.select<AuthNotifier, bool>(
      (auth) => auth.state is AuthLoggedIn || auth.state is AuthSessionExpiring,
    );
    final currentUser = context.select<AuthNotifier, AppUser?>((auth) => auth.currentUser);

    return DashboardAppBar(
      menuTree: menuTree,
      flattenedMenus: flattenedMenus,
      currentRoute: currentRoute,
      isLoggedIn: isLoggedIn,
      isActiveRouteDashboard: notifier.isActiveRouteDashboard,
      onHomeTap: () {
        notifier.navigateTo('dashboard');
        notifier.refresh();
      },
      onLoginTap: () => _showLoginModal(context),
      onLogoutTap: () => context.read<AuthNotifier>().logout(),
      onSettingsTap: () => SettingsView.show(context),
      user: currentUser,
    );
  }

  void _showLoginModal(BuildContext context) {
    final auth = context.read<AuthNotifier>();
    final settings = context.read<SettingsNotifier>();

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AnimatedBuilder(
        animation: auth,
        builder: (ctx, _) {
          final isLoading = auth.state is AuthLoading;
          return LoginModal(
            isLoading: isLoading,
            onLogin: (username, password, onError) async {
              await auth.login(email: username, password: password, onError: onError);
              if (auth.state is AuthLoggedIn && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            onLoginWithBadge: (cardData, onError) async {
              await auth.loginWithBadge(cardData: cardData, onError: onError);
              if (auth.state is AuthLoggedIn && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            currentLanguage: settings.language,
            onLanguageChanged: settings.setLanguage,
          );
        },
      ),
    );
  }
}

class _DashboardRouteContent extends StatelessWidget {
  const _DashboardRouteContent({required this.notifier});

  final DashboardNotifier notifier;

  @override
  Widget build(BuildContext context) {
    // IntakeView/RefillView/vb. burada üretiliyor — isLoggedIn nadiren
    // değiştiği için bu widget artık saniyede bir DEĞİL, sadece gerçek
    // login/logout/timeout anında rebuild olur.
    final isLoggedIn = context.select<AuthNotifier, bool>(
      (auth) => auth.state is AuthLoggedIn || auth.state is AuthSessionExpiring,
    );
    return DashboardContentFactory.buildContent(context, notifier, isLoggedIn);
  }
}

class _SessionTimeoutOverlay extends StatelessWidget {
  const _SessionTimeoutOverlay();

  @override
  Widget build(BuildContext context) {
    // Countdown tick'i SADECE bu küçük widget'ı etkiler — appbar ve route
    // content bu değişiklikten tamamen izole.
    final authState = context.select<AuthNotifier, AuthState>((auth) => auth.state);
    if (authState is! AuthSessionExpiring) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      right: 20,
      child: SessionTimeoutBanner(
        secondsRemaining: authState.secondsRemaining,
        onExtend: () => context.read<AuthNotifier>().onUserActivity(),
      ),
    );
  }
}
