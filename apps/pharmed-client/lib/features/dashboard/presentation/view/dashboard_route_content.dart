part of 'dashboard_screen.dart';

class DashboardRouteContent extends ConsumerWidget {
  const DashboardRouteContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(dashboardNotifierProvider);
    final currentRoute = notifier.activeRoute;
    final activeMenu = notifier.flattenedMenus?.firstWhereOrNull((m) => m.slug == currentRoute);
    final activeCabin = notifier.activeCabin;
    final cabinData = activeCabin != null ? notifier.cabinVisualizerDataByCabin[activeCabin] : null;
    final deviceMode = notifier.deviceMode;

    final cabinDataByCabinId = <int, CabinVisualizerData>{
      for (final entry in notifier.cabinVisualizerDataByCabin.entries)
        if (entry.key.id != null) entry.key.id!: entry.value,
    };

    final cabinRouteContext = activeMenu != null
        ? CabinRouteContext(menu: activeMenu, cabinData: cabinData, deviceMode: deviceMode, station: notifier.station)
        : null;

    final stationCabinsContext = activeMenu != null
        ? StationCabinsContext(
            menu: activeMenu,
            cabinDataByCabinId: cabinDataByCabinId,
            cabins: notifier.cabins,
            station: notifier.station,
            deviceMode: deviceMode,
          )
        : null;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(authNotifierProvider.notifier).onUserActivity(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        reverseDuration: Duration.zero,
        child: KeyedSubtree(
          key: ValueKey(currentRoute),
          child: switch (currentRoute) {
            'dashboard' => SizedBox.shrink(),
            'drug-assignment' =>
              cabinRouteContext != null ? AssignmentView(cabinRouteContext: cabinRouteContext) : SizedBox.shrink(),
            'drug-refill' =>
              cabinRouteContext != null ? RefillView(cabinRouteContext: cabinRouteContext) : const SizedBox.shrink(),
            'drug-intake' =>
              stationCabinsContext != null ? IntakeView(stationContext: stationCabinsContext) : SizedBox.shrink(),
            'drug-activity' => DrugActivityScreen(menu: activeMenu!),
            'drug-unload' =>
              cabinRouteContext != null ? UnloadView(cabinRouteContext: cabinRouteContext) : SizedBox.shrink(),
            'drug-census' =>
              cabinRouteContext != null ? CensusView(cabinRouteContext: cabinRouteContext) : SizedBox.shrink(),
            'drawer-malfunction' =>
              cabinRouteContext != null ? FaultView(cabinRouteContext: cabinRouteContext) : SizedBox.shrink(),
            'drug-return' =>
              stationCabinsContext != null ? RefundView(stationContext: stationCabinsContext) : SizedBox.shrink(),
            'drug-waste' =>
              stationCabinsContext != null ? WasteView(stationContext: stationCabinsContext) : SizedBox.shrink(),
            'cabin-stock' =>
              cabinRouteContext != null ? CabinStockView(cabinRouteContext: cabinRouteContext) : SizedBox.shrink(),
            'patient-request-review' =>
              cabinRouteContext != null
                  ? PrescriptionScreen(cabinRouteContext: cabinRouteContext)
                  : const SizedBox.shrink(),
            'unapplied-prescriptions' =>
              cabinRouteContext != null
                  ? UnappliedPrescriptionScreen(cabinRouteContext: cabinRouteContext)
                  : const SizedBox.shrink(),
            'my-patients' =>
              cabinRouteContext != null
                  ? MyPatientsScreen(cabinRouteContext: cabinRouteContext)
                  : const SizedBox.shrink(),
            'drug-destruction' =>
              cabinRouteContext != null
                  ? DestructionView(cabinRouteContext: cabinRouteContext)
                  : const SizedBox.shrink(),
            'daily-job-list' =>
              cabinRouteContext != null ? JobListScreen(cabinRouteContext: cabinRouteContext) : const SizedBox.shrink(),
            'expiring-materials' => ExpiringItemsScreen(),
            'unscanned-barcodes' => UnscannedBarcodesScreen(),
            'cabin-design' => _CabinDesignRouteHandler(notifier: notifier),
            'return-box-unload' =>
              cabinRouteContext != null
                  ? UnloadDrawerScreen(cabinRouteContext: cabinRouteContext)
                  : const SizedBox.shrink(),
            'station-inventory' => InventoryScreen(),
            'directed-orders' => RedirectedOrdersScreen(),
            'emergency-patient-end' =>
              stationCabinsContext != null
                  ? UrgentPatientScreen(stationContext: stationCabinsContext)
                  : const SizedBox.shrink(),
            _ => Center(child: Text(context.l10n.common_pageNotFound)),
          },
        ),
      ),
    );
  }
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
