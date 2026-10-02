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
  });

  /// İptal edilirse geri dönülecek kabin.
  final int? previousCabinId;
  final String name;
  final CabinType? type;
  final String? addressChar;
  final NewCabinSaveStep saveStep;

  bool get isSaving => saveStep != NewCabinSaveStep.idle;
  bool get isComplete => name.trim().isNotEmpty && type != null && addressChar != null;

  NewCabinDraft copyWith({String? name, CabinType? type, String? addressChar, NewCabinSaveStep? saveStep}) =>
      NewCabinDraft(
        previousCabinId: previousCabinId,
        name: name ?? this.name,
        type: type ?? this.type,
        addressChar: addressChar ?? this.addressChar,
        saveStep: saveStep ?? this.saveStep,
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
    this.returnSlotId,
    this.returnValue,
    this.scanGroups,
  });

  static const none = CabinPendingChanges();

  final String? name;

  /// Yalnızca master kabin.
  final ComPort? comPort;

  /// Yalnızca slave kabin.
  final String? addressChar;

  /// İade çekmecesi değişikliği: hangi slot, açık mı kapalı mı.
  final int? returnSlotId;
  final bool? returnValue;

  /// Tarama sonucu mevcut tasarımdan FARKLI çıktıysa yeni yerleşim.
  final List<DrawerGroup>? scanGroups;

  bool get hasNameChange => name != null;
  bool get hasConnectionChange => comPort != null || addressChar != null;
  bool get hasReturnChange => returnSlotId != null && returnValue != null;
  bool get hasDesignChange => scanGroups != null;
  bool get hasAny => hasNameChange || hasConnectionChange || hasReturnChange || hasDesignChange;

  CabinPendingChanges withName(String? v) => _copy(name: () => v);
  CabinPendingChanges withComPort(ComPort? v) => _copy(comPort: () => v);
  CabinPendingChanges withAddressChar(String? v) => _copy(addressChar: () => v);
  CabinPendingChanges withReturn(int slotId, bool value) => _copy(returnSlotId: () => slotId, returnValue: () => value);
  CabinPendingChanges withScanGroups(List<DrawerGroup>? v) => _copy(scanGroups: () => v);

  CabinPendingChanges _copy({
    String? Function()? name,
    ComPort? Function()? comPort,
    String? Function()? addressChar,
    int? Function()? returnSlotId,
    bool? Function()? returnValue,
    List<DrawerGroup>? Function()? scanGroups,
  }) => CabinPendingChanges(
    name: name != null ? name() : this.name,
    comPort: comPort != null ? comPort() : this.comPort,
    addressChar: addressChar != null ? addressChar() : this.addressChar,
    returnSlotId: returnSlotId != null ? returnSlotId() : this.returnSlotId,
    returnValue: returnValue != null ? returnValue() : this.returnValue,
    scanGroups: scanGroups != null ? scanGroups() : this.scanGroups,
  );
}
