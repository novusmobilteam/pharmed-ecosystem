// [SWREQ-UI-DASH-004] [HAZ-003] [HAZ-007] [HAZ-009]
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/assignment/presentation/view/assignment_view.dart';
import 'package:pharmed_client/features/dashboard/presentation/extensions/cabin_stock_extension.dart';
import 'package:pharmed_client/features/fault/presentation/view/fault_view.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../auth/presentation/notifier/auth_notifier.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../domain/model/dasboard_data.dart';

import '../notifier/dashboard_notifier.dart';
import '../state/dashboard_ui_state.dart';

part 'upcoming_treatments_view.dart';
part 'kpi_view.dart';
part 'skt_view.dart';
part 'cabin_view.dart';
part 'section_error.dart';
part 'dashboard_content.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardNotifierProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);
    final authNotif = ref.read(authNotifierProvider.notifier);

    final isLoggedIn = authNotif.isLoggedIn;
    final currentUser = authNotif.currentUser;
    final isExpiring = authState is AuthSessionExpiring;

    final (menuTree, flattenedMenus) = switch (dashState) {
      DashboardLoaded(:final menuTree, :final flattenedMenus) => (menuTree ?? [], flattenedMenus ?? []),
      DashboardStale(:final menuTree, :final flattenedMenus) => (menuTree ?? [], flattenedMenus ?? []),
      DashboardPartial(:final menuTree, :final flattenedMenus) => (menuTree ?? [], flattenedMenus ?? []),
      _ => (const <MenuItem>[], const <MenuItem>[]),
    };

    final currentRoute = switch (dashState) {
      DashboardLoaded s => s.activeRoute,
      DashboardStale s => s.activeRoute,
      DashboardPartial s => s.activeRoute,
      _ => 'dashboard',
    };

    final isNotAtHome = currentRoute != 'dashboard';

    return GestureDetector(
      // Her dokunuş oturum sayacını sıfırlar
      onTap: authNotif.onUserActivity,
      child: Scaffold(
        backgroundColor: MedColors.bg,

        appBar: DashboardAppBar(
          cabinLocation: 'Kat 3 · Koridor B',
          user: currentUser,
          onLoginTap: () => _showLoginModal(context, ref),
          onLogoutTap: authNotif.logout,
          cabinName: '',
          showBackButton: isNotAtHome,
          onBackToHome: () => notifier.navigateTo('dashboard'),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Navbar
                if (isLoggedIn)
                  DashboardNavBar(
                    menuTree: menuTree,
                    isLoggedIn: isLoggedIn,
                    onItemTap: (id) => notifier.navigateTo(id),
                    flattenedMenus: flattenedMenus,
                    currentRoute: currentRoute,
                  ),

                // LockedBanner (oturum kapandıysa)
                if (!isLoggedIn && _wasLoggedIn(authState))
                  LockedBanner(onLoginTap: () => _showLoginModal(context, ref)),

                // StaleBanner
                if (dashState is DashboardStale)
                  StaleBanner(lastUpdated: dashState.staleSince, canProceed: dashState.canProceed),

                // İçerik
                Expanded(child: DashboardContentFactory.buildContent(dashState, notifier, isLoggedIn)),
              ],
            ),

            // Session timeout banner (floating, sağ alt) ────
            if (isExpiring)
              Positioned(
                bottom: 20,
                right: 20,
                child: SessionTimeoutBanner(
                  secondsRemaining: (authState).secondsRemaining,
                  onExtend: authNotif.extendSession,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Daha önce giriş yapılmış mıydı? (banner için)
  bool _wasLoggedIn(AuthState state) => state is AuthLoggedOut;

  void _showLoginModal(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginModal(
        onLogin: (username, password) async {
          final notifier = ref.read(authNotifierProvider.notifier);
          final error = await notifier.login(email: username, password: password);
          return error;
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
