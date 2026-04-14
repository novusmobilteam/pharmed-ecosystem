import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class GetCabinVisualizerDataUseCase {
  const GetCabinVisualizerDataUseCase(this._cabinRepository, this._stockRepository, this._settingsCache);

  final ICabinRepository _cabinRepository;
  final ICabinStockRepository _stockRepository;
  final AppSettingsCache _settingsCache;

  Future<RepoResult<CabinVisualizerData>> call({required String? deviceMode}) async {
    // 1. Aktif cabinId
    final cabinId = await _settingsCache.getCurrentCabinId();

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-DASH-003',
      message: 'GetCabinVisualizerData çağrıldı',
      context: {'cabinId': cabinId, 'deviceMode': deviceMode},
    );

    if (cabinId == null) {
      return RepoFailure(ServiceException(message: 'Aktif kabin bulunamadı', statusCode: 404));
    }

    // 2. Mobil kabin akışı
    if (deviceMode == CabinType.mobile.name) {
      return _buildMobileVisualizer(cabinId);
    }

    // 3. Standart kabin akışı
    return _buildStandardVisualizer(cabinId);
  }

  // Mobil kabin
  Future<RepoResult<CabinVisualizerData>> _buildMobileVisualizer(int cabinId) async {
    final result = await _cabinRepository.getMobileCabinSlots(cabinId);

    final drawers = result.when(success: (data) => data, stale: (data, _) => data, failure: (_) => null);

    if (drawers == null || drawers.isEmpty) {
      return RepoFailure(ServiceException(message: 'Mobil kabin tasarımı bulunamadı', statusCode: 404));
    }

    final isStale = result is RepoStale;

    final slots = drawers.map((drawer) {
      return MobileSlotVisual(
        slotId: drawer.orderNumber,
        rowColumns: drawer.details.map((d) => d.columnsCount).toList(),
      );
    }).toList();

    final data = CabinVisualizerData(
      cabinId: cabinId,
      slots: slots,
      isStale: isStale,
      groups: const [],
      stocks: const [],
    );

    return isStale ? RepoStale(data, DateTime.now()) : RepoSuccess(data);
  }

  // Standart kabin
  Future<RepoResult<CabinVisualizerData>> _buildStandardVisualizer(int cabinId) async {
    final (slotResult, stockResult) = await (
      _cabinRepository.getCabinSlots(cabinId),
      _stockRepository.getCurrentCabinStock(),
    ).wait;

    final slots = slotResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => null);

    if (slots == null || slots.isEmpty) {
      return RepoFailure(ServiceException(message: 'Kabin tasarımı bulunamadı', statusCode: 404));
    }

    final unitResults = await Future.wait(
      slots.where((s) => s.id != null).map((s) => _cabinRepository.getDrawerUnits(s.id!)),
    );

    bool isStale = slotResult is RepoStale || stockResult is RepoStale || unitResults.any((r) => r is RepoStale);

    final groups = <DrawerGroup>[];
    final validSlots = slots.where((s) => s.id != null).toList();

    for (int i = 0; i < validSlots.length; i++) {
      final unitResult = unitResults[i];
      if (unitResult is RepoStale) isStale = true;
      final units = unitResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => <DrawerUnit>[]);
      groups.add(DrawerGroup(slot: validSlots[i], units: units));
    }

    groups.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    final stocks = stockResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => <CabinStock>[]);

    final slotVisuals = _buildSlots(groups, stocks);
    final data = CabinVisualizerData(
      cabinId: cabinId,
      slots: slotVisuals,
      isStale: isStale,
      groups: groups,
      stocks: stocks,
    );

    return isStale ? RepoStale(data, DateTime.now()) : RepoSuccess(data);
  }

  // Standart kabin slot builder
  List<DrawerSlotVisual> _buildSlots(List<DrawerGroup> groups, List<CabinStock> stocks) {
    final stocksByUnitId = <int, List<CabinStock>>{};
    for (final stock in stocks) {
      final unitId = stock.cabinDrawerDetail?.drawerUnit?.id;
      if (unitId != null) {
        stocksByUnitId.putIfAbsent(unitId, () => []).add(stock);
      }
    }

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-DASH-003',
      message: 'Stock lookup',
      context: {
        'stocksByUnitId keys': stocksByUnitId.keys.toList(),
        'group units': groups.map((g) => g.units.map((u) => u.id).toList()).toList(),
      },
    );

    return groups.where((g) => g.units.isNotEmpty).map((group) {
      final slot = group.slot;
      final config = slot.drawerConfig;
      final type = config?.drawerType;
      final deviceNo = config?.deviceTypeNo ?? 0;
      final isKubik = type?.isKubik ?? false;
      final isSerum = deviceNo == 250;
      final colCount = type?.compartmentCount == 20 ? 4 : 4;

      if (isSerum) {
        final allStocks = group.units.expand((u) => stocksByUnitId[u.id] ?? <CabinStock>[]).toList();
        return SerumSlotVisual(slotId: slot.id ?? 0, status: _resolveStatus(allStocks), heightFactor: 2);
      }

      final cells = group.units.map((unit) => _resolveStatus(stocksByUnitId[unit.id] ?? [])).toList();

      if (isKubik) {
        return KubicSlotVisual(slotId: slot.id ?? 0, cells: cells, columnCount: colCount);
      }

      return UnitDoseSlotVisual(slotId: slot.id ?? 0, cells: cells);
    }).toList();
  }

  DrawerStatus _resolveStatus(List<CabinStock> stocks) {
    if (stocks.isEmpty) return DrawerStatus.empty;

    var worst = DrawerStatus.full;

    for (final stock in stocks) {
      final qty = stock.quantity?.toDouble() ?? 0;
      final critical = stock.assignment?.criticalQuantity?.toDouble() ?? 0;
      final min = stock.assignment?.minQuantity?.toDouble() ?? 0;

      final status = switch (qty) {
        0 => DrawerStatus.empty,
        _ when qty <= critical => DrawerStatus.critical,
        _ when qty <= min => DrawerStatus.low,
        _ => DrawerStatus.full,
      };

      if (status._severity > worst._severity) worst = status;
    }

    return worst;
  }
}

extension _DrawerStatusSeverity on DrawerStatus {
  int get _severity => switch (this) {
    DrawerStatus.empty => 3,
    DrawerStatus.critical => 2,
    DrawerStatus.low => 1,
    DrawerStatus.full => 0,
  };
}
