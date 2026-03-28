// lib/feature/dashboard/presentation/screen/dashboard_screen.dart
//
// [SWREQ-UI-DASH-004] [HAZ-003] [HAZ-007] [HAZ-009]
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/notifier/auth_notifier.dart';
import '../../../cabin_stock/domain/model/cabin_stock.dart';
import '../../domain/model/app_model.dart';
import '../../domain/model/dasboard_data.dart';

import '../notifier/dashboard_notifier.dart';
import '../state/dashboard_ui_state.dart';
import '../../../../../shared/widgets/atoms/atoms.dart';
import '../../../../../shared/widgets/molecules/molecules.dart';
import '../../../../../shared/widgets/organisms/organisms.dart';
import '../../../../../shared/widgets/organisms/app_top_bar.dart';
import '../../../../../shared/widgets/organisms/app_nav_organisms.dart';

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

    return GestureDetector(
      // Her dokunuş oturum sayacını sıfırlar
      onTap: authNotif.onUserActivity,
      child: Scaffold(
        backgroundColor: MedColors.bg,

        // ── TopBar ────────────────────────────────────────────
        appBar: AppTopBar(
          cabinCode: _cabinCode(dashState),
          cabinLocation: 'Kat 3 · Koridor B',
          isOnline: true,
          alertCount: _alertCount(dashState),
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
                  items: kDefaultMenuItems,
                  isLoggedIn: isLoggedIn,
                  shiftLabel: 'Gündüz · 07:00–19:00',
                  onItemTap: (id) {
                    // TODO: Navigation
                  },
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

  // ── Yardımcı metodlar ────────────────────────────────────────

  String _cabinCode(DashboardUiState state) => switch (state) {
    DashboardLoaded(:final data) => data.cabin.cabinCode,
    DashboardStale(:final data) => data.cabin.cabinCode,
    DashboardPartial(:final data) => data.cabin.cabinCode,
    _ => 'CB-304',
  };

  int _alertCount(DashboardUiState state) => switch (state) {
    DashboardLoaded(:final data) => data.alerts.length,
    DashboardStale(:final data) => data.alerts.length,
    DashboardPartial(:final data) => data.alerts.length,
    _ => 0,
  };

  // Daha önce giriş yapılmış mıydı? (banner için)
  bool _wasLoggedIn(AuthState state) => state is AuthLoggedOut;

  void _showLoginModal(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoginModal(
        cabinCode: 'CB-304',
        onLogin: (username, password) => ref.read(authNotifierProvider.notifier).login(username, password),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _DashboardBody
// ─────────────────────────────────────────────────────────────────

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
            // ── KPI Row ───────────────────────────────────────
            failedSections.contains(DashboardSection.kpi)
                ? const _SectionError(label: 'KPI verileri yüklenemedi')
                : _KpiSection(kpi: data.kpi, isStale: isStale),

            const SizedBox(height: 14),

            // ── 3 Kolon ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sol kolon: Kabin ─────────────────────────
                SizedBox(
                  width: 260,
                  child: failedSections.contains(DashboardSection.cabin)
                      ? const _SectionError(label: 'Kabin verisi yüklenemedi')
                      : _CabinSection(cabin: data.cabin, isStale: isStale, canProceed: canProceed, notifier: notifier),
                ),

                const SizedBox(width: 14),

                // ── Orta kolon: Tedaviler ────────────────────
                Expanded(
                  child: failedSections.contains(DashboardSection.treatments)
                      ? const _SectionError(label: 'Tedavi listesi yüklenemedi')
                      : _TreatmentsSection(treatments: data.treatments, isStale: isStale, notifier: notifier),
                ),

                const SizedBox(width: 14),

                // ── Sağ kolon: Uyarılar + SKT + Hızlı + Aktivite
                SizedBox(
                  width: 256,
                  child: Column(
                    children: [
                      // Uyarılar
                      if (data.alerts.isNotEmpty) AlertsList(alerts: data.alerts),

                      if (data.alerts.isNotEmpty) const SizedBox(height: 14),

                      // SKT
                      failedSections.contains(DashboardSection.skt)
                          ? const _SectionError(label: 'SKT verisi yüklenemedi')
                          : _SktSection(skt: data.skt, isStale: isStale),

                      const SizedBox(height: 14),

                      // Hızlı İşlemler
                      QuickActionsGrid(
                        actions: kDefaultQuickActions,
                        isLoggedIn: isLoggedIn,
                        onActionTap: (id) {
                          // TODO: action routing
                        },
                      ),

                      const SizedBox(height: 14),

                      // Son Aktiviteler
                      if (data.activities.isNotEmpty) ActivityFeed(activities: data.activities),
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

// ─────────────────────────────────────────────────────────────────
// _KpiSection
// ─────────────────────────────────────────────────────────────────

class _KpiSection extends StatelessWidget {
  const _KpiSection({required this.kpi, required this.isStale});

  final KpiData kpi;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    return KpiGrid(
      isStale: isStale,
      items: [
        KpiItem(
          label: 'Aktif Hasta',
          value: '${kpi.activePatients}',
          accentColor: MedColors.blue,
          progressValue: kpi.activePatientsProgress,
          deltaLabel: _deltaLabel(kpi.activePatientsChange),
          deltaDirection: _deltaDir(kpi.activePatientsChange),
          icon: const Icon(Icons.people_outline_rounded, size: 16, color: MedColors.blue),
        ),
        KpiItem(
          label: 'Tamamlanan İşlem',
          value: '${kpi.completedOperations}',
          accentColor: MedColors.green,
          progressValue: kpi.completedOperationsProgress,
          deltaLabel: '▲ ${kpi.completedOperationsChange}',
          deltaDirection: DeltaDirection.up,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: MedColors.green),
        ),
        KpiItem(
          label: 'Bekleyen Reçete',
          value: '${kpi.pendingPrescriptions}',
          accentColor: MedColors.amber,
          progressValue: kpi.pendingPrescriptionsProgress,
          deltaLabel: '— 0',
          deltaDirection: DeltaDirection.flat,
          icon: const Icon(Icons.receipt_outlined, size: 16, color: MedColors.amber),
        ),
        KpiItem(
          label: 'Kritik Uyarı',
          value: '${kpi.criticalAlerts}',
          accentColor: MedColors.red,
          progressValue: kpi.criticalAlertsProgress,
          deltaLabel: _deltaLabel(kpi.criticalAlertsChange),
          deltaDirection: _deltaDir(kpi.criticalAlertsChange),
          icon: const Icon(Icons.warning_amber_rounded, size: 16, color: MedColors.red),
        ),
      ],
    );
  }

  String _deltaLabel(int change) {
    if (change > 0) return '▲ $change';
    if (change < 0) return '▼ ${change.abs()}';
    return '— 0';
  }

  DeltaDirection _deltaDir(int change) {
    if (change > 0) return DeltaDirection.up;
    if (change < 0) return DeltaDirection.down;
    return DeltaDirection.flat;
  }
}

// ─────────────────────────────────────────────────────────────────
// _CabinSection
// ─────────────────────────────────────────────────────────────────

class _CabinSection extends StatelessWidget {
  const _CabinSection({required this.cabin, required this.isStale, required this.canProceed, required this.notifier});

  final CabinSummary cabin;
  final bool isStale;
  final bool canProceed;
  final DashboardNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: MedColors.border),
        borderRadius: MedRadius.mdAll,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        children: [
          _SectionHeader(
            title: 'KABİN DURUMU',
            dotColor: MedColors.blue,
            badge: MedBadge(
              label: cabin.isLocked ? 'Kilitli' : 'Açık',
              variant: cabin.isLocked ? MedBadgeVariant.green : MedBadgeVariant.amber,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                CabinVisualizer(
                  cabinId: cabin.cabinCode,
                  powerStatus: LedStatus.on,
                  alertStatus: cabin.criticalCount > 0 ? LedStatus.warning : LedStatus.on,
                  drawerGrid: cabin.drawerGrid,
                ),
                const SizedBox(height: 12),
                // Kabin durum satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kabin Durumu',
                      style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: cabin.isLocked ? MedColors.greenLight : MedColors.amberLight,
                        border: Border.all(color: cabin.isLocked ? const Color(0xFFB5DDD4) : const Color(0xFFF5D79E)),
                        borderRadius: MedRadius.xlAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cabin.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            size: 9,
                            color: cabin.isLocked ? MedColors.green : MedColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cabin.isLocked ? 'Kilitli' : 'Açık',
                            style: TextStyle(
                              fontFamily: MedFonts.mono,
                              fontSize: 9,
                              color: cabin.isLocked ? MedColors.green : MedColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                CabinStatsGrid(
                  totalDrawers: cabin.totalDrawers,
                  fullDrawers: cabin.fullDrawers,
                  emptyDrawers: cabin.emptyDrawers,
                  criticalCount: cabin.criticalCount,
                  todayOperations: cabin.todayOperations,
                  lastOpenedAt: cabin.lastOpenedAt,
                  lastOpenedBy: cabin.lastOpenedBy,
                  isStale: isStale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _SktSection
// ─────────────────────────────────────────────────────────────────

class _SktSection extends StatelessWidget {
  const _SktSection({required this.skt, required this.isStale});

  final SktSummary skt;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final items = skt.allItems.map((stock) {
      final sktStatus = switch (stock.expiryStatus) {
        ExpiryStatus.expired => SktStatus.expired,
        ExpiryStatus.critical => SktStatus.critical,
        ExpiryStatus.warning => SktStatus.warning,
        ExpiryStatus.ok => SktStatus.warning,
      };
      return SktItem(
        medicineName: stock.medicineName ?? '—',
        detail: [
          stock.drawerCode,
          if (stock.quantity != null) '${stock.quantity} ${stock.unit ?? ''}',
          if (stock.lotNumber != null) 'Lot: ${stock.lotNumber}',
        ].join(' · '),
        status: sktStatus,
        daysRemaining: stock.daysUntilExpiry,
      );
    }).toList();

    return SktList(items: items, isStale: isStale);
  }
}

// ─────────────────────────────────────────────────────────────────
// _TreatmentsSection
// ─────────────────────────────────────────────────────────────────

class _TreatmentsSection extends StatelessWidget {
  const _TreatmentsSection({required this.treatments, required this.isStale, required this.notifier});

  final List<TreatmentEntry> treatments;
  final bool isStale;
  final DashboardNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final items = treatments.map((t) {
      final palette = AvatarPalette.values[t.id % AvatarPalette.values.length];
      final initials = t.patientName
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();

      return TreatmentItem(
        time: t.timeLabel,
        patientName: t.patientName,
        patientId: t.patientIdLabel,
        avatar: MedAvatar(initials: initials, palette: palette),
        medicineName: t.medicineName,
        dose: t.dose,
        drawerCode: t.drawerCode,
        priority: _mapPriority(t.priority),
        status: _mapStatus(t.status),
        onDetail: () {},
      );
    }).toList();

    return TreatmentList(
      items: items,
      isStale: isStale,
      onNewAssign: () async {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => MedConfirmationDialog(
            title: 'Yeni Tedavi Ata',
            description: 'Yeni tedavi atama ekranına geçilecek.',
            confirmLabel: 'Devam Et',
            cancelLabel: 'İptal',
            isDangerous: false,
            onConfirm: () {
              Navigator.of(context).pop();
              notifier.assignNewTreatment();
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }

  TreatmentPriority _mapPriority(TreatmentPriorityDomain p) => switch (p) {
    TreatmentPriorityDomain.urgent => TreatmentPriority.urgent,
    TreatmentPriorityDomain.normal => TreatmentPriority.normal,
    TreatmentPriorityDomain.routine => TreatmentPriority.routine,
  };

  TreatmentStatus _mapStatus(TreatmentStatusDomain s) => switch (s) {
    TreatmentStatusDomain.pending => TreatmentStatus.pending,
    TreatmentStatusDomain.done => TreatmentStatus.done,
    TreatmentStatusDomain.returned => TreatmentStatus.returned,
  };
}

// ─────────────────────────────────────────────────────────────────
// Yardımcı widget'lar
// ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.dotColor, this.badge});

  final String title;
  final Color dotColor;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
        borderRadius: const BorderRadius.only(topLeft: MedRadius.md, topRight: MedRadius.md),
      ),
      child: Row(
        children: [
          StatusDot(color: dotColor, size: 7),
          const SizedBox(width: 7),
          Text(title, style: MedTextStyles.titleSm()),
          if (badge != null) ...[const Spacer(), badge!],
        ],
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

typedef TreatmentPriorityDomain = TreatmentPriority;
typedef TreatmentStatusDomain = TreatmentStatus;
