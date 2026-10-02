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
    scanCabin: ref.read(scanCabinUseCaseProvider),
    createCabin: ref.read(createCabinUseCaseProvider),
    saveCabinDesign: ref.read(saveCabinDesignUseCaseProvider),
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
    required ScanCabinUseCase scanCabin,
    required CreateCabinUseCase createCabin,
    required SaveCabinDesignUseCase saveCabinDesign,
    required UpdateCabinUseCase updateCabin,
    required ActiveServiceNotifier activeService,
    required ICameraDeviceRepository cameraDevices,
  }) : _cameraDevices = cameraDevices,
       _getCurrentStation = getCurrentStation,
       _getVisualizerData = getVisualizerData,
       _setReturnDrawer = setReturnDrawer,
       _scanCabin = scanCabin,
       _createCabin = createCabin,
       _saveCabinDesign = saveCabinDesign,
       _updateCabin = updateCabin,
       _activeService = activeService;

  final GetCurrentStationUseCase _getCurrentStation;
  final GetCabinVisualizerDataUseCase _getVisualizerData;
  final SetReturnDrawerUseCase _setReturnDrawer;
  final ScanCabinUseCase _scanCabin;
  final CreateCabinUseCase _createCabin;
  final SaveCabinDesignUseCase _saveCabinDesign;
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

  CabinPendingChanges _pending = CabinPendingChanges.none;
  CabinPendingChanges get pending => _pending;

  List<CameraDevice> _cameras = const [];
  List<CameraDevice> get cameras => _cameras;

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

  /// Görselde gösterilecek yerleşim: bekleyen tarama sonucu varsa o.
  List<DrawerGroup> get displayedGroups => _pending.scanGroups ?? _groups;

  DrawerGroup? get selectedGroup => _groups.firstWhereOrNull((g) => g.slot.id == _selectedSlotId);

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

  bool get canSave => _selection is SelectedCabin && _pending.hasAny && !isSaving && !isRescanning;

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
        _currentReturnSlotId = data.groups.firstWhereOrNull((g) => g.isReturnDrawer)?.slot.id;
        _selectedSlotId = data.groups.firstOrNull?.slot.id;
        _pending = CabinPendingChanges.none;
        _selection = SelectedCabin(cabinId);
        _clearInlineErrors(notify: false);
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
    _selectedSlotId = slotId;
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

  /// Sadece master kabin. Port değişince önceki tarama sonucu geçersizdir.
  void updatePendingComPort(String portLabel) {
    final cabin = _cabin;
    if (cabin == null || cabin.type != CabinType.master) return;

    final port = ComPortX.fromLabel(portLabel);
    _pending = _pending.withComPort(port == cabin.comPort ? null : port).withScanGroups(null);
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// Sadece slave kabin. Adres değişince önceki tarama sonucu geçersizdir.
  void updatePendingAddressChar(String addressChar) {
    final cabin = _cabin;
    if (cabin == null || cabin.type == CabinType.master || isRescanning) return;

    final normalized = addressChar.trim().toUpperCase();
    final same = normalized == cabin.no?.trim().toUpperCase();
    _pending = _pending.withAddressChar(same ? null : normalized).withScanGroups(null);
    _clearInlineErrors(notify: false);
    notifyListeners();
  }

  /// "Tekrar Tara" — sadece kabin görselinin üzerinde loading.
  Future<void> rescanCabin() async {
    final cabin = _cabin;
    if (cabin == null || isRescanning || isSaving || !_pending.hasConnectionChange) return;

    _clearInlineErrors(notify: false);
    await execute(
      _rescanOp,
      operation: () => _performRescan(cabin),
      onData: (newGroups) {
        _pending = _pending.withScanGroups(_isSameDrawerLayout(newGroups, _groups) ? null : newGroups);
      },
    );
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

    setLoading(_saveOp);
    final pending = _pending;

    // ── 1. Bağlantı değişikliği varsa — kaydetmeden ÖNCE doğrula ──────
    // ("Tekrar Tara" tetiklenmemiş olsa bile kayıt anında mutlaka kontrol.)
    var finalScanGroups = pending.scanGroups;
    if (pending.hasConnectionChange) {
      final rescan = await _performRescan(cabin);
      if (rescan.isError) return _failSave(_errorOf(rescan));
      final newGroups = rescan.data!;
      finalScanGroups = _isSameDrawerLayout(newGroups, _groups) ? null : newGroups;
    }

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

    // ── 4. İade çekmecesi ─────────────────────────────────────────────
    if (pending.hasReturnChange) {
      final r = await _setReturnDrawer.call(pending.returnSlotId!, pending.returnValue!);
      if (r.isError) return _failSave(_errorOf(r));
    }

    // ── 5. Tasarım (yeni tarama sonucu farklıysa) ─────────────────────
    if (finalScanGroups != null) {
      final r = await _saveCabinDesign.call(
        cabinId: updatedCabin.id!,
        scanResults: finalScanGroups.map((g) => g.slot).toList(),
        isUpdate: true,
      );
      if (r.isError) return _failSave(_errorOf(r));
    }

    // ── 6. Hepsi başarılı — kabini temiz baştan yükle ─────────────────
    await _loadCabin(updatedCabin, fullScreen: false);
    setSuccess(_saveOp);
    return true;
  }

  bool _failSave(AppException e) {
    MedLogger.error(unit: _unit, swreq: _swreq, message: 'Kabin dizaynı kaydedilemedi', error: e);
    setFailed(_saveOp, message: e.userMessage);
    return false;
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

    if (design.isError) {
      MedLogger.warn(
        unit: _unit,
        swreq: _swreq,
        message: 'Yeni kabin oluşturuldu ama tasarım kaydedilemedi',
        context: {'cabinId': created.id, 'error': _errorOf(design).message},
      );
      _cabin = created;
      _groups = const [];
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
    _selectedSlotId = null;
    _currentReturnSlotId = null;
    _pending = CabinPendingChanges.none;
    _cameras = const [];
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
