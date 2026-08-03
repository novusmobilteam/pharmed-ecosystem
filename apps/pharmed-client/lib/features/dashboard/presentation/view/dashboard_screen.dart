// [SWREQ-UI-DASH-004] [HAZ-003] [HAZ-007] [HAZ-009]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/assignment/assignment_view.dart';
import 'package:pharmed_client/features/cabin_stock/cabin_stock.dart';
import 'package:pharmed_client/features/fault/fault_view.dart';
import 'package:pharmed_client/features/job_list/view/job_list_screen.dart';
import 'package:pharmed_client/features/my_patients/view/my_patients_screen.dart';
import 'package:pharmed_client/features/prescription/view/prescription_view.dart';
import 'package:pharmed_client/features/refund/refund_view.dart';
import 'package:pharmed_client/features/unapplied_prescription/unapplied_prescription.dart';
import 'package:pharmed_client/features/unload/unload_view.dart';
import 'package:pharmed_client/features/unscanned_barcodes/view/unscanned_barcodes_screen.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
import '../../../waste/waste.dart';

import '../notifier/dashboard_notifier.dart';
import '../notifier/dashboard_state.dart';
import 'dashboard_app_bar.dart';

part 'dashboard_content.dart';
part 'cabin_telemetry_panel.dart';

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
    final notifier = ref.read(dashboardNotifierProvider.notifier);
    final authNotif = ref.read(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    // AuthSessionExpiring de "logged in" sayılır — countdown sırasında menüler
    // aktif kalsın ki kullanıcı dokunsun, oturum uzasın.
    final isLoggedIn = authState is AuthLoggedIn || authState is AuthSessionExpiring;
    final isExpiring = authState is AuthSessionExpiring;
    final currentUser = authNotif.currentUser;

    final loaded = dashState is DashboardLoaded ? dashState : null;
    final menuTree = loaded?.menuTree ?? const <MenuItem>[];
    final flattenedMenus = loaded?.flattenedMenus ?? const <MenuItem>[];
    final currentRoute = loaded?.activeRoute ?? 'dashboard';

    return GestureDetector(
      onTap: authNotif.onUserActivity,
      child: Scaffold(
        backgroundColor: MedColors.bg,
        //appBar:,
        body: Stack(
          children: [
            Column(
              children: [
                // if (!isLoggedIn && _wasLoggedIn(authState))
                //   LockedBanner(onLoginTap: () => _showLoginModal(context, ref)),
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
                    onHomeTap: () => notifier.navigateTo('dashboard'),
                    onLoginTap: () => _showLoginModal(context, ref),
                    onLogoutTap: authNotif.logout,
                    onSettingsTap: () => _showSettingsPopup(context),
                    onMenuItemTap: (id) => isLoggedIn ? notifier.navigateTo(id) : null,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: MedSpacing.insetXl,
                    child: DashboardContentFactory.buildContent(context, ref, dashState, notifier, isLoggedIn),
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
