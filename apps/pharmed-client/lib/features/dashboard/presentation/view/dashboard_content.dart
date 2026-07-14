part of 'dashboard_screen.dart';

class DashboardContentFactory {
  static Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    DashboardNotifier notifier,
    bool isLoggedIn,
  ) {
    final loaded = state is DashboardLoaded ? state : null;
    final route = loaded?.activeRoute ?? 'dashboard';
    final activeMenu = loaded?.flattenedMenus?.firstWhereOrNull((m) => m.slug == route);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(authNotifierProvider.notifier).onUserActivity(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: Duration.zero,
        child: KeyedSubtree(
          key: ValueKey(route),
          child: switch (route) {
            'dashboard' => _buildMainDashboard(context, state, notifier, isLoggedIn),

            'drug-assignment' => const AssignmentView(),
            'drug-refill' => const RefillView(),
            'drug-intake' => const IntakeView(),
            'drug-activity' => const DrugActivityScreen(),
            'drug-unload' => const UnloadView(),
            'drug-census' => const CensusView(),
            'drawer-malfunction' => const FaultView(),

            'drug-return' => activeMenu != null ? RefundView(menu: activeMenu) : const SizedBox.shrink(),
            'drug-waste' => activeMenu != null ? WasteView(menu: activeMenu) : const SizedBox.shrink(),
            'cabin-stock' => activeMenu != null ? CabinStockView(menu: activeMenu) : const SizedBox.shrink(),
            'patient-request-review' =>
              activeMenu != null ? PrescriptionView(menu: activeMenu) : const SizedBox.shrink(),
            'unapplied-prescriptions' =>
              activeMenu != null ? UnappliedPrescriptionScreen(menu: activeMenu) : const SizedBox.shrink(),
            'my-patients' => activeMenu != null ? MyPatientsScreen(menu: activeMenu) : const SizedBox.shrink(),

            _ => Center(child: Text(context.l10n.common_pageNotFound)),
          },
        ),
      ),
    );
  }

  static Widget _buildMainDashboard(
    BuildContext context,
    DashboardState state,
    DashboardNotifier notifier,
    bool isLoggedIn,
  ) => switch (state) {
    DashboardLoading() => const _LoadingView(),
    DashboardError(:final message, :final isRetryable) => _ErrorView(
      message: message,
      isRetryable: isRetryable,
      onRetry: notifier.refresh,
    ),
    DashboardLoaded s => _DashboardBody(state: s, notifier: notifier, isLoggedIn: isLoggedIn),
  };
}

/// Ana sayfa yerleşimi.
///
/// Sol (esnek): yaklaşan tedaviler → ilaç aktiviteleri
/// Sağ (sabit 300): telemetri → kabin
/// Alt (tam genişlik): KPI şeridi — servis hazır olunca görünür
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state, required this.notifier, required this.isLoggedIn});

  final DashboardLoaded state;
  final DashboardNotifier notifier;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final data = state.data;

    return Padding(
      padding: MedSpacing.insetXl * 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: state.treatmentsFailed
                            ? _SectionError(
                                label: context.l10n.dashboard_treatmentsLoadError,
                                onRetry: notifier.refresh,
                              )
                            : UpcomingTreatmentsPanel(treatments: data.upcomingTreatments, isLoggedIn: isLoggedIn),
                      ),
                      const SizedBox(width: MedSpacing.lg),
                      Expanded(
                        child: state.activitiesFailed
                            ? _SectionError(
                                label: context.l10n.dashboard_activitiesLoadError,
                                onRetry: notifier.refresh,
                              )
                            : DrugActivityPanel(
                                activities: data.drugActivities,
                                onSeeAll: () => notifier.navigateTo('drug-activity'),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: MedSpacing.xl3),

                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CabinTelemetryPanel(),
                      const SizedBox(height: MedSpacing.lg),
                      data.hasCabinData
                          ? CabinView(cabin: data.cabinVisualizerData!, notifier: notifier)
                          : _SectionError(label: context.l10n.dashboard_cabinLoadError, onRetry: notifier.refresh),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (data.hasKpi) ...[const SizedBox(height: MedSpacing.lg), KpiStrip(kpi: data.kpi!)],
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: MedColors.blue));
}

/// Panel içi hata — tüm ekran yerine sadece o bölüm başarısız olduğunda.
class _SectionError extends StatelessWidget {
  const _SectionError({required this.label, this.onRetry});

  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MedSpacing.xl),
      decoration: BoxDecoration(
        color: MedColors.surface,
        borderRadius: MedRadius.lgAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 18, color: MedColors.text3),
          const SizedBox(width: MedSpacing.md),
          Expanded(
            child: Text(label, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          if (onRetry != null) _RetryButton(onTap: onRetry!, compact: true),
        ],
      ),
    );
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
        padding: const EdgeInsets.all(MedSpacing.xl4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: MedColors.redLight, borderRadius: MedRadius.lgAll),
              child: Icon(PhosphorIcons.wifiSlash(), size: 28, color: MedColors.red),
            ),
            const SizedBox(height: MedSpacing.xl),
            Text(
              message,
              style: MedTextStyles.bodyMd(color: MedColors.text2),
              textAlign: TextAlign.center,
            ),
            if (isRetryable) ...[const SizedBox(height: MedSpacing.xl2), _RetryButton(onTap: onRetry)],
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          height: compact ? 32 : MedSpacing.touchTarget,
          padding: EdgeInsets.symmetric(horizontal: compact ? MedSpacing.lg : MedSpacing.xl3),
          decoration: BoxDecoration(
            color: compact ? MedColors.surface2 : MedColors.blue,
            borderRadius: MedRadius.mdAll,
            border: compact ? Border.all(color: MedColors.border2) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.arrowClockwise(), size: 14, color: compact ? MedColors.text2 : Colors.white),
              const SizedBox(width: MedSpacing.sm),
              Text(
                context.l10n.common_retryButton,
                style: MedTextStyles.bodySm(color: compact ? MedColors.text2 : Colors.white, weight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
