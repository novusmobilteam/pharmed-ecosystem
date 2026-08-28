import 'package:collection/collection.dart';
import 'package:pharmed_core/pharmed_core.dart';

/// saveNewCabin() akışının hangi adımında olduğumuzu temsil eder.
/// UI buna göre buton metnini/göstergesini değiştirebilir
/// ("Adres doğrulanıyor...", "Kabin oluşturuluyor..." gibi).
enum NewCabinSaveStep { idle, verifyingAddress, creatingCabin, savingLayout }

sealed class CabinDesignState {
  const CabinDesignState();
}

final class CabinDesignLoading extends CabinDesignState {
  const CabinDesignLoading();
}

final class CabinDesignReady extends CabinDesignState {
  const CabinDesignReady({
    required this.station,
    required this.stationCabins,
    required this.cabin,
    required this.groups,
    required this.currentReturnSlotId,
    this.selectedSlotId,
    this.pendingReturnSlotId,
    this.pendingReturnValue,
    this.pendingComPort,
    this.pendingName,
    this.pendingAddressChar,
    this.pendingScanGroups,
    this.isSaving = false,
    this.isSwitchingCabin = false,
    this.isScanning = false,
    this.isTogglingStatus = false,
    this.error,
  });

  /// İşlem yapılan istasyon — kabin listesinin kaynağı.
  final Station station;

  /// station.cabins ile aynı — ayrı tutulmasının sebebi, ileride kabin
  /// oluşturma/güncelleme sonrası bu listeyi station'ı yeniden çekmeden
  /// yerel güncelleyebilmek (optimistic update).
  final List<Cabin> stationCabins;

  /// O an sağ tarafta gösterilen (seçili) kabin.
  final Cabin cabin;

  final List<DrawerGroup> groups;
  final int? selectedSlotId;
  final int? currentReturnSlotId;

  final int? pendingReturnSlotId;
  final bool? pendingReturnValue;
  final bool isSaving;

  /// Master kabin için taslak COM port değişikliği. Sadece
  /// cabin.type == CabinType.master iken anlamlı/gösterilir.
  final ComPort? pendingComPort;

  /// Slave (master olmayan) kabin için taslak adres harfi değişikliği.
  /// Sadece cabin.type != CabinType.master iken anlamlı/gösterilir.
  final String? pendingAddressChar;

  /// Taslak isim değişikliği.
  final String? pendingName;

  /// "Tekrar Tara" (veya kaydet sırasındaki otomatik doğrulama taraması)
  /// sonucu önceki tasarımdan FARKLI çıktıysa burada tutulur. Aynıysa
  /// null kalır — gereksiz kayıt yapılmaz.
  final List<DrawerGroup>? pendingScanGroups;

  /// Sol listeden kabin değiştirirken sağ panelin üzerine hafif overlay.
  final bool isSwitchingCabin;

  /// "Tekrar Tara" sırasında true — SADECE kabin görselinin (visual pane)
  /// üzerinde loading gösterilir.
  final bool isScanning;

  /// true → "Pasife Al/Etkinleştir" işlemi sürüyor. SADECE o butonda
  /// spinner gösterilir, tüm sayfa/görsel etkilenmez.
  final bool isTogglingStatus;

  /// Tarama/kayıt sırasında oluşan herhangi bir hata (bağlantı, güncelleme,
  /// tasarım kaydı) — hepsi aynı yoldan (.userMessage) UI'da gösterilir.
  final AppException? error;

  bool get hasPendingNameChange => pendingName != null && pendingName!.trim() != cabin.name?.trim();
  bool get hasPendingReturnChange => pendingReturnSlotId != null && pendingReturnValue != null;
  bool get hasPendingConnectionChange => pendingComPort != null || pendingAddressChar != null;
  bool get hasPendingDesignChange => pendingScanGroups != null;

  DrawerGroup? get selectedGroup => groups.firstWhereOrNull((g) => g.slot.id == selectedSlotId);

  int? get effectiveReturnSlotId {
    if (!hasPendingReturnChange) return currentReturnSlotId;
    return pendingReturnValue! ? pendingReturnSlotId : null;
  }

  bool get canSave =>
      (hasPendingReturnChange || hasPendingConnectionChange || hasPendingDesignChange || hasPendingNameChange) &&
      !isSaving &&
      !isScanning;

  /// Bu kabinin (kendi adresi hariç) istasyonda seçilebilir adres harfleri.
  /// Master hariç B-P arası — kabin güncellenirken kendi mevcut adresi de
  /// listede kalmalı (kendine karşı "taken" sayılmamalı).
  List<String> get availableAddressCharsForEdit {
    const aCode = 65; // 'A'
    final allExceptMaster = List.generate(15, (i) => String.fromCharCode(aCode + 1 + i));
    final taken = stationCabins
        .where((c) => c.id != cabin.id)
        .map((c) => c.no?.trim().toUpperCase())
        .whereType<String>()
        .toSet();
    return allExceptMaster.where((c) => !taken.contains(c)).toList();
  }

  CabinDesignReady copyWith({
    Station? station,
    List<Cabin>? stationCabins,
    Cabin? cabin,
    List<DrawerGroup>? groups,
    int? selectedSlotId,
    int? currentReturnSlotId,
    bool clearCurrentReturnSlotId = false,
    int? pendingReturnSlotId,
    bool? pendingReturnValue,
    bool clearPendingReturn = false,
    String? pendingName,
    ComPort? pendingComPort,
    bool clearPendingComPort = false,
    String? pendingAddressChar,
    bool clearPendingAddressChar = false,
    List<DrawerGroup>? pendingScanGroups,
    bool clearPendingScanGroups = false,
    bool? isSaving,
    bool? isSwitchingCabin,
    bool? isScanning,
    AppException? error,
    bool clearError = false,
    bool clearPendingName = false,
    bool? isTogglingStatus,
  }) {
    return CabinDesignReady(
      station: station ?? this.station,
      stationCabins: stationCabins ?? this.stationCabins,
      cabin: cabin ?? this.cabin,
      groups: groups ?? this.groups,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
      currentReturnSlotId: clearCurrentReturnSlotId ? null : (currentReturnSlotId ?? this.currentReturnSlotId),
      pendingReturnSlotId: clearPendingReturn ? null : (pendingReturnSlotId ?? this.pendingReturnSlotId),
      pendingReturnValue: clearPendingReturn ? null : (pendingReturnValue ?? this.pendingReturnValue),
      pendingComPort: clearPendingComPort ? null : (pendingComPort ?? this.pendingComPort),
      pendingAddressChar: clearPendingAddressChar ? null : (pendingAddressChar ?? this.pendingAddressChar),
      pendingScanGroups: clearPendingScanGroups ? null : (pendingScanGroups ?? this.pendingScanGroups),
      isSaving: isSaving ?? this.isSaving,
      isSwitchingCabin: isSwitchingCabin ?? this.isSwitchingCabin,
      isScanning: isScanning ?? this.isScanning,
      error: clearError ? null : (error ?? this.error),
      pendingName: clearPendingName ? null : (pendingName ?? this.pendingName),
      isTogglingStatus: isTogglingStatus ?? this.isTogglingStatus,
    );
  }
}

/// Sağ panelde "yeni kabin tanımla" formu gösterilirken aktif state.
/// Sol kabin listesi (station + stationCabins) yaşamaya devam eder — dialog
/// hâlâ aynı istasyon bağlamında, sadece sağ taraf farklı bir akışa geçmiştir.
final class CabinDesignCreating extends CabinDesignState {
  const CabinDesignCreating({
    required this.station,
    required this.stationCabins,
    required this.previousCabinId,
    this.name = '',
    this.selectedType,
    this.selectedAddressChar,
    this.saveStep = NewCabinSaveStep.idle,
    this.error,
  });

  final Station station;
  final List<Cabin> stationCabins;
  final int? previousCabinId;

  final String name;
  final CabinType? selectedType;
  final String? selectedAddressChar;

  final NewCabinSaveStep saveStep;

  /// 1. veya 2. adımda oluşan hata — genel CabinDesignError'dan FARKLI olarak
  /// formu terk etmez, kullanıcı aynı ekranda kalıp tekrar dener.
  /// (3. adım — tasarım kaydı — bu alana hiç düşmez, ayrı ele alınır; bkz. saveNewCabin.)
  final AppException? error;

  bool get isSaving => saveStep != NewCabinSaveStep.idle;

  Set<String> get _takenAddressChars =>
      stationCabins.map((c) => c.no?.trim().toUpperCase()).whereType<String>().toSet();

  List<String> get availableAddressChars {
    const aCode = 65;
    final allExceptMaster = List.generate(15, (i) => String.fromCharCode(aCode + 1 + i));
    return allExceptMaster.where((c) => !_takenAddressChars.contains(c)).toList();
  }

  bool get canSave => name.trim().isNotEmpty && selectedType != null && selectedAddressChar != null && !isSaving;

  CabinDesignCreating copyWith({
    String? name,
    CabinType? selectedType,
    String? selectedAddressChar,
    NewCabinSaveStep? saveStep,
    AppException? error,
    bool clearSaveError = false,
  }) {
    return CabinDesignCreating(
      station: station,
      stationCabins: stationCabins,
      previousCabinId: previousCabinId,
      name: name ?? this.name,
      selectedType: selectedType ?? this.selectedType,
      selectedAddressChar: selectedAddressChar ?? this.selectedAddressChar,
      saveStep: saveStep ?? this.saveStep,
      error: clearSaveError ? null : (error ?? this.error),
    );
  }
}

final class CabinDesignError extends CabinDesignState {
  const CabinDesignError({required this.message, required this.previousState});

  final String message;
  final CabinDesignState previousState;
}
