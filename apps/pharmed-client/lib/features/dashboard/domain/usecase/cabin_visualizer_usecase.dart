import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class GetCabinVisualizerDataUseCase {
  const GetCabinVisualizerDataUseCase(this._cabinRepository, this._stockRepository, this._settingsCache);

  final ICabinRepository _cabinRepository;
  final ICabinStockRepository _stockRepository;
  final AppSettingsCache _settingsCache;

  Future<RepoResult<CabinVisualizerData>> call() async {
    // ── 1. Aktif cabinId ─────────────────────────────────────
    final cabinId = await _settingsCache.getCurrentCabinId();

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-DASH-003',
      message: 'GetCabinVisualizerData çağrıldı',
      context: {'cabinId': cabinId},
    );

    if (cabinId == null) {
      return RepoFailure(ServiceException(message: 'Aktif kabin bulunamadı', statusCode: 404));
    }

    // ── 2. Slots + Stock paralel çek ─────────────────────────
    final (slotResult, stockResult) = await (
      _cabinRepository.getCabinSlots(cabinId),
      _stockRepository.getCurrentCabinStock(),
    ).wait;

    final slots = slotResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => null);

    if (slots == null || slots.isEmpty) {
      return RepoFailure(ServiceException(message: 'Kabin tasarımı bulunamadı', statusCode: 404));
    }

    // ── 3. Her slot için units çek ───────────────────────────
    final unitResults = await Future.wait(
      slots.where((s) => s.id != null).map((s) => _cabinRepository.getDrawerUnits(s.id!)),
    );

    // isStale: herhangi bir kaynak cache'den geldiyse
    bool isStale = slotResult is RepoStale || stockResult is RepoStale || unitResults.any((r) => r is RepoStale);

    // Slot → units eşleştir
    final groups = <DrawerGroup>[];
    final validSlots = slots.where((s) => s.id != null).toList();

    for (int i = 0; i < validSlots.length; i++) {
      final unitResult = unitResults[i];

      if (unitResult is RepoStale) isStale = true;

      final units = unitResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => <DrawerUnit>[]);

      groups.add(DrawerGroup(slot: validSlots[i], units: units));
    }

    groups.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    // ── 4. Stok lookup ───────────────────────────────────────
    final stocks = stockResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => <CabinStock>[]);

    // ── 5. Grid üret ─────────────────────────────────────────
    final slot = _buildSlots(groups, stocks);
    final data = CabinVisualizerData(cabinId: cabinId, slots: slot, isStale: isStale);

    return isStale
        ? RepoStale(data, DateTime.now()) // en erken stale zamanı idealde, şimdilik now
        : RepoSuccess(data);
  }

  List<DrawerSlotVisual> _buildSlots(List<DrawerGroup> groups, List<CabinStock> stocks) {
    // Unit → stok lookup
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
      final colCount = type?.compartmentCount == 20 ? 4 : 4; // 4×4 ve 4×5 için sütun sayısı

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
