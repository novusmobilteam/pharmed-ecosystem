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

  String get title {
    switch (this) {
      case CabinInventoryType.refill:
        return 'İlaç Dolum';
      case CabinInventoryType.refillList:
        return 'İlaç Dolum Listesi';
      case CabinInventoryType.census:
        return 'İlaç Sayım';
      case CabinInventoryType.disposal:
        return 'İlaç İmha';
      case CabinInventoryType.unload:
        return 'İlaç Boşaltma';
      case CabinInventoryType.intake:
        return 'İlaç Alım';
    }
  }

  String get buttonText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Dolum Yap';
      case CabinInventoryType.refillList:
        return 'Dolum Yap';
      case CabinInventoryType.census:
        return 'Sayım Yap';
      case CabinInventoryType.disposal:
        return 'İmha Et';
      case CabinInventoryType.unload:
        return 'İlaç Boşalt';
      case CabinInventoryType.intake:
        return 'İlaç Al';
    }
  }

  String get fieldText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Dolum Miktarı';
      case CabinInventoryType.refillList:
        return 'Dolum Miktarı';
      case CabinInventoryType.census:
        return 'Sayım Miktarı';
      case CabinInventoryType.disposal:
        return 'İmha Miktarı';
      case CabinInventoryType.unload:
        return 'Boşaltım Miktarı';
      case CabinInventoryType.intake:
        return 'Alım Miktarı';
    }
  }

  String get sequentialText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Otomatik Dolumu Başlat';
      case CabinInventoryType.refillList:
        return 'Otomatik Dolumu Başlat';
      case CabinInventoryType.census:
        return 'Otomatik Sayımı Başlat';
      case CabinInventoryType.disposal:
        return 'Otomatik İmhayı Başlat';
      case CabinInventoryType.unload:
        return 'Otomatik Boşaltmayı Başlat';
      case CabinInventoryType.intake:
        return 'Otomatik Alım Başlat';
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
