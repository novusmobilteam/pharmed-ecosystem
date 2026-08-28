import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class GetCabinVisualizerDataUseCase {
  const GetCabinVisualizerDataUseCase(this._cabinRepository, this._getMasterFaults, this._getMobileFaults);

  final ICabinRepository _cabinRepository;
  final GetMasterCabinFaultRecordsUseCase _getMasterFaults;
  final GetMobileCabinFaultRecordsUseCase _getMobileFaults;

  Future<Result<CabinVisualizerData>> call({
    required Cabin cabin,
    CabinType? deviceMode,
    bool forceRefresh = false,
  }) async {
    final cabinId = cabin.id;

    if (cabinId == null) {
      return Result.error(ServiceException(message: contextlessL10n().cabinCore_activeCabinNotFound, statusCode: 404));
    }

    if (deviceMode == CabinType.mobile) {
      return _buildMobileVisualizer(cabin, cabinId, forceRefresh: forceRefresh);
    }

    return _buildStandardVisualizer(cabin, cabinId, forceRefresh: forceRefresh);
  }

  Future<Result<CabinVisualizerData>> _buildMobileVisualizer(
    Cabin cabin,
    int cabinId, {
    required bool forceRefresh,
  }) async {
    final results = await Future.wait([
      _cabinRepository.getMobileCabinSlots(cabinId, forceRefresh: forceRefresh),
      _getMobileFaults.call(cabinId),
    ]);

    final slotResult = results[0] as Result<List<MobileDrawerSlot>>;
    final faultResult = results[1] as Result<List<MobileFault>>;

    final slots = slotResult.when(ok: (data) => data, error: (_) => null);

    if (slots == null || slots.isEmpty) {
      return Result.error(
        ServiceException(message: contextlessL10n().cabinCore_mobileCabinDesignNotFound, statusCode: 404),
      );
    }

    final mobileFaults = faultResult.when(
      ok: (faults) => faults.where((f) => f.endDate == null).toList(),
      error: (_) => <MobileFault>[],
    );

    final faultBySlotId = {for (final f in mobileFaults) f.cabinDesignId: f};

    final slotVisuals = slots.map((slot) {
      return MobileSlotVisual(
        slotId: slot.id,
        rowColumns: slot.units.map((u) => u.columnCount).toList(),
        workingStatus: faultBySlotId[slot.id]?.workingStatus,
      );
    }).toList();

    final data = CabinVisualizerData(
      cabin: cabin,
      slots: slotVisuals,
      mobileSlots: slots,
      groups: const [],
      stocks: const [],
      mobileFaults: mobileFaults,
    );

    return Result.ok(data);
  }

  Future<Result<CabinVisualizerData>> _buildStandardVisualizer(
    Cabin cabin,
    int cabinId, {
    required bool forceRefresh,
  }) async {
    final (slotResult, faultResult) = await (
      _cabinRepository.getCabinSlots(cabinId, forceRefresh: forceRefresh),
      _getMasterFaults.call(cabinId),
    ).wait;

    final slots = slotResult.when(ok: (data) => data, error: (_) => null);

    if (slots == null || slots.isEmpty) {
      return Result.error(ServiceException(message: contextlessL10n().cabinCore_cabinDesignNotFound, statusCode: 404));
    }

    final masterFaults = faultResult.when(
      ok: (faults) => faults.where((f) => f.endDate == null).toList(),
      error: (_) => <MasterFault>[],
    );

    final faultByUnitId = {for (final f in masterFaults) f.slotId: f};

    final unitResults = await Future.wait(
      slots.where((s) => s.id != null).map((s) => _cabinRepository.getDrawerUnits(s.id!, forceRefresh: forceRefresh)),
    );

    final groups = <DrawerGroup>[];
    final validSlots = slots.where((s) => s.id != null).toList();

    for (int i = 0; i < validSlots.length; i++) {
      final unitResult = unitResults[i];
      final units = unitResult.when(ok: (data) => data, error: (_) => <DrawerUnit>[]);

      final enrichedUnits = units.map((u) {
        final fault = faultByUnitId[u.id];
        if (fault == null) return u;
        return u.copyWith(workingStatus: fault.workingStatus ?? CabinWorkingStatus.faulty);
      }).toList();

      groups.add(DrawerGroup(slot: validSlots[i], units: enrichedUnits));
    }

    groups.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    final slotVisuals = _buildSlots(groups);

    final data = CabinVisualizerData(
      cabin: cabin,
      slots: slotVisuals,
      groups: groups,
      stocks: const [],
      masterFaults: masterFaults,
    );

    return Result.ok(data);
  }

  // Stock kaldırıldı — renk artık her zaman nötr (empty). Yapı (Kubic/UnitDose/
  // Serum ayrımı, iade kutusu birleşimi) korunuyor; başka bir tüketicisi varsa
  // kırılmasın diye.
  List<DrawerSlotVisual> _buildSlots(List<DrawerGroup> groups) {
    return groups.where((g) => g.units.isNotEmpty).map((group) {
      final slot = group.slot;
      final config = slot.drawerConfig;
      final type = config?.drawerType;
      final deviceNo = config?.deviceTypeNo ?? 0;
      final isKubik = type?.isKubik ?? false;
      final isSerum = deviceNo == 250;
      const colCount = 4;
      const returnCellCount = 4;

      if (isSerum) {
        return SerumSlotVisual(slotId: slot.id ?? 0, status: DrawerStatus.empty, heightFactor: 2);
      }

      if (isKubik && group.isReturnDrawer && group.units.length > returnCellCount) {
        final normalUnits = group.units.sublist(0, group.units.length - returnCellCount);
        final orderedNormalUnits = kubikUnitsInVisualOrder(normalUnits);

        return KubicSlotVisual(
          slotId: slot.id ?? 0,
          cells: List.filled(orderedNormalUnits.length, DrawerStatus.empty),
          columnCount: colCount,
          mergedReturnStatus: DrawerStatus.empty,
        );
      }

      final orderedCells = isKubik ? kubikUnitsInVisualOrder(group.units) : group.units;

      if (isKubik) {
        return KubicSlotVisual(
          slotId: slot.id ?? 0,
          cells: List.filled(orderedCells.length, DrawerStatus.empty),
          columnCount: colCount,
        );
      }

      return UnitDoseSlotVisual(slotId: slot.id ?? 0, cells: List.filled(orderedCells.length, DrawerStatus.empty));
    }).toList();
  }
}
