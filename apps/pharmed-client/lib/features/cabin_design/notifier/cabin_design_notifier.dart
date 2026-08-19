// [SWREQ-CLI-CABIN-DESIGN-001] [IEC 62304 §5.5]
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../../core/providers/providers.dart';
import 'cabin_design_state.dart';

final cabinDesignNotifierProvider = NotifierProvider<CabinDesignNotifier, CabinDesignState>(CabinDesignNotifier.new);

class CabinDesignNotifier extends Notifier<CabinDesignState> {
  GetCurrentStationUseCase get _getCurrentStation => ref.read(getCurrentStationUseCaseProvider);
  GetCabinVisualizerDataUseCase get _getVisualizerData => ref.read(getCabinVisualizerDataUseCaseProvider);
  SetReturnDrawerUseCase get _setReturnDrawer => ref.read(setReturnDrawerUseCaseProvider);
  ScanCabinUseCase get _scanCabin => ref.read(scanCabinUseCaseProvider);
  CreateCabinUseCase get _createCabin => ref.read(createCabinUseCaseProvider);
  SaveCabinDesignUseCase get _saveCabinDesign => ref.read(saveCabinDesignUseCaseProvider);
  UpdateCabinUseCase get _updateCabin => ref.read(updateCabinUseCaseProvider);

  @override
  CabinDesignState build() => const CabinDesignLoading();

  /// İki çekmece düzeninin "aynı tasarım" olup olmadığını karşılaştırır.
  /// Adres + çekmece config'i + hücre sayısı bazında; sıradan bağımsız.
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

  Future<void> init() async {
    state = const CabinDesignLoading();

    final stationResult = await _getCurrentStation.call();

    final station = stationResult.when(ok: (s) => s, error: (_) => null);
    if (station == null) {
      state = CabinDesignError(message: '...', previousState: CabinDesignLoading());
      return;
    }

    final cabins = station.cabins;
    if (cabins.isEmpty) {
      state = CabinDesignError(message: '...', previousState: CabinDesignLoading());
      return;
    }

    final targetCabin = cabins.first;
    await _loadCabin(station: station, stationCabins: cabins, cabin: targetCabin);
  }

  Future<void> _loadCabin({
    required Station station,
    required List<Cabin> stationCabins,
    required Cabin cabin,
    bool showFullScreenLoading = true,
  }) async {
    final cabinId = cabin.id;
    final previous = state;

    if (cabinId == null) {
      state = CabinDesignError(message: '...', previousState: previous);
      return;
    }

    if (showFullScreenLoading) {
      state = const CabinDesignLoading();
    } else if (previous is CabinDesignReady) {
      state = previous.copyWith(isSwitchingCabin: true);
    }

    final result = await _getVisualizerData.call(cabinId: cabinId);

    result.when(
      ok: (data) {
        final groups = data.groups;
        final currentReturn = groups.firstWhereOrNull((g) => g.isReturnDrawer);

        state = CabinDesignReady(
          station: station,
          stationCabins: stationCabins,
          cabin: cabin,
          groups: groups,
          currentReturnSlotId: currentReturn?.slot.id,
          selectedSlotId: groups.firstOrNull?.slot.id,
        );
      },
      error: (e) {
        final fallback = previous is CabinDesignReady ? previous.copyWith(isSwitchingCabin: false) : previous;
        state = CabinDesignError(message: e.message, previousState: fallback);
      },
    );
  }

  /// Kullanıcı soldaki listeden başka bir kabine tıkladığında çağrılır.
  Future<void> selectCabin(int cabinId) async {
    final s = state;
    if (s is! CabinDesignReady) return;
    if (s.isSwitchingCabin) return;
    if (s.cabin.id == cabinId) return;

    final target = s.stationCabins.firstWhereOrNull((c) => c.id == cabinId);
    if (target == null) return;

    await _loadCabin(station: s.station, stationCabins: s.stationCabins, cabin: target, showFullScreenLoading: false);
  }

  void selectSlot(int slotId) {
    final s = state;
    if (s is! CabinDesignReady) return;
    state = s.copyWith(selectedSlotId: slotId);
  }

  void toggleReturnDrawer(bool value) {
    final s = state;
    if (s is! CabinDesignReady || s.isSaving) return;
    final slotId = s.selectedSlotId;
    if (slotId == null) return;
    state = s.copyWith(pendingReturnSlotId: slotId, pendingReturnValue: value);
  }

  void updatePendingName(String? value) {
    final s = state;
    if (s is! CabinDesignReady) return;

    final isSameAsCurrent = value?.trim() == s.cabin.name?.trim();

    state = s.copyWith(
      pendingName: isSameAsCurrent ? null : value,
      clearPendingName: isSameAsCurrent,
      clearError: true,
    );
  }

  /// Sadece master kabinde çağrılabilir.
  void updatePendingComPort(String portLabel) {
    final s = state;
    if (s is! CabinDesignReady || s.cabin.type != CabinType.master) return;

    final newPort = ComPortX.fromLabel(portLabel);
    final isSameAsCurrent = newPort == s.cabin.comPort;

    state = s.copyWith(
      pendingComPort: isSameAsCurrent ? null : newPort,
      clearPendingComPort: isSameAsCurrent,
      clearPendingScanGroups: true, // port değişti, önceki tarama sonucu geçersiz
      clearError: true,
    );
  }

  /// Sadece master OLMAYAN (slave) kabinlerde çağrılabilir.
  void updatePendingAddressChar(String addressChar) {
    final s = state;
    if (s is! CabinDesignReady || s.cabin.type == CabinType.master) return;

    final normalized = addressChar.trim().toUpperCase();
    final isSameAsCurrent = normalized == s.cabin.no?.trim().toUpperCase();

    state = s.copyWith(
      pendingAddressChar: isSameAsCurrent ? null : normalized,
      clearPendingAddressChar: isSameAsCurrent,
      clearPendingScanGroups: true,
      clearError: true,
    );
  }

  /// "Tekrar Tara" butonu — kullanıcı manuel tetikler. Sadece kabin
  /// görselinin üzerinde loading gösterilir (isScanning), tüm ekran değil.
  Future<void> rescanCabin() async {
    final s = state;
    if (s is! CabinDesignReady || s.isScanning || s.isSaving) return;
    if (!s.hasPendingConnectionChange) return;

    state = s.copyWith(isScanning: true, clearError: true);

    final rescanResult = await _performRescan(s);
    final newGroups = rescanResult.when(ok: (g) => g, error: (_) => null);

    if (newGroups == null) {
      final error = rescanResult.when(ok: (_) => null, error: (e) => e);
      state = s.copyWith(isScanning: false, error: error);
      return;
    }

    final sameAsCurrent = _isSameDrawerLayout(newGroups, s.groups);

    state = s.copyWith(
      isScanning: false,
      pendingScanGroups: sameAsCurrent ? null : newGroups,
      clearPendingScanGroups: sameAsCurrent,
    );
  }

  /// Master ise: (pending ?? mevcut) port + adres her zaman 'A'.
  /// Slave ise: master'ın portu (hat paylaşılıyor) + (pending ?? mevcut) adres.
  Future<Result<List<DrawerGroup>>> _performRescan(CabinDesignReady s) async {
    final isMaster = s.cabin.type == CabinType.master;

    final portName = isMaster
        ? (s.pendingComPort?.label ?? s.cabin.comPort?.label)
        : s.stationCabins.firstWhereOrNull((c) => c.type == CabinType.master)?.comPort?.label;

    final addressChar = isMaster ? 'A' : (s.pendingAddressChar ?? s.cabin.no);
    final addressIndex = ManagementCard.indexFromAddressChar(addressChar);

    if (addressIndex == null || portName == null) {
      return Result.error(const UnexpectedException());
    }

    return _scanCabin.call(
      portName: portName,
      cabinType: s.cabin.type ?? CabinType.cabinet,
      targetAddressIndex: addressIndex,
    );
  }

  /// Temel Ayarlar panelindeki tek "Kaydet" butonu — tüm bekleyen
  /// değişiklikleri (bağlantı, tasarım, iade çekmecesi) tek akışta uygular.
  Future<bool> save() async {
    final s = state;
    if (s is! CabinDesignReady || !s.canSave) return false;

    state = s.copyWith(isSaving: true, clearError: true);

    // ── 1. Bağlantı değişikliği varsa — kaydetmeden ÖNCE doğrula ──────
    // (Kullanıcı "Tekrar Tara"yı hiç tetiklememiş olsa bile burada
    // yeniden doğrulanır — port/adres değiştikten sonra manuel tarama
    // zorunlu tutulmuyor, ama kayıt anında mutlaka kontrol ediliyor.)
    List<DrawerGroup>? finalScanGroups = s.pendingScanGroups;

    if (s.hasPendingConnectionChange) {
      final rescanResult = await _performRescan(s);
      final newGroups = rescanResult.when(ok: (g) => g, error: (_) => null);

      if (newGroups == null) {
        final error = rescanResult.when(ok: (_) => null, error: (e) => e);
        state = s.copyWith(isSaving: false, error: error);
        return false;
      }

      finalScanGroups = _isSameDrawerLayout(newGroups, s.groups) ? null : newGroups;
    }

    // ── 2. Bu kabinin bilgisini güncelle (comPort/no) ──────────────────
    Cabin updatedCabin = s.cabin;
    if (s.hasPendingConnectionChange || s.hasPendingNameChange) {
      final candidate = s.cabin.copyWith(
        comPort: s.pendingComPort ?? s.cabin.comPort,
        no: s.pendingAddressChar ?? s.cabin.no,
        name: s.pendingName ?? s.cabin.name,
      );

      final updateResult = await _updateCabin.call(candidate);
      final updateOk = updateResult.when(ok: (_) => true, error: (_) => false);

      if (!updateOk) {
        final error = updateResult.when(ok: (_) => null, error: (e) => e);
        state = s.copyWith(isSaving: false, error: error);
        return false;
      }

      // API güncellenmiş kaydı geri döndürmüyor — yerelde inşa ettiğimiz
      // candidate'i doğru kabul edip devam ediyoruz.
      updatedCabin = candidate;
    }

    var updatedStationCabins = s.stationCabins.map((c) => c.id == updatedCabin.id ? updatedCabin : c).toList();

    // ── 3. Master portu değiştiyse — hat paylaşıldığı için TÜM diğer
    //      kabinlerin comPort'u da güncellenir. ──────────────────────
    if (s.cabin.type == CabinType.master && s.pendingComPort != null) {
      final others = updatedStationCabins.where((c) => c.id != updatedCabin.id).toList();

      for (final other in others) {
        final candidateOther = other.copyWith(comPort: s.pendingComPort);
        final otherResult = await _updateCabin.call(candidateOther);
        final otherOk = otherResult.when(ok: (_) => true, error: (_) => false);

        if (!otherOk) {
          final error = otherResult.when(ok: (_) => null, error: (e) => e);
          state = s.copyWith(isSaving: false, error: error, stationCabins: updatedStationCabins, cabin: updatedCabin);
          return false;
        }

        updatedStationCabins = updatedStationCabins.map((c) => c.id == candidateOther.id ? candidateOther : c).toList();
      }
    }
    // ── 4. İade çekmecesi değişikliği ──────────────────────────────
    if (s.hasPendingReturnChange) {
      final returnResult = await _setReturnDrawer.call(s.pendingReturnSlotId!, s.pendingReturnValue!);
      final returnOk = returnResult.when(ok: (_) => true, error: (_) => false);

      if (!returnOk) {
        final error = returnResult.when(ok: (_) => null, error: (e) => e);
        state = s.copyWith(isSaving: false, error: error, stationCabins: updatedStationCabins, cabin: updatedCabin);
        return false;
      }
    }

    // ── 5. Tasarım değişikliği (yeni tarama sonucu farklıysa) ──────────
    if (finalScanGroups != null) {
      final slots = finalScanGroups.map((g) => g.slot).toList();
      final designResult = await _saveCabinDesign.call(cabinId: updatedCabin.id!, scanResults: slots, isUpdate: true);
      final designOk = designResult.when(ok: (_) => true, error: (_) => false);

      if (!designOk) {
        final error = designResult.when(ok: (_) => null, error: (e) => e);
        state = s.copyWith(isSaving: false, error: error, stationCabins: updatedStationCabins, cabin: updatedCabin);
        return false;
      }
    }

    // ── 6. Hepsi başarılı — state'i temiz baştan yükle ─────────────────
    await _loadCabin(
      station: s.station,
      stationCabins: updatedStationCabins,
      cabin: updatedCabin,
      showFullScreenLoading: false,
    );
    return true;
  }

  void startAddCabin() {
    final s = state;
    if (s is! CabinDesignReady) return;
    state = CabinDesignCreating(station: s.station, stationCabins: s.stationCabins, previousCabinId: s.cabin.id);
  }

  Future<void> cancelAddCabin() async {
    final s = state;
    if (s is! CabinDesignCreating) return;

    final target = s.previousCabinId != null
        ? s.stationCabins.firstWhereOrNull((c) => c.id == s.previousCabinId)
        : null;

    await _loadCabin(station: s.station, stationCabins: s.stationCabins, cabin: target ?? s.stationCabins.first);
  }

  void updateNewCabinName(String? value) {
    final s = state;
    if (s is! CabinDesignCreating) return;
    state = s.copyWith(name: value);
  }

  void selectNewCabinType(CabinType type) {
    final s = state;
    if (s is! CabinDesignCreating) return;
    state = s.copyWith(selectedType: type);
  }

  void selectNewCabinAddress(String addressChar) {
    final s = state;
    if (s is! CabinDesignCreating) return;
    state = s.copyWith(selectedAddressChar: addressChar);
  }

  /// Kaydet ve Tara: 1) hedef adreste yönetim kartı var mı doğrula,
  /// 2) varsa çekmece yapısını tara, 3) kabini oluştur, 4) tarama
  /// sonucunu (DrawerSlot'ları) kaydet, 5) yeni kabine geç.
  Future<void> saveNewCabin() async {
    final s = state;
    if (s is! CabinDesignCreating || !s.canSave) return;

    final addressIndex = ManagementCard.indexFromAddressChar(s.selectedAddressChar);
    if (addressIndex == null) {
      state = s.copyWith(error: const UnexpectedException());
      return;
    }

    final portName = s.stationCabins.firstWhereOrNull((c) => c.type == CabinType.master)?.comPort?.label;

    // ── Adım 1-2: adres doğrulama + çekmece taraması ──────────────────
    state = s.copyWith(saveStep: NewCabinSaveStep.verifyingAddress, clearSaveError: true);

    final scanResult = await _scanCabin.call(
      portName: portName,
      cabinType: s.selectedType!,
      targetAddressIndex: addressIndex,
    );

    final drawerGroups = scanResult.when(ok: (g) => g, error: (_) => null);
    if (drawerGroups == null) {
      final error = scanResult.when(ok: (_) => null, error: (e) => e);
      // Hiçbir şey oluşmadı — formda kal, hatayı göster, tekrar denenebilir.
      state = s.copyWith(saveStep: NewCabinSaveStep.idle, error: error);
      return;
    }

    // ── Adım 3: kabini oluştur ──────────────────────────────────────
    state = s.copyWith(saveStep: NewCabinSaveStep.creatingCabin);

    final newCabin = Cabin(
      name: s.name.trim(),
      type: s.selectedType,
      no: s.selectedAddressChar,
      comPort: ComPortX.fromLabel(portName),
      status: Status.active,
      station: s.station,
    );

    final createResult = await _createCabin.call(newCabin);
    final createdCabin = createResult.when(ok: (c) => c, error: (_) => null);

    if (createdCabin?.id == null) {
      final error = createResult.when(ok: (_) => null, error: (e) => e);
      // Kabin oluşmadı — formda kal, tekrar denenebilir.
      state = s.copyWith(saveStep: NewCabinSaveStep.idle, error: error);
      return;
    }

    // ── Adım 4: tasarımı (DrawerSlot'ları) kaydet ─────────────────────
    // NOT: Bu adımdan itibaren kabin ARTIK VAR. Başarısız olsa bile formu
    // terk ediyoruz — kabin zaten oluşmuş sayılır, sadece çekmece verisi
    // eksik kalmış olur; kullanıcı yeni kabinin dizayn ekranında
    // "Yeniden Tara" ile bunu tamamlar. Bu yüzden CabinDesignError'a DEĞİL,
    // doğrudan (boş groups ile) CabinDesignReady'ye geçiyoruz.
    state = s.copyWith(saveStep: NewCabinSaveStep.savingLayout);

    final slots = drawerGroups.map((g) => g.slot).toList();
    final saveDesignResult = await _saveCabinDesign.call(
      cabinId: createdCabin!.id!,
      scanResults: slots,
      isUpdate: false,
    );

    final designOk = saveDesignResult.when(ok: (_) => true, error: (_) => false);
    final updatedCabins = [...s.stationCabins, createdCabin];

    if (!designOk) {
      // Kabin var, tasarım yok — boş groups ile Ready'e geç.
      state = CabinDesignReady(
        station: s.station,
        stationCabins: updatedCabins,
        cabin: createdCabin,
        groups: const [],
        currentReturnSlotId: null,
      );
      return;
    }

    // Her şey başarılı — yeni kabine tam tasarımıyla geç.
    await _loadCabin(station: s.station, stationCabins: updatedCabins, cabin: createdCabin);
  }

  void dismissError() {
    final s = state;
    if (s is CabinDesignError) state = s.previousState;
  }
}
