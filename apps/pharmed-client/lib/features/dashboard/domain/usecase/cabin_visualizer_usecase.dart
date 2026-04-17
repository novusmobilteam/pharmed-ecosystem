import 'package:pharmed_client/core/cache/app_settings_cache.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// lib/features/cabin/domain/usecase/get_cabin_visualizer_data_use_case.dart
//
// [SWREQ-UI-DASH-003]
// Kabin görselleştirme verisi use case.
//
// debugCabin != null ise cache'e dokunulmadan bu kabinin
// id ve type'ı kullanılır. Cache değişmez.
//
// Sınıf: Class B

import 'package:flutter/foundation.dart';

import '../../../fault/fault.dart';

class GetCabinVisualizerDataUseCase {
  const GetCabinVisualizerDataUseCase(
    this._cabinRepository,
    this._stockRepository,
    this._settingsCache,
    this._getMasterFaults,
    this._getMobileFaults,
  );

  final ICabinRepository _cabinRepository;
  final ICabinStockRepository _stockRepository;
  final AppSettingsCache _settingsCache;
  final GetMasterCabinFaultRecordsUseCase _getMasterFaults;
  final GetMobileCabinFaultRecordsUseCase _getMobileFaults;

  /// [debugCabin] sadece kDebugMode'da geçilir.
  /// null → normal akış (cache'deki cabinId + deviceMode).
  /// non-null → debugCabin.id ve debugCabin.type kullanılır.
  Future<RepoResult<CabinVisualizerData>> call({required CabinType? deviceMode, Cabin? debugCabin}) async {
    // Effective id ve mode
    final int? cabinId;
    final CabinType? effectiveMode;

    if (kDebugMode && debugCabin != null) {
      cabinId = debugCabin.id;
      effectiveMode = debugCabin.type;
      MedLogger.info(
        unit: 'SW-UNIT-UI',
        swreq: 'SWREQ-UI-DASH-003',
        message: '[DEBUG] Kabin override aktif',
        context: {'cabinId': cabinId, 'deviceMode': effectiveMode},
      );
    } else {
      cabinId = await _settingsCache.getCurrentCabinId();
      effectiveMode = deviceMode;
      MedLogger.info(
        unit: 'SW-UNIT-UI',
        swreq: 'SWREQ-UI-DASH-003',
        message: 'GetCabinVisualizerData çağrıldı',
        context: {'cabinId': cabinId, 'deviceMode': deviceMode},
      );
    }

    if (cabinId == null) {
      return RepoFailure(ServiceException(message: 'Aktif kabin bulunamadı', statusCode: 404));
    }

    if (effectiveMode == CabinType.mobile) {
      return _buildMobileVisualizer(cabinId);
    }

    return _buildStandardVisualizer(cabinId);
  }

  // Mobil kabin akışı
  Future<RepoResult<CabinVisualizerData>> _buildMobileVisualizer(int cabinId) async {
    final results = await Future.wait([_cabinRepository.getMobileCabinSlots(cabinId), _getMobileFaults.call()]);

    final slotResult = results[0] as RepoResult<List<MobileDrawerSlot>>;
    final faultResult = results[1] as Result<List<MobileFault>>;

    final slots = slotResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => null);

    if (slots == null || slots.isEmpty) {
      return RepoFailure(ServiceException(message: 'Mobil kabin tasarımı bulunamadı', statusCode: 404));
    }

    final mobileFaults = faultResult.when(
      ok: (faults) => faults.where((f) => f.endDate == null).toList(),
      error: (_) => <MobileFault>[],
    );

    // Aktif fault'a göre slot visual oluştur
    final faultBySlotId = {for (final f in mobileFaults) f.cabinDesignId: f};

    final isStale = slotResult is RepoStale;

    final slotVisuals = slots.map((slot) {
      return MobileSlotVisual(
        slotId: slot.id,
        rowColumns: slot.units.map((u) => u.columnCount).toList(),
        workingStatus: faultBySlotId[slot.id]?.workingStatus,
      );
    }).toList();

    final data = CabinVisualizerData(
      cabinId: cabinId,
      slots: slotVisuals,
      mobileSlots: slots,
      isStale: isStale,
      groups: const [],
      stocks: const [],
      mobileFaults: mobileFaults,
    );

    return isStale ? RepoStale(data, DateTime.now()) : RepoSuccess(data);
  }

  // Standart kabin akışı
  Future<RepoResult<CabinVisualizerData>> _buildStandardVisualizer(int cabinId) async {
    final (slotResult, stockResult, faultResult) = await (
      _cabinRepository.getCabinSlots(cabinId),
      _stockRepository.getCurrentCabinStock(),
      _getMasterFaults.call(),
    ).wait;

    final slots = slotResult.when(success: (data) => data, stale: (data, _) => data, failure: (_) => null);

    if (slots == null || slots.isEmpty) {
      return RepoFailure(ServiceException(message: 'Kabin tasarımı bulunamadı', statusCode: 404));
    }

    final masterFaults = faultResult.when(
      ok: (faults) => faults.where((f) => f.endDate == null).toList(),
      error: (_) => <MasterFault>[],
    );

    final faultByUnitId = {for (final f in masterFaults) f.slotId: f};

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

      // Fault durumunu DrawerUnit'e yansıt
      final enrichedUnits = units.map((u) {
        final fault = faultByUnitId[u.id];
        if (fault == null) return u;
        return u.copyWith(workingStatus: fault.workingStatus ?? CabinWorkingStatus.faulty);
      }).toList();

      groups.add(DrawerGroup(slot: validSlots[i], units: enrichedUnits));
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
      masterFaults: masterFaults,
    );

    return isStale ? RepoStale(data, DateTime.now()) : RepoSuccess(data);
  }

  // Slot builder

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
      const colCount = 4;

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
