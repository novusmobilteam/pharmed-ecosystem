// [SWREQ-UI-DASH-004] [HAZ-003] [HAZ-007] [HAZ-009]
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/dashboard/presentation/extensions/cabin_stock_extension.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import '../../../auth/presentation/notifier/auth_notifier.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../domain/model/app_model.dart';
import '../../domain/model/dasboard_data.dart';

import '../notifier/dashboard_notifier.dart';
import '../state/dashboard_ui_state.dart';

part 'upcoming_treatments_view.dart';
part 'kpi_view.dart';
part 'skt_view.dart';
part 'cabin_view.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final notifier = ref.read(dashboardNotifierProvider.notifier);
    final authNotif = ref.read(authNotifierProvider.notifier);

    final isLoggedIn = authNotif.isLoggedIn;
    final currentUser = authNotif.currentUser;
    final isExpiring = authState is AuthSessionExpiring;

    final List<MenuItem> menuItems = switch (dashState) {
      DashboardLoaded(:final menuTree) => menuTree ?? [],
      DashboardStale(:final menuTree) => menuTree ?? [],
      DashboardPartial(:final menuTree) => menuTree ?? [],
      _ => [], // Loading veya Error durumunda boş liste
    };

    return GestureDetector(
      // Her dokunuş oturum sayacını sıfırlar
      onTap: authNotif.onUserActivity,
      child: Scaffold(
        backgroundColor: MedColors.bg,

        appBar: AppTopBar(
          cabinCode: 'd3',
          cabinLocation: 'Kat 3 · Koridor B',
          isOnline: true,
          alertCount: 0,
          user: currentUser,
          onLoginTap: () => _showLoginModal(context, ref),
          onLogoutTap: authNotif.logout,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // ── SubNav ────────────────────────────────────
                AppSubNav(
                  items: menuItems,
                  isLoggedIn: isLoggedIn,
                  shiftLabel: 'Gündüz · 07:00–19:00',
                  onItemTap: (id) {},
                ),

                // ── LockedBanner (oturum kapandıysa) ──────────
                if (!isLoggedIn && _wasLoggedIn(authState))
                  LockedBanner(onLoginTap: () => _showLoginModal(context, ref)),

                // ── StaleBanner ───────────────────────────────
                if (dashState is DashboardStale)
                  StaleBanner(lastUpdated: dashState.staleSince, canProceed: dashState.canProceed),

                // ── İçerik ────────────────────────────────────
                Expanded(
                  child: switch (dashState) {
                    DashboardLoading() => const _LoadingView(),

                    DashboardLoaded(:final data) => _DashboardBody(
                      data: data,
                      notifier: notifier,
                      isLoggedIn: isLoggedIn,
                    ),

                    DashboardStale(:final data, :final canProceed) => _DashboardBody(
                      data: data,
                      notifier: notifier,
                      isStale: true,
                      canProceed: canProceed,
                      isLoggedIn: isLoggedIn,
                    ),

                    DashboardPartial(:final data, :final failedSections) => _DashboardBody(
                      data: data,
                      notifier: notifier,
                      failedSections: failedSections,
                      isLoggedIn: isLoggedIn,
                    ),

                    DashboardError(:final message, :final isRetryable) => _ErrorView(
                      message: message,
                      isRetryable: isRetryable,
                      onRetry: notifier.refresh,
                    ),
                  },
                ),
              ],
            ),

            // ── Session timeout banner (floating, sağ alt) ────
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
      builder: (_) => LoginModal(
        cabinCode: 'CB-304',
        onLogin: (username, password) {},
        // onLogin: (username, password) => ref.read(authNotifierProvider.notifier).login(username, password),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.data,
    required this.notifier,
    required this.isLoggedIn,
    this.isStale = false,
    this.canProceed = true,
    this.failedSections = const [],
  });

  final DashboardData data;
  final DashboardNotifier notifier;
  final bool isLoggedIn;
  final bool isStale;
  final bool canProceed;
  final List<DashboardSection> failedSections;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: MedColors.blue,
      onRefresh: notifier.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            failedSections.contains(DashboardSection.kpi)
                ? const _SectionError(label: 'KPI verileri yüklenemedi')
                : KpiView(kpi: data.kpi, isStale: isStale),
            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sol kolon: Kabin ─────────────────────────
                SizedBox(
                  width: 260,
                  child: data.hasCabinData
                      ? CabinView(
                          cabin: data.cabinVisualizerData!,
                          isStale: isStale,
                          canProceed: canProceed,
                          notifier: notifier,
                        )
                      : const _SectionError(label: 'Kabin verisi yüklenemedi'),
                ),
                const SizedBox(width: 14),

                // ── Orta kolon: Tedaviler ────────────────────
                Expanded(
                  child: failedSections.contains(DashboardSection.treatments)
                      ? const _SectionError(label: 'Tedavi listesi yüklenemedi')
                      : UpcomingTreatmentsView(
                          treatments: data.upcomingTreatments,
                          isStale: isStale,
                          notifier: notifier,
                        ),
                ),

                const SizedBox(width: 14),

                // ── Sağ kolon: Uyarılar + SKT + Hızlı + Aktivite
                SizedBox(
                  width: 256,
                  child: Column(
                    children: [
                      // Uyarılar
                      // if (data.alerts.isNotEmpty) AlertsList(alerts: data.alerts),

                      // if (data.alerts.isNotEmpty) const SizedBox(height: 14),

                      // // SKT
                      failedSections.contains(DashboardSection.skt)
                          ? const _SectionError(label: 'SKT verisi yüklenemedi')
                          : SktView(skt: data.expiringMaterials, isStale: isStale),
                      const SizedBox(height: 14),

                      // Hızlı İşlemler
                      // QuickActionsGrid(
                      //   actions: kDefaultQuickActions,
                      //   isLoggedIn: isLoggedIn,
                      //   onActionTap: (id) {
                      //     // TODO: action routing
                      //   },
                      // ),
                      const SizedBox(height: 14),

                      // Son Aktiviteler
                      // if (data.activities.isNotEmpty) ActivityFeed(activities: data.activities),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: MedColors.blue));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.isRetryable, required this.onRetry});

  final String message;
  final bool isRetryable;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: MedColors.redLight, borderRadius: MedRadius.lgAll),
              child: const Icon(Icons.wifi_off_rounded, size: 28, color: MedColors.red),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: MedTextStyles.bodySm(color: MedColors.text2),
              textAlign: TextAlign.center,
            ),
            if (isRetryable) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
                  child: Text('Tekrar Dene', style: MedTextStyles.bodyMd(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.redLight,
        border: Border.all(color: MedColors.red.withOpacity(0.3)),
        borderRadius: MedRadius.mdAll,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: MedColors.red),
          const SizedBox(width: 8),
          Text(label, style: MedTextStyles.bodySm(color: MedColors.red)),
        ],
      ),
    );
  }
}
