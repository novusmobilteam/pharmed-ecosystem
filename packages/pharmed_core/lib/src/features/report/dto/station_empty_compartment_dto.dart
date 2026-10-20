class StationEmptyCompartmentDto {
  final int? cabinDesignId;
  final int? stationId;
  final String? stationName;
  final int? cabinId;
  final String? cabinName;
  final int? drawrId;
  final String? drawrName;
  final int? emptyCount;
  final int? occupiedCount;

  const StationEmptyCompartmentDto({
    this.cabinDesignId,
    this.stationId,
    this.stationName,
    this.cabinId,
    this.cabinName,
    this.drawrId,
    this.drawrName,
    this.emptyCount,
    this.occupiedCount,
  });

  factory StationEmptyCompartmentDto.fromJson(Map<String, dynamic> json) {
    return StationEmptyCompartmentDto(
      cabinDesignId: json['cabinDesignId'] as int?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      cabinId: json['cabinId'] as int?,
      cabinName: json['cabinName'] as String?,
      drawrId: json['drawrId'] as int?,
      drawrName: json['drawrName'] as String?,
      emptyCount: (json['emptyCount'] as num?)?.toInt(),
      occupiedCount: (json['occupiedCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cabinDesignId != null) 'cabinDesignId': cabinDesignId,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (cabinId != null) 'cabinId': cabinId,
      if (cabinName != null) 'cabinName': cabinName,
      if (drawrId != null) 'drawrId': drawrId,
      if (drawrName != null) 'drawrName': drawrName,
      if (emptyCount != null) 'emptyCount': emptyCount,
      if (occupiedCount != null) 'occupiedCount': occupiedCount,
    };
  }
}

class StationEmptyCompartmentDetailDto {
  final int? cabinDrawrId;
  final int? cabinDesignId;
  final int? stationId;
  final String? stationName;
  final int? cabinId;
  final String? cabinName;
  final int? drawrId;
  final int? orderNumber;
  final String? address;
  final int? compartmentNo;
  final int? orderNo;
  final String? location;
  final int? compartmentCount;
  final int? stepCount;

  const StationEmptyCompartmentDetailDto({
    this.cabinDrawrId,
    this.cabinDesignId,
    this.stationId,
    this.stationName,
    this.cabinId,
    this.cabinName,
    this.drawrId,
    this.orderNumber,
    this.address,
    this.compartmentNo,
    this.orderNo,
    this.location,
    this.compartmentCount,
    this.stepCount,
  });

  factory StationEmptyCompartmentDetailDto.fromJson(Map<String, dynamic> json) {
    return StationEmptyCompartmentDetailDto(
      cabinDrawrId: json['cabinDrawrId'] as int?,
      cabinDesignId: json['cabinDesignId'] as int?,
      stationId: json['stationId'] as int?,
      stationName: json['stationName'] as String?,
      cabinId: json['cabinId'] as int?,
      cabinName: json['cabinName'] as String?,
      drawrId: json['drawrId'] as int?,
      orderNumber: json['orderNumber'] as int?,
      address: json['address']?.toString(),
      compartmentNo: json['compartmentNo'] as int?,
      orderNo: json['orderNo'] as int?,
      location: json['location'] as String?,
      compartmentCount: (json['compartmentCount'] as num?)?.toInt(),
      stepCount: (json['stepCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (cabinDrawrId != null) 'cabinDrawrId': cabinDrawrId,
      if (cabinDesignId != null) 'cabinDesignId': cabinDesignId,
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      if (cabinId != null) 'cabinId': cabinId,
      if (cabinName != null) 'cabinName': cabinName,
      if (drawrId != null) 'drawrId': drawrId,
      if (orderNumber != null) 'orderNumber': orderNumber,
      if (address != null) 'address': address,
      if (compartmentNo != null) 'compartmentNo': compartmentNo,
      if (orderNo != null) 'orderNo': orderNo,
      if (location != null) 'location': location,
      if (compartmentCount != null) 'compartmentCount': compartmentCount,
      if (stepCount != null) 'stepCount': stepCount,
    };
  }
}
