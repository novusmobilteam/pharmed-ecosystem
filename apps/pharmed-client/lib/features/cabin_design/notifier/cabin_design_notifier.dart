// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Kabin dizayn ekranı — ChangeNotifier + ApiRequestMixin.
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../core/mixins/api_request_mixin.dart';
import '../../../../core/providers/providers.dart';
import '../../service_selection/service_selection.dart';
import 'cabin_design_models.dart';

final cabinDesignNotifierProvider = ChangeNotifierProvider.autoDispose<CabinDesignNotifier>((ref) {
  return CabinDesignNotifier(
    getCurrentStation: ref.read(getCurrentStationUseCaseProvider),
    getVisualizerData: ref.read(getCabinVisualizerDataUseCaseProvider),
    setReturnDrawer: ref.read(setReturnDrawerUseCaseProvider),
    changeDrawerPosition: ref.read(changeDrawerPositionUseCaseProvider),
    getMedicineAssignments: ref.read(getMedicineAssignmentsUseCaseProvider),
    scanCabin: ref.read(scanCabinUseCaseProvider),
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
    getSerumLayout: ref.read(getSerumLayoutUseCaseProvider),
    saveSerumLayout: ref.read(saveSerumLayoutUseCaseProvider),
    updateCabin: ref.read(updateCabinUseCaseProvider),
    activeService: ref.read(activeServiceNotifierProvider),
    cameraDevices: ref.read(cameraDeviceRepositoryProvider),
  );
});

class CabinDesignNotifier extends ChangeNotifier with ApiRequestMixin {
  CabinDesignNotifier({
    required GetCurrentStationUseCase getCurrentStation,
    required GetCabinVisualizerDataUseCase getVisualizerData,
    required SetReturnDrawerUseCase setReturnDrawer,
    required ChangeDrawerPositionUseCase changeDrawerPosition,
    required GetMedicineAssignmentsUseCase getMedicineAssignments,
    required ScanCabinUseCase scanCabin,
    required CreateCabinUseCase createCabin,
    required SaveCabinDesignUseCase saveCabinDesign,
    required GetSerumLayoutUseCase getSerumLayout,
    required SaveSerumLayoutUseCase saveSerumLayout,
    required UpdateCabinUseCase updateCabin,
    required ActiveServiceNotifier activeService,
    required ICameraDeviceRepository cameraDevices,
  }) : _cameraDevices = cameraDevices,
       _getCurrentStation = getCurrentStation,
       _getVisualizerData = getVisualizerData,
       _setReturnDrawer = setReturnDrawer,
       _changeDrawerPosition = changeDrawerPosition,
       _getMedicineAssignments = getMedicineAssignments,
       _scanCabin = scanCabin,
       _createCabin = createCabin,
       _saveCabinDesign = saveCabinDesign,
       _getSerumLayout = getSerumLayout,
       _saveSerumLayout = saveSerumLayout,
       _updateCabin = updateCabin,
       _activeService = activeService;

  final GetCurrentStationUseCase _getCurrentStation;
  final GetCabinVisualizerDataUseCase _getVisualizerData;
  final SetReturnDrawerUseCase _setReturnDrawer;
  final ChangeDrawerPositionUseCase _changeDrawerPosition;
  final GetMedicineAssignmentsUseCase _getMedicineAssignments;
  final ScanCabinUseCase _scanCabin;
  final CreateCabinUseCase _createCabin;
  final SaveCabinDesignUseCase _saveCabinDesign;
  final GetSerumLayoutUseCase _getSerumLayout;
  final SaveSerumLayoutUseCase _saveSerumLayout;
  final UpdateCabinUseCase _updateCabin;
  final ActiveServiceNotifier _activeService;
  final ICameraDeviceRepository _cameraDevices;

  static const _unit = 'SW-UNIT-CABIN-DESIGN';
  static const _swreq = 'SWREQ-CLI-CABIN-DESIGN-001';

  // ── Operasyonlar ──────────────────────────────────────────────────────────
  // Her buton yalnızca kendi anahtarının durumunu dinler (tüm sayfa değil).

  /// İstasyon + ilk kabin yüklemesi, yeni kabin sonrası tam yükleme — tüm gövde.
  static const loadOp = OperationKey.custom('cabin-design-load');

  /// Sol listeden kabin değiştirme / kayıt sonrası yenileme — sadece sağ panel.
  static const switchCabinOp = OperationKey.custom('cabin-design-switch-cabin');

  static const _rescanOp = OperationKey.custom('cabin-design-rescan');
  static const _saveOp = OperationKey.custom('cabin-design-save');
  static const _toggleStatusOp = OperationKey.custom('cabin-design-toggle-status');
  static const _createCabinOp = OperationKey.custom('cabin-design-create-cabin');

  /// Serum raf yerleşiminin okunması — sadece serum panelinde loading/hata.
  static const _serumLoadOp = OperationKey.custom('cabin-design-serum-load');

  /// Seçili kabin paneline satır içi gösterilen hatalar.
  static const _inlineErrorOps = [_saveOp, _rescanOp, _toggleStatusOp];

  // ── Durum ─────────────────────────────────────────────────────────────────

  Station? _station;
  Station? get station => _station;

  List<Cabin> _stationCabins = const [];
  List<Cabin> get stationCabins => _stationCabins;

  CabinDesignSelection? _selection;
  CabinDesignSelection? get selection => _selection;

  /// Son yüklenen kabin. Yeni kabin formu açıkken de korunur (iptalde geri dönülür).
  Cabin? _cabin;
  Cabin? get cabin => _cabin;

  List<DrawerGroup> _groups = const [];
  List<DrawerGroup> get groups => _groups;

  int? _selectedSlotId;
  int? get selectedSlotId => _selectedSlotId;

  int? _currentReturnSlotId;

  /// Yer değiştirme modu: kaynak çekmece seçildi, kullanıcı kabin görselinden
  /// hedef çekmeceyi seçecek. null → mod kapalı.
  int? _swapSourceSlotId;
  int? get swapSourceSlotId => _swapSourceSlotId;

  /// Yükleme anındaki pozisyon → adres eşlemesi (üstten alta). Adres fiziksel
  /// yuvaya bağlı olduğu için yer değiştirmede sabit kalır; kısmi kayıtta
  /// `_groups` listesi yeniden sıralansa da pozisyonun adresi buradan okunur.
  List<String> _positionAddresses = const [];

  /// Son çekmece değişimi taramasında aynı adreste tipi değişen çekmeceler.
  /// `_pending.scanGroups` ile birlikte atanır/temizlenir.
  List<DrawerReplacement> _replacements = const [];
  List<DrawerReplacement> get replacements => _replacements;
  bool get hasReplacementBlockers => _replacements.any((r) => r.isBlocked);

  /// Son tarama tamamlandı ama kayıtlı tasarımdan farklı bir çekmece bulunmadı.
  bool _scanFoundNoChange = false;
  bool get scanFoundNoChange => _scanFoundNoChange;
  bool get isSwapMode => _swapSourceSlotId != null;

  CabinPendingChanges _pending = CabinPendingChanges.none;
  CabinPendingChanges get pending => _pending;

  /// Backend'e kalıcı bir değişiklik yazıldıkça artar. Dialog kapanınca
  /// dashboard'daki istasyon/kabin verisinin yenilenip yenilenmeyeceği buna
  /// bakılarak karar verilir (diğer ekranlar o veriden beslenir).
  int _persistedVersion = 0;
  int get persistedVersion => _persistedVersion;

  void _markPersisted() => _persistedVersion++;

  List<CameraDevice> _cameras = const [];
  List<CameraDevice> get cameras => _cameras;

  /// Backend'den okunan serum yerleşimleri (slotId → 3 raf). Kabin her
  /// yüklendiğinde yeniden çekilir; okunmamış slot düzenlenemez (kayıtlı
  /// yerleşimin üzerine yanlışlıkla yeni kayıt atılmasın diye).
  final Map<int, List<SerumShelfLayout>> _serumLayouts = {};

  // ── Türetilmiş ────────────────────────────────────────────────────────────

  bool get hasStation => _station != null;

  /// Seçili kabin paneli gösteriliyorsa kabin; form açıkken null.
  Cabin? get selectedCabin => _selection is SelectedCabin ? _cabin : null;

  CameraSelection? get cameraSelection => switch (_selection) {
    CameraSelection c => c,
    _ => null,
  };

  /// Kabine hizmet veren kamera (bir kabin en fazla bir kameraya atanabilir).
  CameraDevice? cameraForCabin(int? cabinId) =>
      cabinId == null ? null : _cameras.firstWhereOrNull((c) => c.cabinIds.contains(cabinId));

  NewCabinDraft? get newCabinDraft => switch (_selection) {
    NewCabinDraft d => d,
    _ => null,
  };

  bool get isMaster => _cabin?.type == CabinType.master;

  /// Görselde gösterilecek yerleşim: bekleyen tarama sonucu varsa o, yoksa
  /// (bekleyen yer değiştirmeler uygulanmış) kayıtlı yerleşim.
  List<DrawerGroup> get displayedGroups => _pending.scanGroups ?? _orderedGroups;

  /// Kayıtlı yerleşime bekleyen sıra değişikliği uygulanmış hali.
  List<DrawerGroup> get _orderedGroups {
    final order = _pending.slotOrder;
    if (order == null) return _groups;
    final byId = {
      for (final g in _groups)
        if (g.slot.id != null) g.slot.id!: g,
    };
    final ordered = order.map((id) => byId[id]).whereType<DrawerGroup>().toList();
    return ordered.length == _groups.length ? ordered : _groups;
  }

  /// Yer değiştirmeye yalnızca birim doz ve kübik çekmeceler katılır;
  /// serum kabini sabittir.
  static bool isSwappable(DrawerGroup group) => !group.isSerum && group.slot.id != null;

  /// Seçili çekmece için "Yer Değiştir" kullanılabilir mi. Bağlantı/tarama
  /// değişikliği bekliyorsa yerleşim zaten yeniden taranacağı için kapalı.
  bool canSwap(DrawerGroup group) =>
      isSwappable(group) &&
      _groups.every((g) => g.slot.id != null) &&
      _groups.where(isSwappable).length >= 2 &&
      !_pending.hasConnectionChange &&
      !_pending.hasDesignChange &&
      !isSaving &&
      !isRescanning;

  DrawerGroup? get selectedGroup => _groups.firstWhereOrNull((g) => g.slot.id == _selectedSlotId);

  /// Serum slot'unun ekranda gösterilecek 3 rafı: bekleyen değişiklik >
  /// kayıtlı > boş (henüz okunmadıysa).
  List<SerumShelfLayout> serumShelvesFor(int slotId) {
    if (_pending.hasSerumLayoutChange && _pending.serumSlotId == slotId) return _pending.serumShelves!;
    return _serumBaseline(slotId);
  }

  List<SerumShelfLayout> _serumBaseline(int slotId) => _serumLayouts[slotId] ?? SerumShelfLayout.emptyShelves();

  bool get isLoadingSerumLayout => isLoading(_serumLoadOp);
  String? get serumLoadError => isFailed(_serumLoadOp) ? message(_serumLoadOp) : null;

  /// Yerleşim okunmadan düzenlemeye izin verilmez.
  bool canEditSerumLayout(int slotId) => _serumLayouts.containsKey(slotId) && !isSaving && !isLoadingSerumLayout;

  int? get effectiveReturnSlotId {
    if (!_pending.hasReturnChange) return _currentReturnSlotId;
    return _pending.returnValue! ? _pending.returnSlotId : null;
  }

  String? get effectiveComPortLabel => _pending.comPort?.label ?? _cabin?.comPort?.label;
  String? get effectiveAddressChar => _pending.addressChar ?? _cabin?.no?.toUpperCase();

  bool get isSaving => isLoading(_saveOp);
  bool get isRescanning => isLoading(_rescanOp);
  bool get isSwitchingCabin => isLoading(switchCabinOp);
  bool get isTogglingStatus => isLoading(_toggleStatusOp);

  bool get canSave =>
      _selection is SelectedCabin && _pending.hasAny && !isSaving && !isRescanning && !hasReplacementBlockers;

  /// "Tekrar Tara": bağlantı değişikliği varsa yeni bağlantıyla tarar, yoksa
  /// çekmece değişimi (aynı adreste tip değişimi) arar. Bekleyen yer
  /// değiştirme ile birlikte yapılamaz (biri sırayı, diğeri tipi değiştirir).
  bool get canRescan =>
      _cabin != null && !isRescanning && !isSaving && !_pending.hasOrderChange && !isSwapMode;

  /// Seçili kabin panelindeki satır içi hata (kaydet / tara / durum değiştir).
  String? get inlineError => _inlineErrorOps.where(isFailed).map(message).firstOrNull;

  /// Yeni kabin formundaki hata.
  String? get newCabinError => isFailed(_createCabinOp) ? message(_createCabinOp) : null;

  bool get canSaveNewCabin => (newCabinDraft?.isComplete ?? false) && !(newCabinDraft?.isSaving ?? true);

  /// Master hariç B-P arası. Düzenlenen kabinin kendi adresi listede kalır.
  List<String> get availableAddressCharsForEdit => _freeAddressChars(exceptCabinId: _cabin?.id);

  List<String> get availableAddressCharsForNew => _freeAddressChars();

  // ── Yükleme ───────────────────────────────────────────────────────────────

  Future<void> init() async {
    _resetAll();

    Station? loaded;
    await execute(loadOp, operation: () => _getCurrentStation.call(), onData: (s) => loaded = s);
    if (isFailed(loadOp)) return;

    final station = loaded;
    if (station == null) {
      setFailed(loadOp, message: contextlessL10n().cabinDesign_load_stationNotFoundError);
      return;
    }
    if (station.cabins.isEmpty) {
      setFailed(loadOp, message: contextlessL10n().cabinDesign_load_noCabinsError);
      return;
    }

    _station = station;
    _stationCabins = station.cabins;
    await _loadCameras();
    await _loadCabin(station.cabins.first, fullScreen: true);
  }

  /// [fullScreen]: tüm gövdede (loadOp) ya da sadece sağ panelde (switchCabinOp)
  /// loading. Hata olursa önceki kabin ekranda kalır.
  Future<void> _loadCabin(Cabin cabin, {required bool fullScreen}) async {
    final key = fullScreen ? loadOp : switchCabinOp;
    final cabinId = cabin.id;
    if (cabinId == null) {
      setFailed(key, message: contextlessL10n().cabinDesign_load_cabinIdMissingError);
      return;
    }

    await execute(
      key,
      operation: () => _getVisualizerData.call(cabin: cabin, deviceMode: cabin.type, forceRefresh: true),
      onData: (data) {
        _cabin = cabin;
        _groups = data.groups;
        _positionAddresses = data.groups.map((g) => g.address).toList();
        _replacements = const [];
        _scanFoundNoChange = false;
        _currentReturnSlotId = data.groups.firstWhereOrNull((g) => g.isReturnDrawer)?.slot.id;
        _selectedSlotId = data.groups.firstOrNull?.slot.id;
        _pending = CabinPendingChanges.none;
        _swapSourceSlotId = null;
        _selection = SelectedCabin(cabinId);
        _clearInlineErrors(notify: false);
      },
    );
    if (isFailed(key) || _cabin?.id != cabinId) return;

    // Serum yerleşimi karttan taranmaz, ayrı servisten okunur.
    _serumLayouts.clear();
    clearOperation(_serumLoadOp);
    for (final slotId in _groups.where((g) => g.isSerum).map((g) => g.slot.id).whereType<int>()) {
      await loadSerumLayout(slotId);
    }
  }

  /// Serum slot'unun kayıtlı yerleşimini okur. Panel "Tekrar Dene" ile de çağırır.
  Future<void> loadSerumLayout(int slotId) async {
    await execute(
      _serumLoadOp,
      operation: () => _getSerumLayout.call(slotId),
      onData: (shelves) {
        _serumLayouts[slotId] = shelves;
      },
    );
  }

  /// Sol listeden kabin seçimi. Yeni kabin formu açıkken de çalışır
  /// (kayıt sürmüyorsa) — formdan çıkıp seçilen kabine geçer.
  Future<void> selectCabin(int cabinId) async {
    if (isSwitchingCabin || isSaving) return;
    if (newCabinDraft?.isSaving ?? false) return;
    final current = _selection;
    if (current is SelectedCabin && current.cabinId == cabinId) return;

    final target = _stationCabins.firstWhereOrNull((c) => c.id == cabinId);
    if (target == null) return;

    // Form açıkken ve hedef zaten bellekteki kabinse yeniden çekmeye gerek yok.
    if ((current is NewCabinDraft || current is CameraSelection) && _cabin?.id == cabinId) {
      _selection = SelectedCabin(cabinId);
      notifyListeners();
      return;
    }
    await _loadCabin(target, fullScreen: false);
  }

  // ── Seçili kabin: düzenleme ───────────────────────────────────────────────

  void selectSlot(int slotId) {
    if (isSwapMode) {
      _completeSwap(slotId);
      return;
    }
    _selectedSlotId = slotId;
    notifyListeners();
  }

  // ── Çekmece yer değiştirme ────────────────────────────────────────────────
  // Sadece sıra değişir; atama/stok kayıtları slot'a bağlı olduğu için
  // çekmeceyle birlikte taşınır, bu yüzden boşaltma şartı yoktur.

  /// Seçili çekmeceyi kaynak olarak işaretler; sıradaki görsel dokunuşu hedeftir.
  void startSwap() {
    final group = selectedGroup;
    if (group == null || !canSwap(group)) return;
    _swapSourceSlotId = group.slot.id;
    notifyListeners();
  }

  void cancelSwap() {
    if (!isSwapMode) return;
    _swapSourceSlotId = null;
    notifyListeners();
  }

  /// Hedefe dokunuldu: aynı çekmece → iptal, uygun değil (serum) → yok say.
  void _completeSwap(int targetSlotId) {
    final sourceId = _swapSourceSlotId;
    if (sourceId == null) return;
    if (targetSlotId == sourceId) return cancelSwap();

    final target = _groups.firstWhereOrNull((g) => g.slot.id == targetSlotId);
    if (target == null || !isSwappable(target)) return;

    final order = _orderedGroups.map((g) => g.slot.id!).toList();
    final a = order.indexOf(sourceId);
    final b = order.indexOf(targetSlotId);
    if (a < 0 || b < 0) return;
    order[a] = targetSlotId;
    order[b] = sourceId;

    final baseline = _groups.map((g) => g.slot.id!).toList();
    _pending = _pending.withSlotOrder(const ListEquality<int>().equals(order, baseline) ? null : order);
    _swapSourceSlotId = null;
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// Hedef sırada, takası aynı tipte (aynı DrawerConfig) iki çekmece arasında
  /// olan adresler. Tarama yalnızca kart tipini okuduğu için bu çekmecelerin
  /// fiziksel olarak yer değiştirip değiştirmediği doğrulanamaz — kayıttan
  /// önce kullanıcıdan açık onay alınır.
  List<String> get sameTypeSwapAddresses {
    final desired = _pending.slotOrder;
    if (desired == null || desired.length != _groups.length || desired.length != _positionAddresses.length) {
      return const [];
    }
    final configById = {for (final g in _groups) g.slot.id: g.slot.drawerConfigId};
    return [
      for (var i = 0; i < desired.length; i++)
        if (desired[i] != _groups[i].slot.id && configById[desired[i]] == _groups[i].slot.drawerConfigId)
          _positionAddresses[i],
    ];
  }

  /// Bekleyen tüm yer değiştirmeleri geri alır.
  void resetSlotOrder() {
    if (isSaving || !_pending.hasOrderChange) return;
    _pending = _pending.withSlotOrder(null);
    _swapSourceSlotId = null;
    notifyListeners();
  }

  void toggleReturnDrawer(bool value) {
    final slotId = _selectedSlotId;
    if (isSaving || slotId == null) return;
    _pending = _pending.withReturn(slotId, value);
    notifyListeners();
  }

  void updatePendingName(String? value) {
    final same = value?.trim() == _cabin?.name?.trim();
    _pending = _pending.withName(same ? null : value);
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// Serum kabininde tek rafın yeni hali (kilit / avadanlık ekle-çıkar).
  /// Sonuç kayıtlı hale eşitse bekleyen değişiklik temizlenir.
  void updateSerumShelf(int slotId, SerumShelfLayout shelf) {
    if (!canEditSerumLayout(slotId)) return;
    if (shelf.usedArea > SerumShelfLayout.totalArea) return;

    final updated = [
      for (final s in serumShelvesFor(slotId)) s.orderNo == shelf.orderNo ? shelf : s,
    ];
    final same = const ListEquality<SerumShelfLayout>().equals(updated, _serumBaseline(slotId));
    _pending = _pending.withSerumLayout(slotId, same ? null : updated);
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// Sadece master kabin. Port değişince önceki tarama sonucu geçersizdir.
  void updatePendingComPort(String portLabel) {
    final cabin = _cabin;
    if (cabin == null || cabin.type != CabinType.master) return;

    final port = ComPortX.fromLabel(portLabel);
    // Bağlantı değişince yerleşim yeniden taranacağı için bekleyen sıra da geçersiz.
    _pending = _pending.withComPort(port == cabin.comPort ? null : port).withScanGroups(null).withSlotOrder(null);
    _swapSourceSlotId = null;
    _replacements = const [];
    _scanFoundNoChange = false;
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// Sadece slave kabin. Adres değişince önceki tarama sonucu geçersizdir.
  void updatePendingAddressChar(String addressChar) {
    final cabin = _cabin;
    if (cabin == null || cabin.type == CabinType.master || isRescanning) return;

    final normalized = addressChar.trim().toUpperCase();
    final same = normalized == cabin.no?.trim().toUpperCase();
    _pending = _pending.withAddressChar(same ? null : normalized).withScanGroups(null).withSlotOrder(null);
    _swapSourceSlotId = null;
    _replacements = const [];
    _scanFoundNoChange = false;
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// "Tekrar Tara" — sadece kabin görselinin üzerinde loading.
  Future<void> rescanCabin() async {
    final cabin = _cabin;
    if (cabin == null || !canRescan) return;

    _clearInlineErrors(notify: false);
    _replacements = const [];
    _scanFoundNoChange = false;

    // Bağlantı (port/adres) değiştiyse yeni bağlantının yerleşimi okunur.
    if (_pending.hasConnectionChange) {
      await execute(
        _rescanOp,
        operation: () => _performRescan(cabin),
        onData: (newGroups) {
          _pending = _pending.withScanGroups(_isSameDrawerLayout(newGroups, _groups) ? null : newGroups);
        },
      );
      return;
    }

    // Bağlantı aynı — çekmece değişimi taraması.
    setLoading(_rescanOp);
    final detected = await _detectReplacements(cabin);
    detected.when(
      ok: (d) {
        _replacements = d.replacements;
        _scanFoundNoChange = d.replacements.isEmpty;
        _pending = _pending.withScanGroups(d.replacements.isEmpty ? null : d.scanGroups);
        MedLogger.info(
          unit: _unit,
          swreq: _swreq,
          message: 'Çekmece değişimi taraması tamamlandı',
          context: {
            'cabinId': cabin.id,
            'replaced': [for (final r in d.replacements) r.address],
            'blocked': [for (final r in d.replacements.where((r) => r.isBlocked)) r.address],
          },
        );
        setSuccess(_rescanOp);
      },
      error: (e) {
        _pending = _pending.withScanGroups(null);
        MedLogger.warn(
          unit: _unit,
          swreq: _swreq,
          message: 'Çekmece değişimi taraması reddedildi',
          context: {'cabinId': cabin.id, 'error': e.message},
        );
        setFailed(_rescanOp, message: e.userMessage);
      },
    );
  }

  /// Kabini tarar ve kayıtlı tasarımla adres bazında karşılaştırır. Yalnızca
  /// aynı adreste tip (DrawerConfig) değişimi desteklenir; adres seti
  /// değiştiyse ya da serum çekmecesi işin içindeyse reddedilir. Değişen
  /// çekmecelerin atama/stokları [DrawerReplacement.blockers] olarak eklenir.
  Future<Result<({List<DrawerGroup> scanGroups, List<DrawerReplacement> replacements})>> _detectReplacements(
    Cabin cabin,
  ) async {
    final scan = await _performRescan(cabin);
    if (scan.isError) return Result.error(_errorOf(scan));
    final scanned = scan.data!;

    final currentByAddress = {for (final g in _groups) g.address: g};
    final scannedByAddress = {for (final g in scanned) g.address: g};

    if (!const SetEquality<String>().equals(currentByAddress.keys.toSet(), scannedByAddress.keys.toSet())) {
      return Result.error(
        BusinessRuleException(
          message: contextlessL10n().cabinDesign_replace_addressMismatchError,
          ruleCode: 'DRAWER_REPLACE_ADDRESS_MISMATCH',
        ),
      );
    }

    final replacements = [
      for (final e in currentByAddress.entries)
        if (scannedByAddress[e.key]!.slot.drawerConfigId != e.value.slot.drawerConfigId)
          DrawerReplacement(address: e.key, current: e.value, scanned: scannedByAddress[e.key]!),
    ];

    if (replacements.any((r) => r.current.isSerum || r.scanned.isSerum)) {
      return Result.error(
        BusinessRuleException(
          message: contextlessL10n().cabinDesign_replace_serumError,
          ruleCode: 'DRAWER_REPLACE_SERUM',
        ),
      );
    }

    if (replacements.isEmpty) return Result.ok((scanGroups: scanned, replacements: const <DrawerReplacement>[]));

    final assignments = await _getMedicineAssignments.call(cabin.id!);
    if (assignments.isError) return Result.error(_errorOf(assignments));

    return Result.ok((scanGroups: scanned, replacements: _withBlockers(replacements, assignments.data!)));
  }

  /// Sökülen çekmeceye (slot id) bağlı atamaları, stok toplamlarıyla birlikte ekler.
  static List<DrawerReplacement> _withBlockers(
    List<DrawerReplacement> replacements,
    List<MedicineAssignment> assignments,
  ) {
    return [
      for (final r in replacements)
        r.withBlockers([
          for (final a in assignments)
            if ((a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId) == r.current.slot.id)
              DrawerReplacementBlocker(
                medicineName: a.medicine?.name ?? '—',
                stockQuantity: (a.stocks ?? const <CabinStock>[]).fold<num>(0, (sum, st) => sum + (st.quantity ?? 0)),
              ),
        ]),
    ];
  }

  /// Master: (bekleyen ?? mevcut) port + adres her zaman 'A'.
  /// Slave: master'ın portu (hat paylaşılıyor) + (bekleyen ?? mevcut) adres.
  Future<Result<List<DrawerGroup>>> _performRescan(Cabin cabin) {
    final master = cabin.type == CabinType.master;

    final portName = master
        ? (_pending.comPort?.label ?? cabin.comPort?.label)
        : _stationCabins.firstWhereOrNull((c) => c.type == CabinType.master)?.comPort?.label;

    final addressChar = master ? 'A' : (_pending.addressChar ?? cabin.no);
    final addressIndex = ManagementCard.indexFromAddressChar(addressChar);

    if (addressIndex == null || portName == null) {
      return Future.value(const Result.error(UnexpectedException()));
    }

    return _scanCabin.call(
      portName: portName,
      cabinType: cabin.type ?? CabinType.cabinet,
      targetAddressIndex: addressIndex,
    );
  }

  /// active <-> passive. Başarılıysa istasyon yeniden çekilir (sol liste
  /// rozetleri güncel kalsın); yeniden çekme başarısızsa yerel güncellenir.
  Future<void> toggleCabinActiveStatus() async {
    final cabin = _cabin;
    if (cabin == null || isTogglingStatus) return;

    final candidate = cabin.copyWith(status: cabin.status == Status.passive ? Status.active : Status.passive);
    _clearInlineErrors(notify: false);

    await execute<Station?>(
      _toggleStatusOp,
      operation: () async {
        final update = await _updateCabin.call(candidate);
        if (update.isError) return Result.error(_errorOf(update));
        final refreshed = await _getCurrentStation.call();
        return Result.ok(refreshed.when(ok: (s) => s, error: (_) => null));
      },
      onData: (refreshed) {
        _markPersisted();
        if (refreshed == null) {
          _stationCabins = _stationCabins.map((c) => c.id == candidate.id ? candidate : c).toList();
          _cabin = candidate;
          return;
        }
        _station = refreshed;
        _stationCabins = refreshed.cabins;
        _cabin = refreshed.cabins.firstWhereOrNull((c) => c.id == candidate.id) ?? candidate;
      },
    );
  }

  // ── Kaydet ────────────────────────────────────────────────────────────────

  /// Alt bardaki tek "Kaydet" — tüm bekleyen değişiklikleri tek akışta uygular.
  /// Bir adım başarısız olursa o ana kadar başarılı olanlar yerelde korunur.
  Future<bool> save() async {
    final cabin = _cabin;
    if (cabin == null || !canSave) return false;

    _swapSourceSlotId = null;
    setLoading(_saveOp);
    final pending = _pending;
    final returnSlotId = effectiveReturnSlotId;

    // ── 1. Bağlantı değişikliği varsa — kaydetmeden ÖNCE doğrula ──────
    // ("Tekrar Tara" tetiklenmemiş olsa bile kayıt anında mutlaka kontrol.)
    var finalScanGroups = pending.scanGroups;
    if (pending.hasConnectionChange) {
      final rescan = await _performRescan(cabin);
      if (rescan.isError) return _failSave(_errorOf(rescan));
      final newGroups = rescan.data!;
      finalScanGroups = _isSameDrawerLayout(newGroups, _groups) ? null : newGroups;
    }

    // ── 1a. Çekmece değişimi — kayıttan hemen önce yeniden doğrula ────
    // Tarama ile kayıt arasında çekmece tekrar değişmiş ya da atama/stok
    // eklenmiş olabilir; bayat sonuçla tasarım yazılmaz.
    var isReplacementSave = false;
    if (!pending.hasConnectionChange && pending.hasDesignChange) {
      final detected = await _detectReplacements(cabin);
      if (detected.isError) return _failSave(_errorOf(detected));
      final d = detected.data!;
      if (d.replacements.isEmpty || !_isSameDrawerLayout(d.scanGroups, pending.scanGroups!)) {
        return _failSave(
          BusinessRuleException(
            message: contextlessL10n().cabinDesign_replace_scanChangedError,
            ruleCode: 'DRAWER_REPLACE_SCAN_CHANGED',
          ),
        );
      }
      _replacements = d.replacements;
      if (hasReplacementBlockers) {
        return _failSave(
          BusinessRuleException(
            message: contextlessL10n().cabinDesign_replace_blockedSaveError,
            ruleCode: 'DRAWER_REPLACE_BLOCKED',
          ),
        );
      }
      finalScanGroups = d.scanGroups;
      isReplacementSave = true;
    }

    // ── 1b. Yer değiştirme varsa — fiziksel takası taramayla doğrula ──
    // Açma komutları slot.address (yönetim kartının satırı = fiziksel yuva)
    // ile gider. Çekmeceler gerçekten takılmadan kayıt yapılırsa atamalar
    // yanlış yuvaya bağlanır ve yanlış çekmece açılır.
    if (pending.hasOrderChange && finalScanGroups == null) {
      final error = await _verifyPhysicalSwap(cabin, pending.slotOrder!);
      if (error != null) return _failSave(error);
    }

    // Bu noktadan sonra adımlar tek tek backend'e yazılır; ortada hata olsa
    // bile önceki adımlar kalıcıdır — dashboard'un yenilenmesi için işaretlenir.
    _markPersisted();

    // ── 2. Bu kabinin bilgisi (comPort / no / ad) ─────────────────────
    var updatedCabin = cabin;
    if (pending.hasConnectionChange || pending.hasNameChange) {
      final candidate = cabin.copyWith(
        comPort: pending.comPort ?? cabin.comPort,
        no: pending.addressChar ?? cabin.no,
        name: pending.name ?? cabin.name,
      );
      final update = await _updateCabin.call(candidate);
      if (update.isError) return _failSave(_errorOf(update));
      // API güncellenmiş kaydı döndürmüyor — yerelde inşa edilen doğru kabul edilir.
      updatedCabin = candidate;
      _applyCabinLocally(updatedCabin);
    }

    // ── 3. Master portu değiştiyse — hat paylaşıldığı için TÜM kabinler ──
    if (cabin.type == CabinType.master && pending.comPort != null) {
      for (final other in _stationCabins.where((c) => c.id != updatedCabin.id).toList()) {
        final candidateOther = other.copyWith(comPort: pending.comPort);
        final r = await _updateCabin.call(candidateOther);
        if (r.isError) return _failSave(_errorOf(r));
        _applyCabinLocally(candidateOther);
      }
    }

    // ── 4. Çekmece sırası (yer değiştirme) ────────────────────────────
    // Bağlantı değişikliğinde sıra zaten temizlenir; yine de tarama sonucu
    // kaydedilecekse eski slot'lar üzerinde takas yapılmaz.
    if (pending.hasOrderChange && finalScanGroups == null) {
      final error = await _applySlotOrder(updatedCabin.id!, pending.slotOrder!);
      if (error != null) return _failSave(error);
    }

    // ── 5. İade çekmecesi ─────────────────────────────────────────────
    if (pending.hasReturnChange) {
      final r = await _setReturnDrawer.call(pending.returnSlotId!, pending.returnValue!);
      if (r.isError) return _failSave(_errorOf(r));
    }

    // ── 6. Serum raf yerleşimi ────────────────────────────────────────
    if (pending.hasSerumLayoutChange) {
      final slotId = pending.serumSlotId!;
      final shelves = pending.serumShelves!;
      final r = await _saveSerumLayout.call(serumSlotId: slotId, shelves: shelves);
      if (r.isError) return _failSave(_errorOf(r));
      // Yeni id'ler için yerleşim adım 8'deki yeniden yüklemede tekrar okunur.
    }

    // ── 7. Tasarım (yeni tarama sonucu farklıysa) ─────────────────────
    if (finalScanGroups != null) {
      final r = await _saveCabinDesign.call(
        cabinId: updatedCabin.id!,
        scanResults: isReplacementSave
            ? _replacementSlots(finalScanGroups, returnSlotId)
            : finalScanGroups.map((g) => g.slot).toList(),
        isUpdate: true,
      );
      if (r.isError) return _failSave(_errorOf(r));
    }

    // ── 8. Hepsi başarılı — kabini temiz baştan yükle ─────────────────
    await _loadCabin(updatedCabin, fullScreen: false);
    setSuccess(_saveOp);
    return true;
  }

  bool _failSave(AppException e) {
    MedLogger.error(unit: _unit, swreq: _swreq, message: 'Kabin dizaynı kaydedilemedi', error: e);
    setFailed(_saveOp, message: e.userMessage);
    return false;
  }

  /// Çekmece değişimi kaydı: PUT /CabinDesign/bulk adres bazlı eşleşir.
  /// Her adres mevcut kaydın id'siyle gönderilir. Değişmeyen çekmeceler iade
  /// bayrağını ve port yönünü korur; yeni takılan çekmecede iade bayrağı düşer.
  List<DrawerSlot> _replacementSlots(List<DrawerGroup> scanned, int? returnSlotId) {
    final currentByAddress = {for (final g in _groups) g.address: g.slot};
    final replaced = _replacements.map((r) => r.address).toSet();
    return [
      for (final g in scanned)
        g.slot.copyWith(
          id: currentByAddress[g.address]?.id,
          isReturnDrawerHere:
              !replaced.contains(g.address) &&
              returnSlotId != null &&
              currentByAddress[g.address]?.id == returnSlotId,
          isPortReversed: replaced.contains(g.address) ? null : currentByAddress[g.address]?.isPortReversed,
        ),
    ];
  }

  /// Kabini yeniden tarar ve hedef sıraya göre her adreste beklenen çekmece
  /// tipinin (DrawerConfig) bulunduğunu doğrular. Adres konuma bağlıdır: i.
  /// pozisyonun adresinde, takastan sonra [desired]'ın i. slot'unun çekmecesi
  /// görülmelidir. Hata yoksa null.
  Future<AppException?> _verifyPhysicalSwap(Cabin cabin, List<int> desired) async {
    if (desired.length != _groups.length || desired.length != _positionAddresses.length) {
      return const UnexpectedException();
    }

    final scan = await _performRescan(cabin);
    if (scan.isError) return _errorOf(scan);

    final scanned = {for (final g in scan.data!) g.address: g.slot.drawerConfigId};
    final configById = {for (final g in _groups) g.slot.id: g.slot.drawerConfigId};
    final expected = {
      for (var i = 0; i < desired.length; i++) _positionAddresses[i]: configById[desired[i]],
    };

    if (!const SetEquality<String>().equals(scanned.keys.toSet(), expected.keys.toSet())) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Yer değiştirme doğrulaması: taranan adresler kayıtlı tasarımla uyuşmuyor',
        context: {'scanned': scanned.keys.toList(), 'expected': expected.keys.toList()},
      );
      return BusinessRuleException(
        message: contextlessL10n().cabinDesign_position_layoutMismatchError,
        ruleCode: 'DRAWER_SWAP_LAYOUT_MISMATCH',
      );
    }

    final notSwapped = [
      for (final e in expected.entries)
        if (scanned[e.key] != e.value) e.key,
    ];
    if (notSwapped.isNotEmpty) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Yer değiştirme doğrulaması: beklenen çekmece tipi bulunamadı',
        context: {'addresses': notSwapped, 'scanned': scanned, 'expected': expected},
      );
      return BusinessRuleException(
        message: contextlessL10n().cabinDesign_position_notSwappedError(notSwapped.join(', ')),
        ruleCode: 'DRAWER_SWAP_NOT_PHYSICAL',
      );
    }
    return null;
  }

  /// Hedef sırayı minimum takasla uygular (seçmeli sıralama mantığı: her
  /// pozisyona olması gereken slot tek takasla getirilir). Her başarılı takas
  /// kayıtlı yerleşime (`_groups`) yerelde de işlenir; böylece kısmi hatada
  /// tekrar kaydetmek aynı takası ikinci kez göndermez. Hata yoksa null.
  Future<AppException?> _applySlotOrder(int cabinId, List<int> desired) async {
    for (var i = 0; i < desired.length; i++) {
      final current = _groups.map((g) => g.slot.id).toList();
      if (current.length != desired.length) return const UnexpectedException();
      if (current[i] == desired[i]) continue;

      final j = current.indexOf(desired[i]);
      if (j < 0) return const UnexpectedException();

      final r = await _changeDrawerPosition.call(
        cabinId: cabinId,
        sourceSlotId: current[i]!,
        targetSlotId: desired[i],
      );
      if (r.isError) return _errorOf(r);

      MedLogger.info(
        unit: _unit,
        swreq: _swreq,
        message: 'Çekmece yer değiştirildi',
        context: {'cabinId': cabinId, 'sourceSlotId': current[i], 'targetSlotId': desired[i]},
      );

      final next = [..._groups];
      final tmp = next[i];
      next[i] = next[j];
      next[j] = tmp;
      _groups = next;
    }
    _pending = _pending.withSlotOrder(null);
    return null;
  }

  void _applyCabinLocally(Cabin updated) {
    _stationCabins = _stationCabins.map((c) => c.id == updated.id ? updated : c).toList();
    if (_cabin?.id == updated.id) _cabin = updated;
  }

  // ── Kameralar ─────────────────────────────────────────────────────────────
  // Tanım/doğrulama/test CameraFormNotifier'da; burada yalnızca liste ve seçim.

  /// Kamera tanımları kabin ekranı için kritik değil: okunamazsa liste boş
  /// kalır, hata loglanır, kabin akışı etkilenmez.
  Future<void> _loadCameras() async {
    final result = await _cameraDevices.getAll();
    _cameras = result.when(
      ok: (list) => list,
      error: (e) {
        MedLogger.error(unit: _unit, swreq: _swreq, message: 'Kamera tanımları okunamadı', error: e);
        return const <CameraDevice>[];
      },
    );
    notifyListeners();
  }

  void selectCamera(String cameraId) => _openCameraForm(cameraId);

  /// [forCabinId]: kabin panelindeki "Kamera Ekle"den gelindiyse o kabin seçili gelir.
  void startAddCamera({int? forCabinId}) => _openCameraForm(null, initialCabinId: forCabinId);

  void _openCameraForm(String? cameraId, {int? initialCabinId}) {
    if (isSaving || (newCabinDraft?.isSaving ?? false)) return;
    final current = _selection;
    if (current is CameraSelection && current.cameraId == cameraId && cameraId != null) return;
    _swapSourceSlotId = null;
    _selection = CameraSelection(cameraId: cameraId, previousCabinId: _cabin?.id, initialCabinId: initialCabinId);
    notifyListeners();
  }

  /// Formdan çıkış — bellekteki kabine döner.
  void closeCameraForm() {
    if (_selection is! CameraSelection) return;
    final id = _cabin?.id;
    _selection = id != null ? SelectedCabin(id) : null;
    notifyListeners();
  }

  /// Form kaydetti: listeyi yenile, kaydedilen kamerada kal.
  Future<void> onCameraSaved(CameraDevice device) async {
    await _loadCameras();
    _selection = CameraSelection(cameraId: device.id, previousCabinId: _cabin?.id);
    notifyListeners();
  }

  Future<void> onCameraDeleted() async {
    await _loadCameras();
    closeCameraForm();
  }

  // ── Yeni kabin ────────────────────────────────────────────────────────────

  void startAddCabin() {
    if (isSaving) return;
    clearOperation(_createCabinOp);
    _swapSourceSlotId = null;
    _selection = NewCabinDraft(previousCabinId: _cabin?.id);
    notifyListeners();
  }

  /// Bellekteki kabine geri döner — yeniden yükleme gerekmez.
  Future<void> cancelAddCabin() async {
    final draft = newCabinDraft;
    if (draft == null || draft.isSaving) return;

    final previous = _cabin;
    if (previous?.id != null) {
      _selection = SelectedCabin(previous!.id!);
      notifyListeners();
      return;
    }
    final first = _stationCabins.firstOrNull;
    if (first != null) await _loadCabin(first, fullScreen: true);
  }

  void updateNewCabinName(String? value) => _updateDraft((d) => d.copyWith(name: value ?? ''));
  void selectNewCabinType(CabinType type) => _updateDraft((d) => d.copyWith(type: type));
  void selectNewCabinAddress(String addressChar) => _updateDraft((d) => d.copyWith(addressChar: addressChar));

  void _updateDraft(NewCabinDraft Function(NewCabinDraft) update) {
    final draft = newCabinDraft;
    if (draft == null || draft.isSaving) return;
    _selection = update(draft);
    notifyListeners();
  }

  /// Kaydet ve Tara: 1) adreste yönetim kartı var mı, 2) çekmece yapısını tara,
  /// 3) kabini oluştur, 4) tasarımı kaydet, 5) yeni kabine geç.
  Future<void> saveNewCabin() async {
    final draft = newCabinDraft;
    if (draft == null || !canSaveNewCabin) return;

    final addressIndex = ManagementCard.indexFromAddressChar(draft.addressChar);
    if (addressIndex == null) {
      setFailed(_createCabinOp, message: const UnexpectedException().userMessage);
      return;
    }
    final portName = _stationCabins.firstWhereOrNull((c) => c.type == CabinType.master)?.comPort?.label;

    setLoading(_createCabinOp);

    // ── 1-2: adres doğrulama + çekmece taraması ───────────────────────
    _setDraftStep(NewCabinSaveStep.verifyingAddress);
    final scan = await _scanCabin.call(portName: portName, cabinType: draft.type!, targetAddressIndex: addressIndex);
    if (scan.isError) return _failCreate(_errorOf(scan)); // hiçbir şey oluşmadı — formda kal
    final drawerGroups = scan.data!;

    // ── 3: kabini oluştur ─────────────────────────────────────────────
    _setDraftStep(NewCabinSaveStep.creatingCabin);
    final create = await _createCabin.call(
      Cabin(
        name: draft.name.trim(),
        type: draft.type,
        no: draft.addressChar,
        comPort: ComPortX.fromLabel(portName),
        status: Status.active,
        station: _station,
        stationId: _activeService.station?.id,
      ),
    );
    final created = create.when(ok: (c) => c, error: (_) => null);
    if (created?.id == null) return _failCreate(_errorOf(create)); // kabin oluşmadı — formda kal

    // ── 4: tasarımı kaydet ───────────────────────────────────────────
    // Bu noktadan sonra kabin VAR. Tasarım kaydı başarısız olsa bile formdan
    // çıkılır; kullanıcı yeni kabinde "Tekrar Tara" ile tamamlar.
    _setDraftStep(NewCabinSaveStep.savingLayout);
    final design = await _saveCabinDesign.call(
      cabinId: created!.id!,
      scanResults: drawerGroups.map((g) => g.slot).toList(),
      isUpdate: false,
    );

    _stationCabins = [..._stationCabins, created];
    _markPersisted();

    if (design.isError) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Yeni kabin oluşturuldu ama tasarım kaydedilemedi',
        context: {'cabinId': created.id, 'error': _errorOf(design).message},
      );
      _cabin = created;
      _groups = const [];
      _positionAddresses = const [];
      _currentReturnSlotId = null;
      _selectedSlotId = null;
      _pending = CabinPendingChanges.none;
      _selection = SelectedCabin(created.id!);
      setSuccess(_createCabinOp);
      return;
    }

    await _loadCabin(created, fullScreen: true);
    setSuccess(_createCabinOp);
  }

  void _setDraftStep(NewCabinSaveStep step) {
    final draft = newCabinDraft;
    if (draft == null) return;
    _selection = draft.copyWith(saveStep: step);
    notifyListeners();
  }

  void _failCreate(AppException e) {
    MedLogger.error(unit: _unit, swreq: _swreq, message: 'Yeni kabin oluşturulamadı', error: e);
    _setDraftStep(NewCabinSaveStep.idle);
    setFailed(_createCabinOp, message: e.userMessage);
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  void _resetAll() {
    _station = null;
    _stationCabins = const [];
    _selection = null;
    _cabin = null;
    _groups = const [];
    _positionAddresses = const [];
    _replacements = const [];
    _scanFoundNoChange = false;
    _selectedSlotId = null;
    _currentReturnSlotId = null;
    _swapSourceSlotId = null;
    _pending = CabinPendingChanges.none;
    _cameras = const [];
    _serumLayouts.clear();
    clearAllOperations();
  }

  void _clearInlineErrors({required bool notify}) {
    var changed = false;
    for (final key in _inlineErrorOps) {
      if (isFailed(key)) {
        clearOperation(key); // clearOperation kendi notify'ını yapar
        changed = true;
      }
    }
    if (notify && changed) notifyListeners();
  }

  List<String> _freeAddressChars({int? exceptCabinId}) {
    const aCode = 65; // 'A'
    final allExceptMaster = List.generate(15, (i) => String.fromCharCode(aCode + 1 + i));
    final taken = _stationCabins
        .where((c) => c.id != exceptCabinId)
        .map((c) => c.no?.trim().toUpperCase())
        .whereType<String>()
        .toSet();
    return allExceptMaster.where((c) => !taken.contains(c)).toList();
  }

  /// İki çekmece düzeni "aynı tasarım" mı? Adres + config + hücre sayısı; sıradan bağımsız.
  static bool _isSameDrawerLayout(List<DrawerGroup> a, List<DrawerGroup> b) {
    if (a.length != b.length) return false;
    final aSorted = [...a]..sort((x, y) => x.address.compareTo(y.address));
    final bSorted = [...b]..sort((x, y) => x.address.compareTo(y.address));
    for (var i = 0; i < aSorted.length; i++) {
      if (aSorted[i].address != bSorted[i].address) return false;
      if (aSorted[i].slot.drawerConfigId != bSorted[i].slot.drawerConfigId) return false;
      if (aSorted[i].units.length != bSorted[i].units.length) return false;
    }
    return true;
  }

  static AppException _errorOf(Result<Object?> r) => r.when(ok: (_) => const UnexpectedException(), error: (e) => e);
}
