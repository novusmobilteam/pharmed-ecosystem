/// CabinInventoryView'ı açarken kullanılan tip.
enum CabinInventoryType {
  refill,
  count,
  disposal,
  unload,
  refillList;

  String get title {
    switch (this) {
      case CabinInventoryType.refill:
        return 'İlaç Dolum';
      case CabinInventoryType.refillList:
        return 'İlaç Dolum Listesi';
      case CabinInventoryType.count:
        return 'İlaç Sayım';
      case CabinInventoryType.disposal:
        return 'İlaç İmha';
      case CabinInventoryType.unload:
        return 'İlaç Boşaltma';
    }
  }

  String get buttonText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Dolum Yap';
      case CabinInventoryType.refillList:
        return 'Dolum Yap';
      case CabinInventoryType.count:
        return 'Sayım Yap';
      case CabinInventoryType.disposal:
        return 'İmha Et';
      case CabinInventoryType.unload:
        return 'İlaç Boşalt';
    }
  }

  String get fieldText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Dolum Miktarı';
      case CabinInventoryType.refillList:
        return 'Dolum Miktarı';
      case CabinInventoryType.count:
        return 'Sayım Miktarı';
      case CabinInventoryType.disposal:
        return 'İmha Miktarı';
      case CabinInventoryType.unload:
        return 'Boşaltım Miktarı';
    }
  }

  String get sequentialText {
    switch (this) {
      case CabinInventoryType.refill:
        return 'Otomatik Dolumu Başlat';
      case CabinInventoryType.refillList:
        return 'Otomatik Dolumu Başlat';
      case CabinInventoryType.count:
        return 'Otomatik Sayımı Başlat';
      case CabinInventoryType.disposal:
        return 'Otomatik İmhayı Başlat';
      case CabinInventoryType.unload:
        return 'Otomatik Boşaltmayı Başlat';
    }
  }

  /// Miad tarihi giriş alanı gösterilsin mi?
  /// disposal ve unload için miad girişi gerekmez; kullanıcı miad girmez.
  bool get enableMiadDateInput =>
      this == CabinInventoryType.count || this == CabinInventoryType.refill || this == CabinInventoryType.refillList;

  /// Bu operasyon tipinde miad geçmişse giriş alanları kilitlensin mi?
  ///
  /// Sadece refill ve count tiplerinde miad bloklama uygulanır.
  /// disposal ve unload işlemleri geçmiş miadlı stok üzerinde yapılabilir —
  /// zaten bu işlemlerin amacı geçmiş miadlı ürünü sistemden çıkarmaktır.
  bool get shouldBlockOnExpiry =>
      this == CabinInventoryType.count || this == CabinInventoryType.refill || this == CabinInventoryType.refillList;
}
