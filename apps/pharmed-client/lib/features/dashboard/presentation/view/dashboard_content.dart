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

    // Kabin verisi tamamen yoksa (hiç kabin çekilemediyse) — TÜM ekranı
    // kaplayan blok. Uygulama genelinde kabin verisi olmadan işlem
    // yapılamıyor, bu yüzden route'a bakılmaksızın burada durulur.
    if (loaded != null && loaded.data.cabinDataFailed && loaded.data.cabinVisualizerDataByCabinId.isEmpty) {
      return Center(
        child: EmptyStateWidget(variant: EmptyStateVariant.cabinData, onRetry: notifier.retryCabinData),
      );
    }

    if (loaded != null && loaded.pendingCabinRoute != null) {
      return CabinSelectionView(
        cabins: loaded.data.stationCabins,
        cabinDataByCabinId: loaded.data.cabinVisualizerDataByCabinId,
        onCabinSelected: notifier.selectCabinForPendingRoute,
      );
    }

    final route = loaded?.activeRoute ?? 'dashboard';
    final activeMenu = loaded?.flattenedMenus?.firstWhereOrNull((m) => m.slug == route);

    final cabinId = loaded?.activeCabinId;
    final cabinData = cabinId != null ? loaded?.data.cabinVisualizerDataByCabinId[cabinId] : null;
    final deviceMode = loaded?.deviceMode;
    final cabin = cabinId != null ? loaded?.data.stationCabins.firstWhereOrNull((c) => c.id == cabinId) : null;

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
            'drug-assignment' =>
              activeMenu != null
                  ? AssignmentView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode, cabin: cabin)
                  : SizedBox.shrink(),
            'drug-refill' =>
              activeMenu != null
                  ? RefillView(menu: activeMenu, deviceMode: deviceMode, cabinData: cabinData)
                  : const SizedBox.shrink(),
            'drug-intake' =>
              activeMenu != null
                  ? IntakeView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'drug-activity' => const DrugActivityScreen(),
            'drug-unload' =>
              activeMenu != null
                  ? UnloadView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'drug-census' =>
              activeMenu != null
                  ? CensusView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'drawer-malfunction' =>
              activeMenu != null
                  ? FaultView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'drug-return' =>
              activeMenu != null
                  ? RefundView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'drug-waste' =>
              activeMenu != null
                  ? WasteView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : SizedBox.shrink(),
            'cabin-stock' =>
              activeMenu != null ? CabinStockView(menu: activeMenu, cabinData: cabinData!) : SizedBox.shrink(),
            'patient-request-review' =>
              activeMenu != null
                  ? PrescriptionView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : const SizedBox.shrink(),
            'unapplied-prescriptions' =>
              activeMenu != null
                  ? UnappliedPrescriptionScreen(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : const SizedBox.shrink(),
            'my-patients' => activeMenu != null ? MyPatientsScreen(menu: activeMenu) : const SizedBox.shrink(),
            'drug-destruction' =>
              activeMenu != null
                  ? DestructionView(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : const SizedBox.shrink(),
            'daily-job-list' =>
              activeMenu != null
                  ? JobListScreen(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode)
                  : const SizedBox.shrink(),
            'expiring-materials' => ExpiringItemsScreen(),
            'unscanned-barcodes' => UnscannedBarcodesScreen(),
            'cabin-design' => _CabinDesignRouteHandler(notifier: notifier),
            'return-box-unload' =>
              activeMenu != null ? UnloadDrawerView(menu: activeMenu, cabinData: cabinData) : const SizedBox.shrink(),

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

class _CabinDesignRouteHandler extends StatefulWidget {
  const _CabinDesignRouteHandler({required this.notifier});

  final DashboardNotifier notifier;

  @override
  State<_CabinDesignRouteHandler> createState() => _CabinDesignRouteHandlerState();
}

class _CabinDesignRouteHandlerState extends State<_CabinDesignRouteHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await CabinDesignDialog.show(context);
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
  const _DashboardBody({required this.state, required this.notifier, required this.isLoggedIn});

  final DashboardLoaded state;
  final DashboardNotifier notifier;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final data = state.data;

    return Row(
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
              if (_primaryCabinData(state, data) case final cabinData?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CabinStatusPanel(cabin: cabinData),
                ),
              const CabinTelemetryPanel(),
            ],
          ),
        ),
      ],
    );
  }

  /// Dashboard özetinde gösterilecek TEK kabin — master istasyonda master
  /// kabin, mobil istasyonda (zaten tek kabin olduğu için) o kabin.
  CabinVisualizerData? _primaryCabinData(DashboardLoaded state, DashboardData data) {
    final targetCabin = state.deviceMode == CabinType.mobile
        ? data.stationCabins.firstOrNull
        : data.stationCabins.firstWhereOrNull((c) => c.type == CabinType.master);

    if (targetCabin?.id == null) return null;
    return data.cabinVisualizerDataByCabinId[targetCabin!.id];
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
