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
    DashboardLoading() => const Center(child: MedLoadingIndicator()),
    DashboardError() => EmptyStateWidget(variant: EmptyStateVariant.networkError, onRetry: notifier.refresh),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              spacing: MedSpacing.lg,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: data.upcomingTreatments.showError
                      ? EmptyStateWidget(variant: EmptyStateVariant.networkError, onRetry: notifier.refresh)
                      : UpcomingTreatmentPanel(section: data.upcomingTreatments),
                ),
                Expanded(
                  child: data.drugActivities.showError
                      ? EmptyStateWidget(variant: EmptyStateVariant.networkError, onRetry: notifier.refresh)
                      : DrugActivityPanel(section: data.drugActivities),
                ),
                Expanded(
                  child: data.unappliedPrescriptions.showError
                      ? EmptyStateWidget(variant: EmptyStateVariant.networkError, onRetry: notifier.refresh)
                      : UnappliedPrescriptionPanel(section: data.unappliedPrescriptions),
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
                data.hasCabinData
                    ? CabinStatusPanel(cabin: data.cabinVisualizerData!)
                    : EmptyStateWidget(variant: EmptyStateVariant.error, onRetry: notifier.refresh),
                const SizedBox(height: MedSpacing.lg),
                const CabinTelemetryPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrugActivityPanel extends StatelessWidget {
  const DrugActivityPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItemMovement>?> section;

  @override
  Widget build(BuildContext context) {
    final movements = section.data ?? const <PrescriptionItemMovement>[];

    return MedDashboardPanel(
      title: context.l10n.dashboard_drugActivityPanelTitle.toUpperCase(),
      section: section,
      itemCount: movements.length,
      itemBuilder: (BuildContext context, int index) {
        final movement = movements[index];
        return MedDrugActivityCard(movement: movement);
      },
    );
  }
}

class UpcomingTreatmentPanel extends StatelessWidget {
  const UpcomingTreatmentPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItem>?> section;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItem>[];

    return MedDashboardPanel(
      key: const ValueKey('upcoming_panel'),
      title: context.l10n.dashboardUpcomingTreatmentsPanelTitle,
      section: section,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MedDashboardRxCard(
          item: item,
          showFlags: true,
          showStatusChip: true,
          showTimeChip: true,
          tone: MedTone.neutral,
          infoLines: [
            DashboardRxInfoLine(
              context.l10n.assignment_patientLabel,
              item.prescription?.hospitalization?.patient?.fullName ?? '-',
            ),
            DashboardRxInfoLine('SERVİS', item.prescription?.hospitalization?.physicalService?.name ?? '-'),
          ],
        );
      },
    );
  }
}

class UnappliedPrescriptionPanel extends StatelessWidget {
  const UnappliedPrescriptionPanel({super.key, required this.section});

  final DashboardSection<List<PrescriptionItem>?> section;

  @override
  Widget build(BuildContext context) {
    final items = section.data ?? const <PrescriptionItem>[];

    return MedDashboardPanel(
      key: const ValueKey('unapplied_panel'),
      title: context.l10n.dashboardUnappliedPrescriptionsPanelTitle,
      section: section,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MedDashboardRxCard(
          item: item,
          showFlags: true,
          showStatusChip: false,
          showTimeChip: true,
          tone: MedTone.warning,
          infoLines: [
            DashboardRxInfoLine(
              context.l10n.assignment_patientLabel,
              item.prescription?.hospitalization?.patient?.fullName ?? '-',
            ),
            DashboardRxInfoLine(context.l10n.dashboardDoctorLabel, item.doctor?.fullName ?? '-'),
            DashboardRxInfoLine(
              'SERVİS',
              item.prescription?.hospitalization?.physicalService?.name ?? '-',
            ), // TODO(l10n): no all-caps ARB key exists for this label yet; see migration report
            DashboardRxInfoLine(
              context.l10n.dashboardRoomBedLabel,
              [
                item.prescription?.hospitalization?.room?.name,
                item.prescription?.hospitalization?.bed?.name,
              ].whereType<String>().join(' / '),
            ),
          ],
        );
      },
    );
  }
}
