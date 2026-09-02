import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/assignment/assignment_view.dart';
import 'package:pharmed_client/features/cabin_design/view/cabin_design_dialog.dart';
import 'package:pharmed_client/features/cabin_stock/cabin_stock.dart';
import 'package:pharmed_client/features/fault/fault_view.dart';
import 'package:pharmed_client/features/job_list/view/job_list_screen.dart';
import 'package:pharmed_client/features/my_patients/view/my_patients_screen.dart';
import 'package:pharmed_client/features/refund/refund_view.dart';
import 'package:pharmed_client/features/unapplied_prescription/unapplied_prescription.dart';
import 'package:pharmed_client/features/unload/unload_view.dart';
import 'package:pharmed_client/features/unscanned_barcodes/view/unscanned_barcodes_screen.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/hardware/hardware.dart';
import '../../../../widgets/widgets.dart';
import '../../../auth/auth.dart';
import '../../../census/census.dart';
import '../../../destruction/view/destruction_view.dart';
import '../../../drug_activity/drug_activity.dart';
import '../../../expiring_items/view/expiring_items_screen.dart';
import '../../../intake/intake.dart';
import '../../../inventory/view/inventory_screen.dart';
import '../../../prescription/view/prescription_screen.dart';
import '../../../redirected_orders/view/redirected_orders_screen.dart';
import '../../../refill/refill.dart';
import '../../../settings/notifier/settings_notifier.dart';
import '../../../settings/view/settings_view.dart';
import '../../../unload_drawer/view/unload_drawer_screen.dart';
import '../../../urgent_patient/urgent_patient.dart';
import '../../../waste/waste.dart';

import '../../dashboard.dart';
import '../notifier/dashboard_notifier.dart';
import '../widgets/dashboard_app_bar.dart';
import 'cabin_selection_view.dart';

part 'dashboard_route_content.dart';
part 'cabin_telemetry_panel.dart';
part 'upcoming_treatment_panel.dart';

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
    final notifier = ref.watch(dashboardNotifierProvider);
    final authNotif = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    final isLoggedIn = authState is AuthLoggedIn || authState is AuthSessionExpiring;
    final isExpiring = authState is AuthSessionExpiring;
    final currentUser = authNotif.currentUser;

    final menuTree = notifier.menuTree ?? const <MenuItem>[];
    final flattenedMenus = notifier.flattenedMenus ?? const <MenuItem>[];
    final currentRoute = notifier.activeRoute;

    ref.listen(authNotifierProvider, (previous, next) {
      final wasActive = previous is AuthLoggedIn || previous is AuthSessionExpiring;
      final isNowLoggedOut = next is AuthLoggedOut;
      if (wasActive && isNowLoggedOut) {
        ref.read(dashboardNotifierProvider.notifier).navigateTo('dashboard');
      }
    });

    if (notifier.isMainDataLoading) {
      return const Scaffold(body: Center(child: MedLoadingIndicator()));
    }

    return Scaffold(
      body: GestureDetector(
        onTap: authNotif.onUserActivity,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MedSpacing.insetXl.top,
                    right: MedSpacing.insetXl.right,
                    left: MedSpacing.insetXl.left,
                  ),
                  child: DashboardAppBar(
                    menuTree: menuTree,
                    flattenedMenus: flattenedMenus,
                    currentRoute: currentRoute,
                    isLoggedIn: isLoggedIn,
                    user: currentUser,
                    onHomeTap: () {
                      notifier.navigateTo('dashboard');
                      notifier.refresh(forceRefresh: false);
                    },
                    onLoginTap: () => _showLoginModal(context, ref),
                    onLogoutTap: authNotif.logout,
                    onSettingsTap: () => _showSettingsPopup(context),
                    onMenuItemTap: (id) => isLoggedIn ? notifier.navigateTo(id) : null,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: MedSpacing.insetXl,
                    child: _DashboardBody(isLoggedIn: isLoggedIn),
                  ),
                ),
              ],
            ),

            if (isExpiring)
              Positioned(
                bottom: 20,
                right: 20,
                child: SessionTimeoutBanner(
                  secondsRemaining: authState.secondsRemaining,
                  onExtend: authNotif.onUserActivity,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLoginModal(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final isLoading = ref.watch(authNotifierProvider) is AuthLoading;
          return LoginModal(
            isLoading: isLoading,
            onLogin: (username, password, onError) async {
              await ref
                  .read(authNotifierProvider.notifier)
                  .login(email: username, password: password, onError: onError);
              if (ref.read(authNotifierProvider) is AuthLoggedIn && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            onLoginWithBadge: (cardData, onError) async {
              await ref.read(authNotifierProvider.notifier).loginWithBadge(cardData: cardData, onError: onError);
              if (ref.read(authNotifierProvider) is AuthLoggedIn && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            currentLanguage: ref.watch(settingsNotifierProvider.select((s) => s.language)),
            onLanguageChanged: (lang) => ref.read(settingsNotifierProvider.notifier).setLanguage(lang),
          );
        },
      ),
    );
  }

  void _showSettingsPopup(BuildContext context) => SettingsView.show(context);
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(dashboardNotifierProvider);

    final cabinDataByCabinId = <int, CabinVisualizerData>{
      for (final entry in notifier.cabinVisualizerDataByCabin.entries)
        if (entry.key.id != null) entry.key.id!: entry.value,
    };

    if (notifier.pendingCabinRoute != null) {
      return CabinSelectionView(
        cabins: notifier.cabins,
        cabinDataByCabinId: cabinDataByCabinId,
        onCabinSelected: notifier.selectCabinForPendingRoute,
      );
    }

    if (notifier.isActiveRouteDashboard) {
      return Row(
        spacing: MedSpacing.lg,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: UpcomingTreatmentPanel(section: DashboardSection(data: notifier.upcomingTreatments)),
          ),
          Expanded(
            flex: 2,
            child: DrugActivityPanel(section: DashboardSection(data: notifier.drugActivities)),
          ),
          Expanded(
            child: Column(
              children: [
                if (notifier.primaryCabinData() case final cabinData?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CabinStatusPanel(cabin: cabinData),
                  ),
                CabinTelemetryPanel(),
              ],
            ),
          ),
        ],
      );
    }

    return DashboardRouteContent();
  }
}
