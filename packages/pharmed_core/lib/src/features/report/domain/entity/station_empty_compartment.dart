/// İstasyon Boş Göz Listesi — çekmece bazında özet satırı.
///
/// Bir kabin çekmecesindeki (cabinDesign) boş ve dolu göz sayılarını taşır.
/// Boş gözlerin konum detayı [StationEmptyCompartmentDetail] ile ayrıca alınır.
class StationEmptyCompartment {
  final int? cabinDesignId;
  final int? stationId;
  final String? stationName;
  final int? cabinId;
  final String? cabinName;
  final int? drawerId;
  final String? drawerName;
  final int? emptyCount;
  final int? occupiedCount;

  const StationEmptyCompartment({
    this.cabinDesignId,
    this.stationId,
    this.stationName,
    this.cabinId,
    this.cabinName,
    this.drawerId,
    this.drawerName,
    this.emptyCount,
    this.occupiedCount,
  });
}

/// İstasyon Boş Göz Listesi — bir çekmecedeki tek bir boş gözün detayı.
class StationEmptyCompartmentDetail {
  final int? cabinDrawerId;
  final int? cabinDesignId;
  final int? stationId;
  final String? stationName;
  final int? cabinId;
  final String? cabinName;
  final int? drawerId;
  final int? orderNumber;
  final String? address;
  final int? compartmentNo;
  final int? orderNo;
  final String? location;
  final int? compartmentCount;
  final int? stepCount;

  const StationEmptyCompartmentDetail({
    this.cabinDrawerId,
    this.cabinDesignId,
    this.stationId,
    this.stationName,
    this.cabinId,
    this.cabinName,
    this.drawerId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.orderNo,
    this.location,
    this.compartmentCount,
    this.stepCount,
  });
}
