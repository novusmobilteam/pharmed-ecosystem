part of 'dashboard_screen.dart';

class DashboardContentFactory {
  static Widget buildContent(BuildContext context, DashboardNotifier notifier, bool isLoggedIn) {
    final route = notifier.activeRoute;
    final activeMenu = notifier.flattenedMenus?.firstWhereOrNull((m) => m.slug == route);
    final cabinData = notifier.cabinVisualizerData;
    final auth = context.read<AuthNotifier>();

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => auth.onUserActivity(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: Duration.zero,
        child: KeyedSubtree(
          key: ValueKey(route),
          child: switch (route) {
            'dashboard' => _buildMainDashboard(context, notifier, isLoggedIn),
            'drug-assignment' => AssignmentView(),
            'drug-refill' => RefillView(cabinData: cabinData),
            'drug-intake' => IntakeView(cabinData: cabinData),
            'drug-activity' => const DrugActivityScreen(),
            'drug-unload' => UnloadView(cabinData: cabinData),
            'drug-census' => CensusView(cabinData: cabinData),
            'drawer-malfunction' => const FaultView(),
            //'drug-return' => activeMenu != null ? RefundView(menu: activeMenu) : const SizedBox.shrink(),
            //'drug-waste' => activeMenu != null ? WasteView(menu: activeMenu) : const SizedBox.shrink(),
            'cabin-stock' => activeMenu != null ? CabinStockView(menu: activeMenu) : const SizedBox.shrink(),
            'patient-request-review' =>
              activeMenu != null ? PrescriptionView(menu: activeMenu) : const SizedBox.shrink(),
            'unapplied-prescriptions' =>
              activeMenu != null ? UnappliedPrescriptionScreen(menu: activeMenu) : const SizedBox.shrink(),
            'my-patients' => activeMenu != null ? MyPatientsScreen(menu: activeMenu) : const SizedBox.shrink(),
            'drug-destruction' => DestructionView(),
            'daily-job-list' => activeMenu != null ? JobListScreen(menu: activeMenu) : const SizedBox.shrink(),
            'expiring-materials' => ExpiringItemsScreen(),
            'unscanned-barcodes' => UnscannedBarcodesScreen(),
            'cabin-design' => _CabinDesignRouteHandler(cabinId: cabinData?.cabinId ?? 0, notifier: notifier),

            //'return-box-unload' => activeMenu != null ? UnloadDrawerView(menu: activeMenu) : const SizedBox.shrink(),
            _ => Center(child: Text(context.l10n.common_pageNotFound)),
          },
        ),
      ),
    );
  }

  static Widget _buildMainDashboard(BuildContext context, DashboardNotifier notifier, bool isLoggedIn) {
    if (notifier.isInitialLoading && notifier.menuTree.isEmpty) {
      return const Center(child: MedLoadingIndicator());
    }
    if (notifier.globalErrorMessage != null) {
      return EmptyStateWidget(variant: EmptyStateVariant.networkError, onRetry: notifier.refresh);
    }
    return _DashboardBody(notifier: notifier, isLoggedIn: isLoggedIn);
  }
}

class _CabinDesignRouteHandler extends StatefulWidget {
  const _CabinDesignRouteHandler({required this.cabinId, required this.notifier});

  final int cabinId;
  final DashboardNotifier notifier;

  @override
  State<_CabinDesignRouteHandler> createState() => _CabinDesignRouteHandlerState();
}

class _CabinDesignRouteHandlerState extends State<_CabinDesignRouteHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CabinDesignDialog.show(context, cabinId: widget.cabinId);
      if (mounted) widget.notifier.navigateTo('dashboard');
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Ana sayfa yerleşimi.
///
/// Sol (esnek): yaklaşan tedaviler → ilaç aktiviteleri
/// Sağ (sabit 300): telemetri → kabin
/// Alt (tam genişlik): KPI şeridi — servis hazır olunca görünür
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.notifier, required this.isLoggedIn});

  final DashboardNotifier notifier;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: MenuView(isLoggedIn: isLoggedIn)),
        VerticalDivider(width: 1),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              // Kpi Section
              KpiView(),
              Divider(height: 1),
              Expanded(child: TablesView()),
              // Tables
            ],
          ),
        ),
        VerticalDivider(width: 1),
        Expanded(flex: 2, child: Column(children: [])),
      ],
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
              context.l10n.assignment_serviceLabel,
              item.prescription?.hospitalization?.physicalService?.name ?? '-',
            ),
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
