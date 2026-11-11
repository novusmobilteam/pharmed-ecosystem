// pharmed_data/lib/src/dashboard/repository/dashboard_repository_impl.dart
//
// [SWREQ-DATA-DASH-006] [IEC 62304 §5.5]
// IDashboardRepository implementasyonu.
// In-memory cache + TTL (5 dk) stratejisi.
// Hive kullanılmaz — uygulama yeniden başlatılınca cache sıfırlanır.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// In-memory cache kaydı — veri + kaydedilme zamanı

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl({
    required DashboardRemoteDataSource dataSource,
    required CabinStockMapper cabinStockMapper,
    required CabinMapper cabinMapper,
    required PrescriptionItemMapper prescriptionItemMapper,
    required RefundMapper refundMapper,
    required MenuTreeMapper menuMapper,
    required PrescriptionItemMovementMapper itemMovementMapper,
    required UpcomingTreatmentMapper upcomingMapper,
    Duration cacheTtl = const Duration(minutes: 5),
  }) : _dataSource = dataSource,
       _cabinStockMapper = cabinStockMapper,
       _cabinMapper = cabinMapper,
       _prescriptionItemMapper = prescriptionItemMapper,
       _refundMapper = refundMapper,
       _menuMapper = menuMapper,
       _itemMovementMapper = itemMovementMapper,
       _upcomingMapper = upcomingMapper;

  final DashboardRemoteDataSource _dataSource;
  final CabinStockMapper _cabinStockMapper;
  final CabinMapper _cabinMapper;
  final PrescriptionItemMapper _prescriptionItemMapper;
  final RefundMapper _refundMapper;
  final MenuTreeMapper _menuMapper;
  final PrescriptionItemMovementMapper _itemMovementMapper;
  final UpcomingTreatmentMapper _upcomingMapper;

  @override
  Future<Result<List<PrescriptionItem>>> getUnreadQrCodes({bool forceRefresh = false}) async {
    final result = await _dataSource.getUnreadQrCodes();
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringMaterials({required int stationId, bool forceRefresh = false}) async {
    final result = await _dataSource.getExpiringMaterials(stationId: stationId);
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getCriticalStocks({bool isClient = false, bool forceRefresh = false}) async {
    final result = await _dataSource.getCriticalStocks(isClient: isClient);
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnappliedPrescriptions({bool forceRefresh = false}) async {
    final result = await _dataSource.getUnappliedPrescriptions();
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<Refund>>> getRefunds({bool forceRefresh = false}) async {
    final result = await _dataSource.getRefunds();
    return result.when(ok: (dtos) => Result.ok(_refundMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<CabinStock>>> getGeneralStocks({bool forceRefresh = false}) async {
    final result = await _dataSource.getGeneralStocks();
    return result.when(ok: (dtos) => Result.ok(_cabinStockMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<UpcomingTreatment>>> getUpcomingTreatments({
    bool forceRefresh = false,
    required String mac,
  }) async {
    final result = await _dataSource.getUpcomingTreatments(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_upcomingMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<MenuItem>>> getMenuItems({bool forceRefresh = true, int? userId}) async {
    final result = await _dataSource.getMenus(userId: userId);
    final List<MenuDTO> menus;
    switch (result) {
      case Ok(value: final dtos):
        menus = dtos ?? [];
      case Error(error: final error):
        return Result.error(error);
    }
    final complete = userId == null ? menus : await _withMissingParents(menus);
    return Result.ok(_menuMapper.toTreeList(complete));
  }

  /// [SWREQ-DATA-DASH-007] Kullanıcı menüsünde eksik üst menüleri tamamlar.
  ///
  /// `/Menu/user/{id}` yalnızca kullanıcının yetkili olduğu menüleri döndürür;
  /// alt menüye yetkisi olup grup (üst) menüsüne ayrıca yetki verilmemiş
  /// kullanıcıda üst menü yanıtta yoktur. Ağaç kurulurken üstü bulunamayan
  /// alt menü köke düştüğü için navbar'da gruplar yerine alt menüler
  /// görünüyordu. Eksik üst menüler (ve onların üstleri) tüm menü listesinden
  /// eklenir. Üst menüler yalnızca gruplama içindir, sayfa açmaz; kullanıcının
  /// erişebildiği sayfalar değişmez.
  ///
  /// Tüm liste alınamazsa kullanıcı listesi olduğu gibi döner (eski davranış).
  Future<List<MenuDTO>> _withMissingParents(List<MenuDTO> userMenus) async {
    Set<int> missingParentIds(List<MenuDTO> menus) {
      final ids = menus.map((m) => m.id).nonNulls.toSet();
      return menus
          .map((m) => m.parentId)
          .nonNulls
          .where((parentId) => parentId != 0 && !ids.contains(parentId))
          .toSet();
    }

    if (missingParentIds(userMenus).isEmpty) return userMenus;

    final allResult = await _dataSource.getMenus();
    final allMenus = allResult.when(ok: (dtos) => dtos ?? <MenuDTO>[], error: (_) => <MenuDTO>[]);
    if (allMenus.isEmpty) return userMenus;

    final byId = {for (final m in allMenus) if (m.id != null) m.id!: m};
    final completed = [...userMenus];
    var missing = missingParentIds(completed);
    // Her turda bir üst seviye eklenir; derinlik kadar döner. Döngüye karşı sınırlı.
    for (var depth = 0; missing.isNotEmpty && depth < 10; depth++) {
      final found = missing.map((id) => byId[id]).nonNulls.toList();
      if (found.isEmpty) break;
      completed.addAll(found);
      missing = missingParentIds(completed);
    }
    return completed;
  }

  @override
  Future<Result<List<PrescriptionItem>>> getMissingStocks({bool forceRefresh = false, required String mac}) async {
    final result = await _dataSource.getMissingStocks(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_prescriptionItemMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<Cabin>>> getCabins() async {
    final result = await _dataSource.getCabins();
    return result.when(ok: (dtos) => Result.ok(_cabinMapper.toEntityList(dtos ?? [])), error: Result.error);
  }

  @override
  Future<Result<List<PrescriptionItemMovement>?>> getDrugActivities({required String mac}) async {
    final result = await _dataSource.getDrugActivities(mac: mac);
    return result.when(ok: (dtos) => Result.ok(_itemMovementMapper.toEntityList(dtos ?? [])), error: Result.error);
  }
}
