import 'package:pharmed_ui/pharmed_ui.dart';

/// CabinInventoryView'ı açarken kullanılan tip.
enum CabinInventoryType {
  refill(1),
  intake(2),
  unload(3),
  census(4),
  disposal(5),
  refillList(6);

  final int id;

  const CabinInventoryType(this.id);

  /// Banner/mesaj bağlamı için kısa işlem etiketi.
  String get operationLabel => switch (this) {
    CabinInventoryType.refill => contextlessL10n().enumCore_cabinInventoryTypeRefillOperationLabel,
    CabinInventoryType.intake => contextlessL10n().enumCore_cabinInventoryTypeIntakeOperationLabel,
    CabinInventoryType.unload => contextlessL10n().enumCore_cabinInventoryTypeUnloadOperationLabel,
    CabinInventoryType.census => contextlessL10n().enumCore_cabinInventoryTypeCensusOperationLabel,
    CabinInventoryType.disposal => contextlessL10n().enumCore_cabinInventoryTypeDisposalOperationLabel,
    CabinInventoryType.refillList => contextlessL10n().enumCore_cabinInventoryTypeRefillListOperationLabel,
  };

  String get title {
    switch (this) {
      case CabinInventoryType.refill:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillTitle;
      case CabinInventoryType.refillList:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillListTitle;
      case CabinInventoryType.census:
        return contextlessL10n().enumCore_cabinInventoryTypeCensusTitle;
      case CabinInventoryType.disposal:
        return contextlessL10n().enumCore_cabinInventoryTypeDisposalTitle;
      case CabinInventoryType.unload:
        return contextlessL10n().enumCore_cabinInventoryTypeUnloadTitle;
      case CabinInventoryType.intake:
        return contextlessL10n().enumCore_cabinInventoryTypeIntakeTitle;
    }
  }

  String get buttonText {
    switch (this) {
      case CabinInventoryType.refill:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillButtonText;
      case CabinInventoryType.refillList:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillListButtonText;
      case CabinInventoryType.census:
        return contextlessL10n().enumCore_cabinInventoryTypeCensusButtonText;
      case CabinInventoryType.disposal:
        return contextlessL10n().enumCore_cabinInventoryTypeDisposalButtonText;
      case CabinInventoryType.unload:
        return contextlessL10n().enumCore_cabinInventoryTypeUnloadButtonText;
      case CabinInventoryType.intake:
        return contextlessL10n().enumCore_cabinInventoryTypeIntakeButtonText;
    }
  }

  String get fieldText {
    switch (this) {
      case CabinInventoryType.refill:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillFieldText;
      case CabinInventoryType.refillList:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillListFieldText;
      case CabinInventoryType.census:
        return contextlessL10n().enumCore_cabinInventoryTypeCensusFieldText;
      case CabinInventoryType.disposal:
        return contextlessL10n().enumCore_cabinInventoryTypeDisposalFieldText;
      case CabinInventoryType.unload:
        return contextlessL10n().enumCore_cabinInventoryTypeUnloadFieldText;
      case CabinInventoryType.intake:
        return contextlessL10n().enumCore_cabinInventoryTypeIntakeFieldText;
    }
  }

  String get sequentialText {
    switch (this) {
      case CabinInventoryType.refill:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillSequentialText;
      case CabinInventoryType.refillList:
        return contextlessL10n().enumCore_cabinInventoryTypeRefillListSequentialText;
      case CabinInventoryType.census:
        return contextlessL10n().enumCore_cabinInventoryTypeCensusSequentialText;
      case CabinInventoryType.disposal:
        return contextlessL10n().enumCore_cabinInventoryTypeDisposalSequentialText;
      case CabinInventoryType.unload:
        return contextlessL10n().enumCore_cabinInventoryTypeUnloadSequentialText;
      case CabinInventoryType.intake:
        return contextlessL10n().enumCore_cabinInventoryTypeIntakeSequentialText;
    }
  }

  /// Miad tarihi giriş alanı gösterilsin mi?
  /// disposal ve unload için miad girişi gerekmez; kullanıcı miad girmez.
  bool get enableMiadDateInput =>
      this == CabinInventoryType.census || this == CabinInventoryType.refill || this == CabinInventoryType.refillList;

  /// Bu operasyon tipinde miad geçmişse giriş alanları kilitlensin mi?
  ///
  /// Sadece refill ve count tiplerinde miad bloklama uygulanır.
  /// disposal ve unload işlemleri geçmiş miadlı stok üzerinde yapılabilir —
  /// zaten bu işlemlerin amacı geçmiş miadlı ürünü sistemden çıkarmaktır.
  bool get shouldBlockOnExpiry =>
      this == CabinInventoryType.census || this == CabinInventoryType.refill || this == CabinInventoryType.refillList;
}
