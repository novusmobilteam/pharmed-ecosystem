import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../core/providers/providers.dart';
import '../../dashboard/dashboard.dart';

final cabinDesignNotifierProvider = ChangeNotifierProvider<CabinDesignNotifier>((ref) {
  return CabinDesignNotifier(
    scanCabinUseCase: ref.read(scanCabinUseCaseProvider),
    getCabinVisualizerDataUseCase: ref.read(getCabinVisualizerDataUseCaseProvider),
    setReturnDrawerUseCase: ref.read(setReturnDrawerUseCaseProvider),
    createCabinUseCase: ref.read(createCabinUseCaseProvider),
    saveCabinDesignUseCase: ref.read(saveCabinDesignUseCaseProvider),
    updateCabinUseCase: ref.read(updateCabinUseCaseProvider),
  );
});

// Kabin dizayn ekranı gösterim modu.
enum CabinDesignMode {
  // Default mod
  initial,
  // Yeni kabin oluşturma modu
  create,
}

class CabinDesignNotifier extends ChangeNotifier with ApiRequestMixin {
  CabinDesignNotifier({
    required ScanCabinUseCase scanCabinUseCase,
    required GetCabinVisualizerDataUseCase getCabinVisualizerDataUseCase,
    required SetReturnDrawerUseCase setReturnDrawerUseCase,
    required CreateCabinUseCase createCabinUseCase,
    required SaveCabinDesignUseCase saveCabinDesignUseCase,
    required UpdateCabinUseCase updateCabinUseCase,
  }) : _scanCabinUseCase = scanCabinUseCase,
       _getCabinVisualizerDataUseCase = getCabinVisualizerDataUseCase,
       _setReturnDrawerUseCase = setReturnDrawerUseCase,
       _createCabinUseCase = createCabinUseCase,
       _saveCabinDesignUseCase = saveCabinDesignUseCase,
       _updateCabinUseCase = updateCabinUseCase;

  final ScanCabinUseCase _scanCabinUseCase;
  final GetCabinVisualizerDataUseCase _getCabinVisualizerDataUseCase;
  final SetReturnDrawerUseCase _setReturnDrawerUseCase;
  final CreateCabinUseCase _createCabinUseCase;
  final SaveCabinDesignUseCase _saveCabinDesignUseCase;
  final UpdateCabinUseCase _updateCabinUseCase;

  final OperationKey scanOp = OperationKey.custom('rescan-cabin');
  final OperationKey saveChangesOp = OperationKey.submit();
  final OperationKey createCabinOp = OperationKey.create();

  bool get isScanning => isLoading(scanOp);
  bool get isSaving => isLoading(saveChangesOp);
  bool get isSavingNewCabin => isLoading(createCabinOp);

  CabinDesignMode _mode = CabinDesignMode.initial;
  CabinDesignMode get mode => _mode;

  List<Cabin> _cabins = [];
  List<Cabin> get cabins => _cabins;

  late Cabin _masterCabin;

  late Cabin _selectedCabin;
  Cabin get selectedCabin => _selectedCabin;

  /// Seçili kabinin son KAYITLI hali — pending değişiklikleri tespit etmek
  /// (canSave/hasPendingXChange) ve "iptal" durumunda karşılaştırma için.
  late Cabin _originalCabin;

  int _selectedSlotId = 1;
  int get selectedSlotId => _selectedSlotId;

  Cabin? _newCabin;
  Cabin? get newCabin => _newCabin;

  // Seçili kabinin çekmece düzeni — tarama yapıldıysa taslak (pending) sonuç,
  // yoksa DB'den yüklenen mevcut düzen gösterilir.
  List<DrawerGroup> _groups = [];
  List<DrawerGroup>? _pendingScanGroups;
  List<DrawerGroup> get groups => _pendingScanGroups ?? _groups;

  // init() sırasında gelen tüm kabinlerin görsel/tasarım verisi. Kabin
  // değişiminde tazelenir (bkz. selectCabin), save() sonrası ilgili kabin
  // için güncellenir.
  final Map<int, CabinVisualizerData> _cabinDataByCabinId = {};

  // Mecvcut iade kutusunun yer aldığı çekmece (DB'deki güncel hali)
  DrawerGroup? _currentReturnDrawer;
  DrawerGroup? get currentReturnDrawer => _currentReturnDrawer;

  int? _pendingReturnSlotId;
  bool? _pendingReturnValue;

  DrawerGroup? get selectedGroup => groups.firstWhereOrNull((g) => g.slot.id == _selectedSlotId);

  bool get hasPendingNameChange => _selectedCabin.name?.trim() != _originalCabin.name?.trim();
  bool get hasPendingConnectionChange =>
      _selectedCabin.comPort != _originalCabin.comPort || _selectedCabin.no != _originalCabin.no;
  bool get hasPendingReturnChange => _pendingReturnSlotId != null && _pendingReturnValue != null;
  bool get hasPendingDesignChange => _pendingScanGroups != null;

  bool get canSave =>
      (hasPendingNameChange || hasPendingConnectionChange || hasPendingReturnChange || hasPendingDesignChange) &&
      !isLoading(saveChangesOp) &&
      !isLoading(scanOp);

  bool get canSaveNewCabin =>
      (_newCabin?.name?.trim().isNotEmpty ?? false) && _newCabin?.type != null && _newCabin?.no != null;

  int? get effectiveReturnSlotId {
    if (!hasPendingReturnChange) return _currentReturnDrawer?.slot.id;
    return _pendingReturnValue! ? _pendingReturnSlotId : null;
  }

  /// Seçili kabinin (kendi adresi hariç) istasyonda seçilebilir adres harfleri.
  List<String> get availableAddressCharsForEdit {
    const aCode = 65; // 'A'
    final allExceptMaster = List.generate(15, (i) => String.fromCharCode(aCode + 1 + i));
    final taken = _cabins
        .where((c) => c.id != _selectedCabin.id)
        .map((c) => c.no?.trim().toUpperCase())
        .whereType<String>()
        .toSet();
    return allExceptMaster.where((c) => !taken.contains(c)).toList();
  }

  /// Yeni kabin formu için seçilebilir adres harfleri.
  List<String> get availableAddressCharsForNewCabin {
    const aCode = 65;
    final allExceptMaster = List.generate(15, (i) => String.fromCharCode(aCode + 1 + i));
    final taken = _cabins.map((c) => c.no?.trim().toUpperCase()).whereType<String>().toSet();
    return allExceptMaster.where((c) => !taken.contains(c)).toList();
  }

  void init(StationCabinsContext stationContext) {
    _cabins = stationContext.cabins;
    _masterCabin = stationContext.cabins.firstWhere((c) => c.type == CabinType.master);
    _cabinDataByCabinId
      ..clear()
      ..addAll(stationContext.cabinDataByCabinId);

    _applySelectedCabin(stationContext.cabins.first);

    notifyListeners();
  }

  /// Seçili kabin + ona bağlı türetilmiş state'i tek yerden set eder.
  /// [groupsOverride] verilmezse cache'teki (varsa) veri kullanılır.
  void _applySelectedCabin(Cabin cabin, {List<DrawerGroup>? groupsOverride}) {
    _selectedCabin = cabin;
    _originalCabin = cabin;
    _pendingReturnSlotId = null;
    _pendingReturnValue = null;
    _pendingScanGroups = null;

    _groups = groupsOverride ?? _cabinDataByCabinId[cabin.id]?.groups ?? const [];
    _currentReturnDrawer = _groups.firstWhereOrNull((g) => g.isReturnDrawer);
    _selectedSlotId = _groups.firstOrNull?.slot.id ?? 1;
  }

  /// İki çekmece düzeninin "aynı tasarım" olup olmadığını karşılaştırır.
  bool _isSameDrawerLayout(List<DrawerGroup> a, List<DrawerGroup> b) {
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

  /// Sol listeden kabin değiştirirken çağrılır — güncel veriyi tazeler.
  Future<void> selectCabin(Cabin cabin) async {
    if (_selectedCabin.id == cabin.id || cabin.id == null) return;

    _applySelectedCabin(cabin);

    notifyListeners();
  }

  void selectCabinSlot(int slotId) {
    _selectedSlotId = slotId;
    notifyListeners();
  }

  /// İade çekmecesi seçimi — DB'ye kaydedilmez, save() sırasında uygulanır.
  void toggleReturnDrawer(bool value) {
    _pendingReturnSlotId = _selectedSlotId;
    _pendingReturnValue = value;

    notifyListeners();
  }

  /// Kabin güncelleme işlemleri (taslak — save() çağrılana kadar DB'ye yazılmaz)
  void updateCabinName(String? value) {
    _selectedCabin = _selectedCabin.copyWith(name: value);

    notifyListeners();
  }

  // Kabin com portu değiştirme. Sadece master kabinin com portu değiştirilebilir.
  // Mastera bağlı kabinler master kabinin kullandığı portu kullanırlar.
  void updateCabinComPort(String port) {
    if (_selectedCabin.type != CabinType.master) return;

    _selectedCabin = _selectedCabin.copyWith(comPort: ComPortX.fromLabel(port));
    _pendingScanGroups = null;

    notifyListeners();
  }

  // Kabin adresi değiştirme. Sadece slave kabinlerin adresi değiştirilebilir.
  // Master kabinin adresi sabit 'A' harfidir.
  void updateCabinAddress(String address) {
    if (_selectedCabin.type == CabinType.master) return;

    _selectedCabin = _selectedCabin.copyWith(no: address);
    _pendingScanGroups = null;

    notifyListeners();
  }

  /// "Tekrar Tara" butonu — sadece kabin görselinin üzerinde loading
  /// gösterilir (isScanning), tüm ekran değil.
  Future<void> rescanCabin() async {
    if (!hasPendingConnectionChange || isScanning || isSaving) return;

    await execute<List<DrawerGroup>>(
      scanOp,
      operation: _scan,
      onData: (newGroups) {
        final sameAsCurrent = _isSameDrawerLayout(newGroups, _groups);
        _pendingScanGroups = sameAsCurrent ? null : newGroups;
      },
    );
  }

  /// Temel Ayarlar panelindeki tek "Kaydet" butonu — tüm bekleyen
  /// değişiklikleri (bağlantı, tasarım, iade çekmecesi) tek akışta uygular.
  Future<bool> save() async {
    if (!canSave) return false;

    setLoading(saveChangesOp);

    // 1. Bağlantı değişikliği varsa kaydetmeden ÖNCE doğrula
    List<DrawerGroup>? finalScanGroups = _pendingScanGroups;

    if (hasPendingConnectionChange) {
      final rescanResult = await _scan();
      final newGroups = rescanResult.when(ok: (g) => g, error: (_) => null);

      if (newGroups == null) {
        final error = rescanResult.when(ok: (_) => null, error: (e) => e);
        setFailed(saveChangesOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
        return false;
      }

      finalScanGroups = _isSameDrawerLayout(newGroups, _groups) ? null : newGroups;
    }

    // 2. Bu kabinin bilgisini güncelle (comPort/no/name)
    Cabin updatedCabin = _selectedCabin;
    if (hasPendingConnectionChange || hasPendingNameChange) {
      final updateResult = await _updateCabinUseCase.call(_selectedCabin);
      final updateOk = updateResult.when(ok: (_) => true, error: (_) => false);

      if (!updateOk) {
        final error = updateResult.when(ok: (_) => null, error: (e) => e);
        setFailed(saveChangesOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
        return false;
      }

      updatedCabin = _selectedCabin;
    }

    var updatedCabins = _cabins.map((c) => c.id == updatedCabin.id ? updatedCabin : c).toList();

    // 3. Master portu değiştiyse — hat paylaşıldığı için TÜM diğer
    // kabinlerin comPort'u da güncellenir.
    if (updatedCabin.type == CabinType.master && updatedCabin.comPort != _originalCabin.comPort) {
      final others = updatedCabins.where((c) => c.id != updatedCabin.id).toList();

      for (final other in others) {
        final candidateOther = other.copyWith(comPort: updatedCabin.comPort);
        final otherResult = await _updateCabinUseCase.call(candidateOther);
        final otherOk = otherResult.when(ok: (_) => true, error: (_) => false);

        if (!otherOk) {
          _cabins = updatedCabins;
          final error = otherResult.when(ok: (_) => null, error: (e) => e);
          setFailed(saveChangesOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
          return false;
        }

        updatedCabins = updatedCabins.map((c) => c.id == candidateOther.id ? candidateOther : c).toList();
      }
    }

    // 4. İade çekmecesi değişikliği
    if (hasPendingReturnChange) {
      final returnResult = await _setReturnDrawerUseCase.call(_pendingReturnSlotId!, _pendingReturnValue!);
      final returnOk = returnResult.when(ok: (_) => true, error: (_) => false);

      if (!returnOk) {
        _cabins = updatedCabins;
        final error = returnResult.when(ok: (_) => null, error: (e) => e);
        setFailed(saveChangesOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
        return false;
      }
    }

    // 5. Tasarım değişikliği (yeni tarama sonucu farklıysa)
    if (finalScanGroups != null) {
      final slots = finalScanGroups.map((g) => g.slot).toList();
      final designResult = await _saveCabinDesignUseCase.call(
        cabinId: updatedCabin.id!,
        scanResults: slots,
        isUpdate: true,
      );
      final designOk = designResult.when(ok: (_) => true, error: (_) => false);

      if (!designOk) {
        _cabins = updatedCabins;
        final error = designResult.when(ok: (_) => null, error: (e) => e);
        setFailed(saveChangesOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
        return false;
      }
    }

    // 6. Hepsi başarılı — state'i temiz baştan uygula
    _cabins = updatedCabins;
    if (updatedCabin.type == CabinType.master) _masterCabin = updatedCabin;
    _applySelectedCabin(updatedCabin, groupsOverride: finalScanGroups ?? _groups);

    if (finalScanGroups != null) {
      // Tasarım değişti — init()'ten gelen cache artık eski. Sunucudan
      // taze veriyi çekip cache'i de güncelliyoruz, yoksa bir sonraki
      // selectCabin bu kabine geri dönüldüğünde eski tasarımı gösterir.
      final refreshResult = await _getCabinVisualizerDataUseCase.call(
        cabin: updatedCabin,
        deviceMode: updatedCabin.type,
        forceRefresh: true,
      );

      final refreshedData = refreshResult.when(ok: (d) => d, error: (_) => null);

      if (refreshedData != null) {
        _cabinDataByCabinId[updatedCabin.id!] = refreshedData;
        _applySelectedCabin(updatedCabin, groupsOverride: refreshedData.groups);
      } else {
        // Yenileme başarısız oldu ama kayıt zaten tamamlandı — ekranda
        // az önce taradığımız sonucu göstermeye devam ediyoruz. Cache
        // güncellenemediği için kullanıcı başka kabine geçip GERİ
        // dönerse eski tasarımı görebilir; kritik değil, sonraki
        // "Tekrar Tara" ile kendiliğinden düzelir.
        _applySelectedCabin(updatedCabin, groupsOverride: finalScanGroups);
      }
    } else {
      _applySelectedCabin(updatedCabin, groupsOverride: _groups);
    }

    setSuccess(saveChangesOp, message: contextlessL10n().common_defaultSuccessMessage);
    return true;
  }

  void toggleDesignMode() {
    if (_mode == CabinDesignMode.create) {
      _mode = CabinDesignMode.initial;
      _newCabin = null;
    } else {
      _mode = CabinDesignMode.create;
      _newCabin = Cabin(station: _selectedCabin.station);
    }
    notifyListeners();
  }

  void updateNewCabinName(String? value) {
    if (_newCabin == null) return;
    _newCabin = _newCabin!.copyWith(name: value);
    notifyListeners();
  }

  void selectNewCabinType(CabinType? type) {
    if (_newCabin == null) return;
    _newCabin = _newCabin!.copyWith(type: type);
    notifyListeners();
  }

  void selectNewCabinAddress(String? address) {
    if (_newCabin == null) return;
    _newCabin = _newCabin!.copyWith(no: address);
    notifyListeners();
  }

  /// Kaydet ve Tara: 1) hedef adreste yönetim kartı var mı doğrula,
  /// 2) varsa çekmece yapısını tara, 3) kabini oluştur, 4) tarama
  /// sonucunu (DrawerSlot'ları) kaydet, 5) yeni kabine geç.
  Future<void> saveNewCabin() async {
    final draft = _newCabin;
    if (draft == null || !canSaveNewCabin) return;

    final addressIndex = ManagementCard.indexFromAddressChar(draft.no);
    if (addressIndex == null) {
      setFailed(createCabinOp, message: 'Beklenmeyen bir hata oluştu.');
      return;
    }

    final portName = _masterCabin.comPort?.label;

    // Adım 1-2: adres doğrulama + çekmece taraması
    setLoading(createCabinOp, message: 'Adres doğrulanıyor...');

    final scanResult = await _scanCabinUseCase.call(
      portName: portName,
      cabinType: draft.type!,
      targetAddressIndex: addressIndex,
    );

    final drawerGroups = scanResult.when(ok: (g) => g, error: (_) => null);
    if (drawerGroups == null) {
      final error = scanResult.when(ok: (_) => null, error: (e) => e);
      setFailed(createCabinOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
      return;
    }

    // Adım 3: kabini oluştur
    setLoading(createCabinOp, message: 'Kabin oluşturuluyor...');

    final candidate = draft.copyWith(comPort: ComPortX.fromLabel(portName), status: Status.active);

    final createResult = await _createCabinUseCase.call(candidate);
    final createdCabin = createResult.when(ok: (c) => c, error: (_) => null);

    if (createdCabin?.id == null) {
      final error = createResult.when(ok: (_) => null, error: (e) => e);
      setFailed(createCabinOp, message: error?.message ?? 'Beklenmeyen bir hata oluştu.');
      return;
    }

    // Adım 4: tasarımı (DrawerSlot'ları) kaydet
    // NOT: Bu adımdan itibaren kabin ARTIK VAR. Başarısız olsa bile
    // formu terk ediyoruz — kabin zaten oluşmuş sayılır, sadece çekmece
    // verisi eksik kalmış olur; kullanıcı "Tekrar Tara" ile tamamlar.
    setLoading(createCabinOp, message: 'Tasarım kaydediliyor...');

    final slots = drawerGroups.map((g) => g.slot).toList();
    final saveDesignResult = await _saveCabinDesignUseCase.call(
      cabinId: createdCabin!.id!,
      scanResults: slots,
      isUpdate: false,
    );
    final designOk = saveDesignResult.when(ok: (_) => true, error: (_) => false);

    _cabins = [..._cabins, createdCabin];
    _mode = CabinDesignMode.initial;
    _newCabin = null;

    // Kabin var, tasarım kaydı başarısızsa boş groups ile geç; başarılıysa
    // yeni taranan düzenle geç. Her iki durumda da işlem "başarılı" sayılır
    // çünkü kabin oluşturuldu (bkz. yukarıdaki not).
    _applySelectedCabin(createdCabin, groupsOverride: designOk ? drawerGroups : const []);

    setSuccess(createCabinOp, message: contextlessL10n().common_defaultSuccessMessage);
  }

  /// Master ise: mevcut/taslak port + adres her zaman 'A'.
  /// Slave ise: master'ın portu (hat paylaşılıyor) + mevcut/taslak adres.
  Future<Result<List<DrawerGroup>>> _scan() async {
    final isMaster = _selectedCabin.type == CabinType.master;

    final portName = isMaster ? _selectedCabin.comPort?.label : _masterCabin.comPort?.label;
    final addressChar = isMaster ? 'A' : _selectedCabin.no;

    final addressIndex = ManagementCard.indexFromAddressChar(addressChar);

    if (addressIndex == null || portName == null) {
      return Result.error(
        SerialPortException(message: 'Kabin adresi/port çözümlenemedi: addressChar=$addressChar, portName=$portName'),
      );
    }

    return _scanCabinUseCase.call(
      cabinType: _selectedCabin.type ?? CabinType.cabinet,
      portName: portName,
      targetAddressIndex: addressIndex,
    );
  }
}
