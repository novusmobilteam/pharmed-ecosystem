import 'package:pharmed_core/pharmed_core.dart';

/// saveNewCabin() akışının hangi adımında olduğumuz — UI buton metnini /
/// göstergesini buna göre değiştirebilir.
enum NewCabinSaveStep { idle, verifyingAddress, creatingCabin, savingLayout }

/// Sağ panelde ne gösterildiği. Sol listeden seçilen öğe ya da açık form.
///
/// Kamera dalı ([CameraSelection]) formun durumunu taşımaz; o
/// CameraFormNotifier'dadır. Burada yalnızca neyin açık olduğu tutulur.
sealed class CabinDesignSelection {
  const CabinDesignSelection();
}

/// Mevcut bir kabin görüntüleniyor/düzenleniyor.
final class SelectedCabin extends CabinDesignSelection {
  const SelectedCabin(this.cabinId);
  final int cabinId;
}

/// "Yeni kabin tanımla" formu açık.
final class NewCabinDraft extends CabinDesignSelection {
  const NewCabinDraft({
    this.previousCabinId,
    this.name = '',
    this.type,
    this.addressChar,
    this.saveStep = NewCabinSaveStep.idle,
    this.pendingSerumScan,
    this.serumLidCount,
  });

  /// İptal edilirse geri dönülecek kabin.
  final int? previousCabinId;
  final String name;
  final CabinType? type;
  final String? addressChar;
  final NewCabinSaveStep saveStep;

  /// [#199] Tarama bağımsız serum kabini buldu (tek serum çekmecesi); kapak
  /// sayısı seçilene kadar kayıt burada bekler. Kart değişmediği için ikinci
  /// "Kaydet"te yeniden taranmaz.
  final DrawerGroup? pendingSerumScan;

  /// Kullanıcının seçtiği kapak sayısı (1–4).
  final int? serumLidCount;

  bool get needsSerumLidCount => pendingSerumScan != null;
  bool get isSaving => saveStep != NewCabinSaveStep.idle;
  bool get isComplete =>
      name.trim().isNotEmpty && type != null && addressChar != null && (!needsSerumLidCount || serumLidCount != null);

  /// [clearSerum]: adres değişince bekleyen serum taraması geçersizdir.
  NewCabinDraft copyWith({
    String? name,
    CabinType? type,
    String? addressChar,
    NewCabinSaveStep? saveStep,
    DrawerGroup? pendingSerumScan,
    int? serumLidCount,
    bool clearSerum = false,
  }) => NewCabinDraft(
    previousCabinId: previousCabinId,
    name: name ?? this.name,
    type: type ?? this.type,
    addressChar: addressChar ?? this.addressChar,
    saveStep: saveStep ?? this.saveStep,
    pendingSerumScan: clearSerum ? null : (pendingSerumScan ?? this.pendingSerumScan),
    serumLidCount: clearSerum ? null : (serumLidCount ?? this.serumLidCount),
  );
}

/// Mevcut kabinin bilgilerini düzenleme formu açık (yeni kabin formuyla aynı
/// ekran, mevcut bilgilerle dolu). Kayıt bekleyen değişikliklere aktarılıp
/// seçili kabinin kayıt akışıyla (donanım doğrulaması dahil) yapılır.
///
/// Değiştirilemeyenler: master kabinin adresi (her zaman A) ve ek kabinlerin
/// COM portu (master ile aynı hat).
final class EditCabinForm extends CabinDesignSelection {
  const EditCabinForm({
    required this.cabinId,
    required this.isMaster,
    required this.name,
    required this.type,
    required this.addressChar,
    required this.comPortLabel,
  });

  final int cabinId;
  final bool isMaster;
  final String name;
  final CabinType? type;

  /// Büyük harf ('A'..'P').
  final String? addressChar;
  final String? comPortLabel;

  bool get isComplete => name.trim().isNotEmpty && type != null && addressChar != null && comPortLabel != null;

  EditCabinForm copyWith({String? name, CabinType? type, String? addressChar, String? comPortLabel}) => EditCabinForm(
    cabinId: cabinId,
    isMaster: isMaster,
    name: name ?? this.name,
    type: type ?? this.type,
    addressChar: addressChar ?? this.addressChar,
    comPortLabel: comPortLabel ?? this.comPortLabel,
  );
}

/// Kamera formu açık: [cameraId] null ise yeni kamera, değilse düzenleme.
final class CameraSelection extends CabinDesignSelection {
  const CameraSelection({this.cameraId, this.previousCabinId, this.initialCabinId});
  final String? cameraId;

  /// Yeni kamera kabin panelinden açıldıysa o kabin baştan seçili gelir.
  final int? initialCabinId;

  /// Form kapatılınca geri dönülecek kabin.
  final int? previousCabinId;

  bool get isNew => cameraId == null;
}

/// Seçili kabin üzerindeki kaydedilmemiş değişiklikler.
///
/// Her alan için `null` = "değişiklik yok". Değer mevcut değere eşitse
/// notifier alanı null'a çeker, böylece "kaydedilecek bir şey var mı"
/// hesabı yalnızca bu nesneye bakar. Eski copyWith'teki `clearX`
/// bayraklarının yerini `with...` metotları alır (null da atanabilir).
class CabinPendingChanges {
  const CabinPendingChanges({
    this.name,
    this.comPort,
    this.addressChar,
    this.type,
    this.returnSlotId,
    this.returnValue,
    this.scanGroups,
    this.serumSlotId,
    this.serumShelves,
    this.slotOrder,
  });

  static const none = CabinPendingChanges();

  final String? name;

  /// Yalnızca master kabin.
  final ComPort? comPort;

  /// Yalnızca slave kabin.
  final String? addressChar;

  /// Yalnızca slave kabin: kabin tipi (dolap / buzdolabı / …). Tip tarama
  /// sonucunu belirlediği için bağlantı değişikliği gibi donanımla doğrulanır.
  final CabinType? type;

  /// İade çekmecesi değişikliği: hangi slot, açık mı kapalı mı.
  final int? returnSlotId;
  final bool? returnValue;

  /// Tarama sonucu mevcut tasarımdan FARKLI çıktıysa yeni yerleşim.
  final List<DrawerGroup>? scanGroups;

  /// Serum kabini raf yerleşimi değişikliği: hangi serum slot'u ve 3 rafın
  /// yeni hali. İkisi birlikte atanır/temizlenir.
  final int? serumSlotId;
  final List<SerumShelfLayout>? serumShelves;

  /// Çekmece yer değiştirmesi sonrası hedeflenen sıra (üstten alta slotId).
  /// Kayıtlı sırayla aynıysa null. Kayıtta minimum takas sayısına çevrilip
  /// `/CabinDesign/changePosition` ile tek tek uygulanır.
  final List<int>? slotOrder;

  bool get hasNameChange => name != null;
  bool get hasConnectionChange => comPort != null || addressChar != null || type != null;
  bool get hasReturnChange => returnSlotId != null && returnValue != null;
  bool get hasDesignChange => scanGroups != null;
  bool get hasSerumLayoutChange => serumSlotId != null && serumShelves != null;
  bool get hasOrderChange => slotOrder != null;
  bool get hasAny =>
      hasNameChange ||
      hasConnectionChange ||
      hasReturnChange ||
      hasDesignChange ||
      hasSerumLayoutChange ||
      hasOrderChange;

  CabinPendingChanges withName(String? v) => _copy(name: () => v);
  CabinPendingChanges withComPort(ComPort? v) => _copy(comPort: () => v);
  CabinPendingChanges withAddressChar(String? v) => _copy(addressChar: () => v);
  CabinPendingChanges withType(CabinType? v) => _copy(type: () => v);
  CabinPendingChanges withReturn(int slotId, bool value) => _copy(returnSlotId: () => slotId, returnValue: () => value);
  CabinPendingChanges withScanGroups(List<DrawerGroup>? v) => _copy(scanGroups: () => v);
  CabinPendingChanges withSlotOrder(List<int>? v) => _copy(slotOrder: () => v);

  /// [shelves] null ise serum değişikliği temizlenir.
  CabinPendingChanges withSerumLayout(int slotId, List<SerumShelfLayout>? shelves) =>
      _copy(serumSlotId: () => shelves == null ? null : slotId, serumShelves: () => shelves);

  CabinPendingChanges _copy({
    String? Function()? name,
    ComPort? Function()? comPort,
    String? Function()? addressChar,
    CabinType? Function()? type,
    int? Function()? returnSlotId,
    bool? Function()? returnValue,
    List<DrawerGroup>? Function()? scanGroups,
    int? Function()? serumSlotId,
    List<SerumShelfLayout>? Function()? serumShelves,
    List<int>? Function()? slotOrder,
  }) => CabinPendingChanges(
    name: name != null ? name() : this.name,
    comPort: comPort != null ? comPort() : this.comPort,
    addressChar: addressChar != null ? addressChar() : this.addressChar,
    type: type != null ? type() : this.type,
    returnSlotId: returnSlotId != null ? returnSlotId() : this.returnSlotId,
    returnValue: returnValue != null ? returnValue() : this.returnValue,
    scanGroups: scanGroups != null ? scanGroups() : this.scanGroups,
    serumSlotId: serumSlotId != null ? serumSlotId() : this.serumSlotId,
    serumShelves: serumShelves != null ? serumShelves() : this.serumShelves,
    slotOrder: slotOrder != null ? slotOrder() : this.slotOrder,
  );
}

/// Tarama sonucunda aynı adreste tipi değişmiş bir çekmece: [current] kayıtlı
/// tasarımdaki (sökülen), [scanned] karttan okunan (yeni takılan) çekmece.
class DrawerReplacement {
  const DrawerReplacement({required this.address, required this.current, required this.scanned, this.blockers = const []});

  final String address;
  final DrawerGroup current;
  final DrawerGroup scanned;

  /// Sökülen çekmecedeki atama/stoklar. Boş değilse değişim kaydedilemez:
  /// kullanıcı önce çekmeceyi boşaltıp atamaları silmeli, sonra tekrar taramalı.
  final List<DrawerReplacementBlocker> blockers;

  bool get isBlocked => blockers.isNotEmpty;

  String? get currentTypeName => current.slot.drawerConfig?.drawerType?.name;
  String? get scannedTypeName => scanned.slot.drawerConfig?.drawerType?.name;

  DrawerReplacement withBlockers(List<DrawerReplacementBlocker> value) =>
      DrawerReplacement(address: address, current: current, scanned: scanned, blockers: value);
}

/// Sökülecek çekmecede değişimi engelleyen tek bir atama (ve varsa stoğu).
class DrawerReplacementBlocker {
  const DrawerReplacementBlocker({required this.medicineName, required this.stockQuantity});

  final String medicineName;

  /// Atamaya bağlı toplam stok; 0 ise yalnızca atama var.
  final num stockQuantity;

  bool get hasStock => stockQuantity > 0;

  /// Tam sayıysa ondalıksız ("5"), değilse en fazla 2 hane ("2.5").
  String get stockLabel {
    final value = stockQuantity.toDouble();
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }
}
